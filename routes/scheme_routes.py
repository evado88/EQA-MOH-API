from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from database import get_db
from models.scheme_model import Scheme, SchemeWithDetail, ParamSchemeEdit, SchemeDB
# approval
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User, UserDB
from models.review_model import Review
from helpers import assist
from sqlalchemy.orm import selectinload
# relations
from models.provider_model import ProviderDB

router = APIRouter(prefix="/schemes", tags=["Schemes"])


@router.post("/create", response_model=Scheme)
async def post_scheme(scheme: Scheme, db: AsyncSession = Depends(get_db)):


    db_context = SchemeDB(
        # update
        name=scheme.name,
        description=scheme.description,
        # properties
        provider_id=scheme.provider_id,
        # approval
        user_id=scheme.user_id,
        status_id=scheme.status_id,
        stage_id=scheme.stage_id,
        approval_levels=scheme.approval_levels,
        # service
        created_by=scheme.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create Scheme: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = [{'name': 'Tuberculosis (TB)'}, {'name': 'Early Infant Diagnosis (EID)'}, {'name': 'Viral Load'}, {'name': 'Rapid Test Continuous Quality Improvement (RTCQI'}]

    for value in itemList:
        db_item = SchemeDB(
            # add item
            name=value["name"],
            user_id=1,
            status_id=4,
            stage_id=5,
            approval_levels=1
        )
        db.add(db_item)

    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=400, detail=f"Unable to initialize items for Scheme: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for Scheme have been successfully initialized",
    }



@router.get("/list", response_model=List[SchemeWithDetail])
async def list_schemes(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(
            SchemeDB
        ).options(
            selectinload(SchemeDB.stage),
            selectinload(SchemeDB.status),
            selectinload(SchemeDB.user),
            
            selectinload(SchemeDB.provider),
        )
    )
    schemes = result.scalars().all()
    return schemes

@router.put("/update/{id}", response_model=Scheme)
async def update_scheme(
    id: int, scheme_update: Scheme, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(SchemeDB).where(SchemeDB.id == id))
    scheme = result.scalar_one_or_none()

    if not scheme:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Scheme with id '{id}'",
        )

    # Update fields that are not None
    for key, value in scheme_update.dict(exclude_unset=True).items():
        setattr(scheme, key, value)

    try:
        await db.commit()
        await db.refresh(scheme)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Scheme {e}")
    return scheme


@router.get("/id/{id}", response_model=ParamSchemeEdit)
async def get_scheme(id: int, db: AsyncSession = Depends(get_db)):
    schemeItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(SchemeDB
            ).options(
                selectinload(SchemeDB.stage),
                selectinload(SchemeDB.status),
                selectinload(SchemeDB.user),
                
                selectinload(SchemeDB.provider),
            )
            .filter(SchemeDB.id == id)
        )
        schemeItem = result.scalars().first()
        if not schemeItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'Scheme with id '{id}' not found"
            )

    # get supporting models if available

    # Provider
    result = await db.execute(
        select(ProviderDB)
        .order_by(ProviderDB.name)
    )
    providerItems =  result.scalars().all()


    res = ParamSchemeEdit(
            scheme=schemeItem,
            providerList = providerItems,
    )

    return res


@router.put("/review-update/{id}", response_model=Scheme)
async def review_posting(
    id: int, review: Review, db: AsyncSession = Depends(get_db)
):
    # check user exists
    result = await db.execute(select(UserDB).where(UserDB.id == review.user_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(
            status_code=400,
            detail=f"The user with id '{review.user_id}' does not exist",
        )

    # check if item exists
    result = await db.execute(select(SchemeDB).where(SchemeDB.id == id))
    scheme = result.scalar_one_or_none()

    if not scheme:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Scheme with id '{id}' not found",
        )

    if scheme.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The Scheme with id '{id}' has already been approved",
        )

    scheme.updated_by = user.email

    approveScheme = False

    if scheme.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage
        
        if scheme.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a Scheme you created",
        )

        scheme.review1_at = assist.get_current_date(False)
        scheme.review1_by = user.email
        scheme.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            scheme.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if scheme.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve scheme
                approveScheme = True

            elif scheme.approval_levels == 2 or scheme.approval_levels == 3:
                # two or three levels, move to primary

                scheme.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif scheme.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage
        
        if scheme.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        scheme.review2_at = assist.get_current_date(False)
        scheme.review2_by = user.email
        scheme.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            scheme.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if scheme.approval_levels == 2:
                # two levels, no furthur stage approvers

                approveScheme = True

            elif scheme.approval_levels == 3:
                # three levels, move to secondary
                scheme.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif scheme.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage
        
        if scheme.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        scheme.review3_at = assist.get_current_date(False)
        scheme.review3_by = user.email
        scheme.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            scheme.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approveScheme = True

    if approveScheme:
        # change scheme status
        scheme.status_id = assist.STATUS_APPROVED
        scheme.stage_id = assist.APPROVAL_STAGE_APPROVED

        # attachment may or may not be provided

    try:
        await db.commit()
        await db.refresh(scheme)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Scheme: {e}")
    return scheme


