from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List

from database import get_db
from models.status_model import Status, StatusDB

router = APIRouter(prefix="/status-types", tags=["Statuses"])


@router.post("/create", response_model=Status)
async def create_status(status: Status, db: AsyncSession = Depends(get_db)):
    
    db_user = StatusDB(
        #personal details
        id = status.id,
        status_name=status.status_name,
    )
    db.add(db_user)
    try:
        await db.commit()
        await db.refresh(db_user)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to create status type: f{e}")
    return db_user

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    statusList = ['Draft', 'Submitted', 'Under Review', 'Approved', 'Rejected']
    statusId = 1
    
    for value in statusList:
        db_status = StatusDB(
            #personal details
            id = statusId,
            status_name=value,
        )
        db.add(db_status)
        statusId += 1
        
    try:
        await db.commit()
        #await db.refresh(db_status)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to initialize status types: f{e}")
    return {'succeeded': True, 'message': 'Statuses have been successfully initialized'}


@router.get("/", response_model=List[Status])
async def list_statuses(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(StatusDB))
    return result.scalars().all()
