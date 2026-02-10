# Production Deployment

**Deploy FastAPI ML applications to production**

## Overview

Deploying ML APIs to production requires proper server configuration, containerization, monitoring, security hardening, and performance optimization. This guide covers production deployment best practices for FastAPI applications.

## ASGI Servers

### Uvicorn

Uvicorn is a lightning-fast ASGI server, ideal for development and production.

**Installation:**
```bash
uv add uvicorn[standard]
```

**Development:**
```bash
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

**Production:**
```bash
uvicorn src.main:app \
    --host 0.0.0.0 \
    --port 8000 \
    --workers 4 \
    --loop uvloop \
    --http httptools \
    --log-level info \
    --access-log
```

**Key Options:**
- `--workers` - Number of worker processes (2-4 × CPU cores)
- `--loop uvloop` - High-performance event loop
- `--http httptools` - Fast HTTP parser
- `--log-level` - Logging level (debug, info, warning, error)
- `--access-log` - Enable access logging

### Gunicorn + Uvicorn Workers

For production, combine Gunicorn's process management with Uvicorn workers:

```bash
uv add gunicorn
```

**Run:**
```bash
gunicorn src.main:app \
    --workers 4 \
    --worker-class uvicorn.workers.UvicornWorker \
    --bind 0.0.0.0:8000 \
    --timeout 120 \
    --graceful-timeout 30 \
    --keep-alive 5 \
    --log-level info \
    --access-logfile - \
    --error-logfile -
```

**gunicorn_config.py:**
```python
import multiprocessing

# Server socket
bind = "0.0.0.0:8000"
backlog = 2048

# Worker processes
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "uvicorn.workers.UvicornWorker"
worker_connections = 1000
max_requests = 1000
max_requests_jitter = 50

# Timeouts
timeout = 120
graceful_timeout = 30
keepalive = 5

# Logging
accesslog = "-"
errorlog = "-"
loglevel = "info"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# Process naming
proc_name = "ml-api"

# Server mechanics
daemon = False
pidfile = None
user = None
group = None
tmp_upload_dir = None
```

**Run with config:**
```bash
gunicorn -c gunicorn_config.py src.main:app
```

## Docker Containerization

### Dockerfile

**Dockerfile:**
```dockerfile
# Use Python 3.11 slim image
FROM python:3.11-slim as base

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Set working directory
WORKDIR /app

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies
RUN uv sync --frozen --no-dev

# Copy application code
COPY src/ ./src/
COPY alembic/ ./alembic/
COPY alembic.ini ./

# Create non-root user
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

USER appuser

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run application
CMD ["uv", "run", "gunicorn", "-c", "gunicorn_config.py", "src.main:app"]
```

### Multi-Stage Build (Smaller Image)

```dockerfile
# Builder stage
FROM python:3.11-slim as builder

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Install dependencies
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

# Runtime stage
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Copy installed dependencies from builder
COPY --from=builder /app/.venv /app/.venv
ENV PATH="/app/.venv/bin:$PATH"

# Copy application
COPY src/ ./src/
COPY alembic/ ./alembic/
COPY alembic.ini gunicorn_config.py ./

# Non-root user
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health')" || exit 1

CMD ["gunicorn", "-c", "gunicorn_config.py", "src.main:app"]
```

### docker-compose.yml

```yaml
version: '3.8'

services:
  api:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql+asyncpg://mluser:password@db:5432/mldb
      - SECRET_KEY=${SECRET_KEY}
      - LOG_LEVEL=info
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=mluser
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=mldb
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U mluser"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```

**Run:**
```bash
# Build and start
docker-compose up -d

# View logs
docker-compose logs -f api

# Stop
docker-compose down
```

## Health Checks

### Basic Health Check

```python
from fastapi import FastAPI, status
from sqlalchemy import text
from typing import Dict

@app.get("/health", status_code=status.HTTP_200_OK)
async def health_check() -> Dict[str, str]:
    """Basic health check."""
    return {
        "status": "healthy",
        "version": "1.0.0"
    }
```

### Readiness Probe

```python
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

@app.get("/ready")
async def readiness_check(
    db: AsyncSession = Depends(get_db)
) -> Dict[str, any]:
    """Readiness check with dependencies."""
    checks = {
        "database": "unknown",
        "models": "unknown"
    }

    # Check database
    try:
        await db.execute(text("SELECT 1"))
        checks["database"] = "healthy"
    except Exception as e:
        checks["database"] = f"unhealthy: {str(e)}"

    # Check models loaded
    try:
        from src.ml.model_loader import model_manager
        checks["models"] = "healthy" if model_manager.models else "no models"
    except Exception as e:
        checks["models"] = f"unhealthy: {str(e)}"

    # Overall status
    all_healthy = all(
        status == "healthy" for status in checks.values()
    )

    return {
        "status": "ready" if all_healthy else "not ready",
        "checks": checks
    }
```

### Liveness Probe

```python
@app.get("/live")
async def liveness_check():
    """Liveness check - is app running?"""
    return {"status": "alive"}
```

## Logging

### Structured Logging

```python
import logging
import json
from datetime import datetime

class JSONFormatter(logging.Formatter):
    """JSON log formatter."""

    def format(self, record: logging.LogRecord) -> str:
        log_data = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
        }

        if hasattr(record, "request_id"):
            log_data["request_id"] = record.request_id

        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)

        return json.dumps(log_data)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    handlers=[logging.StreamHandler()]
)

for handler in logging.root.handlers:
    handler.setFormatter(JSONFormatter())
```

### Request Logging Middleware

```python
import time
import logging
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware

logger = logging.getLogger(__name__)

class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """Log all requests with timing."""

    async def dispatch(self, request: Request, call_next):
        start_time = time.time()

        # Log request
        logger.info(
            "Request started",
            extra={
                "method": request.method,
                "path": request.url.path,
                "client": request.client.host,
                "request_id": getattr(request.state, "request_id", None)
            }
        )

        response = await call_next(request)

        # Log response
        duration = time.time() - start_time
        logger.info(
            "Request completed",
            extra={
                "method": request.method,
                "path": request.url.path,
                "status_code": response.status_code,
                "duration": f"{duration:.3f}s",
                "request_id": getattr(request.state, "request_id", None)
            }
        )

        return response

app.add_middleware(RequestLoggingMiddleware)
```

## Security

### HTTPS Configuration

**Using Nginx as reverse proxy:**

```nginx
server {
    listen 80;
    server_name api.example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.example.com;

    ssl_certificate /etc/letsencrypt/live/api.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.example.com/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

### Security Headers

```python
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from starlette.middleware.httpsredirect import HTTPSRedirectMiddleware

# HTTPS redirect
app.add_middleware(HTTPSRedirectMiddleware)

# Trusted hosts
app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=["api.example.com", "*.example.com"]
)

# Security headers middleware
from starlette.middleware.base import BaseHTTPMiddleware

class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """Add security headers."""

    async def dispatch(self, request, call_next):
        response = await call_next(request)

        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"

        return response

app.add_middleware(SecurityHeadersMiddleware)
```

### Rate Limiting

```bash
uv add slowapi
```

```python
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

@app.post("/predict")
@limiter.limit("100/minute")
async def predict(request: Request, data: PredictionInput):
    """Rate-limited prediction endpoint."""
    # Your logic here
    pass
```

### API Key Authentication

```python
from fastapi import Security, HTTPException, status
from fastapi.security import APIKeyHeader

API_KEY_HEADER = APIKeyHeader(name="X-API-Key")

async def verify_api_key(api_key: str = Security(API_KEY_HEADER)):
    """Verify API key."""
    from src.config import settings

    if api_key != settings.API_KEY:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid API key"
        )
    return api_key

@app.post("/predict")
async def predict(
    data: PredictionInput,
    api_key: str = Depends(verify_api_key)
):
    """Protected endpoint."""
    # Your logic here
    pass
```

## Monitoring and Observability

### Prometheus Metrics

```bash
uv add prometheus-fastapi-instrumentator
```

```python
from prometheus_fastapi_instrumentator import Instrumentator

# Add metrics endpoint
Instrumentator().instrument(app).expose(app)

# Access metrics at /metrics
```

### Custom Metrics

```python
from prometheus_client import Counter, Histogram, Gauge
import time

# Define metrics
prediction_counter = Counter(
    "predictions_total",
    "Total number of predictions",
    ["model_version", "status"]
)

prediction_duration = Histogram(
    "prediction_duration_seconds",
    "Prediction duration in seconds",
    ["model_version"]
)

active_models = Gauge(
    "active_models",
    "Number of loaded models"
)

@app.post("/predict")
async def predict(data: PredictionInput, model_version: str = "v1"):
    """Instrumented prediction endpoint."""
    start_time = time.time()

    try:
        # Make prediction
        result = model_manager.get_model("classifier", model_version).predict(
            [data.features]
        )

        # Record success metrics
        prediction_counter.labels(
            model_version=model_version,
            status="success"
        ).inc()

        return {"prediction": float(result[0])}

    except Exception as e:
        # Record failure metrics
        prediction_counter.labels(
            model_version=model_version,
            status="error"
        ).inc()
        raise

    finally:
        # Record duration
        duration = time.time() - start_time
        prediction_duration.labels(
            model_version=model_version
        ).observe(duration)
```

### Application Performance Monitoring (APM)

**Sentry integration:**

```bash
uv add sentry-sdk[fastapi]
```

```python
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

sentry_sdk.init(
    dsn="your-sentry-dsn",
    integrations=[FastApiIntegration()],
    traces_sample_rate=0.1,
    environment="production"
)
```

## Performance Optimization

### Connection Pooling

```python
# In database.py
from sqlalchemy.ext.asyncio import create_async_engine

engine = create_async_engine(
    DATABASE_URL,
    pool_size=20,           # Base connections
    max_overflow=10,        # Additional connections
    pool_timeout=30,        # Connection timeout
    pool_recycle=3600,      # Recycle after 1 hour
    pool_pre_ping=True,     # Verify connection health
)
```

### Response Compression

```python
from fastapi.middleware.gzip import GZipMiddleware

app.add_middleware(GZipMiddleware, minimum_size=1000)
```

### Caching

**Redis caching:**

```bash
uv add redis[asyncio]
```

```python
from redis.asyncio import Redis
import json

redis_client = Redis(host="localhost", port=6379, decode_responses=True)

@app.post("/predict")
async def predict_cached(data: PredictionInput):
    """Cached predictions."""
    cache_key = f"pred:{hash(str(data.features))}"

    # Check cache
    cached = await redis_client.get(cache_key)
    if cached:
        return json.loads(cached)

    # Make prediction
    result = {"prediction": 0.5}  # Your logic

    # Cache result (expire in 1 hour)
    await redis_client.setex(
        cache_key,
        3600,
        json.dumps(result)
    )

    return result
```

## Environment Configuration

### .env Files

**.env.production:**
```bash
# Database
DATABASE_URL=postgresql+asyncpg://user:pass@db.example.com:5432/mldb
DB_POOL_SIZE=20
DB_MAX_OVERFLOW=10

# Security
SECRET_KEY=your-production-secret-key
API_KEY=your-production-api-key

# App
DEBUG=false
LOG_LEVEL=INFO
ENVIRONMENT=production

# CORS
CORS_ORIGINS=["https://app.example.com"]

# Redis
REDIS_URL=redis://cache.example.com:6379

# Monitoring
SENTRY_DSN=your-sentry-dsn
```

### Configuration Loading

```python
from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    """Application settings."""
    model_config = SettingsConfigDict(
        env_file=".env.production",
        case_sensitive=True
    )

    DATABASE_URL: str
    SECRET_KEY: str
    API_KEY: str
    DEBUG: bool = False
    LOG_LEVEL: str = "INFO"

@lru_cache()
def get_settings() -> Settings:
    """Cached settings singleton."""
    return Settings()

settings = get_settings()
```

## Deployment Checklist

- [ ] **Security**
  - [ ] HTTPS enabled
  - [ ] Security headers configured
  - [ ] API authentication implemented
  - [ ] Rate limiting enabled
  - [ ] Secrets in environment variables

- [ ] **Performance**
  - [ ] Connection pooling configured
  - [ ] Response compression enabled
  - [ ] Caching implemented
  - [ ] Multiple workers configured

- [ ] **Monitoring**
  - [ ] Health checks implemented
  - [ ] Logging configured
  - [ ] Metrics exposed
  - [ ] Error tracking enabled

- [ ] **Database**
  - [ ] Migrations applied
  - [ ] Backups configured
  - [ ] Connection pooling tuned

- [ ] **Testing**
  - [ ] All tests passing
  - [ ] Load testing completed
  - [ ] Security scanning done

- [ ] **Documentation**
  - [ ] API documentation accessible
  - [ ] Deployment docs updated
  - [ ] Runbook created

## Deployment Strategies

### Blue-Green Deployment

1. Deploy new version (green) alongside current (blue)
2. Test green environment
3. Switch traffic to green
4. Keep blue as rollback option

### Rolling Deployment

1. Deploy to subset of servers
2. Monitor health and errors
3. Gradually roll out to all servers
4. Rollback if issues detected

### Canary Deployment

1. Deploy to small percentage of traffic
2. Monitor metrics and errors
3. Gradually increase traffic
4. Full rollout or rollback

## Best Practices

1. **Use ASGI servers** - Uvicorn or Gunicorn+Uvicorn
2. **Containerize** - Docker for consistency
3. **Health checks** - Implement liveness and readiness
4. **Structured logging** - JSON format for parsing
5. **Monitor everything** - Metrics, logs, traces
6. **Secure by default** - HTTPS, headers, authentication
7. **Environment-based config** - Never hardcode secrets
8. **Graceful shutdown** - Handle signals properly
9. **Connection pooling** - Tune for your workload
10. **Test in production-like environment** - Staging before prod

## Next Steps

Your FastAPI ML API is now production-ready! Consider:

1. **Kubernetes deployment** - For container orchestration
2. **CI/CD pipeline** - Automated testing and deployment
3. **Multi-region deployment** - For global availability
4. **Advanced monitoring** - Distributed tracing, custom dashboards

## Resources

- [Uvicorn Deployment](https://www.uvicorn.org/deployment/)
- [FastAPI Deployment](https://fastapi.tiangolo.com/deployment/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Twelve-Factor App](https://12factor.net/)
- [Prometheus Documentation](https://prometheus.io/docs/)
