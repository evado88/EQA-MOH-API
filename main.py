from fastapi import FastAPI
from database import engine, Base
from contextlib import asynccontextmanager
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from helpers.http_client import init_client, close_client
from routes import auth_routes
#relationships
from routes import provider_routes
from routes import ptcycle_routes
from routes import user_routes
from routes import stage_routes
from routes import status_routes
from routes import audit_routes
from routes import attachment_routes
from routes import province_routes
from routes import district_routes
from routes import ptcyclestatus_routes
from routes import scheme_routes
from routes import labtype_routes
from routes import laboratory_routes
from routes import service_routes
from routes import method_routes
from routes import methodsample_routes
from routes import tbxpertultraresult_routes
from routes import tbxpertxdrresult_routes
from routes import hivvlresult_routes
from routes import hiveidresult_routes
from routes import bacteriologyresult_routes
from routes import announcement_routes
from routes import evaluation_routes
from routes import target_routes
from routes import breakpoint_routes
from routes import report_routes
from routes import enrollment_routes
from routes import applications_routes
from routes import role_routes
from routes import import_routes
from routes import dashboard_routes
from routes import facility_routes
from routes import registration_routes
from routes import result_submission_routes
from routes import samplereceipt_routes
from routes import shipmentreceipt_routes
from routes import result_navigation_routes

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup logic
    print("Application starting up new...")
    yield
    # Shutdown logic
    print("Application shutting down new...")

# allowed browser origins come from the environment so the deployed server can
# be set without a code change. CORS_ORIGINS is a comma-separated list; the
# default keeps local development working. Set it to the public frontend URL on
# the server, e.g. CORS_ORIGINS=https://eqa.example.org
from helpers.env import env as _env, env_bool as _env_bool
origins = [
    o.strip()
    for o in _env(
        "CORS_ORIGINS",
        "http://localhost,http://localhost:5173,http://127.0.0.1:5173",
    ).split(",")
    if o.strip()
]


app = FastAPI(title="App Routes [FastAPI/PostgreSQL]")

app.mount("/static", StaticFiles(directory="uploads"), name="static")

#COR
app.add_middleware(
        CORSMiddleware,
        allow_origins=origins,
        allow_credentials=True,
        allow_methods=["*"],  # Allows all HTTP methods
        allow_headers=["*"],  # Allows all headers
    )

# include routers
app.include_router(auth_routes.router)
app.include_router(provider_routes.router)
app.include_router(ptcycle_routes.router)
app.include_router(user_routes.router)
app.include_router(stage_routes.router)
app.include_router(status_routes.router)
app.include_router(audit_routes.router)
app.include_router(attachment_routes.router)
app.include_router(province_routes.router)
app.include_router(district_routes.router)
app.include_router(ptcyclestatus_routes.router)
app.include_router(scheme_routes.router)
app.include_router(labtype_routes.router)
app.include_router(laboratory_routes.router)
app.include_router(service_routes.router)
app.include_router(method_routes.router)
app.include_router(methodsample_routes.router)
app.include_router(tbxpertultraresult_routes.router)
app.include_router(tbxpertxdrresult_routes.router)
app.include_router(hivvlresult_routes.router)
app.include_router(hiveidresult_routes.router)
app.include_router(bacteriologyresult_routes.router)
app.include_router(announcement_routes.router)
app.include_router(evaluation_routes.router)
app.include_router(target_routes.router)
app.include_router(breakpoint_routes.router)
app.include_router(report_routes.router)
app.include_router(enrollment_routes.router)
app.include_router(applications_routes.router)
app.include_router(role_routes.router)
app.include_router(import_routes.router)
app.include_router(dashboard_routes.router)
app.include_router(facility_routes.router)
app.include_router(registration_routes.router)
app.include_router(result_submission_routes.router)
app.include_router(samplereceipt_routes.router)
app.include_router(shipmentreceipt_routes.router)
app.include_router(result_navigation_routes.router)


# create tables at startup

async def _daily_pt_cycle_job():
    """Runs once a day: sends due PT cycle reminders and refreshes cached
    statuses. Opens its own session since it runs outside a request."""
    from database import AsyncSessionLocal
    from routes.ptcycle_routes import run_pt_cycle_reminders
    try:
        async with AsyncSessionLocal() as db:
            result = await run_pt_cycle_reminders(db)
            print(f"[scheduler] pt-cycle job: {result.reminders_sent} reminder(s) sent")
    except Exception as e:
        print(f"[scheduler] pt-cycle job failed: {e}")


@app.on_event("startup")
async def startup():
    await init_client()
    async with engine.begin() as conn:
        print("Application starting up old...")
        await conn.run_sync(Base.metadata.create_all)

    # daily in-app scheduler for PT cycle reminders / status refresh.
    # Gated by RUN_SCHEDULER so that when the API is run with several uvicorn
    # workers the job does not fire once per worker (which would send duplicate
    # reminder emails): set RUN_SCHEDULER=0 on the multi-worker web service and
    # run exactly one process with RUN_SCHEDULER=1. Default on (single worker).
    if _env_bool("RUN_SCHEDULER", True):
        from apscheduler.schedulers.asyncio import AsyncIOScheduler
        scheduler = AsyncIOScheduler(timezone=_env("CURRENT_TIME_ZONE", "Africa/Lusaka"))
        scheduler.add_job(
            _daily_pt_cycle_job, "cron", hour=7, minute=0,
            id="pt_cycle_reminders", replace_existing=True,
        )
        scheduler.start()
        app.state.scheduler = scheduler
        print("[scheduler] pt-cycle reminder job scheduled (07:00 daily)")
    else:
        print("[scheduler] disabled on this process (RUN_SCHEDULER=0)")

@app.on_event("shutdown")
async def shutdown_event():
    await close_client()
    scheduler = getattr(app.state, "scheduler", None)
    if scheduler:
        scheduler.shutdown(wait=False)
    
def get_httpsx_client():
    return app.state.client