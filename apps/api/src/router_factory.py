from __future__ import annotations

from typing import Any, Callable, Sequence, Tuple, Type
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from sqlalchemy import select, update, delete, exc

from .database import get_db
from .schemas import make_pydantic_pair

def build_router(sa_cls) -> APIRouter:
    """Generate an APIRouter with full CRUD for *sa_cls*.

    *Views* (VW*, V*) are treated as read‑only (GET only).
    Composite‑key tables get list/filtered + POST; single‑PK tables add /{id} paths.
    """
    router = APIRouter(tags=[sa_cls.__tablename__], prefix=f"/{sa_cls.__tablename__}")

    ModelIn, ModelOut = make_pydantic_pair(sa_cls)
    pk_cols = [c for c in sa_cls.__table__.columns if c.primary_key]
    read_only = sa_cls.__tablename__.startswith(("v_", "vw_")) or sa_cls.__name__.startswith("V")

    # ---- GET many (with basic paging) ----------------------------------------
    @router.get("/", response_model=list[ModelOut])
    def list_items(
        db: Session = Depends(get_db),
        skip: int = Query(0, ge=0),
        limit: int = Query(100, le=500),
    ):
        return db.scalars(select(sa_cls).offset(skip).limit(limit)).all()

    # ---- GET by PK (only if single‑key) -------------------------------------
    if len(pk_cols) == 1:
        pk_name = pk_cols[0].name
        pk_type = pk_cols[0].type.python_type

        @router.get("/{item_id}", response_model=ModelOut)
        def get_item(item_id: pk_type, db: Session = Depends(get_db)):  # type: ignore
            obj = db.get(sa_cls, item_id)
            if not obj:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
            return obj

    # ---- Early exit for read‑only objects -----------------------------------
    if read_only:
        return router

    # ---- POST create --------------------------------------------------------
    @router.post("/", response_model=ModelOut, status_code=status.HTTP_201_CREATED)
    def create(item: ModelIn, db: Session = Depends(get_db)):
        obj = sa_cls(**item.model_dump(exclude_unset=True))
        db.add(obj)
        db.flush()           # allows PK to be populated
        db.refresh(obj)
        return obj

    # ---- PUT (full replacement) – single‑PK only ---------------------------
    if len(pk_cols) == 1:
        pk_name = pk_cols[0].name
        pk_type = pk_cols[0].type.python_type

        @router.put("/{item_id}", response_model=ModelOut)
        def update_item(item_id: pk_type, item: ModelIn, db: Session = Depends(get_db)):  # type: ignore
            obj = db.get(sa_cls, item_id)
            if not obj:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
            for k, v in item.model_dump(exclude_unset=True).items():
                setattr(obj, k, v)
            db.add(obj)
            db.flush()
            db.refresh(obj)
            return obj

        @router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
        def delete_item(item_id: pk_type, db: Session = Depends(get_db)):  # type: ignore
            if not db.get(sa_cls, item_id):
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
            db.execute(delete(sa_cls).where(pk_cols[0] == item_id))
            # 204 ‑ no body
    else:
        # For composite keys: allow delete via JSON body
        @router.delete("/", status_code=status.HTTP_204_NO_CONTENT)
        def delete_composite(item: ModelIn, db: Session = Depends(get_db)):
            filt = [pk_cols[i] == getattr(item, pk_cols[i].name) for i in range(len(pk_cols))]
            db.execute(delete(sa_cls).where(*filt))

    return router
