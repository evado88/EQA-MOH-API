from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional

from database import get_db
from helpers import assist
from models.samplereceipt_model import (
    SampleReceipt,
    SampleReceiptDB,
    ParamSampleReceipt,
)
from models.user_model import UserDB

router = APIRouter(prefix="/sample-receipts", tags=["SampleReceipts"])


@router.post("", response_model=SampleReceipt)
async def upsert_sample_receipt(
    param: ParamSampleReceipt, db: AsyncSession = Depends(get_db)
):
    """Record (or correct) a sample's receipt details. A lab may only do this
    for its own samples. Upserts on (cycle, lab, sample)."""
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
            select(SampleReceiptDB).where(
                SampleReceiptDB.pt_cycle_id == param.pt_cycle_id,
                SampleReceiptDB.lab_id == param.lab_id,
                SampleReceiptDB.method_sample_id == param.method_sample_id,
            )
        )
    ).scalars().first()

    if existing:
        existing.date_received = param.date_received
        existing.condition = param.condition
        existing.temperature_c = param.temperature_c
        existing.comments = param.comments
        existing.updated_by = user.email
        receipt = existing
    else:
        receipt = SampleReceiptDB(
            pt_cycle_id=param.pt_cycle_id,
            lab_id=param.lab_id,
            method_sample_id=param.method_sample_id,
            date_received=param.date_received,
            condition=param.condition,
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
        raise HTTPException(status_code=400, detail=f"Could not save the sample receipt: {e}")
    return receipt


@router.get("", response_model=List[SampleReceipt])
async def list_sample_receipts(
    pt_cycle_id: Optional[int] = Query(default=None),
    lab_id: Optional[int] = Query(default=None),
    db: AsyncSession = Depends(get_db),
):
    """Receipts recorded for a lab's samples in a cycle."""
    query = select(SampleReceiptDB)
    if pt_cycle_id is not None:
        query = query.where(SampleReceiptDB.pt_cycle_id == pt_cycle_id)
    if lab_id is not None:
        query = query.where(SampleReceiptDB.lab_id == lab_id)
    result = await db.execute(query)
    return result.scalars().all()


@router.get("/sample", response_model=Optional[SampleReceipt])
async def get_sample_receipt(
    pt_cycle_id: int = Query(...),
    lab_id: int = Query(...),
    method_sample_id: int = Query(...),
    db: AsyncSession = Depends(get_db),
):
    """The receipt for one sample, or null if none has been recorded yet."""
    result = await db.execute(
        select(SampleReceiptDB).where(
            SampleReceiptDB.pt_cycle_id == pt_cycle_id,
            SampleReceiptDB.lab_id == lab_id,
            SampleReceiptDB.method_sample_id == method_sample_id,
        )
    )
    return result.scalars().first()
