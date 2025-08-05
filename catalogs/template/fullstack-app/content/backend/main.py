from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, DateTime, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from datetime import datetime
import os
import logging
import structlog
from dotenv import load_dotenv
from pydantic import BaseModel
from typing import Optional, List

# Load environment variables
load_dotenv()

# Configure structured logging
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
        structlog.processors.JSONRenderer()
    ],
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
    wrapper_class=structlog.stdlib.BoundLogger,
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger()

# Database setup
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://appuser:apppass@localhost:5432/appdb")
engine = create_engine(DATABASE_URL, echo=False)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Models
class HealthLog(Base):
    __tablename__ = "health_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    status = Column(String, default="healthy")
    timestamp = Column(DateTime, default=datetime.utcnow)
    endpoint = Column(String, nullable=True)
    response_time = Column(Integer, nullable=True)  # in milliseconds

class AppLog(Base):
    __tablename__ = "app_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    level = Column(String, nullable=False)
    message = Column(Text, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)
    component = Column(String, nullable=True)

# Pydantic models
class HealthResponse(BaseModel):
    status: str
    timestamp: str
    database: str
    service: str

class ServiceStatusResponse(BaseModel):
    service: str
    status: str
    recent_health_checks: int
    last_check: Optional[str] = None

class LogEntry(BaseModel):
    level: str
    message: str
    component: Optional[str] = None

# Create tables
try:
    Base.metadata.create_all(bind=engine)
    logger.info("Database tables created successfully")
except Exception as e:
    logger.error("Failed to create database tables", error=str(e))
    raise

# FastAPI app
app = FastAPI(
    title="${{ values.name | capitalize }} API",
    description="${{ values.description }}",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        # Add your production frontend URL here
        # "https://your-frontend-domain.com"
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

# Dependency to get database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Root endpoint
@app.get("/")
async def root():
    logger.info("Root endpoint accessed")
    return {
        "message": "Welcome to ${{ values.name | capitalize }} API",
        "description": "${{ values.description }}",
        "version": "1.0.0",
        "docs": "/docs",
        "health": "/health"
    }

# Health check endpoint
@app.get("/health", response_model=HealthResponse)
async def health_check(db: Session = Depends(get_db)):
    start_time = datetime.utcnow()
    
    try:
        # Test database connection
        db.execute("SELECT 1")
        
        # Calculate response time
        response_time = int((datetime.utcnow() - start_time).total_seconds() * 1000)
        
        # Log health check
        health_log = HealthLog(
            status="healthy",
            endpoint="/health",
            response_time=response_time
        )
        db.add(health_log)
        db.commit()
        
        logger.info("Health check successful", response_time=response_time)
        
        return HealthResponse(
            status="healthy",
            timestamp=datetime.utcnow().isoformat(),
            database="connected",
            service="${{ values.name }}"
        )
    except Exception as e:
        logger.error("Health check failed", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Health check failed: {str(e)}"
        )

# Service status endpoint
@app.get("/api/status", response_model=ServiceStatusResponse)
async def get_status(db: Session = Depends(get_db)):
    try:
        # Get recent health check logs
        recent_logs = db.query(HealthLog).order_by(HealthLog.timestamp.desc()).limit(10).all()
        
        response = ServiceStatusResponse(
            service="${{ values.name }}",
            status="running",
            recent_health_checks=len(recent_logs),
            last_check=recent_logs[0].timestamp.isoformat() if recent_logs else None
        )
        
        logger.info("Status endpoint accessed", 
                   health_checks=len(recent_logs),
                   last_check=response.last_check)
        
        return response
    except Exception as e:
        logger.error("Failed to get service status", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

# Logs endpoint
@app.get("/api/logs")
async def get_logs(limit: int = 50, level: Optional[str] = None, db: Session = Depends(get_db)):
    try:
        query = db.query(AppLog).order_by(AppLog.timestamp.desc())
        
        if level:
            query = query.filter(AppLog.level == level.upper())
            
        logs = query.limit(limit).all()
        
        return {
            "logs": [
                {
                    "id": log.id,
                    "level": log.level,
                    "message": log.message,
                    "timestamp": log.timestamp.isoformat(),
                    "component": log.component
                }
                for log in logs
            ],
            "total": len(logs),
            "filters": {"level": level, "limit": limit}
        }
    except Exception as e:
        logger.error("Failed to get logs", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

# Create log entry
@app.post("/api/logs")
async def create_log(log_entry: LogEntry, db: Session = Depends(get_db)):
    try:
        app_log = AppLog(
            level=log_entry.level.upper(),
            message=log_entry.message,
            component=log_entry.component
        )
        db.add(app_log)
        db.commit()
        db.refresh(app_log)
        
        logger.info("Log entry created", 
                   log_id=app_log.id,
                   level=log_entry.level,
                   component=log_entry.component)
        
        return {"message": "Log entry created", "id": app_log.id}
    except Exception as e:
        logger.error("Failed to create log entry", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

# Database info endpoint
@app.get("/api/database/info")
async def get_database_info(db: Session = Depends(get_db)):
    try:
        # Get table information
        health_count = db.query(HealthLog).count()
        logs_count = db.query(AppLog).count()
        
        # Get recent activity
        recent_health = db.query(HealthLog).order_by(HealthLog.timestamp.desc()).first()
        recent_log = db.query(AppLog).order_by(AppLog.timestamp.desc()).first()
        
        return {
            "database": "PostgreSQL",
            "tables": {
                "health_logs": health_count,
                "app_logs": logs_count
            },
            "recent_activity": {
                "last_health_check": recent_health.timestamp.isoformat() if recent_health else None,
                "last_log_entry": recent_log.timestamp.isoformat() if recent_log else None
            },
            "connection_status": "active"
        }
    except Exception as e:
        logger.error("Failed to get database info", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

# Startup event
@app.on_event("startup")
async def startup_event():
    logger.info("${{ values.name | capitalize }} API starting up", 
               version="1.0.0",
               environment=os.getenv("NODE_ENV", "development"))

# Shutdown event
@app.on_event("shutdown")
async def shutdown_event():
    logger.info("${{ values.name | capitalize }} API shutting down")

# Main execution
if __name__ == "__main__":
    import uvicorn
    
    port = int(os.getenv("PORT", 8000))
    host = os.getenv("HOST", "0.0.0.0")
    
    logger.info("Starting server", host=host, port=port)
    
    uvicorn.run(
        "main:app",
        host=host,
        port=port,
        reload=os.getenv("NODE_ENV") != "production",
        log_config=None  # Use our structured logging
    )