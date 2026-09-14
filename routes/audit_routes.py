import os
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from sqlalchemy import select, desc
from database import get_db
from models.audit_model import Audit, AuditDB
from models.user_model import UserDB

router = APIRouter(prefix="/audit", tags=["Audit"])


@router.post("/", response_model=Audit)
async def post_audit(audit: Audit, db: AsyncSession = Depends(get_db)):
    # check user exists

    if audit.user_id != 0:
        result = await db.execute(select(UserDB).where(UserDB.id == audit.user_id))
        user = result.scalars().first()
        if not user:
            raise HTTPException(
                status_code=400, detail=f"User with id {audit.user_id} does not exist"
            )

    db_tran = AuditDB(
        # user
        user_id=audit.user_id,
        user_email=audit.user_email,
        token=audit.token,
        # audit
        date=audit.date,
        feature=audit.feature,
        model=audit.model,
        object_id=audit.object_id,
        action=audit.action,
        before=audit.before,
        after=audit.after,
        # service
        created_by=audit.user_email,
    )
    db.add(db_tran)
    try:
        await db.commit()
        await db.refresh(db_tran)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create audit: {e}")

    return db_tran


@router.get("/list", response_model=List[Audit])
async def list_audits(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(AuditDB).order_by(desc(AuditDB.created_at)).limit(300)
    )
    audits = result.scalars().all()
    return audits

@router.get("/sessions/list", response_model=List[Audit])
async def list_audit_sessions(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(AuditDB).filter(
        AuditDB.feature =="Session",
        AuditDB.action =="Start",
    ).order_by(desc(AuditDB.created_at)).limit(390)
    )
    audits = result.scalars().all()
    return audits

@router.get("/id/{id}", response_model=Audit)
async def get_audit(id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(AuditDB).filter(AuditDB.id == id))
    audit = result.scalars().first()
    if not audit:
        raise HTTPException(
            status_code=404, detail=f"Audit with id '{id}' not found"
        )

    return audit