"""Bulk loads the system's forms from CSV, for data migration.

A migration arrives as a spreadsheet, not as JSON, and it names things the way
the laboratory does - 'REG0007', 'Ultra', 'ultra-CDL-2026-A-3' - not by the
identifiers this database happens to have handed out. So every template is
written in natural keys, and resolved here.

Each form is described once, as a list of columns, and that one description
drives all three things a migration needs: the blank template, the sample data
that shows what a good row looks like, and the import itself. They cannot drift
apart because there is only one of them.

A result row is validated by the form's own Pydantic model before it is
written, so an imported result has been through exactly the rules a result
captured in the browser goes through - see `_validation_status` for the one
deliberate difference.
"""
import csv
import io
from datetime import datetime

from pydantic import ValidationError
from sqlalchemy.future import select

from helpers import assist
from models.applications_model import ApplicationsDB
from models.district_model import DistrictDB
from models.enrollment_model import EnrollmentDB
from models.hiveidresult_model import HIVEIDResult, HIVEIDResultDB
from models.hivvlresult_model import HIVVLResult, HIVVLResultDB
from models.laboratory_model import LaboratoryDB
from models.labtype_model import LabTypeDB
from models.method_model import (
    RESULT_FORM_HIV_EID,
    RESULT_FORM_HIV_VL,
    RESULT_FORM_TB_XPERT_ULTRA,
    RESULT_FORM_TB_XPERT_XDR,
    MethodDB,
)
from models.methodsample_model import MethodSampleDB
from models.province_model import ProvinceDB
from models.ptcycle_model import PTCycleDB
from models.scheme_model import SchemeDB
from models.service_model import ServiceDB
from models.tbxpertultraresult_model import TBXpertUltraResult, TBXpertUltraResultDB
from models.tbxpertxdrresult_model import TBXpertXDRResult, TBXpertXDRResultDB
from models.user_model import UserDB


# ---------- Column kinds ----------
TEXT = "text"
DATE = "date"
NUMBER = "number"

# the ways a migration source is likely to have written a date. ISO first,
# because that is what a spreadsheet exports when the cell is a real date.
DATE_FORMATS = ("%Y-%m-%d", "%d/%m/%Y", "%d-%m-%Y", "%d %b %Y", "%d %B %Y", "%Y/%m/%d")

LAB_IMPORT = "laboratory"


class RowError(Exception):
    """Something wrong with one row, reported against the column at fault"""

    def __init__(self, message, column=None):
        super().__init__(message)
        self.message = message
        self.column = column


class Column:
    def __init__(self, name, label, kind=TEXT, required=False, note="", field=None):
        self.name = name
        self.label = label
        self.kind = kind
        self.required = required
        self.note = note
        # the attribute this column lands on; a lookup key has none
        self.field = field

    def parse(self, raw):
        text = "" if raw is None else str(raw).strip()

        if not text:
            if self.required:
                raise RowError(f"{self.label} is required", self.name)
            return None

        if self.kind == NUMBER:
            try:
                return float(text)
            except ValueError:
                raise RowError(f"{self.label} must be a number, not '{text}'", self.name)

        if self.kind == DATE:
            for fmt in DATE_FORMATS:
                try:
                    return datetime.strptime(text, fmt).date()
                except ValueError:
                    continue
            raise RowError(
                f"{self.label} must be a date, e.g. 2026-03-14, not '{text}'", self.name
            )

        return text


# ---------- Status ----------
# how a migration spells the approval state a row arrives in
STATUS_BY_NAME = {
    "draft": (assist.STATUS_DRAFT, assist.APPROVAL_STAGE_AWAIT_SUBMISSION),
    "submitted": (assist.STATUS_SUBMITTED, assist.APPROVAL_STAGE_SUBMITTED),
    "under review": (assist.STATUS_UNDER_REVIEW, assist.APPROVAL_STAGE_PRIMARY),
    "approved": (assist.STATUS_APPROVED, assist.APPROVAL_STAGE_APPROVED),
    # a rejected row stays at the stage the reviewer left it on
    "rejected": (assist.STATUS_REJECTED, assist.APPROVAL_STAGE_SUBMITTED),
}

RESULT_STATUS_VALUES = ["Draft", "Submitted", "Under Review", "Approved", "Rejected"]
DEFAULT_RESULT_STATUS = "Approved"


def _resolve_status(value, table, spelled, default, column="status"):
    """Turns the status column into the (status, stage) pair a row is written at"""
    name = (value or default).strip().lower()
    if name not in table:
        raise RowError(f"Status must be one of {', '.join(spelled)}", column)
    return table[name]


def _validation_status(status_id):
    """The status a row is validated as.

    A migrated result is historical: it was reported, reviewed and in most
    cases approved years before it reached this importer. The completeness
    rules on each form only fire at Submitted, so a row imported as Approved
    would sail past them. Anything that is not an explicit draft is therefore
    checked as if it were being submitted, which is what makes a migration
    trustworthy rather than merely loaded.
    """
    if status_id == assist.STATUS_DRAFT:
        return assist.STATUS_DRAFT
    return assist.STATUS_SUBMITTED


# ---------- The columns every result form shares ----------
# These locate the result sheet. They are not fields on it.
def _result_key_columns():
    return [
        Column("scheme", "Scheme", required=True,
               note="Scheme name, exactly as it reads in the system"),
        Column("service", "Service", required=True,
               note="Service name within that scheme"),
        Column("method", "Method", required=True,
               note="Method name within that service; its result form must be this form"),
        Column("sample", "Sample", required=True,
               note="Method sample name, i.e. the panel item"),
        Column("pt_cycle_code", "PT Cycle Code", required=True,
               note="PT cycle code within that scheme, e.g. 2026-A"),
        Column("lab_code", "Laboratory Code", required=False,
               note="The lab's code, e.g. REG0007. Give this or Laboratory Email"),
        Column("lab_email", "Laboratory Email", required=False,
               note="Used when the code is blank; if both are given they must agree"),
        Column("captured_by", "Captured By", required=False,
               note="Email of the user the result is recorded against; "
                    "defaults to the user running the import"),
        Column("status", "Status", required=False,
               note=f"One of {', '.join(RESULT_STATUS_VALUES)}. "
                    f"Defaults to {DEFAULT_RESULT_STATUS}"),
        Column("description", "Description", required=False, field="description",
               note="Free text kept against the result"),
    ]


class FormSpec:
    """One importable form: what it is called, what it writes, and its columns"""

    def __init__(self, key, label, source, db_model, schema, columns, samples,
                 kind="result"):
        self.key = key
        self.label = label
        # the paper form or register the data comes off
        self.source = source
        self.db_model = db_model
        self.schema = schema
        self.columns = columns
        self.samples = samples
        self.kind = kind

    @property
    def headers(self):
        return [column.name for column in self.columns]

    def column(self, name):
        for column in self.columns:
            if column.name == name:
                return column
        return None

    @property
    def value_columns(self):
        """The columns that land on the row itself rather than locating it"""
        return [c for c in self.columns if c.field]


def _result_spec(key, label, source, db_model, schema, columns, samples):
    return FormSpec(
        key=key,
        label=label,
        source=source,
        db_model=db_model,
        schema=schema,
        columns=_result_key_columns() + columns,
        samples=samples,
        kind="result",
    )


def _field(name, label, kind=TEXT, note=""):
    return Column(name, label, kind=kind, field=name, note=note)


# ---------- TB Xpert Ultra, form CDL-PT-F-008 ----------
TB_XPERT_ULTRA_COLUMNS = [
    _field("date_tested", "Date Tested", DATE, "Required once submitted"),
    _field("result_interpretable", "Result Interpretable", TEXT, "Yes or No"),
    _field("tb_detection_result", "TB Detection Result", TEXT,
           "NOT DETECTED, TRACE, VERY LOW, LOW, MEDIUM or HIGH; "
           "blank when not interpretable"),
    _field("rif_result", "Rif Result", TEXT,
           "N/A, NOT DETECTED or DETECTED; blank when not interpretable"),
    _field("uninterpretable_result", "Uninterpretable Result", TEXT,
           "INVALID, NO RESULT, ERROR or INDETERMINATE; only when not interpretable"),
    _field("error_code", "Error Code", TEXT,
           "Only for an ERROR result, and required for one"),
    _field("ultra_spc", "Ultra SPC", NUMBER, "Cycle threshold, 0 to 100"),
    _field("is1081_is6110", "IS1081-IS6110", NUMBER, "Cycle threshold, 0 to 100"),
    _field("rpob1", "rpoB1", NUMBER, "Cycle threshold, 0 to 100"),
    _field("rpob2", "rpoB2", NUMBER, "Cycle threshold, 0 to 100"),
    _field("rpob3", "rpoB3", NUMBER, "Cycle threshold, 0 to 100"),
    _field("rpob4", "rpoB4", NUMBER, "Cycle threshold, 0 to 100"),
    _field("xpert_module_number", "Xpert Module Number", TEXT,
           "Required once submitted"),
]

TB_XPERT_ULTRA_SAMPLES = [
    {
        "scheme": "Tuberculosis (TB)", "service": "TB Xpert", "method": "Ultra",
        "sample": "ultra-CDL-2026-A-1", "pt_cycle_code": "2026-A",
        "lab_code": "REG0001", "lab_email": "", "captured_by": "",
        "status": "Approved", "description": "Migrated from the 2026-A register",
        "date_tested": "2026-03-04", "result_interpretable": "Yes",
        "tb_detection_result": "MEDIUM", "rif_result": "NOT DETECTED",
        "uninterpretable_result": "", "error_code": "",
        "ultra_spc": "24.6", "is1081_is6110": "18.2", "rpob1": "19.4",
        "rpob2": "19.8", "rpob3": "20.1", "rpob4": "20.4",
        "xpert_module_number": "A1-0431",
    },
    {
        "scheme": "Tuberculosis (TB)", "service": "TB Xpert", "method": "Ultra",
        "sample": "ultra-CDL-2026-A-2", "pt_cycle_code": "2026-A",
        "lab_code": "REG0001", "lab_email": "", "captured_by": "",
        "status": "Approved", "description": "",
        "date_tested": "2026-03-04", "result_interpretable": "Yes",
        "tb_detection_result": "NOT DETECTED", "rif_result": "N/A",
        "uninterpretable_result": "", "error_code": "",
        "ultra_spc": "25.1", "is1081_is6110": "0", "rpob1": "0",
        "rpob2": "0", "rpob3": "0", "rpob4": "0",
        "xpert_module_number": "A1-0431",
    },
    {
        "scheme": "Tuberculosis (TB)", "service": "TB Xpert", "method": "Ultra",
        "sample": "ultra-CDL-2026-A-3", "pt_cycle_code": "2026-A",
        "lab_code": "REG0001", "lab_email": "", "captured_by": "",
        "status": "Approved", "description": "Cartridge failed on the first run",
        "date_tested": "2026-03-04", "result_interpretable": "No",
        "tb_detection_result": "", "rif_result": "",
        "uninterpretable_result": "ERROR", "error_code": "5007",
        "ultra_spc": "", "is1081_is6110": "", "rpob1": "",
        "rpob2": "", "rpob3": "", "rpob4": "",
        "xpert_module_number": "A1-0432",
    },
]


# ---------- TB Xpert XDR, form CDL-PT-F-027 ----------
TB_XPERT_XDR_COLUMNS = [
    _field("date_tested", "Date Tested", DATE, "Required once submitted"),
    _field("result_interpretable", "Result Interpretable", TEXT, "Yes or No"),
    _field("tb_detection_result", "TB Detection Result", TEXT,
           "NOT DETECTED or DETECTED; blank when not interpretable"),
    _field("inh_result", "INH Result", TEXT,
           "N/A, NOT DETECTED or DETECTED; must be N/A when TB is NOT DETECTED"),
    _field("flq_result", "FLQ Result", TEXT,
           "N/A, NOT DETECTED or DETECTED; must be N/A when TB is NOT DETECTED"),
    _field("amk_result", "AMK Result", TEXT,
           "N/A, NOT DETECTED or DETECTED; must be N/A when TB is NOT DETECTED"),
    _field("eth_result", "ETH Result", TEXT,
           "N/A, NOT DETECTED or DETECTED; must be N/A when TB is NOT DETECTED"),
    _field("uninterpretable_result", "Uninterpretable Result", TEXT,
           "INVALID, NO RESULT, ERROR or INDETERMINATE; only when not interpretable"),
    _field("error_code", "Error Code", TEXT,
           "Only for an ERROR result, and required for one"),
    _field("spc_ahpc", "SPC-ahpC", NUMBER, "Cycle threshold, 0 to 100"),
    _field("inha", "inhA", NUMBER, "Cycle threshold, 0 to 100"),
    _field("katg", "KatG", NUMBER, "Cycle threshold, 0 to 100"),
    _field("fabg1", "fabG1", NUMBER, "Cycle threshold, 0 to 100"),
    _field("gyra1", "gyrA1", NUMBER, "Cycle threshold, 0 to 100"),
    _field("gyra2", "gyrA2", NUMBER, "Cycle threshold, 0 to 100"),
    _field("gyra3", "gyrA3", NUMBER, "Cycle threshold, 0 to 100"),
    _field("gyrb2", "gyrB2", NUMBER, "Cycle threshold, 0 to 100"),
    _field("rrs", "rrs", NUMBER, "Cycle threshold, 0 to 100"),
]

TB_XPERT_XDR_SAMPLES = [
    {
        "scheme": "Tuberculosis (TB)", "service": "TB Xpert", "method": "XDR",
        "sample": "xdr-CDL-2026-A-1", "pt_cycle_code": "2026-A",
        "lab_code": "REG0002", "lab_email": "", "captured_by": "",
        "status": "Approved", "description": "Migrated from the 2026-A register",
        "date_tested": "2026-03-06", "result_interpretable": "Yes",
        "tb_detection_result": "DETECTED",
        "inh_result": "DETECTED", "flq_result": "NOT DETECTED",
        "amk_result": "NOT DETECTED", "eth_result": "NOT DETECTED",
        "uninterpretable_result": "", "error_code": "",
        "spc_ahpc": "23.9", "inha": "21.7", "katg": "22.4", "fabg1": "22.9",
        "gyra1": "24.1", "gyra2": "24.6", "gyra3": "25.0", "gyrb2": "25.4",
        "rrs": "26.1",
    },
    {
        "scheme": "Tuberculosis (TB)", "service": "TB Xpert", "method": "XDR",
        "sample": "xdr-CDL-2026-A-2", "pt_cycle_code": "2026-A",
        "lab_code": "REG0002", "lab_email": "", "captured_by": "",
        "status": "Approved", "description": "",
        "date_tested": "2026-03-06", "result_interpretable": "Yes",
        "tb_detection_result": "NOT DETECTED",
        # the assay cannot call resistance against TB it did not detect
        "inh_result": "N/A", "flq_result": "N/A",
        "amk_result": "N/A", "eth_result": "N/A",
        "uninterpretable_result": "", "error_code": "",
        "spc_ahpc": "24.2", "inha": "0", "katg": "0", "fabg1": "0",
        "gyra1": "0", "gyra2": "0", "gyra3": "0", "gyrb2": "0", "rrs": "0",
    },
    {
        "scheme": "Tuberculosis (TB)", "service": "TB Xpert", "method": "XDR",
        "sample": "xdr-CDL-2026-A-3", "pt_cycle_code": "2026-A",
        "lab_code": "REG0002", "lab_email": "", "captured_by": "",
        "status": "Approved", "description": "The repeat run was also invalid",
        "date_tested": "2026-03-06", "result_interpretable": "No",
        "tb_detection_result": "",
        "inh_result": "", "flq_result": "", "amk_result": "", "eth_result": "",
        "uninterpretable_result": "INVALID", "error_code": "",
        "spc_ahpc": "", "inha": "", "katg": "", "fabg1": "",
        "gyra1": "", "gyra2": "", "gyra3": "", "gyrb2": "", "rrs": "",
    },
]


# ---------- HIV-1 Viral Load, form TF-009 ----------
HIV_VL_COLUMNS = [
    _field("date_panel_received", "Date PT Panel Received", DATE,
           "Required once submitted"),
    _field("date_tested", "Date PT Panel Tested", DATE,
           "Required once submitted when a result was reported"),
    _field("detection_assay", "Detection Assay", TEXT, "Required once submitted"),
    _field("extraction_assay", "Extraction Assay", TEXT, "Required once submitted"),
    _field("assay_kit_lot_number", "Assay Kit Lot Number", TEXT),
    _field("assay_kit_expiry_date", "Assay Kit Expiration Date", DATE),
    _field("assay_serial_number", "Assay Serial Number", TEXT),
    _field("result_reported", "Result Reported", TEXT, "Yes or No"),
    _field("viral_load_log10", "Viral Load Result", NUMBER,
           "log10 copies/ml, 0 to 10. Blank when the sample was not tested"),
    _field("not_tested_reason", "Reason Not Tested", TEXT,
           "Only when no result was reported, and required then"),
    _field("tested_by", "Tested By", TEXT),
    _field("supervisor_name", "Supervisor Name", TEXT),
]

HIV_VL_SAMPLES = [
    {
        "scheme": "HIV-1 Viral Load- Conventional PCR", "service": "HIV-1 Viral Load",
        "method": "Abbott m2000", "sample": "VL 2026-A1",
        "pt_cycle_code": "VL-2026-A",
        "lab_code": "REG0005", "lab_email": "", "captured_by": "",
        "status": "Approved", "description": "Migrated from the VL-2026-A register",
        "date_panel_received": "2026-04-02", "date_tested": "2026-04-08",
        "detection_assay": "Abbott RealTime HIV-1",
        "extraction_assay": "Abbott m2000sp",
        "assay_kit_lot_number": "LOT-44219", "assay_kit_expiry_date": "2026-11-30",
        "assay_serial_number": "M2000-77041",
        "result_reported": "Yes", "viral_load_log10": "4.82",
        "not_tested_reason": "",
        "tested_by": "M. Banda", "supervisor_name": "C. Phiri",
    },
    {
        "scheme": "HIV-1 Viral Load- Conventional PCR", "service": "HIV-1 Viral Load",
        "method": "Abbott m2000", "sample": "VL 2026-A2",
        "pt_cycle_code": "VL-2026-A",
        "lab_code": "REG0005", "lab_email": "", "captured_by": "",
        "status": "Approved", "description": "",
        "date_panel_received": "2026-04-02", "date_tested": "2026-04-08",
        "detection_assay": "Abbott RealTime HIV-1",
        "extraction_assay": "Abbott m2000sp",
        "assay_kit_lot_number": "LOT-44219", "assay_kit_expiry_date": "2026-11-30",
        "assay_serial_number": "M2000-77041",
        "result_reported": "Yes", "viral_load_log10": "0",
        "not_tested_reason": "",
        "tested_by": "M. Banda", "supervisor_name": "C. Phiri",
    },
    {
        "scheme": "HIV-1 Viral Load- Conventional PCR", "service": "HIV-1 Viral Load",
        "method": "Abbott m2000", "sample": "VL 2026-A3",
        "pt_cycle_code": "VL-2026-A",
        "lab_code": "REG0005", "lab_email": "", "captured_by": "",
        "status": "Approved", "description": "",
        "date_panel_received": "2026-04-02", "date_tested": "",
        "detection_assay": "", "extraction_assay": "",
        "assay_kit_lot_number": "", "assay_kit_expiry_date": "",
        "assay_serial_number": "",
        "result_reported": "No", "viral_load_log10": "",
        "not_tested_reason": "Vial arrived leaking, insufficient volume",
        "tested_by": "M. Banda", "supervisor_name": "C. Phiri",
    },
]


# ---------- HIV-1 EID, form TF-012 ----------
HIV_EID_COLUMNS = [
    _field("date_panel_received", "Date PT Panel Received", DATE,
           "Required once submitted"),
    _field("date_tested", "Date PT Panel Tested", DATE,
           "Required once submitted when a result was reported"),
    _field("detection_assay", "Detection Assay", TEXT, "Required once submitted"),
    _field("extraction_assay", "Extraction Assay", TEXT, "Required once submitted"),
    _field("assay_serial_number", "Assay Serial Number", TEXT),
    _field("result_reported", "Result Reported", TEXT, "Yes or No"),
    _field("hiv_result", "Your Result", TEXT,
           "Exactly 'HIV-1 Detected' or 'HIV-1 Not Detected'. "
           "Blank when the sample was not tested"),
    _field("hiv_ct_od_value", "HIV CT/OD Value", NUMBER, "Optional, 0 to 100"),
    _field("ic_qs_value", "IC/QS Value", NUMBER, "Optional, 0 to 100"),
    _field("not_tested_reason", "Reason Not Tested", TEXT,
           "Only when no result was reported, and required then"),
    _field("tested_by", "Tested By", TEXT),
    _field("supervisor_name", "Supervisor Name", TEXT),
]

HIV_EID_SAMPLES = [
    {
        "scheme": "HIV EID-Conventional PCR", "service": "Early Infant Diagnosis",
        "method": "Cobas 4800", "sample": "2026-01", "pt_cycle_code": "EID-2026-A",
        "lab_code": "REG0009", "lab_email": "", "captured_by": "",
        "status": "Approved", "description": "Migrated from the EID-2026-A register",
        "date_panel_received": "2026-05-04", "date_tested": "2026-05-11",
        "detection_assay": "Roche Cobas 4800 HIV-1 Qual",
        "extraction_assay": "Cobas x480",
        "assay_serial_number": "C4800-20918",
        "result_reported": "Yes", "hiv_result": "HIV-1 Detected",
        "hiv_ct_od_value": "28.4", "ic_qs_value": "31.2",
        "not_tested_reason": "",
        "tested_by": "L. Mwale", "supervisor_name": "G. Tembo",
    },
    {
        "scheme": "HIV EID-Conventional PCR", "service": "Early Infant Diagnosis",
        "method": "Cobas 4800", "sample": "2026-02", "pt_cycle_code": "EID-2026-A",
        "lab_code": "REG0009", "lab_email": "", "captured_by": "",
        "status": "Approved", "description": "",
        "date_panel_received": "2026-05-04", "date_tested": "2026-05-11",
        "detection_assay": "Roche Cobas 4800 HIV-1 Qual",
        "extraction_assay": "Cobas x480",
        "assay_serial_number": "C4800-20918",
        "result_reported": "Yes", "hiv_result": "HIV-1 Not Detected",
        "hiv_ct_od_value": "", "ic_qs_value": "30.7",
        "not_tested_reason": "",
        "tested_by": "L. Mwale", "supervisor_name": "G. Tembo",
    },
    {
        # a kit control is recorded on the form but never scored
        "scheme": "HIV EID-Conventional PCR", "service": "Early Infant Diagnosis",
        "method": "Cobas 4800", "sample": "Kit Positive Control",
        "pt_cycle_code": "EID-2026-A",
        "lab_code": "REG0009", "lab_email": "", "captured_by": "",
        "status": "Approved", "description": "",
        "date_panel_received": "2026-05-04", "date_tested": "2026-05-11",
        "detection_assay": "Roche Cobas 4800 HIV-1 Qual",
        "extraction_assay": "Cobas x480",
        "assay_serial_number": "C4800-20918",
        "result_reported": "Yes", "hiv_result": "HIV-1 Detected",
        "hiv_ct_od_value": "27.1", "ic_qs_value": "30.9",
        "not_tested_reason": "",
        "tested_by": "L. Mwale", "supervisor_name": "G. Tembo",
    },
]


# ---------- Laboratory ----------
# A laboratory is imported on its own, before any result that names it. Its
# code is the match key - `laboratorys.code` is unique, it is what the lab is
# called in every listing, and it is what a result file carries. Leave it blank
# and the server issues the next REG####; supply it and the legacy identifier
# is carried across, which is what lets the result files reference the lab.
LAB_STATUS_VALUES = ["Pending", "Approved"]
DEFAULT_LAB_STATUS = "Pending"

LAB_STATUS_BY_NAME = {
    "pending": (assist.STATUS_SUBMITTED, assist.APPROVAL_STAGE_SUBMITTED),
    "approved": (assist.STATUS_APPROVED, assist.APPROVAL_STAGE_APPROVED),
}

LABORATORY_COLUMNS = [
    Column("code", "Laboratory Code", required=False, field="code",
           note="The match key. Blank issues the next REG#### code"),
    Column("name", "Laboratory Name", required=True, field="name"),
    Column("description", "Description", required=False, field="description"),
    Column("contact_person_name", "Contact Person Name", required=True,
           field="contact_person_name",
           note="Becomes the lab's super user when the registration is approved"),
    Column("position", "Position", required=True, field="position"),
    Column("phone_number", "Phone Number", required=True, field="phone_number"),
    Column("email_address", "Email Address", required=True, field="email_address",
           note="Unique across laboratories; also the super user's sign in"),
    Column("lab_type", "Laboratory Type", required=True,
           note="Government, Private, Religious or Mine"),
    Column("province", "Province", required=True, note="Province name"),
    Column("district", "District", required=True,
           note="District name within that province"),
    Column("physical_address", "Physical Address", required=True,
           field="physical_address"),
    Column("methods", "Methods", required=False,
           note="The methods the lab takes part in, separated by '|'. "
                "Qualify an ambiguous name as 'Service > Method'"),
    Column("status", "Status", required=False,
           note=f"One of {', '.join(LAB_STATUS_VALUES)}. "
                f"Defaults to {DEFAULT_LAB_STATUS}, which leaves the registration "
                "for the normal review"),
]

LABORATORY_SAMPLES = [
    {
        "code": "REG0101", "name": "Mpika District Hospital Laboratory",
        "description": "Migrated from the 2025 participant register",
        "contact_person_name": "Chanda Mulenga", "position": "Laboratory Manager",
        "phone_number": "260977100101", "email_address": "lab.mpika@moh.gov.zm",
        "lab_type": "Government", "province": "Muchinga", "district": "Mpika",
        "physical_address": "Great North Road, Mpika",
        "methods": "Ultra|XDR", "status": "Pending",
    },
    {
        "code": "REG0102", "name": "Kasama General Hospital Laboratory",
        "description": "",
        "contact_person_name": "Bwalya Musonda",
        "position": "Senior Biomedical Scientist",
        "phone_number": "260977100102", "email_address": "lab.kasama@moh.gov.zm",
        "lab_type": "Government", "province": "Northern", "district": "Kasama",
        "physical_address": "Zambia Road, Kasama",
        "methods": "Ultra", "status": "Pending",
    },
    {
        "code": "", "name": "Choma Mission Hospital Laboratory",
        "description": "No legacy code, so the server issues the next one",
        "contact_person_name": "Naomi Sakala", "position": "Laboratory Scientist",
        "phone_number": "260977100103", "email_address": "lab.choma@moh.gov.zm",
        "lab_type": "Religious", "province": "Southern", "district": "Choma",
        "physical_address": "Livingstone Road, Choma",
        "methods": "Abbott m2000|Cobas 4800", "status": "Pending",
    },
]


# ---------- The registry ----------
FORM_SPECS = {
    RESULT_FORM_TB_XPERT_ULTRA: _result_spec(
        key=RESULT_FORM_TB_XPERT_ULTRA,
        label="TB Xpert Ultra Result",
        source="CDL-PT-F-008 Xpert PT Results form",
        db_model=TBXpertUltraResultDB,
        schema=TBXpertUltraResult,
        columns=TB_XPERT_ULTRA_COLUMNS,
        samples=TB_XPERT_ULTRA_SAMPLES,
    ),
    RESULT_FORM_TB_XPERT_XDR: _result_spec(
        key=RESULT_FORM_TB_XPERT_XDR,
        label="TB Xpert XDR Result",
        source="CDL-PT-F-027 Xpert MTB/XDR Result Form",
        db_model=TBXpertXDRResultDB,
        schema=TBXpertXDRResult,
        columns=TB_XPERT_XDR_COLUMNS,
        samples=TB_XPERT_XDR_SAMPLES,
    ),
    RESULT_FORM_HIV_VL: _result_spec(
        key=RESULT_FORM_HIV_VL,
        label="HIV-1 Viral Load Result",
        source="TF-009 HIV-1 Viral Load (HIV-1 VL) Result Report Form",
        db_model=HIVVLResultDB,
        schema=HIVVLResult,
        columns=HIV_VL_COLUMNS,
        samples=HIV_VL_SAMPLES,
    ),
    RESULT_FORM_HIV_EID: _result_spec(
        key=RESULT_FORM_HIV_EID,
        label="HIV-1 Early Infant Diagnosis Result",
        source="TF-012 HIV-1 Early Infant Diagnosis (HIV-1 EID) Result Report Form",
        db_model=HIVEIDResultDB,
        schema=HIVEIDResult,
        columns=HIV_EID_COLUMNS,
        samples=HIV_EID_SAMPLES,
    ),
    LAB_IMPORT: FormSpec(
        key=LAB_IMPORT,
        label="Laboratory",
        source="MF006 PT Application Form",
        db_model=LaboratoryDB,
        schema=None,
        columns=LABORATORY_COLUMNS,
        samples=LABORATORY_SAMPLES,
        kind=LAB_IMPORT,
    ),
}

# a laboratory has to be in the system before any result that names it, so it
# is listed first
IMPORT_ORDER = [
    LAB_IMPORT,
    RESULT_FORM_TB_XPERT_ULTRA,
    RESULT_FORM_TB_XPERT_XDR,
    RESULT_FORM_HIV_VL,
    RESULT_FORM_HIV_EID,
]


def get_spec(key):
    spec = FORM_SPECS.get(key)
    if not spec:
        raise KeyError(key)
    return spec


# ---------- Templates ----------
def template_csv(key, with_samples=True):
    """The CSV template for a form, with the sample rows that show its shape"""
    spec = get_spec(key)

    buffer = io.StringIO()
    writer = csv.DictWriter(buffer, fieldnames=spec.headers, lineterminator="\n")
    writer.writeheader()

    if with_samples:
        for sample in spec.samples:
            writer.writerow({name: sample.get(name, "") for name in spec.headers})

    return buffer.getvalue()


def template_guide(key):
    """What each column means, for the docs and for the /columns endpoint"""
    spec = get_spec(key)
    return [
        {
            "column": column.name,
            "label": column.label,
            "type": column.kind,
            "required": column.required,
            "notes": column.note,
        }
        for column in spec.columns
    ]


# ---------- Lookups ----------
class Lookups:
    """Resolves the natural keys in a file, once each, for the whole run"""

    def __init__(self, db):
        self.db = db
        self._cache = {}

    async def _one(self, key, query):
        if key not in self._cache:
            result = await self.db.execute(query)
            self._cache[key] = result.scalars().first()
        return self._cache[key]

    async def scheme(self, name):
        row = await self._one(("scheme", name), select(SchemeDB).where(SchemeDB.name == name))
        if not row:
            raise RowError(f"No scheme named '{name}'", "scheme")
        return row

    async def service(self, scheme, name):
        row = await self._one(
            ("service", scheme.id, name),
            select(ServiceDB).where(
                ServiceDB.scheme_id == scheme.id, ServiceDB.name == name
            ),
        )
        if not row:
            raise RowError(f"No service named '{name}' in '{scheme.name}'", "service")
        return row

    async def method(self, service, name, expected_form):
        row = await self._one(
            ("method", service.id, name),
            select(MethodDB).where(
                MethodDB.service_id == service.id, MethodDB.name == name
            ),
        )
        if not row:
            raise RowError(f"No method named '{name}' in '{service.name}'", "method")

        if row.result_form != expected_form:
            spelled = row.result_form or "no result form"
            raise RowError(
                f"The method '{name}' is captured on {spelled}, so its results "
                f"cannot be imported into the {expected_form} form",
                "method",
            )
        return row

    async def sample(self, method, name):
        row = await self._one(
            ("sample", method.id, name),
            select(MethodSampleDB).where(
                MethodSampleDB.method_id == method.id, MethodSampleDB.name == name
            ),
        )
        if not row:
            raise RowError(
                f"No method sample named '{name}' for the method '{method.name}'",
                "sample",
            )
        return row

    async def cycle(self, scheme, code):
        row = await self._one(
            ("cycle", scheme.id, code),
            select(PTCycleDB).where(
                PTCycleDB.scheme_id == scheme.id, PTCycleDB.code == code
            ),
        )
        if not row:
            raise RowError(
                f"No PT cycle with the code '{code}' in '{scheme.name}'",
                "pt_cycle_code",
            )
        return row

    async def laboratory(self, code, email):
        """Matches the lab on its code, falling back to its contact email.

        Both columns are unique on `laboratorys`, so either identifies a lab on
        its own. The name is not - two registers spell the same hospital three
        ways - so it is deliberately not accepted as a match.
        """
        if not code and not email:
            raise RowError(
                "Give either the Laboratory Code or the Laboratory Email",
                "lab_code",
            )

        by_code = None
        if code:
            by_code = await self._one(
                ("lab_code", code),
                select(LaboratoryDB).where(LaboratoryDB.code == code),
            )
            if not by_code:
                raise RowError(
                    f"No laboratory with the code '{code}'. Import the "
                    "laboratories first",
                    "lab_code",
                )

        by_email = None
        if email:
            by_email = await self._one(
                ("lab_email", email.lower()),
                select(LaboratoryDB).where(LaboratoryDB.email_address == email),
            )
            if not by_email:
                raise RowError(
                    f"No laboratory registered under '{email}'. Import the "
                    "laboratories first",
                    "lab_email",
                )

        if by_code and by_email and by_code.id != by_email.id:
            raise RowError(
                f"The code '{code}' is '{by_code.name}' but '{email}' is "
                f"'{by_email.name}'. The row names two different laboratories",
                "lab_email",
            )

        return by_code or by_email

    async def user(self, email):
        row = await self._one(
            ("user", email.lower()), select(UserDB).where(UserDB.email == email)
        )
        if not row:
            raise RowError(f"No user account for '{email}'", "captured_by")
        return row

    async def lab_type(self, name):
        row = await self._one(
            ("lab_type", name), select(LabTypeDB).where(LabTypeDB.name == name)
        )
        if not row:
            raise RowError(f"No laboratory type named '{name}'", "lab_type")
        return row

    async def province(self, name):
        row = await self._one(
            ("province", name), select(ProvinceDB).where(ProvinceDB.name == name)
        )
        if not row:
            raise RowError(f"No province named '{name}'", "province")
        return row

    async def district(self, province, name):
        row = await self._one(
            ("district", province.id, name),
            select(DistrictDB).where(
                DistrictDB.province_id == province.id, DistrictDB.name == name
            ),
        )
        if not row:
            raise RowError(
                f"No district named '{name}' in {province.name} province", "district"
            )
        return row

    async def method_by_label(self, label):
        """Resolves a method written as 'Method' or 'Service > Method'"""
        service_name = None
        name = label

        if ">" in label:
            service_name, name = [part.strip() for part in label.split(">", 1)]

        query = select(MethodDB).where(MethodDB.name == name)
        if service_name:
            query = query.join(ServiceDB, MethodDB.service_id == ServiceDB.id).where(
                ServiceDB.name == service_name
            )

        result = await self.db.execute(query)
        matches = result.scalars().all()

        if not matches:
            raise RowError(f"No method named '{label}'", "methods")

        if len(matches) > 1:
            raise RowError(
                f"'{label}' matches {len(matches)} methods. Qualify it as "
                "'Service > Method'",
                "methods",
            )

        return matches[0]


# ---------- Enrolment ----------
async def _enrollment_for(db, lookups, cycle, laboratory, method, service, user,
                          received_on, imported_by):
    """The lab's enrolment for this method in this cycle, opened if it is missing.

    A historical result cannot be loaded without one - the result hangs off the
    enrolment - and a migration will rarely carry the enrolment separately. One
    that is opened here is opened as settled: the round is over, the panel was
    received, the result is in hand.
    """
    result = await db.execute(
        select(EnrollmentDB).where(
            EnrollmentDB.pt_cycle_id == cycle.id,
            EnrollmentDB.lab_id == laboratory.id,
            EnrollmentDB.method_id == method.id,
        )
    )
    enrollment = result.scalars().first()

    if enrollment:
        return enrollment, False

    received = received_on or cycle.shipping_date

    enrollment = EnrollmentDB(
        name=f"{cycle.name} - {laboratory.name} - {method.name}",
        description="Opened by the data migration to carry an imported result",
        # properties
        scheme_id=cycle.scheme_id,
        lab_id=laboratory.id,
        service_id=service.id,
        method_id=method.id,
        pt_cycle_id=cycle.id,
        samples_received_at=(
            datetime(received.year, received.month, received.day)
            if received
            else None
        ),
        samples_received_by=imported_by,
        # approval - the round is history, so the enrolment is settled
        user_id=user.id,
        status_id=assist.STATUS_APPROVED,
        stage_id=assist.APPROVAL_STAGE_APPROVED,
        approval_levels=1,
        # service
        created_by=imported_by,
    )
    db.add(enrollment)
    await db.flush()

    return enrollment, True


# ---------- Result import ----------
async def _import_result_row(db, spec, lookups, values, importer, counts):
    scheme = await lookups.scheme(values["scheme"])
    service = await lookups.service(scheme, values["service"])
    method = await lookups.method(service, values["method"], spec.key)
    sample = await lookups.sample(method, values["sample"])
    cycle = await lookups.cycle(scheme, values["pt_cycle_code"])
    laboratory = await lookups.laboratory(values.get("lab_code"), values.get("lab_email"))

    captured_by = values.get("captured_by")
    user = await lookups.user(captured_by) if captured_by else importer

    status_id, stage_id = _resolve_status(
        values.get("status"), STATUS_BY_NAME, RESULT_STATUS_VALUES,
        DEFAULT_RESULT_STATUS,
    )

    enrollment, opened = await _enrollment_for(
        db, lookups, cycle, laboratory, method, service, user,
        values.get("date_panel_received") or values.get("date_tested"),
        importer.email,
    )
    if opened:
        counts["enrollments_opened"] += 1

    payload = {
        "name": f"{sample.name} - {laboratory.name}",
        "scheme_id": scheme.id,
        "lab_id": laboratory.id,
        "service_id": service.id,
        "enrollment_id": enrollment.id,
        "pt_cycle_id": cycle.id,
        "method_id": method.id,
        "method_sample_id": sample.id,
        "user_id": user.id,
        # checked as a submission so a historical row cannot slip in incomplete
        "status_id": _validation_status(status_id),
        "stage_id": stage_id,
        "approval_levels": 1,
    }
    for column in spec.value_columns:
        payload[column.field] = values.get(column.name)

    try:
        validated = spec.schema(**payload)
    except ValidationError as error:
        raise RowError(_first_message(error), _first_column(error, spec))

    # one sheet per sample, per lab, per cycle - the table says so
    result = await db.execute(
        select(spec.db_model).where(
            spec.db_model.pt_cycle_id == cycle.id,
            spec.db_model.lab_id == laboratory.id,
            spec.db_model.method_sample_id == sample.id,
        )
    )
    row = result.scalars().first()
    action = "updated" if row else "created"

    if not row:
        row = spec.db_model(
            name=payload["name"],
            scheme_id=scheme.id,
            lab_id=laboratory.id,
            service_id=service.id,
            enrollment_id=enrollment.id,
            pt_cycle_id=cycle.id,
            method_id=method.id,
            method_sample_id=sample.id,
            user_id=user.id,
            approval_levels=1,
            created_by=importer.email,
        )
        db.add(row)
    else:
        row.enrollment_id = enrollment.id
        row.user_id = user.id
        row.updated_by = importer.email

    for column in spec.value_columns:
        setattr(row, column.field, getattr(validated, column.field))

    # the real state the row is migrated into, not the one it was checked as
    row.status_id = status_id
    row.stage_id = stage_id

    await db.flush()
    return action


# ---------- Laboratory import ----------
async def _import_laboratory_row(db, spec, lookups, values, importer, counts):
    lab_type = await lookups.lab_type(values["lab_type"])
    province = await lookups.province(values["province"])
    district = await lookups.district(province, values["district"])

    status_id, stage_id = _resolve_status(
        values.get("status"), LAB_STATUS_BY_NAME, LAB_STATUS_VALUES,
        DEFAULT_LAB_STATUS,
    )

    methods = []
    for label in (values.get("methods") or "").split("|"):
        label = label.strip()
        if label:
            methods.append(await lookups.method_by_label(label))

    code = values.get("code")
    email = values["email_address"]

    result = await db.execute(select(LaboratoryDB).where(LaboratoryDB.email_address == email))
    by_email = result.scalars().first()

    row = None
    if code:
        result = await db.execute(select(LaboratoryDB).where(LaboratoryDB.code == code))
        row = result.scalars().first()

    if row and by_email and row.id != by_email.id:
        raise RowError(
            f"'{email}' already belongs to the laboratory '{by_email.code}'",
            "email_address",
        )

    row = row or by_email
    action = "updated" if row else "created"

    if not row:
        row = LaboratoryDB(
            code=code or await _next_laboratory_code(db),
            status_id=status_id,
            stage_id=stage_id,
            approval_levels=1,
            # a migrated lab gets its login the way every other lab does, when
            # the registration is approved
            user_id=None,
            created_by=importer.email,
        )
        db.add(row)
    else:
        row.updated_by = importer.email

    for column in spec.value_columns:
        if column.name == "code":
            continue
        setattr(row, column.field, values.get(column.name))

    row.lab_type_id = lab_type.id
    row.province_id = province.id
    row.district_id = district.id
    row.method_list = [
        {
            "id": method.id,
            "name": method.name,
            "scheme_id": method.scheme_id,
            "service_id": method.service_id,
        }
        for method in methods
    ]
    row.status_id = status_id
    row.stage_id = stage_id

    await db.flush()

    counts["applications"] += await _sync_applications(db, row, methods, status_id, importer)

    return action


async def _next_laboratory_code(db):
    """The next sequential registration code, as /laboratorys/create issues it"""
    result = await db.execute(select(LaboratoryDB.id).order_by(LaboratoryDB.id.desc()))
    last_id = result.scalars().first() or 0
    return f"REG{last_id + 1:04d}"


async def _sync_applications(db, laboratory, methods, status_id, importer):
    """Gives the lab one application per method, the way registration does.

    Enrolment reads approved applications, so without these a migrated lab
    could carry its history but never take part in the next round.
    """
    result = await db.execute(
        select(ApplicationsDB).where(ApplicationsDB.lab_id == laboratory.id)
    )
    existing = {row.method_id: row for row in result.scalars().all()}

    stage_id = (
        assist.APPROVAL_STAGE_APPROVED
        if status_id == assist.STATUS_APPROVED
        else assist.APPROVAL_STAGE_SUBMITTED
    )

    added = 0
    for method in methods:
        application = existing.get(method.id)

        if application:
            application.status_id = status_id
            application.stage_id = stage_id
            application.updated_by = importer.email
            continue

        db.add(
            ApplicationsDB(
                name=f"{laboratory.name} - {method.name}",
                description=(
                    f"Application by {laboratory.name} to take part in {method.name}"
                ),
                lab_id=laboratory.id,
                scheme_id=method.scheme_id,
                service_id=method.service_id,
                method_id=method.id,
                user_id=None,
                status_id=status_id,
                stage_id=stage_id,
                approval_levels=1,
                created_by=importer.email,
            )
        )
        added += 1

    await db.flush()
    return added


# ---------- Pydantic errors, in the file's own words ----------
def _first_message(error):
    first = error.errors()[0]
    location = first.get("loc") or ()
    message = first.get("msg", "is not valid")

    # a root validator error is already a whole sentence
    if not location or location[0] == "__root__":
        return message

    return f"{location[0]}: {message}"


def _first_column(error, spec):
    for detail in error.errors():
        for part in detail.get("loc") or ():
            if spec.column(str(part)):
                return str(part)
    return None


# ---------- The run ----------
async def import_csv(db, key, content, imported_by, dry_run=True):
    """Loads one CSV into the system, all of it or none of it.

    A migration file is one consignment: a half loaded round is worse than a
    rejected one, because nobody can tell by looking which half landed. So the
    first failure still lets the rest of the file be checked - every error is
    reported - but nothing is committed unless every row passed.
    """
    spec = get_spec(key)

    result = await db.execute(select(UserDB).where(UserDB.email == imported_by))
    importer = result.scalars().first()
    if not importer:
        raise RowError(f"No user account for '{imported_by}'")

    text = content.decode("utf-8-sig") if isinstance(content, bytes) else content
    reader = csv.DictReader(io.StringIO(text))

    if not reader.fieldnames:
        raise RowError("The file is empty")

    supplied = [name.strip() for name in reader.fieldnames if name]
    missing = [name for name in spec.headers if name not in supplied]
    if missing:
        raise RowError(
            "The file is missing the column(s): " + ", ".join(missing) +
            ". Start from the template"
        )

    unknown = [name for name in supplied if name not in spec.headers]

    lookups = Lookups(db)
    counts = {"created": 0, "updated": 0, "enrollments_opened": 0, "applications": 0}
    errors = []
    rows = 0

    for number, raw in enumerate(reader, start=2):  # row 1 is the header
        if not any((value or "").strip() for value in raw.values()):
            continue

        rows += 1

        try:
            values = {}
            for column in spec.columns:
                values[column.name] = column.parse(raw.get(column.name))

            if spec.kind == LAB_IMPORT:
                action = await _import_laboratory_row(
                    db, spec, lookups, values, importer, counts
                )
            else:
                action = await _import_result_row(
                    db, spec, lookups, values, importer, counts
                )

            counts[action] += 1
        except RowError as error:
            errors.append(
                {"row": number, "column": error.column, "message": error.message}
            )
        except Exception as error:  # a constraint the row could not have known
            errors.append({"row": number, "column": None, "message": str(error)})

    committed = False
    if errors or dry_run:
        await db.rollback()
    else:
        try:
            await db.commit()
            committed = True
        except Exception as error:
            await db.rollback()
            errors.append({"row": None, "column": None, "message": str(error)})

    return {
        "form": spec.key,
        "label": spec.label,
        "dry_run": dry_run,
        "committed": committed,
        "rows": rows,
        "created": counts["created"] if committed or dry_run else 0,
        "updated": counts["updated"] if committed or dry_run else 0,
        "enrollments_opened": counts["enrollments_opened"],
        "applications_opened": counts["applications"],
        "failed": len(errors),
        "errors": errors,
        "ignored_columns": unknown,
        "message": _summarise(spec, counts, errors, rows, dry_run, committed),
    }


def _summarise(spec, counts, errors, rows, dry_run, committed):
    if errors:
        return (
            f"{len(errors)} of {rows} row(s) could not be imported, so nothing "
            "was written. Fix the rows listed and run the file again."
        )

    what = (
        f"{counts['created']} created, {counts['updated']} updated"
        if rows
        else "no rows"
    )

    if dry_run:
        return (
            f"All {rows} row(s) in the {spec.label} file are valid ({what}). "
            "Nothing was written - run it again with dry_run=false to import."
        )

    if committed:
        return f"Imported {rows} {spec.label} row(s): {what}."

    return "The import could not be written."
