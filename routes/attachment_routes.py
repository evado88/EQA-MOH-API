import io
import os
import uuid
from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional

from database import get_db
from helpers import assist
from models.attachment_model import Attachment, AttachmentDB, AttachmentInput
import csv

from models.user_model import UserDB

router = APIRouter(prefix="/attachments", tags=["Attachment"])


@router.post(
    "/create/type/{typeId}/parent/{parentId}", response_model=Attachment
)
async def post_attachment(
    typeId: str = "Attachment",
    parentId: int = 0,
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
):
    try:

        # ensure folders exist
        current = assist.get_current_date()
        dir = f"{assist.UPLOAD_DIR}/{current.year}/{current.month}"

        os.makedirs(dir, exist_ok=True)

        # Validate filename
        if not file.filename:
            raise HTTPException(status_code=400, detail="No filename provided")

        # Generate unique name
        fileDetail = os.path.splitext(file.filename)
        noextensionfile = fileDetail[0]
        ext = fileDetail[1]

        unique_name = f"{noextensionfile}_{uuid.uuid4()}{ext}"
        file_path = os.path.join(dir, unique_name)

        # Save file safely
        contents = await file.read()
        with open(file_path, "wb") as f:
            f.write(contents)

        # update file
        db_attachment = AttachmentDB(
            # personal details
            name=file.filename,
            path=f"{current.year}/{current.month}/{unique_name}",
            filesize=len(contents),
            filetype=file.content_type,
            type=typeId,
            parent=parentId,
        )

        db.add(db_attachment)
        await db.commit()
        await db.refresh(db_attachment)

        # rerturn response
        return db_attachment

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"File upload failed: {str(e)}")


@router.get("/list", response_model=List[Attachment])
async def list_attachments(
    type: Optional[str] = Query(default=None),
    parent: Optional[int] = Query(default=None),
    db: AsyncSession = Depends(get_db),
):
    """All attachments, optionally filtered by type and parent - e.g. the
    result files a lab attached to an enrolment (type='result-files')."""
    query = select(AttachmentDB)
    if type is not None:
        query = query.where(AttachmentDB.type == type)
    if parent is not None:
        query = query.where(AttachmentDB.parent == parent)
    query = query.order_by(AttachmentDB.id)
    result = await db.execute(query)
    return result.scalars().all()


@router.get("/{id}", response_model=Attachment)
async def get_attachment(id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(AttachmentDB).filter(AttachmentDB.id == id))
    attachment = result.scalars().first()
    if not attachment:
        raise HTTPException(
            status_code=404, detail=f"Attachment with id '{id}' not found"
        )
    return attachment


@router.delete("/{id}")
async def delete_attachment(id: int, db: AsyncSession = Depends(get_db)):
    """Removes an attachment (row and the stored file). Used to detach a result
    file a lab added by mistake."""
    result = await db.execute(select(AttachmentDB).filter(AttachmentDB.id == id))
    attachment = result.scalars().first()
    if not attachment:
        raise HTTPException(status_code=404, detail=f"Attachment with id '{id}' not found")

    # best-effort removal of the stored file
    if attachment.path:
        file_path = os.path.join(assist.UPLOAD_DIR, attachment.path)
        try:
            if os.path.exists(file_path):
                os.remove(file_path)
        except OSError:
            pass

    await db.delete(attachment)
    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not delete the attachment: {e}")
    return {"succeeded": True, "message": "Attachment removed"}