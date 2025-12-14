from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from src.cores.config import settings
from src.cores.database import create_db_and_tables
from src.cores.firebase_config import initialize_firebase
from src.controllers.auth_controller import router as auth_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events"""
    # Startup
    print("Starting up...")
    create_db_and_tables()
    print("Database tables created")

    try:
        initialize_firebase()
    except Exception as e:
        print(f"Warning: Firebase initialization failed: {e}")
        print("Firebase authentication will not be available")

    yield

    # Shutdown
    print("Shutting down...")


app = FastAPI(
    title=settings.APP_NAME,
    description="Jar Talk - Shared Journaling Application API",
    version="1.0.0",
    lifespan=lifespan
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth_router)


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Welcome to Jar Talk API",
        "version": "1.0.0",
        "docs": "/docs"
    }


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG
    )
