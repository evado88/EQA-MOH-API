"""One import surface for every form, rather than one per router.

The forms differ only in their columns, and `helpers/import_csv.py` already
holds those. So there is a single set of endpoints here, taking the form as a
path parameter, and the client gets the same shape back whichever form it is
loading.
"""
from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile
from fastapi.responses import PlainTextResponse
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_db
from helpers import import_csv

router = APIRouter(prefix="/imports", tags=["Imports"])

# a spreadsheet can be large, but a migration file of this size is a mistake
MAX_UPLOAD_BYTES = 8 * 1024 * 1024


def _spec(form: str):
    try:
        return import_csv.get_spec(form)
    except KeyError:
        raise HTTPException(
            status_code=404,
            detail=(
                f"Unable to find an import for '{form}'. The forms that can be "
                f"imported are: {', '.join(import_csv.IMPORT_ORDER)}"
            ),
        )


@router.get("/forms")
async def list_import_forms():
    """The forms that can be imported, in the order a migration should load them"""
    forms = []

    for key in import_csv.IMPORT_ORDER:
        spec = import_csv.get_spec(key)
        forms.append(
            {
                "form": spec.key,
                "label": spec.label,
                "source": spec.source,
                "kind": spec.kind,
                "columnCount": len(spec.columns),
                "templateUrl": f"/imports/{spec.key}/template",
            }
        )

    return {
        "formList": forms,
        "note": (
            "Load the laboratories first - every result names the laboratory "
            "that reported it, and the laboratory has to already be in the "
            "system for the row to match."
        ),
    }


@router.get("/{form}/columns")
async def get_import_columns(form: str):
    """What every column in a template means, so the client can show the guide"""
    spec = _spec(form)

    return {
        "form": spec.key,
        "label": spec.label,
        "source": spec.source,
        "columnList": import_csv.template_guide(spec.key),
        "matchedOn": (
            "code, falling back to the email address"
            if spec.kind == import_csv.LAB_IMPORT
            else "the PT cycle, laboratory and sample together"
        ),
    }


@router.get("/{form}/template", response_class=PlainTextResponse)
async def get_import_template(
    form: str,
    with_samples: bool = Query(
        default=True, description="Include the worked sample rows"
    ),
):
    """The CSV template for a form, with sample rows that show what a good row is"""
    spec = _spec(form)
    content = import_csv.template_csv(spec.key, with_samples=with_samples)

    return PlainTextResponse(
        content=content,
        media_type="text/csv; charset=utf-8",
        headers={
            "Content-Disposition": f'attachment; filename="{spec.key}-import-template.csv"'
        },
    )


@router.post("/{form}")
async def post_import(
    form: str,
    file: UploadFile = File(..., description="The completed CSV template"),
    imported_by: str = Query(
        ..., description="Email of the user running the migration"
    ),
    dry_run: bool = Query(
        default=True,
        description=(
            "Checks the file and reports what would happen without writing "
            "anything. Run a file this way first."
        ),
    ),
    db: AsyncSession = Depends(get_db),
):
    """Loads a completed template.

    The file is all or nothing: every row is checked and every fault reported,
    but a file with one bad row writes nothing at all. That way a failed import
    never leaves half a round behind for somebody to find later.
    """
    spec = _spec(form)

    content = await file.read()

    if not content:
        raise HTTPException(status_code=400, detail="The uploaded file is empty")

    if len(content) > MAX_UPLOAD_BYTES:
        raise HTTPException(
            status_code=400,
            detail=(
                f"The file is larger than {MAX_UPLOAD_BYTES // (1024 * 1024)}MB. "
                "Split the migration into smaller files"
            ),
        )

    try:
        report = await import_csv.import_csv(
            db, spec.key, content, imported_by=imported_by, dry_run=dry_run
        )
    except import_csv.RowError as error:
        # the file itself is wrong, not one of its rows
        await db.rollback()
        raise HTTPException(status_code=400, detail=error.message)

    report["succeeded"] = report["failed"] == 0
    report["fileName"] = file.filename

    return report
