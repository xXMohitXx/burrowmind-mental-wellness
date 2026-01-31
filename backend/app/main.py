"""
BurrowMind Backend - FastAPI Application
AI-Assisted Mental Wellness Companion
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import auth, chat, resources, community, support
from app.core.config import settings

app = FastAPI(
    title="BurrowMind API",
    description="Backend API for BurrowMind Mental Wellness App",
    version="1.0.0",
    docs_url="/docs" if settings.DEBUG else None,
    redoc_url="/redoc" if settings.DEBUG else None,
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api/v1/auth", tags=["Authentication"])
app.include_router(chat.router, prefix="/api/v1/chat", tags=["AI Chat"])
app.include_router(resources.router, prefix="/api/v1/resources", tags=["Resources"])
app.include_router(community.router, prefix="/api/v1/community", tags=["Community"])
app.include_router(support.router, prefix="/api/v1/support", tags=["Support"])


@app.get("/")
async def root():
    return {
        "app": "BurrowMind API",
        "version": "1.0.0",
        "status": "running",
    }


@app.get("/health")
async def health_check():
    return {"status": "healthy"}
