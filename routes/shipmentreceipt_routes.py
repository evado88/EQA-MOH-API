from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import Optional

from database import get_db
from helpers import assist
from models.shipmentreceipt_model import (
    ShipmentReceipt,
    ShipmentReceiptDB,
    ParamShipmentReceipt,
)
from models.user_model import UserDB

router = APIRouter(prefix="/shipment-receipts", tags=["ShipmentReceipts"])


@router.post("", response_model=ShipmentReceipt)
async def upsert_shipment_receipt(
    param: ParamShipmentReceipt, db: AsyncSession = Depends(get_db)
):
    """Record (or correct) how a shipment arrived. A lab may only do this for
    its own shipments. Upserts on (cycle, lab)."""
    user = (
        await db.execute(select(UserDB).where(UserDB.id == param.user_id))
    ).scalars().first()
    if not user:
        raise HTTPException(status_code=400, detail="The user does not exist")

    if assist.is_laboratory_role(user.role_id) and user.laboratory_id != param.lab_id:
        raise HTTPException(
            status_code=403,
            detail="You are not permitted to record receipts for another laboratory",
        )

    existing = (
        await db.execute(
            select(ShipmentReceiptDB).where(
                ShipmentReceiptDB.pt_cycle_id == param.pt_cycle_id,
                ShipmentReceiptDB.lab_id == param.lab_id,
            )
        )
    ).scalars().first()

    if existing:
        existing.date_received = param.date_received
        existing.temperature_c = param.temperature_c
        existing.comments = param.comments
        existing.updated_by = user.email
        receipt = existing
    else:
        receipt = ShipmentReceiptDB(
            pt_cycle_id=param.pt_cycle_id,
            lab_id=param.lab_id,
            date_received=param.date_received,
            temperature_c=param.temperature_c,
            comments=param.comments,
            created_by=user.email,
        )
        db.add(receipt)

    try:
        await db.commit()
        await db.refresh(receipt)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not save the shipment receipt: {e}")
    return receipt


@router.get("/by", response_model=Optional[ShipmentReceipt])
async def get_shipment_receipt(
    pt_cycle_id: int = Query(...),
    lab_id: int = Query(...),
    db: AsyncSession = Depends(get_db),
):
    """The shipment receipt for one (cycle, lab), or null if none recorded yet."""
    result = await db.execute(
        select(ShipmentReceiptDB).where(
            ShipmentReceiptDB.pt_cycle_id == pt_cycle_id,
            ShipmentReceiptDB.lab_id == lab_id,
        )
    )
    return result.scalars().first()
