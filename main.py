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
from routes import evaluation_routes
from routes import report_routes
from routes import enrollment_routes
from routes import applications_routes
from routes import role_routes
from routes import import_routes
from routes import dashboard_routes

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup logic
    print("Application starting up new...")
    yield
    # Shutdown logic
    print("Application shutting down new...")

origins = [
        "http://localhost",
        "http://localhost:5173",
        "https://your-frontend-domain.com",
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
app.include_router(evaluation_routes.router)
app.include_router(report_routes.router)
app.include_router(enrollment_routes.router)
app.include_router(applications_routes.router)
app.include_router(role_routes.router)
app.include_router(import_routes.router)
app.include_router(dashboard_routes.router)


# create tables at startup

@app.on_event("startup")
async def startup():
    await init_client()
    async with engine.begin() as conn:
        print("Application starting up old...")
        await conn.run_sync(Base.metadata.create_all)
        
@app.on_event("shutdown")
async def shutdown_event():
    await close_client()
    
def get_httpsx_client():
    return app.state.client