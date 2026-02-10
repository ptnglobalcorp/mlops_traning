# FastAPI for MLOps

**Build production-ready ML APIs with FastAPI**

## Overview

This module teaches you to build high-performance, production-grade ML APIs using FastAPI. Designed for developers with advanced Python knowledge, this course focuses on real-world patterns for serving machine learning models at scale.

## Learning Objectives

After completing this module, you will:

- Build type-safe REST APIs with automatic documentation
- Handle complex request/response patterns for ML workloads
- Design scalable API architectures with proper database integration
- Serve ML models with streaming and async inference
- Write comprehensive API tests
- Deploy FastAPI applications to production

## Prerequisites

You should be comfortable with:

- Python typing and type hints
- Pydantic models and validation
- Async/await and asyncio
- Decorators and dependency injection concepts
- Basic HTTP and REST API concepts

**Required from Module 02:**

- Python Typing
- Pydantic
- Async/Await

## Module Structure

### 1. FastAPI Fundamentals

**Document:** [FastAPI Fundamentals](./01-fastapi-fundamentals.md)

Learn the core concepts:

- Why FastAPI is ideal for MLOps
- Request/response models with Pydantic
- Path operations and routing
- Dependency injection system
- Request validation and error handling
- Automatic API documentation

**Key Skills:** Building basic CRUD endpoints, handling validation errors, using dependency injection.

### 2. Advanced Request Handling

**Document:** [Advanced Request Handling](./02-advanced-requests.md)

Master complex request patterns:

- Query parameters and path parameters
- Request body validation
- File uploads for ML models and datasets
- Form data and multipart requests
- Headers, cookies, and custom responses
- Background tasks for async processing

**Key Skills:** Handling file uploads, processing background tasks, managing complex request types.

### 3. API Architecture & Database Integration

**Document:** [API Architecture & Database Integration](./03-api-architecture.md)

Build scalable API architectures:

- Project structure for ML APIs
- Router organization and modularity
- Middleware (CORS, authentication, logging)
- Configuration management
- SQLAlchemy 2.0 async ORM
- Database models and relationships
- Alembic migrations
- Connection pooling and session management

**Key Skills:** Structuring large APIs, database integration, managing migrations, implementing middleware.

### 4. ML Model Serving & Streaming

**Document:** [ML Model Serving & Streaming](./04-ml-model-serving.md)

Serve ML models effectively:

- Loading and caching models at startup
- Building prediction endpoints
- Batch prediction APIs
- Model versioning strategies
- Async inference patterns
- Server-Sent Events (SSE) for streaming
- WebSocket for real-time predictions
- Streaming LLM token-by-token responses

**Key Skills:** Model lifecycle management, streaming responses, real-time predictions.

### 5. Testing FastAPI

**Document:** [Testing FastAPI](./05-testing.md)

Write comprehensive tests:

- TestClient for endpoint testing
- Testing async endpoints
- Dependency overrides and mocking
- Database testing with fixtures
- Integration test patterns
- Load testing and performance benchmarks

**Key Skills:** Writing maintainable tests, mocking dependencies, performance testing.

### 6. Production Deployment

**Document:** [Production Deployment](./06-production.md)

Deploy to production:

- Uvicorn and Gunicorn configuration
- Docker containerization
- Health checks and readiness probes
- Structured logging and observability
- Performance optimization
- Security best practices

**Key Skills:** Production deployment, monitoring, optimization, security hardening.

## Common Patterns

### Pattern 1: Dependency Injection for Models

```python
from fastapi import Depends
from typing import Annotated

async def get_model() -> MLModel:
    """Load model as dependency."""
    if not hasattr(get_model, "model"):
        get_model.model = await load_model()
    return get_model.model

@app.post("/predict")
async def predict(
    data: PredictionInput,
    model: Annotated[MLModel, Depends(get_model)]
) -> PredictionOutput:
    result = await model.predict(data)
    return PredictionOutput(**result)
```

### Pattern 2: Database Session Management

```python
from sqlalchemy.ext.asyncio import AsyncSession

async def get_db() -> AsyncSession:
    """Provide database session."""
    async with SessionLocal() as session:
        yield session

@app.post("/predictions")
async def save_prediction(
    data: PredictionInput,
    db: Annotated[AsyncSession, Depends(get_db)]
):
    prediction = Prediction(**data.dict())
    db.add(prediction)
    await db.commit()
```

### Pattern 3: Streaming Responses

```python
from fastapi.responses import StreamingResponse

async def generate_tokens(text: str):
    """Stream LLM tokens."""
    async for token in model.generate_stream(text):
        yield f"data: {token}\n\n"

@app.post("/generate")
async def stream_generation(prompt: str):
    return StreamingResponse(
        generate_tokens(prompt),
        media_type="text/event-stream"
    )
```

## Tools and Libraries

Install the FastAPI ecosystem:

```bash
# Core FastAPI
uv add fastapi uvicorn[standard]

# Database
uv add sqlalchemy[asyncio] alembic asyncpg

# Validation and utilities
uv add pydantic pydantic-settings python-multipart

# Development tools
uv add --dev pytest pytest-asyncio httpx

# Optional: Authentication
uv add python-jose[cryptography] passlib[bcrypt]

# Optional: Monitoring
uv add prometheus-fastapi-instrumentator
```

## Quick Start

Create your first FastAPI app:

```python
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="ML API")

class PredictionInput(BaseModel):
    features: list[float]

class PredictionOutput(BaseModel):
    prediction: float
    confidence: float

@app.post("/predict", response_model=PredictionOutput)
async def predict(data: PredictionInput) -> PredictionOutput:
    # Your ML logic here
    prediction = sum(data.features) / len(data.features)
    return PredictionOutput(prediction=prediction, confidence=0.95)
```

Run with:

```bash
uvicorn main:app --reload
```

Visit `http://localhost:8000/docs` for interactive API documentation.

## Development Workflow

1. **Setup project:**

   ```bash
   uv init ml-api
   cd ml-api
   uv add fastapi uvicorn[standard]
   ```

2. **Create app structure:**

   ```
   ml-api/
   ├── src/
   │   ├── main.py
   │   ├── models.py
   │   ├── routes/
   │   └── dependencies.py
   ├── tests/
   ├── alembic/
   └── pyproject.toml
   ```

3. **Run development server:**

   ```bash
   uvicorn src.main:app --reload
   ```

4. **Run tests:**

   ```bash
   pytest tests/
   ```

5. **Generate migrations:**
   ```bash
   alembic revision --autogenerate -m "Add predictions table"
   alembic upgrade head
   ```

## Troubleshooting

### Import Errors

If modules not found:

```bash
# Ensure you're in the project directory
cd ml-api

# Sync dependencies
uv sync

# Run with uv
uv run uvicorn src.main:app --reload
```

### Async Database Issues

Common async/await mistakes:

```python
# Wrong: Using sync methods
session.commit()

# Correct: Use async methods
await session.commit()
```

### CORS Errors

Enable CORS for frontend access:

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Performance Tips

1. **Use async everywhere** - FastAPI shines with async/await
2. **Enable response compression** - For large JSON responses
3. **Cache model predictions** - Redis or in-memory caching
4. **Connection pooling** - Configure SQLAlchemy pool size
5. **Background tasks** - For non-blocking operations

## Security Checklist

- [ ] Input validation with Pydantic
- [ ] Authentication and authorization
- [ ] HTTPS in production
- [ ] CORS configured properly
- [ ] Rate limiting enabled
- [ ] SQL injection prevention (use ORM)
- [ ] Environment variables for secrets
- [ ] Request size limits

## Next Steps

After completing this module:

1. **Build a project** - Create your own ML API
2. **Module 03** - CI/CD and deployment automation
3. **Advanced topics** - GraphQL, gRPC, service mesh
4. **Scale up** - Kubernetes deployment, load balancing

## Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [SQLAlchemy 2.0 Documentation](https://docs.sqlalchemy.org/)
- [Alembic Tutorial](https://alembic.sqlalchemy.org/en/latest/tutorial.html)
- [Uvicorn Deployment](https://www.uvicorn.org/deployment/)
- [Pydantic v2 Documentation](https://docs.pydantic.dev/)

## Community and Support

- **Questions**: Open an issue in the repository
- **Discussions**: Join the MLOps training community
- **Contributions**: Submit improvements via pull requests

---

**Ready to start?** Begin with [FastAPI Fundamentals](./01-fastapi-fundamentals.md) to build your first API.
