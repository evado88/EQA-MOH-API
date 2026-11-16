"""Attachment helpers shared by the result-capture endpoints."""
from sqlalchemy import text

# result files are attached to the enrolment (the panel), type 'result-files'
RESULT_FILES_TYPE = "result-files"


async def result_file_exists(db, enrollment_id) -> bool:
    """True when the lab has attached at least one supporting file (e.g. the
    physical result worksheet) to the enrolment."""
    row = (
        await db.execute(
            text(
                "SELECT 1 FROM attachments "
                "WHERE type = :t AND parent = :p LIMIT 1"
            ),
            {"t": RESULT_FILES_TYPE, "p": enrollment_id},
        )
    ).first()
    return row is not None
