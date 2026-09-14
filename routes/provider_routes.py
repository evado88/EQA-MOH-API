from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from database import get_db
from models.provider_model import Provider, ProviderWithDetail, ParamProviderEdit, ProviderDB
# approval
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User, UserDB
from models.review_model import Review
from helpers import assist
from sqlalchemy.orm import selectinload
# relations

router = APIRouter(prefix="/providers", tags=["Providers"])


@router.post("/create", response_model=Provider)
async def post_provider(provider: Provider, db: AsyncSession = Depends(get_db)):


    db_context = ProviderDB(
        # update
        name=provider.name,
        description=provider.description,
        # properties
        # approval
        user_id=provider.user_id,
        status_id=provider.status_id,
        stage_id=provider.stage_id,
        approval_levels=provider.approval_levels,
        # service
        created_by=provider.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create Provider: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = [{'name': 'CDL'}]

    for value in itemList:
        db_item = ProviderDB(
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
            status_code=400, detail=f"Unable to initialize items for Provider: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for Provider have been successfully initialized",
    }



@router.get("/list", response_model=List[ProviderWithDetail])
async def list_providers(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(
            ProviderDB
        ).options(
            selectinload(ProviderDB.stage),
            selectinload(ProviderDB.status),
            selectinload(ProviderDB.user),
            
        )
    )
    providers = result.scalars().all()
    return providers

@router.put("/update/{id}", response_model=Provider)
async def update_provider(
    id: int, provider_update: Provider, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(ProviderDB).where(ProviderDB.id == id))
    provider = result.scalar_one_or_none()

    if not provider:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Provider with id '{id}'",
        )

    # Update fields that are not None
    for key, value in provider_update.dict(exclude_unset=True).items():
        setattr(provider, key, value)

    try:
        await db.commit()
        await db.refresh(provider)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Provider {e}")
    return provider


@router.get("/id/{id}", response_model=ParamProviderEdit)
async def get_provider(id: int, db: AsyncSession = Depends(get_db)):
    providerItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(ProviderDB
            ).options(
                selectinload(ProviderDB.stage),
                selectinload(ProviderDB.status),
                selectinload(ProviderDB.user),
                
            )
            .filter(ProviderDB.id == id)
        )
        providerItem = result.scalars().first()
        if not providerItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'Provider with id '{id}' not found"
            )

    # get supporting models if available


    res = ParamProviderEdit(
            provider=providerItem,
    )

    return res


@router.put("/review-update/{id}", response_model=Provider)
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
    result = await db.execute(select(ProviderDB).where(ProviderDB.id == id))
    provider = result.scalar_one_or_none()

    if not provider:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Provider with id '{id}' not found",
        )

    if provider.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The Provider with id '{id}' has already been approved",
        )

    provider.updated_by = user.email

    approveProvider = False

    if provider.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage
        
        if provider.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a Provider you created",
        )

        provider.review1_at = assist.get_current_date(False)
        provider.review1_by = user.email
        provider.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            provider.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if provider.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve provider
                approveProvider = True

            elif provider.approval_levels == 2 or provider.approval_levels == 3:
                # two or three levels, move to primary

                provider.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif provider.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage
        
        if provider.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        provider.review2_at = assist.get_current_date(False)
        provider.review2_by = user.email
        provider.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            provider.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if provider.approval_levels == 2:
                # two levels, no furthur stage approvers

                approveProvider = True

            elif provider.approval_levels == 3:
                # three levels, move to secondary
                provider.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif provider.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage
        
        if provider.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        provider.review3_at = assist.get_current_date(False)
        provider.review3_by = user.email
        provider.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            provider.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approveProvider = True

    if approveProvider:
        # change provider status
        provider.status_id = assist.STATUS_APPROVED
        provider.stage_id = assist.APPROVAL_STAGE_APPROVED

        # attachment may or may not be provided

    try:
        await db.commit()
        await db.refresh(provider)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Provider: {e}")
    return provider


