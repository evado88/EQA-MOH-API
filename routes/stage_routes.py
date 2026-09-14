from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List

from database import get_db
from models.stage_model import Stage, StageDB

router = APIRouter(prefix="/review-stages", tags=["Stages"])


@router.post("/create", response_model=Stage)
async def create_stage(status: Stage, db: AsyncSession = Depends(get_db)):

    db_user = StageDB(
        # personal details
        id=status.id,
        stage_name=status.stage_name,
    )
    db.add(db_user)
    try:
        await db.commit()
        await db.refresh(db_user)
    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=400, detail=f"Unable to create review stage: f{e}"
        )
    return db_user


@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    stageList = [
        "Awaiting Submission", #1 
        "Submitted",#2 
        "First Approval",#3 first admin reviews
        "Second Approval",#4 second admin reviews
        "Approved",#5 approved, third admin reviews
    ]
    stageId = 1

    for value in stageList:
        db_status = StageDB(
            # personal details
            id=stageId,
            stage_name=value,
        )
        db.add(db_status)
        stageId += 1

    try:
        await db.commit()
        # await db.refresh(db_status)
    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=400, detail=f"Unable to initialize review stages: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Review stages have been successfully initialized",
    }


@router.get("/", response_model=List[Stage])
async def list_stages(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(StageDB))
    return result.scalars().all()