# API Architecture & Database Integration

**Build scalable APIs with proper structure, SQLAlchemy, and Alembic**

## Overview

Production ML APIs require solid architecture: organized code structure, database integration, middleware for cross-cutting concerns, and proper configuration management. This guide covers building maintainable, scalable FastAPI applications.

## Project Structure

### Recommended Layout

```
ml-api/
├── src/
│   ├── __init__.py
│   ├── main.py                 # Application entry point
│   ├── config.py               # Configuration management
│   ├── database.py             # Database setup
│   ├── models/                 # SQLAlchemy models
│   │   ├── __init__.py
│   │   ├── prediction.py
│   │   └── model_version.py
│   ├── schemas/                # Pydantic schemas
│   │   ├── __init__.py
│   │   ├── prediction.py
│   │   └── model.py
│   ├── routes/                 # API routers
│   │   ├── __init__.py
│   │   ├── predictions.py
│   │   ├── models.py
│   │   └── health.py
│   ├── dependencies.py         # Shared dependencies
│   ├── middleware.py           # Custom middleware
│   └── ml/                     # ML logic
│       ├── __init__.py
│       ├── model_loader.py
│       └── inference.py
├── alembic/                    # Database migrations
│   ├── versions/
│   └── env.py
├── tests/
│   ├── test_api.py
│   └── test_models.py
├── alembic.ini                 # Alembic config
├── pyproject.toml              # Project dependencies
└── README.md
```

### Key Principles

1. **Separation of concerns** - Routes, models, schemas, business logic separated
2. **Single responsibility** - Each module has one clear purpose
3. **Dependency injection** - Shared resources managed centrally
4. **Type safety** - Pydantic for API, SQLAlchemy for database

## Application Setup

### main.py - Application Factory

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from .config import settings
from .database import engine, create_tables
from .routes import predictions, models, health
from .middleware import LoggingMiddleware, RequestIDMiddleware

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan: startup and shutdown."""
    # Startup
    print("Starting up...")
    await create_tables()
    # Load ML models, initialize resources
    yield
    # Shutdown
    print("Shutting down...")
    await engine.dispose()

def create_app() -> FastAPI:
    """Create FastAPI application."""
    app = FastAPI(
        title=settings.APP_NAME,
        version=settings.VERSION,
        description="Production ML API",
        lifespan=lifespan
    )

    # CORS middleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Custom middleware
    app.add_middleware(RequestIDMiddleware)
    app.add_middleware(LoggingMiddleware)

    # Include routers
    app.include_router(
        health.router,
        prefix="/health",
        tags=["health"]
    )
    app.include_router(
        predictions.router,
        prefix="/api/v1/predictions",
        tags=["predictions"]
    )
    app.include_router(
        models.router,
        prefix="/api/v1/models",
        tags=["models"]
    )

    return app

app = create_app()
```

## Configuration Management

### config.py - Settings with Pydantic

```python
from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional

class Settings(BaseSettings):
    """Application settings."""
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True
    )

    # App settings
    APP_NAME: str = "ML API"
    VERSION: str = "1.0.0"
    DEBUG: bool = False

    # Database
    DATABASE_URL: str = "postgresql+asyncpg://user:pass@localhost/mldb"
    DB_POOL_SIZE: int = 10
    DB_MAX_OVERFLOW: int = 20

    # CORS
    CORS_ORIGINS: list[str] = ["http://localhost:3000"]

    # ML Models
    MODEL_PATH: str = "models/"
    MODEL_CACHE_SIZE: int = 3

    # Authentication
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # Logging
    LOG_LEVEL: str = "INFO"

settings = Settings()
```

### .env File

```bash
# Database
DATABASE_URL=postgresql+asyncpg://mluser:password@localhost:5432/mldb

# Security
SECRET_KEY=your-secret-key-change-in-production

# App
DEBUG=false
LOG_LEVEL=INFO

# CORS
CORS_ORIGINS=["http://localhost:3000","https://app.example.com"]
```

## SQLAlchemy 2.0 Setup

### database.py - Async Database Setup

```python
from sqlalchemy.ext.asyncio import (
    create_async_engine,
    async_sessionmaker,
    AsyncSession,
    AsyncEngine
)
from sqlalchemy.orm import DeclarativeBase
from typing import AsyncGenerator

from .config import settings

# Create async engine
engine: AsyncEngine = create_async_engine(
    settings.DATABASE_URL,
    echo=settings.DEBUG,
    pool_size=settings.DB_POOL_SIZE,
    max_overflow=settings.DB_MAX_OVERFLOW,
    pool_pre_ping=True,  # Verify connections before using
)

# Session factory
AsyncSessionLocal = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)

# Base class for models
class Base(DeclarativeBase):
    """Base class for all models."""
    pass

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """
    Dependency for database sessions.

    Usage:
        @app.get("/items")
        async def get_items(db: AsyncSession = Depends(get_db)):
            ...
    """
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()

async def create_tables():
    """Create all tables (development only)."""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
```

## Database Models

### models/prediction.py - SQLAlchemy Models

```python
from sqlalchemy import String, Integer, Float, DateTime, JSON, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from typing import Optional

from ..database import Base

class ModelVersion(Base):
    """Model version tracking."""
    __tablename__ = "model_versions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(100), index=True)
    version: Mapped[str] = mapped_column(String(50))
    framework: Mapped[str] = mapped_column(String(50))
    metrics: Mapped[dict] = mapped_column(JSON, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow
    )
    is_active: Mapped[bool] = mapped_column(default=True)

    # Relationship
    predictions: Mapped[list["Prediction"]] = relationship(
        back_populates="model"
    )

class Prediction(Base):
    """Prediction records."""
    __tablename__ = "predictions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    model_id: Mapped[int] = mapped_column(
        Integer,
        ForeignKey("model_versions.id"),
        index=True
    )
    input_data: Mapped[dict] = mapped_column(JSON)
    prediction: Mapped[float] = mapped_column(Float)
    confidence: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    metadata: Mapped[Optional[dict]] = mapped_column(JSON, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        index=True
    )

    # Relationship
    model: Mapped["ModelVersion"] = relationship(back_populates="predictions")

    def __repr__(self) -> str:
        return f"<Prediction(id={self.id}, prediction={self.prediction})>"
```

### SQLAlchemy 2.0 Key Features

- **Mapped types** - Type-safe column definitions
- **Async support** - Native async/await operations
- **Relationships** - Type-safe relationships with generics
- **Declarative syntax** - Clean, modern model definitions

## Pydantic Schemas

### schemas/prediction.py - API Schemas

```python
from pydantic import BaseModel, Field, ConfigDict
from datetime import datetime
from typing import Optional

class PredictionInput(BaseModel):
    """Input for creating prediction."""
    model_id: int = Field(description="Model version ID")
    input_data: dict = Field(description="Input features")

class PredictionOutput(BaseModel):
    """Prediction response."""
    model_config = ConfigDict(from_attributes=True)

    id: int
    model_id: int
    prediction: float
    confidence: Optional[float] = None
    created_at: datetime

class ModelVersionCreate(BaseModel):
    """Create model version."""
    name: str = Field(max_length=100)
    version: str = Field(max_length=50)
    framework: str = Field(max_length=50)
    metrics: Optional[dict] = None

class ModelVersionOutput(BaseModel):
    """Model version response."""
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    version: str
    framework: str
    metrics: Optional[dict]
    created_at: datetime
    is_active: bool
```

**Key differences from SQLAlchemy models:**
- Pydantic for API validation and serialization
- SQLAlchemy for database persistence
- Use `from_attributes=True` to create from ORM models

## API Routers

### routes/predictions.py - Prediction Endpoints

```python
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Annotated

from ..database import get_db
from ..models.prediction import Prediction, ModelVersion
from ..schemas.prediction import PredictionInput, PredictionOutput

router = APIRouter()

@router.post("/", response_model=PredictionOutput, status_code=status.HTTP_201_CREATED)
async def create_prediction(
    data: PredictionInput,
    db: Annotated[AsyncSession, Depends(get_db)]
) -> PredictionOutput:
    """Create new prediction."""
    # Verify model exists
    stmt = select(ModelVersion).where(
        ModelVersion.id == data.model_id,
        ModelVersion.is_active == True
    )
    result = await db.execute(stmt)
    model = result.scalar_one_or_none()

    if not model:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Model {data.model_id} not found or inactive"
        )

    # Make prediction (simplified)
    prediction_value = sum(data.input_data.get("features", [0])) / 10
    confidence = 0.95

    # Save to database
    prediction = Prediction(
        model_id=data.model_id,
        input_data=data.input_data,
        prediction=prediction_value,
        confidence=confidence
    )

    db.add(prediction)
    await db.commit()
    await db.refresh(prediction)

    return PredictionOutput.model_validate(prediction)

@router.get("/{prediction_id}", response_model=PredictionOutput)
async def get_prediction(
    prediction_id: int,
    db: Annotated[AsyncSession, Depends(get_db)]
) -> PredictionOutput:
    """Get prediction by ID."""
    stmt = select(Prediction).where(Prediction.id == prediction_id)
    result = await db.execute(stmt)
    prediction = result.scalar_one_or_none()

    if not prediction:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Prediction {prediction_id} not found"
        )

    return PredictionOutput.model_validate(prediction)

@router.get("/", response_model=list[PredictionOutput])
async def list_predictions(
    skip: int = 0,
    limit: int = 100,
    model_id: Optional[int] = None,
    db: Annotated[AsyncSession, Depends(get_db)]
) -> list[PredictionOutput]:
    """List predictions with pagination."""
    stmt = select(Prediction).offset(skip).limit(limit)

    if model_id:
        stmt = stmt.where(Prediction.model_id == model_id)

    result = await db.execute(stmt)
    predictions = result.scalars().all()

    return [PredictionOutput.model_validate(p) for p in predictions]
```

### routes/models.py - Model Management

```python
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Annotated

from ..database import get_db
from ..models.prediction import ModelVersion
from ..schemas.prediction import ModelVersionCreate, ModelVersionOutput

router = APIRouter()

@router.post("/", response_model=ModelVersionOutput, status_code=status.HTTP_201_CREATED)
async def create_model(
    data: ModelVersionCreate,
    db: Annotated[AsyncSession, Depends(get_db)]
) -> ModelVersionOutput:
    """Register new model version."""
    model = ModelVersion(**data.model_dump())

    db.add(model)
    await db.commit()
    await db.refresh(model)

    return ModelVersionOutput.model_validate(model)

@router.get("/{model_id}", response_model=ModelVersionOutput)
async def get_model(
    model_id: int,
    db: Annotated[AsyncSession, Depends(get_db)]
) -> ModelVersionOutput:
    """Get model by ID."""
    stmt = select(ModelVersion).where(ModelVersion.id == model_id)
    result = await db.execute(stmt)
    model = result.scalar_one_or_none()

    if not model:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Model {model_id} not found"
        )

    return ModelVersionOutput.model_validate(model)

@router.get("/", response_model=list[ModelVersionOutput])
async def list_models(
    skip: int = 0,
    limit: int = 100,
    active_only: bool = True,
    db: Annotated[AsyncSession, Depends(get_db)]
) -> list[ModelVersionOutput]:
    """List model versions."""
    stmt = select(ModelVersion).offset(skip).limit(limit)

    if active_only:
        stmt = stmt.where(ModelVersion.is_active == True)

    result = await db.execute(stmt)
    models = result.scalars().all()

    return [ModelVersionOutput.model_validate(m) for m in models]
```

## Alembic Database Migrations

### Setup Alembic

```bash
# Initialize Alembic
alembic init alembic

# Configure alembic.ini
# Edit: sqlalchemy.url = your_database_url
```

### alembic/env.py - Configure for Async

```python
from logging.config import fileConfig
from sqlalchemy import pool
from sqlalchemy.engine import Connection
from sqlalchemy.ext.asyncio import async_engine_from_config
from alembic import context
import asyncio

from src.database import Base
from src.config import settings

# Import all models for autogenerate
from src.models.prediction import ModelVersion, Prediction

# Alembic Config
config = context.config

# Override sqlalchemy.url from settings
config.set_main_option("sqlalchemy.url", settings.DATABASE_URL)

# Interpret the config file for Python logging
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata

def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()

def do_run_migrations(connection: Connection) -> None:
    """Run migrations with connection."""
    context.configure(connection=connection, target_metadata=target_metadata)

    with context.begin_transaction():
        context.run_migrations()

async def run_async_migrations() -> None:
    """Run migrations in async mode."""
    connectable = async_engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)

    await connectable.dispose()

def run_migrations_online() -> None:
    """Run migrations in 'online' mode."""
    asyncio.run(run_async_migrations())

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
```

### Creating Migrations

```bash
# Create migration automatically
alembic revision --autogenerate -m "Create predictions and model_versions tables"

# Review migration file in alembic/versions/

# Apply migration
alembic upgrade head

# Rollback one version
alembic downgrade -1

# View current version
alembic current

# View migration history
alembic history
```

### Example Migration

```python
"""Create predictions and model_versions tables

Revision ID: abc123
Revises:
Create Date: 2024-01-15 10:00:00.000000
"""
from alembic import op
import sqlalchemy as sa

revision = 'abc123'
down_revision = None
branch_labels = None
depends_on = None

def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        'model_versions',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('version', sa.String(length=50), nullable=False),
        sa.Column('framework', sa.String(length=50), nullable=False),
        sa.Column('metrics', sa.JSON(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.Column('is_active', sa.Boolean(), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_model_versions_id', 'model_versions', ['id'])
    op.create_index('ix_model_versions_name', 'model_versions', ['name'])

    op.create_table(
        'predictions',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('model_id', sa.Integer(), nullable=False),
        sa.Column('input_data', sa.JSON(), nullable=False),
        sa.Column('prediction', sa.Float(), nullable=False),
        sa.Column('confidence', sa.Float(), nullable=True),
        sa.Column('metadata', sa.JSON(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(['model_id'], ['model_versions.id']),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_predictions_id', 'predictions', ['id'])
    op.create_index('ix_predictions_model_id', 'predictions', ['model_id'])

def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index('ix_predictions_model_id', table_name='predictions')
    op.drop_index('ix_predictions_id', table_name='predictions')
    op.drop_table('predictions')

    op.drop_index('ix_model_versions_name', table_name='model_versions')
    op.drop_index('ix_model_versions_id', table_name='model_versions')
    op.drop_table('model_versions')
```

## Middleware

### middleware.py - Custom Middleware

```python
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
import time
import uuid
import logging

logger = logging.getLogger(__name__)

class RequestIDMiddleware(BaseHTTPMiddleware):
    """Add unique request ID to each request."""

    async def dispatch(self, request: Request, call_next):
        request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
        request.state.request_id = request_id

        response = await call_next(request)
        response.headers["X-Request-ID"] = request_id

        return response

class LoggingMiddleware(BaseHTTPMiddleware):
    """Log all requests."""

    async def dispatch(self, request: Request, call_next):
        start_time = time.time()

        # Log request
        logger.info(
            f"Request: {request.method} {request.url.path}",
            extra={
                "request_id": getattr(request.state, "request_id", None),
                "method": request.method,
                "path": request.url.path
            }
        )

        response = await call_next(request)

        # Log response
        duration = time.time() - start_time
        logger.info(
            f"Response: {response.status_code} ({duration:.3f}s)",
            extra={
                "request_id": getattr(request.state, "request_id", None),
                "status_code": response.status_code,
                "duration": duration
            }
        )

        return response
```

## Advanced Database Patterns

### Transactions

```python
from sqlalchemy.ext.asyncio import AsyncSession

async def create_model_with_predictions(
    model_data: dict,
    predictions_data: list[dict],
    db: AsyncSession
):
    """Atomic transaction for model + predictions."""
    async with db.begin():
        # Create model
        model = ModelVersion(**model_data)
        db.add(model)
        await db.flush()  # Get model.id

        # Create predictions
        for pred_data in predictions_data:
            prediction = Prediction(
                model_id=model.id,
                **pred_data
            )
            db.add(prediction)

        # Commit handled by context manager
```

### Connection Pooling

```python
# In database.py
engine = create_async_engine(
    settings.DATABASE_URL,
    pool_size=20,              # Connections to keep open
    max_overflow=10,           # Additional connections when needed
    pool_timeout=30,           # Wait time for connection
    pool_recycle=3600,         # Recycle connections after 1 hour
    pool_pre_ping=True,        # Check connection before use
)
```

### Query Optimization

```python
from sqlalchemy import select
from sqlalchemy.orm import selectinload

# Eager loading to prevent N+1 queries
async def get_model_with_predictions(model_id: int, db: AsyncSession):
    """Load model with predictions in one query."""
    stmt = (
        select(ModelVersion)
        .options(selectinload(ModelVersion.predictions))
        .where(ModelVersion.id == model_id)
    )
    result = await db.execute(stmt)
    return result.scalar_one_or_none()
```

## Best Practices

1. **Use async throughout** - SQLAlchemy async, async dependencies
2. **Separate schemas from models** - Pydantic for API, SQLAlchemy for DB
3. **Use Alembic for migrations** - Never manual schema changes
4. **Connection pooling** - Configure for your workload
5. **Index frequently queried columns** - Improve query performance
6. **Use transactions** - Ensure data consistency
7. **Lazy load relationships carefully** - Prevent N+1 queries
8. **Environment-based config** - Different settings per environment

## Next Steps

Continue to [ML Model Serving & Streaming](./04-ml-model-serving.md) to learn how to serve models with streaming capabilities.

## Resources

- [SQLAlchemy 2.0 Documentation](https://docs.sqlalchemy.org/en/20/)
- [Alembic Tutorial](https://alembic.sqlalchemy.org/en/latest/tutorial.html)
- [FastAPI with Databases](https://fastapi.tiangolo.com/tutorial/sql-databases/)
- [Pydantic Settings](https://docs.pydantic.dev/latest/concepts/pydantic_settings/)
