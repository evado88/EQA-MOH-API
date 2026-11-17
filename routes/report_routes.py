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
from models.bacteriologyresult_model import ast_interpretations
from models.method_model import RESULT_FORM_BACTERIOLOGY

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


def _score(value):
    """A mark, whole where it is whole (3, 10) and one place where it is not (16.7)"""
    if value is None:
        return "0"
    if float(value).is_integer():
        return str(int(value))
    return f"{value:.1f}"


# the three bacterial-identification fields, in the order the worksheet prints
BACTERIOLOGY_ID_ATTRIBUTES = [
    ("gram_stain_reaction", "Gram reaction"),
    ("gram_morphology", "Cell morphology"),
    ("organism_identified", "Bacterial Identification"),
]
AST_ATTRIBUTE = "ast_result"


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


async def _load_ast_rows(db, enrollment_id):
    """The participant's AST table, as reported, for the AST sample."""
    result = await db.execute(
        text(
            "SELECT ar.antibiotic, ar.ast_method, ar.zone_diameter, "
            "ar.mic_reading, ar.interpretation "
            "FROM bacteriology_ast_results ar "
            "JOIN bacteriology_results b ON b.id = ar.bacteriology_result_id "
            "WHERE b.enrollment_id = :id ORDER BY ar.antibiotic"
        ),
        {"id": enrollment_id},
    )
    return result.mappings().all()


def _render_bacteriology(doc, header, rows, ast_rows):
    """The TF-NHRTI-BACT-008 feedback report, from the frozen evaluation.

    Lays out the scheme's own report: the sample-set-design note, a block per
    sample comparing the participant's identification to the expected result and
    the marks earned, the Sample E AST table, the scoring rubric, the overall
    score, and the per-sample performance comments.
    """
    cycle = header["cycle_code"] or header["cycle_name"] or ""

    doc.text(header["provider_name"] or "Proficiency Testing Scheme",
             size=15, bold=True)
    doc.text("Bacteriology PT Feedback Report", size=11)
    doc.rule()
    doc.field("Report Number", header["report_number"])
    doc.field("Laboratory", f"{header['lab_code'] or '-'} - {header['lab_name']}")
    doc.field("Scheme / Round", f"{header['scheme_name']} / {cycle}")
    doc.field("Report Date", str(header["report_date"] or "-"))

    doc.heading("Sample set design")
    doc.text("NHRTI designed the sample set for this survey to:", size=9)
    for line in (
        "- Assess the ability of participants to detect bacterial organisms in "
        "specimens.",
        "- Assess the ability of participants to isolate and identify bacterial "
        "organisms.",
        "- Examine the ability of participants to conduct AST according to CLSI "
        "M100 guidelines.",
    ):
        doc.text(line, size=9)

    doc.heading(f"{cycle} Reported results and scoring tabulation")

    # ---- the identification tables, one block per sample ----
    by_sample = {}
    order = []
    for row in rows:
        if row["attribute"] == AST_ATTRIBUTE:
            continue
        name = row["sample_name"]
        if name not in by_sample:
            by_sample[name] = {}
            order.append(name)
        by_sample[name][row["attribute"]] = row

    cols = [
        (MARGIN_LEFT, ""),
        (MARGIN_LEFT + 150, "Gram reaction"),
        (MARGIN_LEFT + 250, "Cell morphology"),
        (MARGIN_LEFT + 360, "Bacterial ID"),
        (MARGIN_LEFT + 470, "Total"),
    ]
    comments = []
    for name in order:
        fields = by_sample[name]
        doc.spacer(4)
        doc.text(name, size=10, bold=True)
        doc.columns(cols, size=8, bold=True)

        def _cells(label, pick):
            cells = [(cols[0][0], label)]
            for i, (attr, _lbl) in enumerate(BACTERIOLOGY_ID_ATTRIBUTES, start=1):
                r = fields.get(attr)
                cells.append((cols[i][0], pick(r) if r else "-"))
            return cells

        total = sum(
            (fields[a]["score"] or 0)
            for a, _ in BACTERIOLOGY_ID_ATTRIBUTES if a in fields
        )
        max_total = sum(
            (fields[a]["max_score"] or 0)
            for a, _ in BACTERIOLOGY_ID_ATTRIBUTES if a in fields
        )
        row_part = _cells("Participant result", lambda r: r["reported_text"] or "-")
        row_part.append((cols[4][0], _score(total)))
        row_score = _cells("Obtained score", lambda r: _score(r["score"]))
        row_score.append((cols[4][0], f"{_score(total)}/{_score(max_total)}"))
        row_exp = _cells("Expected results", lambda r: r["assigned_text"] or "-")
        row_exp.append((cols[4][0], _score(max_total)))
        doc.columns(row_part, size=8)
        doc.columns(row_score, size=8)
        doc.columns(row_exp, size=8)

        # a per-sample performance line for the comments section
        org = fields.get("organism_identified")
        if org:
            expected = org["assigned_text"] or "the expected organism"
            if (org["grade"] or "") == assist.GRADE_ACCEPTABLE:
                comments.append(
                    f"{name}: The identification of {expected} was acceptable."
                )
            elif (org["grade"] or "") == assist.GRADE_WARNING:
                comments.append(
                    f"{name}: Partial credit - the genus was correct but the "
                    f"species differed from {expected}."
                )
            else:
                comments.append(
                    f"{name}: The identification did not match the expected "
                    f"result of {expected}."
                )

    # ---- the AST table for the AST sample ----
    # there is one ast_result row per sample but only the AST sample carries a
    # target, so pick the row that was actually graded (has an assigned value)
    ast_evals = [r for r in rows if r["attribute"] == AST_ATTRIBUTE]
    ast_eval = next(
        (r for r in ast_evals if r["assigned_text"] or r["evaluated"]),
        ast_evals[0] if ast_evals else None,
    )
    if ast_eval:
        target = ast_interpretations(ast_eval["assigned_text"])
        doc.heading("Antimicrobial Susceptibility Testing (AST)")
        ast_cols = [
            (MARGIN_LEFT, "#"),
            (MARGIN_LEFT + 20, "Antibiotic"),
            (MARGIN_LEFT + 170, "Zone (mm)"),
            (MARGIN_LEFT + 230, "Interp."),
            (MARGIN_LEFT + 285, "Expected"),
            (MARGIN_LEFT + 350, "Conclusion"),
        ]
        doc.columns(ast_cols, size=8, bold=True)
        for i, ar in enumerate(ast_rows, start=1):
            agent = (ar["antibiotic"] or "").upper()
            mine = (ar["interpretation"] or "").upper()
            expected = target.get(agent)
            if not expected:
                conclusion, exp_show = "NE", "NE"
            elif mine == expected:
                conclusion, exp_show = "Acceptable", expected
            else:
                conclusion, exp_show = "Unacceptable", expected
            zone = ar["zone_diameter"]
            doc.columns(
                [
                    (ast_cols[0][0], str(i)),
                    (ast_cols[1][0], ar["antibiotic"] or "-"),
                    (ast_cols[2][0], _number(zone, 0) if zone is not None else "-"),
                    (ast_cols[3][0], ar["interpretation"] or "-"),
                    (ast_cols[4][0], exp_show),
                    (ast_cols[5][0], conclusion),
                ],
                size=8,
            )
        doc.spacer(2)
        doc.field(
            "AST section score",
            f"{_score(ast_eval['score'])} of {ast_eval['max_score']}",
        )
        if (ast_eval["grade"] or "") != assist.GRADE_ACCEPTABLE:
            disagreed = ast_eval["not_evaluated_reason"]
            comments.append(
                "Sample E AST: " + (disagreed or "One or more antibiotics were "
                "interpreted differently from the expected result") + ". The "
                "laboratory should review antibiotic disc quality control."
            )

    # ---- scoring rubric ----
    doc.heading("Scoring criteria")
    doc.columns(
        [(MARGIN_LEFT, "Gram reaction: 3"), (MARGIN_LEFT + 140, "Morphology: 3"),
         (MARGIN_LEFT + 280, "Identification: 10"), (MARGIN_LEFT + 430, "AST: 20")],
        size=8,
    )
    doc.text("Full marks for identification; half for the correct genus only. "
             "NE indicates results that were not evaluated.", size=8)

    # ---- overall ----
    doc.heading("Overall")
    doc.field(
        "Overall Score",
        f"{_score(header['total_score'])} of {header['max_score']}  "
        f"({header['percent_score_display'] or 0}%)",
    )
    doc.field("Overall Performance", header["overall_performance"])
    doc.text("The acceptable PT performance score is 100%. Laboratories below it "
             "should conduct corrective action.", size=8)

    if comments:
        doc.heading("Performance comments")
        for line in comments:
            doc.text(line, size=8)

    doc.spacer(10)
    doc.text(
        "PLACEHOLDER DOCUMENT - the production TF-NHRTI-BACT-008 report is "
        "rendered by XtraReports from the reporting service.", size=7,
    )
    doc.text(
        f"Evaluation frozen at {header['frozen_at']}. Generated "
        f"{assist.get_current_date(False):%d %b %Y %H:%M}.", size=7,
    )


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

    # bacteriology has its own report form (TF-NHRTI-BACT-008); the others share
    # the generic individual-evaluation layout
    if header["result_form"] == RESULT_FORM_BACTERIOLOGY:
        ast_rows = await _load_ast_rows(db, enrollment_id)
        _render_bacteriology(doc, header, rows, ast_rows)
        pdf = doc.render()
        name = f"PT-Report-{header['report_number']}.pdf".replace("/", "-")
        disposition = "attachment" if download else "inline"
        return Response(
            content=pdf,
            media_type="application/pdf",
            headers={
                "Content-Disposition": f'{disposition}; filename="{name}"',
                "Access-Control-Expose-Headers": "Content-Disposition",
            },
        )

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
                (TABLE_COLUMNS[6][0], f"{_score(row['score'])}/{row['max_score']}"),
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
        f"{_score(header['total_score'])} of {header['max_score']}"
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
