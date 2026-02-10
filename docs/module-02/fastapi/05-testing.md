# Testing FastAPI

**Write comprehensive tests for production-ready ML APIs**

## Overview

Testing is critical for ML APIs: ensuring endpoints work correctly, validating model predictions, testing database interactions, and verifying error handling. This guide covers testing strategies for FastAPI applications using pytest.

## Test Setup

### Installation

```bash
# Install testing dependencies
uv add --dev pytest pytest-asyncio httpx
```

### Test Project Structure

```
ml-api/
├── src/
│   ├── main.py
│   ├── routes/
│   └── models/
├── tests/
│   ├── __init__.py
│   ├── conftest.py          # Shared fixtures
│   ├── test_api.py          # API endpoint tests
│   ├── test_models.py       # Model tests
│   ├── test_database.py     # Database tests
│   └── test_predictions.py  # Prediction logic tests
└── pytest.ini
```

### pytest Configuration

**pytest.ini:**
```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
asyncio_mode = auto
```

### conftest.py - Shared Fixtures

```python
import pytest
import pytest_asyncio
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.pool import NullPool

from src.main import app
from src.database import Base, get_db
from src.models.prediction import ModelVersion, Prediction

# Test database URL
TEST_DATABASE_URL = "postgresql+asyncpg://test:test@localhost:5432/test_mldb"

# Test engine
test_engine = create_async_engine(
    TEST_DATABASE_URL,
    poolclass=NullPool,  # Don't pool connections in tests
)

TestSessionLocal = async_sessionmaker(
    test_engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

@pytest_asyncio.fixture
async def test_db():
    """Create test database tables."""
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    yield

    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

@pytest_asyncio.fixture
async def db_session(test_db):
    """Provide database session for tests."""
    async with TestSessionLocal() as session:
        yield session

@pytest_asyncio.fixture
async def client(db_session):
    """Provide test client with overridden dependencies."""

    async def override_get_db():
        """Override database dependency."""
        yield db_session

    app.dependency_overrides[get_db] = override_get_db

    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac

    app.dependency_overrides.clear()
```

## Testing Endpoints

### Basic Endpoint Tests

```python
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_root_endpoint(client: AsyncClient):
    """Test root endpoint."""
    response = await client.get("/")

    assert response.status_code == 200
    assert "name" in response.json()

@pytest.mark.asyncio
async def test_health_check(client: AsyncClient):
    """Test health check endpoint."""
    response = await client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "healthy"
```

### Testing POST Endpoints

```python
@pytest.mark.asyncio
async def test_create_prediction(client: AsyncClient, db_session):
    """Test prediction creation."""
    # Create model version first
    model = ModelVersion(
        name="test_model",
        version="1.0.0",
        framework="sklearn"
    )
    db_session.add(model)
    await db_session.commit()
    await db_session.refresh(model)

    # Create prediction
    payload = {
        "model_id": model.id,
        "input_data": {"features": [1.0, 2.0, 3.0]}
    }

    response = await client.post("/api/v1/predictions", json=payload)

    assert response.status_code == 201
    data = response.json()
    assert "id" in data
    assert data["model_id"] == model.id
    assert "prediction" in data
```

### Testing Query Parameters

```python
@pytest.mark.asyncio
async def test_list_predictions_with_filters(client: AsyncClient, db_session):
    """Test prediction listing with filters."""
    # Create test data
    model = ModelVersion(name="test", version="1.0", framework="sklearn")
    db_session.add(model)
    await db_session.commit()
    await db_session.refresh(model)

    for i in range(5):
        prediction = Prediction(
            model_id=model.id,
            input_data={"features": [i]},
            prediction=float(i)
        )
        db_session.add(prediction)
    await db_session.commit()

    # Test pagination
    response = await client.get("/api/v1/predictions?skip=2&limit=2")

    assert response.status_code == 200
    data = response.json()
    assert len(data) == 2

    # Test filtering
    response = await client.get(f"/api/v1/predictions?model_id={model.id}")

    assert response.status_code == 200
    assert all(p["model_id"] == model.id for p in response.json())
```

### Testing Error Cases

```python
@pytest.mark.asyncio
async def test_prediction_not_found(client: AsyncClient):
    """Test 404 for non-existent prediction."""
    response = await client.get("/api/v1/predictions/99999")

    assert response.status_code == 404
    assert "not found" in response.json()["detail"].lower()

@pytest.mark.asyncio
async def test_invalid_input(client: AsyncClient):
    """Test validation error."""
    payload = {
        "model_id": "invalid",  # Should be int
        "input_data": {}
    }

    response = await client.post("/api/v1/predictions", json=payload)

    assert response.status_code == 422  # Validation error

@pytest.mark.asyncio
async def test_prediction_with_missing_model(client: AsyncClient):
    """Test prediction with non-existent model."""
    payload = {
        "model_id": 99999,
        "input_data": {"features": [1.0]}
    }

    response = await client.post("/api/v1/predictions", json=payload)

    assert response.status_code == 404
```

## Testing Async Endpoints

### Async Test Functions

```python
@pytest.mark.asyncio
async def test_async_prediction(client: AsyncClient):
    """Test async prediction endpoint."""
    payload = {
        "instances": [[1.0, 2.0], [3.0, 4.0]]
    }

    response = await client.post("/predict/batch/async", json=payload)

    assert response.status_code == 200
    data = response.json()
    assert "predictions" in data
    assert len(data["predictions"]) == 2
```

### Testing Background Tasks

```python
import asyncio

@pytest.mark.asyncio
async def test_background_task(client: AsyncClient, db_session):
    """Test endpoint with background task."""
    payload = {
        "features": [1.0, 2.0, 3.0],
        "user_id": 123
    }

    response = await client.post("/predict/json", json=payload)

    assert response.status_code == 200

    # Wait for background task
    await asyncio.sleep(0.5)

    # Verify background task executed
    # (Check logs, database, or other side effects)
```

## Mocking Dependencies

### Override Dependencies

```python
from unittest.mock import Mock, AsyncMock

@pytest.mark.asyncio
async def test_with_mocked_model(client: AsyncClient):
    """Test with mocked model dependency."""
    mock_model = Mock()
    mock_model.predict.return_value = [0.75]

    async def mock_get_model():
        return mock_model

    # Override dependency
    from src.dependencies import get_model
    app.dependency_overrides[get_model] = mock_get_model

    response = await client.post(
        "/predict",
        json={"features": [1.0, 2.0]}
    )

    assert response.status_code == 200
    assert response.json()["prediction"] == 0.75

    # Clean up
    app.dependency_overrides.clear()
```

### Mock External Services

```python
from unittest.mock import patch, AsyncMock

@pytest.mark.asyncio
@patch("src.ml.inference.external_api_call")
async def test_with_external_api_mock(mock_api, client: AsyncClient):
    """Test with mocked external API."""
    mock_api.return_value = {"result": "success"}

    response = await client.post("/process", json={"data": "test"})

    assert response.status_code == 200
    mock_api.assert_called_once()
```

## Database Testing

### Test Database Operations

```python
from sqlalchemy import select

@pytest.mark.asyncio
async def test_create_model_version(db_session):
    """Test model version creation."""
    model = ModelVersion(
        name="classifier",
        version="1.0.0",
        framework="sklearn",
        metrics={"accuracy": 0.95}
    )

    db_session.add(model)
    await db_session.commit()
    await db_session.refresh(model)

    assert model.id is not None
    assert model.name == "classifier"
    assert model.metrics["accuracy"] == 0.95

@pytest.mark.asyncio
async def test_query_predictions(db_session):
    """Test querying predictions."""
    # Create test data
    model = ModelVersion(name="test", version="1.0", framework="sklearn")
    db_session.add(model)
    await db_session.commit()
    await db_session.refresh(model)

    prediction = Prediction(
        model_id=model.id,
        input_data={"features": [1.0]},
        prediction=0.8
    )
    db_session.add(prediction)
    await db_session.commit()

    # Query
    stmt = select(Prediction).where(Prediction.model_id == model.id)
    result = await db_session.execute(stmt)
    predictions = result.scalars().all()

    assert len(predictions) == 1
    assert predictions[0].prediction == 0.8
```

### Test Relationships

```python
@pytest.mark.asyncio
async def test_model_prediction_relationship(db_session):
    """Test relationship between model and predictions."""
    from sqlalchemy.orm import selectinload

    # Create model with predictions
    model = ModelVersion(name="test", version="1.0", framework="sklearn")
    db_session.add(model)
    await db_session.flush()

    for i in range(3):
        prediction = Prediction(
            model_id=model.id,
            input_data={"features": [i]},
            prediction=float(i)
        )
        db_session.add(prediction)

    await db_session.commit()

    # Load model with predictions
    stmt = (
        select(ModelVersion)
        .options(selectinload(ModelVersion.predictions))
        .where(ModelVersion.id == model.id)
    )
    result = await db_session.execute(stmt)
    loaded_model = result.scalar_one()

    assert len(loaded_model.predictions) == 3
```

## Testing File Uploads

```python
from io import BytesIO

@pytest.mark.asyncio
async def test_file_upload(client: AsyncClient):
    """Test file upload endpoint."""
    file_content = b"test,data\n1.0,2.0\n3.0,4.0"
    files = {
        "file": ("test.csv", BytesIO(file_content), "text/csv")
    }

    response = await client.post("/upload-model", files=files)

    assert response.status_code == 200
    data = response.json()
    assert data["filename"] == "test.csv"
    assert data["size"] == len(file_content)

@pytest.mark.asyncio
async def test_invalid_file_type(client: AsyncClient):
    """Test file upload with invalid type."""
    files = {
        "file": ("test.txt", BytesIO(b"invalid"), "text/plain")
    }

    response = await client.post("/upload-model", files=files)

    assert response.status_code == 400
    assert "not allowed" in response.json()["detail"].lower()
```

## Testing Streaming Endpoints

### Test SSE Streaming

```python
@pytest.mark.asyncio
async def test_sse_stream(client: AsyncClient):
    """Test server-sent events endpoint."""
    async with client.stream(
        "POST",
        "/predict/stream",
        json={"instances": [[1.0], [2.0], [3.0]]}
    ) as response:
        assert response.status_code == 200
        assert response.headers["content-type"] == "text/event-stream; charset=utf-8"

        events = []
        async for line in response.aiter_lines():
            if line.startswith("data: "):
                data = json.loads(line[6:])
                events.append(data)

        assert len(events) == 3
        assert all("prediction" in e for e in events)
```

### Test WebSocket

```python
@pytest.mark.asyncio
async def test_websocket_prediction():
    """Test WebSocket endpoint."""
    from fastapi.testclient import TestClient

    with TestClient(app) as test_client:
        with test_client.websocket_connect("/ws/predict") as websocket:
            # Send data
            websocket.send_json({
                "features": [1.0, 2.0, 3.0],
                "version": "v1"
            })

            # Receive response
            data = websocket.receive_json()

            assert "prediction" in data
            assert "version" in data
            assert data["version"] == "v1"
```

## Testing Model Predictions

### Test Model Logic

```python
import numpy as np

def test_model_prediction():
    """Test model prediction logic."""
    from src.ml.model_loader import load_model

    model = load_model("classifier", "v1")
    features = np.array([[1.0, 2.0, 3.0]])

    prediction = model.predict(features)

    assert prediction is not None
    assert len(prediction) == 1
    assert isinstance(prediction[0], (int, float, np.number))

def test_model_batch_prediction():
    """Test batch predictions."""
    from src.ml.model_loader import load_model

    model = load_model("classifier", "v1")
    features = np.array([
        [1.0, 2.0, 3.0],
        [4.0, 5.0, 6.0],
        [7.0, 8.0, 9.0]
    ])

    predictions = model.predict(features)

    assert len(predictions) == 3
```

### Test Model Versioning

```python
@pytest.mark.asyncio
async def test_model_version_selection(client: AsyncClient):
    """Test selecting different model versions."""
    payload = {"features": [1.0, 2.0, 3.0]}

    # Test v1
    response_v1 = await client.post(
        "/predict?version=v1",
        json=payload
    )
    assert response_v1.status_code == 200
    result_v1 = response_v1.json()

    # Test v2
    response_v2 = await client.post(
        "/predict?version=v2",
        json=payload
    )
    assert response_v2.status_code == 200
    result_v2 = response_v2.json()

    # Results may differ between versions
    assert result_v1["version"] == "v1"
    assert result_v2["version"] == "v2"
```

## Integration Tests

### Full Workflow Test

```python
@pytest.mark.asyncio
async def test_full_prediction_workflow(client: AsyncClient, db_session):
    """Test complete prediction workflow."""
    # 1. Create model version
    model_data = {
        "name": "classifier",
        "version": "1.0.0",
        "framework": "sklearn"
    }
    response = await client.post("/api/v1/models", json=model_data)
    assert response.status_code == 201
    model = response.json()

    # 2. Make prediction
    prediction_data = {
        "model_id": model["id"],
        "input_data": {"features": [1.0, 2.0, 3.0]}
    }
    response = await client.post("/api/v1/predictions", json=prediction_data)
    assert response.status_code == 201
    prediction = response.json()

    # 3. Retrieve prediction
    response = await client.get(f"/api/v1/predictions/{prediction['id']}")
    assert response.status_code == 200
    retrieved = response.json()
    assert retrieved["id"] == prediction["id"]

    # 4. List predictions
    response = await client.get(f"/api/v1/predictions?model_id={model['id']}")
    assert response.status_code == 200
    predictions = response.json()
    assert len(predictions) >= 1
```

## Performance Testing

### Load Testing with pytest-benchmark

```bash
uv add --dev pytest-benchmark
```

```python
def test_prediction_performance(benchmark):
    """Benchmark prediction performance."""
    from src.ml.model_loader import load_model
    import numpy as np

    model = load_model("classifier", "v1")
    features = np.array([[1.0, 2.0, 3.0]])

    result = benchmark(model.predict, features)

    assert result is not None
```

### Concurrent Request Testing

```python
import asyncio

@pytest.mark.asyncio
async def test_concurrent_predictions(client: AsyncClient):
    """Test handling concurrent requests."""
    payload = {"features": [1.0, 2.0, 3.0]}

    # Create 100 concurrent requests
    tasks = [
        client.post("/predict", json=payload)
        for _ in range(100)
    ]

    responses = await asyncio.gather(*tasks)

    # All should succeed
    assert all(r.status_code == 200 for r in responses)

    # All should have predictions
    assert all("prediction" in r.json() for r in responses)
```

## Test Coverage

### Generate Coverage Report

```bash
# Install coverage
uv add --dev pytest-cov

# Run tests with coverage
pytest --cov=src --cov-report=html

# View report
# Open htmlcov/index.html in browser
```

### Coverage Configuration

**.coveragerc:**
```ini
[run]
source = src
omit =
    */tests/*
    */migrations/*
    */__init__.py

[report]
exclude_lines =
    pragma: no cover
    def __repr__
    raise AssertionError
    raise NotImplementedError
    if __name__ == .__main__.:
```

## Best Practices

1. **Test happy paths and errors** - Both success and failure cases
2. **Use fixtures** - Share setup code across tests
3. **Mock external dependencies** - Don't call real APIs in tests
4. **Test database isolation** - Each test uses clean database
5. **Test async properly** - Use pytest-asyncio for async tests
6. **Meaningful assertions** - Assert specific expected values
7. **Test edge cases** - Empty inputs, large batches, invalid data
8. **Fast tests** - Mock slow operations like model loading
9. **Clear test names** - Describe what is being tested
10. **Arrange-Act-Assert** - Structure tests clearly

## Running Tests

```bash
# Run all tests
pytest

# Run specific test file
pytest tests/test_api.py

# Run specific test
pytest tests/test_api.py::test_create_prediction

# Run with verbose output
pytest -v

# Run with coverage
pytest --cov=src

# Run in parallel (requires pytest-xdist)
pytest -n auto

# Run only failed tests
pytest --lf
```

## Next Steps

Continue to [Production Deployment](./06-production.md) to learn how to deploy your tested FastAPI application.

## Resources

- [pytest Documentation](https://docs.pytest.org/)
- [pytest-asyncio](https://pytest-asyncio.readthedocs.io/)
- [HTTPX](https://www.python-httpx.org/)
- [FastAPI Testing](https://fastapi.tiangolo.com/tutorial/testing/)
