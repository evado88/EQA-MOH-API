"""PT performance reports.

In production these are rendered by XtraReports from the ASP.NET service,
binding to the vw_pt_* views. This module stands in for that service so the
report page can be built and exercised now: it reads the same views and lays
the same content out in a placeholder PDF.

The paths deliberately match what the ASP.NET service will expose, so moving
over is a base-URL change in the client and nothing else.
"""
from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_db
from helpers import assist
from helpers.pdfstub import MARGIN_LEFT, PdfDocument

router = APIRouter(prefix="/reports", tags=["Reports"])

# where each column of the evaluation table sits on the page
TABLE_COLUMNS = [
    (MARGIN_LEFT, "Sample"),
    (MARGIN_LEFT + 96, "Your Result"),
    (MARGIN_LEFT + 168, "N"),
    (MARGIN_LEFT + 196, "Group Mean"),
    (MARGIN_LEFT + 268, "Robust SD"),
    (MARGIN_LEFT + 336, "Z-score"),
    (MARGIN_LEFT + 392, "Score"),
    (MARGIN_LEFT + 434, "Grade"),
]


def _number(value, places=2):
    if value is None:
        return "-"
    return f"{value:.{places}f}"


async def _load(db, enrollment_id):
    """The header and the rows, from the same views the real report binds to"""
    result = await db.execute(
        text("SELECT * FROM vw_pt_enrollment_performance WHERE enrollment_id = :id"),
        {"id": enrollment_id},
    )
    header = result.mappings().first()

    if not header:
        raise HTTPException(
            status_code=404,
            detail=(
                f"No performance report for enrolment '{enrollment_id}'. The "
                "round may not have been scored yet."
            ),
        )

    result = await db.execute(
        text(
            "SELECT * FROM vw_pt_result_evaluation "
            "WHERE enrollment_id = :id ORDER BY sample_name, attribute"
        ),
        {"id": enrollment_id},
    )
    return header, result.mappings().all()


@router.get("/pt-performance/{enrollment_id}/meta")
async def pt_performance_meta(
    enrollment_id: int, db: AsyncSession = Depends(get_db)
):
    """What the report page shows around the document itself."""
    header, rows = await _load(db, enrollment_id)
    return {
        "enrollment_id": enrollment_id,
        "report_number": header["report_number"],
        "lab_code": header["lab_code"],
        "lab_name": header["lab_name"],
        "scheme_name": header["scheme_name"],
        "method_name": header["method_name"],
        "cycle_code": header["cycle_code"],
        "cycle_name": header["cycle_name"],
        "report_date": header["report_date"],
        "total_score": header["total_score"],
        "max_score": header["max_score"],
        "percent_score_display": header["percent_score_display"],
        "overall_performance": header["overall_performance"],
        "reason_for_no_evaluation": header["reason_for_no_evaluation"],
        "row_count": len(rows),
        "frozen_at": header["frozen_at"],
        # the real renderer is the ASP.NET XtraReports service; this flags that
        # the document below is the stand-in
        "renderer": "placeholder",
    }


@router.get("/pt-performance/{enrollment_id}")
async def pt_performance_report(
    enrollment_id: int,
    download: bool = False,
    db: AsyncSession = Depends(get_db),
):
    """The participant's PT performance report as a PDF."""
    header, rows = await _load(db, enrollment_id)

    doc = PdfDocument(title=f"PT Report {header['report_number']}")

    doc.text(header["provider_name"] or "Proficiency Testing Scheme",
             size=15, bold=True)
    doc.text("Individual Participant Performance Report", size=11)
    doc.rule()

    doc.field("Report Number", header["report_number"])
    doc.field("Laboratory Code", header["lab_code"])
    doc.field("Laboratory", header["lab_name"])
    doc.field("Scheme", header["scheme_name"])
    doc.field("Service / Method", f"{header['service_name']} / {header['method_name']}")
    doc.field("PT Round", f"{header['cycle_code']} - {header['cycle_name']}")
    doc.field("Shipment Date", str(header["shipment_date"] or "-"))
    doc.field("Closing Date", str(header["shipment_target_date"] or "-"))
    doc.field("Report Date", str(header["report_date"] or "-"))
    doc.field("Confidentiality", "This report is confidential")

    doc.heading("Laboratory Data")
    doc.field("Contact Person", header["contact_person_name"] or "-")
    doc.field("Email", header["lab_email"] or "-")
    doc.field("Province / District",
              f"{header['province_name'] or '-'} / {header['district_name'] or '-'}")
    doc.field("Samples Received",
              str(header["samples_received_at"] or "Not recorded"))

    doc.heading("Results of the Individual Evaluation")
    doc.columns(TABLE_COLUMNS, size=8, bold=True)
    doc.rule()

    for row in rows:
        reported = (
            _number(row["reported_numeric"])
            if row["reported_numeric"] is not None
            else (row["reported_text"] or "-")
        )
        doc.columns(
            [
                (TABLE_COLUMNS[0][0], row["sample_name"]),
                (TABLE_COLUMNS[1][0], reported),
                (TABLE_COLUMNS[2][0], str(row["participant_count"] or "-")),
                (TABLE_COLUMNS[3][0], _number(row["group_mean"])),
                (TABLE_COLUMNS[4][0], _number(row["robust_sd"], 3)),
                (TABLE_COLUMNS[5][0], _number(row["z_score"])),
                (TABLE_COLUMNS[6][0], f"{row['score']}/{row['max_score']}"),
                (TABLE_COLUMNS[7][0], row["grade"]),
            ],
            size=8,
        )

        # say which field was graded when a form grades more than one
        if row["attribute_label"] and len(rows) > 5:
            doc.columns(
                [(TABLE_COLUMNS[0][0] + 8, f"  {row['attribute_label']}")], size=7
            )

        if not row["evaluated"] and row["not_evaluated_reason"]:
            doc.columns(
                [(TABLE_COLUMNS[0][0] + 8, f"  {row['not_evaluated_reason']}")],
                size=7,
            )

    doc.rule()
    doc.field(
        "Overall Score",
        f"{header['total_score']} of {header['max_score']}"
        f"  ({header['percent_score_display'] or 0}%)",
    )
    doc.field("Overall Performance", header["overall_performance"])
    if header["reason_for_no_evaluation"]:
        doc.field("Reason for No Evaluation", header["reason_for_no_evaluation"])

    doc.heading("Performance Criteria")
    doc.columns([(MARGIN_LEFT, "z-score"), (MARGIN_LEFT + 140, "Interpretation"),
                 (MARGIN_LEFT + 260, "Recommended Action")], size=8, bold=True)
    for band, interpretation, action in (
        (f"|z| <= {assist.Z_SCORE_ACCEPTABLE}", assist.GRADE_ACCEPTABLE,
         "No action required"),
        (f"{assist.Z_SCORE_ACCEPTABLE} < |z| < {assist.Z_SCORE_WARNING}",
         assist.GRADE_WARNING, "Closely monitor performance"),
        (f"|z| >= {assist.Z_SCORE_WARNING}", assist.GRADE_UNACCEPTABLE,
         "Perform corrective action"),
    ):
        doc.columns([(MARGIN_LEFT, band), (MARGIN_LEFT + 140, interpretation),
                     (MARGIN_LEFT + 260, action)], size=8)

    doc.spacer(14)
    doc.text(
        "PLACEHOLDER DOCUMENT - the production report is rendered by "
        "XtraReports from the reporting service.",
        size=7,
    )
    doc.text(
        f"Evaluation frozen at {header['frozen_at']}. Generated "
        f"{assist.get_current_date(False):%d %b %Y %H:%M}.",
        size=7,
    )

    pdf = doc.render()
    name = f"PT-Report-{header['report_number']}.pdf".replace("/", "-")
    disposition = "attachment" if download else "inline"

    return Response(
        content=pdf,
        media_type="application/pdf",
        headers={
            "Content-Disposition": f'{disposition}; filename="{name}"',
            # the viewer fetches this cross-origin once the real service is in
            "Access-Control-Expose-Headers": "Content-Disposition",
        },
    )
