from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base
from helpers.env import env, env_bool

# connection string and SQL echo come from the environment (.env in dev); the
# default keeps a local Postgres working out of the box
DATABASE_URL = env(
    "DATABASE_URL", "postgresql+asyncpg://postgres:Abc123@localhost:5432/moheqa"
)

engine = create_async_engine(DATABASE_URL, echo=env_bool("DB_ECHO", True))

AsyncSessionLocal = sessionmaker(
    bind=engine, class_=AsyncSession, expire_on_commit=False
)

Base = declarative_base()

# Dependency
async def get_db():
    async with AsyncSessionLocal() as session:
        yield session