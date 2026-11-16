from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy.pool import NullPool
from helpers.env import env, env_bool

# connection string and SQL echo come from the environment (.env in dev); the
# default keeps a local Postgres working out of the box
DATABASE_URL = env(
    "DATABASE_URL", "postgresql+asyncpg://postgres:Abc123@localhost:5432/moheqa"
)

# Fork safety. Under a forking server (gunicorn with >1 worker or --preload) a
# pooled asyncpg connection opened in one process / event loop can be handed to
# a forked worker where its socket is already dead, surfacing as
# "asyncpg ... InterfaceError: connection is closed" on the first query.
#   * pool_pre_ping checks a connection is alive before use and transparently
#     replaces a dead one - the keep-pooling fix.
#   * DB_POOL=null disables pooling (a fresh connection per request): the most
#     fork-safe option, and negligible cost at this workload. Also the right
#     choice behind a transaction-mode pooler such as PgBouncer.
_engine_kwargs = dict(echo=env_bool("DB_ECHO", True))
if env("DB_POOL", "").strip().lower() in ("null", "nullpool", "none"):
    _engine_kwargs["poolclass"] = NullPool
else:
    _engine_kwargs["pool_pre_ping"] = True

engine = create_async_engine(DATABASE_URL, **_engine_kwargs)

AsyncSessionLocal = sessionmaker(
    bind=engine, class_=AsyncSession, expire_on_commit=False
)

Base = declarative_base()

# Dependency
async def get_db():
    async with AsyncSessionLocal() as session:
        yield session