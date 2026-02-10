# Module 02: Advanced Python

**Master advanced Python concepts essential for MLOps engineering**

## Overview

This module covers advanced Python topics that form the foundation of modern MLOps development: type safety, project management, data validation, code patterns, and asynchronous programming.

## Learning Objectives

After completing this module, you will:

- Write type-safe Python code with comprehensive type hints
- Manage Python projects efficiently with uv
- Validate data robustly with Pydantic
- Apply decorator patterns for cleaner code
- Build concurrent applications with async/await

## Prerequisites

- Python 3.10 or higher installed
- Basic Python knowledge (functions, classes, imports)
- Understanding of command-line basics
- Familiarity with pip and virtual environments (helpful)

## Module Structure

This module follows a **dual-path learning approach**:

1. **Theory** (this directory): Comprehensive conceptual guides
2. **Hands-On Labs** (`module-02/advanced-python/`): Practical exercises

### Recommended Learning Path

For each topic, follow this sequence:

1. **Read theory documentation** (this directory)
2. **Complete hands-on lab** (practical exercises)
3. **Review examples** (reference implementations)
4. **Build something** (apply what you learned)

## Topics

### 1. Python Typing

**Theory:** [Python Typing](./01-python-typing.md)
**Lab:** [Typing Hands-On Lab](../module-02/advanced-python/01-typing/README.md)

Learn to write type-safe Python code:

- Basic type annotations (str, int, float, bool)
- Collection types (list, dict, set, tuple)
- Optional and Union types
- Type aliases and NewType
- Generic types with TypeVar
- Protocol for structural typing
- Integration with mypy/pyright

**Why it matters:** Type hints catch bugs early, improve IDE support, and make code self-documenting.

### 2. Project Management with uv

**Theory:** [Project Management with uv](./02-project-management-uv.md)
**Lab:** [uv Hands-On Lab](../module-02/advanced-python/02-uv/README.md)

Master modern Python project management:

- Creating projects with `uv init`
- Managing dependencies with lock files
- Separating dev and runtime dependencies
- Working with multiple Python versions
- Defining project scripts
- CI/CD integration

**Why it matters:** uv is 10-100x faster than pip and ensures reproducible builds across teams.

### 3. Data Validation with Pydantic

**Theory:** [Data Validation with Pydantic](./03-data-validation-pydantic.md)
**Lab:** [Pydantic Hands-On Lab](../module-02/advanced-python/03-pydantic/README.md)

Build robust data models:

- BaseModel fundamentals
- Field validation and constraints
- Custom validators
- Nested models
- JSON serialization
- FastAPI integration
- Pydantic v2 features

**Why it matters:** Pydantic prevents data errors at runtime and powers FastAPI, essential for ML APIs.

### 4. Decorators

**Theory:** [Decorators](./04-decorators.md)
**Lab:** [Decorators Hands-On Lab](../module-02/advanced-python/04-decorators/README.md)

Master Python decorators:

- Function decorator basics
- Decorators with arguments
- Class decorators
- Stacking decorators
- Built-in decorators (@property, @staticmethod, @classmethod)
- Practical patterns (logging, caching, retry, authentication)

**Why it matters:** Decorators reduce boilerplate and separate concerns for cleaner code.

### 5. Async/Await

**Theory:** [Async/Await](./05-async-await.md)
**Lab:** [Async/Await Hands-On Lab](../module-02/advanced-python/05-async-await/README.md)

Write concurrent asynchronous code:

- async/await syntax
- asyncio fundamentals
- Concurrent task execution
- Async HTTP with aiohttp
- Async file I/O
- Real-world async patterns

**Why it matters:** Async programming enables efficient I/O-bound operations crucial for APIs and data processing.

## Study Guide

### Week 1: Types and Tools

- **Day 1-2:** Python Typing theory + exercises
- **Day 3-4:** uv project management + practice
- **Day 5:** Build a typed project with uv

### Week 2: Validation and Patterns

- **Day 1-2:** Pydantic theory + exercises
- **Day 3-4:** Decorators theory + exercises
- **Day 5:** Combine Pydantic + decorators in a project

### Week 3: Asynchronous Programming

- **Day 1-3:** Async/await theory + exercises
- **Day 4-5:** Build async API or data pipeline

## Hands-On Practice

All practical exercises are located in: `module-02/advanced-python/`

Each section includes:

- **README.md**: Lab overview and instructions
- **examples/**: Reference implementations
- **exercises/**: Practice files with TODOs
- **solution/**: Complete solutions

## Assessment

Test your knowledge by building:

### Project 1: Type-Safe API Client

Create a fully typed HTTP client:
- Type hints on all functions
- Pydantic models for requests/responses
- Decorator for retry logic
- Async requests with aiohttp

### Project 2: ML Model Server

Build a FastAPI application:
- Pydantic for input validation
- Type hints throughout
- Async endpoint handlers
- Decorators for logging and metrics

### Project 3: Data Pipeline

Create an async data processing pipeline:
- Type-safe data models
- Async file/HTTP operations
- Decorator for error handling
- uv for dependency management

## Common Patterns

### Pattern 1: Type-Safe Configuration

```python
from pydantic import BaseModel, Field

class DatabaseConfig(BaseModel):
    host: str = "localhost"
    port: int = Field(ge=1, le=65535)
    database: str

config = DatabaseConfig(**env_vars)
```

### Pattern 2: Cached API Calls

```python
from functools import lru_cache

@lru_cache(maxsize=128)
def get_user_data(user_id: int) -> dict:
    return api.fetch(f"/users/{user_id}")
```

### Pattern 3: Async Data Fetching

```python
import asyncio

async def fetch_all(urls: list[str]) -> list[str]:
    tasks = [fetch_url(url) for url in urls]
    return await asyncio.gather(*tasks)
```

## Tools and Libraries

Install recommended tools:

```bash
# Type checking
uv add --dev mypy pyright

# Code quality
uv add --dev black ruff

# Testing
uv add --dev pytest pytest-asyncio

# Async libraries
uv add aiohttp aiofiles

# Data validation
uv add pydantic
```

## Troubleshooting

### Type Checker Issues

If mypy reports errors:

```bash
# Check Python version
mypy --python-version 3.10 src/

# Strict mode
mypy --strict src/
```

### uv Installation

If uv command not found:

```bash
# Add to PATH (macOS/Linux)
export PATH="$HOME/.cargo/bin:$PATH"

# Windows PowerShell
$env:PATH += ";$HOME\.cargo\bin"
```

### Async Debugging

Common async mistakes:

```python
# Wrong: Forgot await
result = async_function()  # Returns coroutine, not result

# Correct: Use await
result = await async_function()
```

## Next Steps

After completing Module 02:

1. **Module 03**: CI/CD and Monitoring
2. **Apply skills**: Build a complete MLOps project
3. **Deep dive**: Explore advanced async patterns
4. **Contribute**: Share your learnings

## Additional Resources

- [Python Type Hints (PEP 484)](https://peps.python.org/pep-0484/)
- [uv Documentation](https://github.com/astral-sh/uv)
- [Pydantic Documentation](https://docs.pydantic.dev/)
- [Python Decorators Guide](https://realpython.com/primer-on-python-decorators/)
- [Asyncio Documentation](https://docs.python.org/3/library/asyncio.html)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)

## Community and Support

- **Questions**: Open an issue in the repository
- **Discussions**: Join the MLOps training community
- **Contributions**: Submit improvements via pull requests

---

**Ready to start?** Begin with [Python Typing](./01-python-typing.md) or jump to the [Hands-On Labs](../module-02/advanced-python/README.md).
