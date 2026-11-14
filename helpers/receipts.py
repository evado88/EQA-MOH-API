"""Per-sample receipt helpers shared by the result-capture endpoints."""
from sqlalchemy import text


async def receipt_exists(db, pt_cycle_id, lab_id, method_sample_id) -> bool:
    """True when the lab has recorded receipt details for this sample, which is
    a precondition for entering results against it."""
    row = (
        await db.execute(
            text(
                "SELECT 1 FROM sample_receipts "
                "WHERE pt_cycle_id = :c AND lab_id = :l AND method_sample_id = :s"
            ),
            {"c": pt_cycle_id, "l": lab_id, "s": method_sample_id},
        )
    ).first()
    return row is not None
