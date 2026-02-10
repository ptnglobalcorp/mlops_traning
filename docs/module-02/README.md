# Module 2: Advanced Python & FastAPI

**Master Python fundamentals and build production ML APIs**

## Overview

Module 2 provides the Python foundation and API development skills essential for MLOps engineering. You'll master advanced Python concepts, then apply them to build production-ready ML APIs with FastAPI.

## Learning Objectives

By the end of this module, you will be able to:

- Write type-safe Python code with comprehensive type hints
- Manage Python projects efficiently with modern tooling (uv)
- Validate data robustly with Pydantic models
- Apply decorator patterns for cleaner, more maintainable code
- Build concurrent applications with async/await
- Create production-ready REST APIs with FastAPI
- Integrate databases with SQLAlchemy and Alembic
- Serve ML models with streaming capabilities
- Test APIs comprehensively
- Deploy APIs to production

## Module Structure

This module consists of two major sections:

### Part A: Advanced Python Foundations

Build the Python skills needed for modern MLOps development

### Part B: FastAPI for ML APIs

Apply Python skills to build production ML serving infrastructure

## Prerequisites

- **Python Experience**: Intermediate Python (functions, classes, modules)
- **Command Line**: Comfortable with terminal/command prompt
- **Development Environment**: Python 3.10+ installed
- **Module 1**: Git fundamentals (helpful for collaboration)

## Study Path

### Part A: Advanced Python

**Core Concepts:**

1. **[Python Typing](./advanced-python/01-python-typing.md)**
   - Type annotations for better code quality
   - Generic types and protocols
   - Type checker integration (mypy/pyright)
   - **Why**: Catch bugs early, improve IDE support

2. **[Project Management with uv](./advanced-python/02-project-management-uv.md)**
   - Modern Python project setup
   - Dependency management and lock files
   - Development vs production dependencies
   - **Why**: 10-100x faster than pip, reproducible builds

3. **[Data Validation with Pydantic](./advanced-python/03-data-validation-pydantic.md)**
   - Robust data models with automatic validation
   - Custom validators and constraints
   - JSON serialization/deserialization
   - **Why**: Powers FastAPI, prevents runtime errors

4. **[Decorators](./advanced-python/04-decorators.md)**
   - Function and class decorators
   - Practical patterns (logging, caching, retry)
   - Decorator composition
   - **Why**: Reduce boilerplate, separation of concerns

5. **[Async/Await](./advanced-python/05-async-await.md)**
   - Asynchronous programming fundamentals
   - Concurrent task execution
   - Async HTTP and file I/O
   - **Why**: Essential for high-performance APIs

**Study Guide:**

- **Week 1**: Types and Tools (Typing, uv)
- **Week 2**: Validation and Patterns (Pydantic, Decorators)
- **Week 3**: Async Programming (async/await)

**[➜ Start with Advanced Python](./advanced-python/README.md)**

---

### Part B: FastAPI for ML APIs

**Building Production APIs:**

1. **[FastAPI Fundamentals](./fastapi/01-fastapi-fundamentals.md)**
   - Core FastAPI concepts and patterns
   - Request/response models with Pydantic
   - Dependency injection system
   - Automatic API documentation

2. **[Advanced Request Handling](./fastapi/02-advanced-requests.md)**
   - File uploads for ML models and datasets
   - Form data and multipart requests
   - Background tasks for async processing
   - Headers, cookies, and custom responses

3. **[API Architecture & Database Integration](./fastapi/03-api-architecture.md)**
   - Scalable project structure
   - SQLAlchemy 2.0 async ORM
   - Alembic database migrations
   - Middleware and configuration management

4. **[ML Model Serving & Streaming](./fastapi/04-ml-model-serving.md)**
   - Model loading and caching strategies
   - Batch and streaming predictions
   - Server-Sent Events (SSE) for progress updates
   - WebSocket for real-time predictions
   - Streaming LLM responses token-by-token

5. **[Testing FastAPI](./fastapi/05-testing.md)**
   - Comprehensive API testing with pytest
   - Testing async endpoints
   - Database testing and fixtures
   - Mocking dependencies
   - Integration and load testing

6. **[Production Deployment](./fastapi/06-production.md)**
   - Uvicorn and Gunicorn configuration
   - Docker containerization
   - Health checks and monitoring
   - Security best practices
   - Performance optimization

**Study Guide:**

- **Week 4**: Core FastAPI (Fundamentals, Requests)
- **Week 5**: Architecture & Serving (Database, ML Models, Streaming)
- **Week 6**: Testing & Deployment (Tests, Production)

**[➜ Start with FastAPI](./fastapi/README.md)**

---

## Common Patterns

### Pattern 1: Type-Safe Configuration

```python
from pydantic import BaseModel, Field

class AppConfig(BaseModel):
    """Application configuration with validation."""
    database_url: str
    api_key: str
    max_workers: int = Field(ge=1, le=100)
    debug: bool = False

config = AppConfig(**env_vars)
```

### Pattern 2: Async Model Serving

```python
from fastapi import FastAPI, Depends
from typing import Annotated

app = FastAPI()

async def get_model():
    """Load model as dependency."""
    return await load_model_async()

@app.post("/predict")
async def predict(
    data: PredictionInput,
    model: Annotated[Model, Depends(get_model)]
):
    """Async prediction endpoint."""
    result = await model.predict_async(data.features)
    return {"prediction": result}
```

### Pattern 3: Streaming Responses

```python
from fastapi.responses import StreamingResponse
import asyncio

async def generate_predictions(data_stream):
    """Stream predictions as they're computed."""
    for batch in data_stream:
        result = await predict(batch)
        yield f"data: {result}\n\n"
        await asyncio.sleep(0.1)

@app.post("/predict/stream")
async def stream_predictions(data: list):
    """Server-sent events for real-time predictions."""
    return StreamingResponse(
        generate_predictions(data),
        media_type="text/event-stream"
    )
```

## Tools and Setup

### Required Tools

```bash
# Python 3.10+
python --version

# Install uv (project management)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install PostgreSQL (for database practice)
# Docker recommended for easy setup
docker run -d \
  --name postgres-mlops \
  -e POSTGRES_PASSWORD=password \
  -p 5432:5432 \
  postgres:15-alpine
```

### Development Environment

```bash
# Create new project
uv init ml-api
cd ml-api

# Add core dependencies
uv add fastapi uvicorn[standard] sqlalchemy[asyncio] alembic pydantic

# Add dev dependencies
uv add --dev pytest pytest-asyncio httpx mypy ruff

# Run development server
uv run uvicorn src.main:app --reload
```

## Assessment Criteria

Demonstrate mastery by:

1. **Code Quality**
   - [ ] All code is fully type-hinted
   - [ ] Pydantic models for all data structures
   - [ ] Proper async/await usage
   - [ ] Clean decorator implementation

2. **API Development**
   - [ ] RESTful API design principles
   - [ ] Proper error handling
   - [ ] Database integration working
   - [ ] Streaming endpoints functional

3. **Testing**
   - [ ] > 80% test coverage
   - [ ] All endpoints tested
   - [ ] Database operations tested
   - [ ] Integration tests passing

4. **Production Readiness**
   - [ ] Docker containerization
   - [ ] Health checks implemented
   - [ ] Logging and monitoring
   - [ ] Security best practices

## Learning Resources

### Documentation

- [Python Type Hints (PEP 484)](https://peps.python.org/pep-0484/)
- [uv Documentation](https://github.com/astral-sh/uv)
- [Pydantic v2 Docs](https://docs.pydantic.dev/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [SQLAlchemy 2.0 Docs](https://docs.sqlalchemy.org/en/20/)

### Video Tutorials

- [FastAPI Course (freeCodeCamp)](https://www.youtube.com/watch?v=0sOvCWFmrtA)
- [Python Async/Await Explained](https://realpython.com/async-io-python/)

### Practice Platforms

- [Real Python](https://realpython.com/) - Python tutorials
- [TestDriven.io](https://testdriven.io/) - FastAPI projects

## Troubleshooting

### Type Checker Issues

```bash
# Run mypy on your code
mypy src/ --strict

# Common fixes
# - Add return type hints to all functions
# - Use Optional[T] for nullable values
# - Import types from typing module
```

### Async Errors

```python
# Wrong: Missing await
result = async_function()  # Returns coroutine!

# Correct: Use await
result = await async_function()

# Wrong: Blocking call in async
def blocking_call():
    time.sleep(5)

# Correct: Use asyncio.to_thread
await asyncio.to_thread(blocking_call)
```

### Database Connection Issues

```bash
# Check PostgreSQL is running
docker ps | grep postgres

# Test connection
psql postgresql://user:pass@localhost:5432/dbname

# Run Alembic migrations
alembic upgrade head
```

## Next Steps

After completing Module 2:

1. **Module 3: CI/CD & Deployment**
   - Automated testing pipelines
   - Container orchestration with Kubernetes
   - Monitoring and observability

2. **Build Your Portfolio**
   - Deploy your ML API to production
   - Add to GitHub with comprehensive README
   - Share with the community

3. **Advanced Topics**
   - GraphQL with Strawberry
   - gRPC for high-performance APIs
   - Event-driven architectures with Kafka

## Community and Support

- **Questions**: Open an issue in the repository
- **Discussions**: Join the MLOps training community
- **Contributions**: Submit improvements via pull requests

---

## Quick Navigation

### Start Learning

- **[Advanced Python →](./advanced-python/README.md)** - Begin with Python foundations
- **[FastAPI →](./fastapi/README.md)** - Jump to API development

### Reference

- [Main Study Guide](../README.md) - Overall training navigation
- [Module 1: Infrastructure](../module-01/README.md) - Previous module
- [Module 3: Deployment](../module-03/README.md) - Next module

---

**Ready to start?** Begin with [Advanced Python](./advanced-python/README.md) to build your Python foundations, then progress to [FastAPI](./fastapi/README.md) for production API development.
