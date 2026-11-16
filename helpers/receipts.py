"""Receipt helpers shared by the result-capture endpoints."""
from sqlalchemy import text


async def receipt_exists(db, pt_cycle_id, lab_id, method_sample_id) -> bool:
    """True when the lab may enter results for this sample.

    Samples arrive in one package, so two things must be on record first: the
    shipment's arrival for the (cycle, lab), and this sample's own condition.
    """
    shipment = (
        await db.execute(
            text(
                "SELECT 1 FROM shipment_receipts "
                "WHERE pt_cycle_id = :c AND lab_id = :l"
            ),
            {"c": pt_cycle_id, "l": lab_id},
        )
    ).first()
    if shipment is None:
        return False

    sample = (
        await db.execute(
            text(
                "SELECT 1 FROM sample_receipts "
                "WHERE pt_cycle_id = :c AND lab_id = :l "
                "AND method_sample_id = :s AND condition IS NOT NULL"
            ),
            {"c": pt_cycle_id, "l": lab_id, "s": method_sample_id},
        )
    ).first()
    return sample is not None
