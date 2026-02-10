# Advanced Request Handling

**Master complex request patterns for ML workloads**

## Overview

Real-world ML APIs need to handle diverse input types: structured data, files, forms, headers, and background tasks. This guide covers advanced request handling patterns essential for production ML systems.

## Query Parameters

Query parameters pass optional data in URL query strings.

### Basic Query Parameters

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/models")
async def list_models(
    skip: int = 0,
    limit: int = 10,
    sort_by: str = "created_at"
):
    """Paginated model list."""
    return {
        "skip": skip,
        "limit": limit,
        "sort_by": sort_by,
        "models": []  # Your data here
    }
```

**Usage:**
```bash
GET /models?skip=20&limit=50&sort_by=name
```

### Query Parameter Validation

Use `Query` for advanced validation:

```python
from fastapi import Query
from typing import Annotated

@app.get("/search")
async def search_models(
    q: Annotated[str, Query(
        min_length=3,
        max_length=50,
        description="Search query",
        examples=["classifier"]
    )],
    limit: Annotated[int, Query(
        ge=1,
        le=100,
        description="Results per page"
    )] = 10
):
    """Search with validated parameters."""
    return {"query": q, "limit": limit}
```

### Optional Query Parameters

```python
from typing import Optional

@app.get("/predictions")
async def get_predictions(
    model_id: Optional[int] = None,
    min_confidence: Optional[float] = None,
    start_date: Optional[str] = None
):
    """Filter predictions with optional parameters."""
    filters = {}
    if model_id:
        filters["model_id"] = model_id
    if min_confidence:
        filters["min_confidence"] = min_confidence
    if start_date:
        filters["start_date"] = start_date

    return {"filters": filters}
```

### List Query Parameters

```python
from fastapi import Query

@app.get("/models")
async def filter_models(
    tags: list[str] = Query(default=[])
):
    """Filter by multiple tags."""
    return {"tags": tags}
```

**Usage:**
```bash
GET /models?tags=classifier&tags=production&tags=v2
```

## Request Body

### JSON Request Body

```python
from pydantic import BaseModel

class TrainingConfig(BaseModel):
    """Training configuration."""
    model_type: str
    learning_rate: float
    epochs: int
    batch_size: int = 32

@app.post("/train")
async def train_model(config: TrainingConfig):
    """Start model training."""
    return {
        "status": "training_started",
        "config": config.model_dump()
    }
```

**Request:**
```json
{
  "model_type": "random_forest",
  "learning_rate": 0.001,
  "epochs": 100,
  "batch_size": 64
}
```

### Nested Models

```python
from pydantic import BaseModel, Field

class DatasetConfig(BaseModel):
    """Dataset configuration."""
    path: str
    train_split: float = 0.8
    shuffle: bool = True

class TrainingConfig(BaseModel):
    """Complete training config with nested dataset."""
    model_type: str
    dataset: DatasetConfig
    epochs: int = Field(ge=1, le=1000)
    learning_rate: float = Field(gt=0, lt=1)

@app.post("/train")
async def train_model(config: TrainingConfig):
    """Train with nested configuration."""
    return {
        "model": config.model_type,
        "dataset_path": config.dataset.path,
        "epochs": config.epochs
    }
```

**Request:**
```json
{
  "model_type": "xgboost",
  "dataset": {
    "path": "s3://bucket/dataset.csv",
    "train_split": 0.75,
    "shuffle": true
  },
  "epochs": 100,
  "learning_rate": 0.01
}
```

### Multiple Body Parameters

```python
from pydantic import BaseModel

class Model(BaseModel):
    name: str
    version: str

class Dataset(BaseModel):
    path: str
    format: str

@app.post("/evaluate")
async def evaluate(
    model: Model,
    dataset: Dataset,
    metrics: list[str]
):
    """Multiple body parameters."""
    return {
        "model": model.name,
        "dataset": dataset.path,
        "metrics": metrics
    }
```

**Request:**
```json
{
  "model": {
    "name": "classifier_v2",
    "version": "2.1.0"
  },
  "dataset": {
    "path": "data/test.csv",
    "format": "csv"
  },
  "metrics": ["accuracy", "f1", "auc"]
}
```

## File Uploads

### Single File Upload

```python
from fastapi import File, UploadFile

@app.post("/upload-model")
async def upload_model(
    file: UploadFile = File(...)
):
    """Upload a model file."""
    contents = await file.read()

    return {
        "filename": file.filename,
        "content_type": file.content_type,
        "size": len(contents)
    }
```

**Usage:**
```bash
curl -X POST "http://localhost:8000/upload-model" \
  -F "file=@model.pkl"
```

### File Upload with Validation

```python
from fastapi import File, UploadFile, HTTPException
from typing import Annotated

ALLOWED_EXTENSIONS = {".pkl", ".joblib", ".h5", ".pt", ".pth"}
MAX_FILE_SIZE = 100 * 1024 * 1024  # 100MB

@app.post("/upload-model")
async def upload_model(
    file: Annotated[UploadFile, File(
        description="Model file (pkl, joblib, h5, pt, pth)"
    )]
):
    """Upload model with validation."""
    # Validate extension
    file_ext = Path(file.filename).suffix.lower()
    if file_ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"File type {file_ext} not allowed. Use: {ALLOWED_EXTENSIONS}"
        )

    # Read and validate size
    contents = await file.read()
    if len(contents) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=400,
            detail=f"File too large. Max size: {MAX_FILE_SIZE} bytes"
        )

    # Save file
    file_path = f"models/{file.filename}"
    with open(file_path, "wb") as f:
        f.write(contents)

    return {
        "filename": file.filename,
        "size": len(contents),
        "saved_to": file_path
    }
```

### Multiple File Uploads

```python
from fastapi import File, UploadFile

@app.post("/upload-dataset")
async def upload_dataset(
    files: list[UploadFile] = File(
        description="Multiple dataset files"
    )
):
    """Upload multiple files."""
    results = []

    for file in files:
        contents = await file.read()
        results.append({
            "filename": file.filename,
            "size": len(contents)
        })

    return {
        "files_uploaded": len(files),
        "details": results
    }
```

### File Upload with Metadata

```python
from fastapi import File, UploadFile, Form
from typing import Annotated

@app.post("/upload-model")
async def upload_model_with_metadata(
    file: Annotated[UploadFile, File()],
    model_name: Annotated[str, Form()],
    version: Annotated[str, Form()],
    description: Annotated[str, Form()] = ""
):
    """Upload file with form metadata."""
    contents = await file.read()

    return {
        "filename": file.filename,
        "model_name": model_name,
        "version": version,
        "description": description,
        "size": len(contents)
    }
```

**Usage:**
```bash
curl -X POST "http://localhost:8000/upload-model" \
  -F "file=@model.pkl" \
  -F "model_name=classifier" \
  -F "version=1.0.0" \
  -F "description=Production model"
```

### Streaming File Processing

For large files, process in chunks:

```python
from fastapi import UploadFile
import hashlib

@app.post("/upload-large-dataset")
async def upload_large_dataset(file: UploadFile):
    """Stream and process large file."""
    chunk_size = 1024 * 1024  # 1MB chunks
    total_size = 0
    hasher = hashlib.sha256()

    # Process file in chunks
    while chunk := await file.read(chunk_size):
        total_size += len(chunk)
        hasher.update(chunk)
        # Process chunk (e.g., write to disk, upload to S3)

    return {
        "filename": file.filename,
        "size": total_size,
        "sha256": hasher.hexdigest()
    }
```

## Form Data

### Simple Form Data

```python
from fastapi import Form
from typing import Annotated

@app.post("/login")
async def login(
    username: Annotated[str, Form()],
    password: Annotated[str, Form()]
):
    """Handle form submission."""
    return {"username": username}
```

### Form with Pydantic Model

```python
from pydantic import BaseModel
from fastapi import Form

class LoginForm(BaseModel):
    """Login form model."""
    username: str
    password: str

@app.post("/login")
async def login(
    username: Annotated[str, Form()],
    password: Annotated[str, Form()]
):
    """Create Pydantic model from form."""
    form_data = LoginForm(username=username, password=password)
    return {"username": form_data.username}
```

### Multipart Form with Files

```python
from fastapi import File, Form, UploadFile
from typing import Annotated

@app.post("/submit-prediction")
async def submit_prediction(
    user_id: Annotated[int, Form()],
    model_version: Annotated[str, Form()],
    input_file: Annotated[UploadFile, File()],
    metadata: Annotated[str, Form()] = "{}"
):
    """Handle complex form with files."""
    contents = await input_file.read()

    return {
        "user_id": user_id,
        "model_version": model_version,
        "file_size": len(contents),
        "metadata": metadata
    }
```

## Headers

### Reading Headers

```python
from fastapi import Header
from typing import Annotated

@app.get("/protected")
async def protected_endpoint(
    authorization: Annotated[str, Header()]
):
    """Read authorization header."""
    return {"auth": authorization}
```

### Optional Headers

```python
from typing import Optional

@app.get("/items")
async def get_items(
    user_agent: Annotated[Optional[str], Header()] = None,
    x_request_id: Annotated[Optional[str], Header()] = None
):
    """Read optional headers."""
    return {
        "user_agent": user_agent,
        "request_id": x_request_id
    }
```

### Header Validation

```python
from fastapi import Header, HTTPException
import uuid

@app.post("/predict")
async def predict(
    x_request_id: Annotated[str, Header()]
):
    """Validate request ID header."""
    try:
        # Validate UUID format
        uuid.UUID(x_request_id)
    except ValueError:
        raise HTTPException(
            status_code=400,
            detail="X-Request-ID must be valid UUID"
        )

    return {"request_id": x_request_id}
```

## Cookies

### Reading Cookies

```python
from fastapi import Cookie
from typing import Annotated, Optional

@app.get("/user")
async def get_user(
    session_id: Annotated[Optional[str], Cookie()] = None
):
    """Read session cookie."""
    if not session_id:
        return {"authenticated": False}

    return {
        "authenticated": True,
        "session_id": session_id
    }
```

### Setting Cookies

```python
from fastapi import Response

@app.post("/login")
async def login(username: str, password: str, response: Response):
    """Set cookie on response."""
    # Validate credentials
    session_id = "generated_session_id"

    response.set_cookie(
        key="session_id",
        value=session_id,
        httponly=True,
        secure=True,
        samesite="lax",
        max_age=3600  # 1 hour
    )

    return {"status": "logged_in"}
```

## Custom Response Headers

```python
from fastapi import Response

@app.get("/data")
async def get_data(response: Response):
    """Add custom response headers."""
    response.headers["X-Custom-Header"] = "value"
    response.headers["X-Processing-Time"] = "0.123"

    return {"data": "value"}
```

## Background Tasks

Execute tasks after returning response.

### Basic Background Task

```python
from fastapi import BackgroundTasks

def send_notification(email: str, message: str):
    """Send email notification (blocking operation)."""
    print(f"Sending email to {email}: {message}")
    # Simulate email sending
    import time
    time.sleep(2)

@app.post("/predict")
async def predict(
    data: dict,
    background_tasks: BackgroundTasks
):
    """Add background task."""
    # Process prediction immediately
    result = {"prediction": 0.5}

    # Send notification in background
    background_tasks.add_task(
        send_notification,
        email="user@example.com",
        message="Prediction completed"
    )

    return result  # Returns immediately
```

### Multiple Background Tasks

```python
from fastapi import BackgroundTasks

def log_prediction(model_id: int, result: dict):
    """Log prediction to database."""
    print(f"Logging: Model {model_id}, Result: {result}")

def update_metrics(model_id: int):
    """Update model metrics."""
    print(f"Updating metrics for model {model_id}")

@app.post("/predict")
async def predict(
    model_id: int,
    data: dict,
    background_tasks: BackgroundTasks
):
    """Chain multiple background tasks."""
    result = {"prediction": 0.5}

    # Add multiple tasks
    background_tasks.add_task(log_prediction, model_id, result)
    background_tasks.add_task(update_metrics, model_id)

    return result
```

### Async Background Tasks

```python
import asyncio
from fastapi import BackgroundTasks

async def async_notification(email: str):
    """Async background task."""
    await asyncio.sleep(1)
    print(f"Notification sent to {email}")

@app.post("/submit")
async def submit(data: dict, background_tasks: BackgroundTasks):
    """Use async background task."""
    background_tasks.add_task(async_notification, "user@example.com")
    return {"status": "submitted"}
```

## Complete Example: ML Prediction Service

```python
from fastapi import FastAPI, File, UploadFile, Form, BackgroundTasks, HTTPException
from pydantic import BaseModel, Field
from typing import Annotated, Optional
import hashlib
from pathlib import Path

app = FastAPI(title="ML Prediction Service")

# Models
class PredictionResult(BaseModel):
    """Prediction result."""
    prediction_id: str
    prediction: float
    confidence: float
    model_version: str

# Background tasks
async def log_prediction(
    prediction_id: str,
    user_id: int,
    result: float
):
    """Log prediction to database."""
    print(f"Logging prediction {prediction_id} for user {user_id}: {result}")
    # In production: save to database

async def send_notification(user_id: int, prediction_id: str):
    """Send completion notification."""
    print(f"Notifying user {user_id} about prediction {prediction_id}")
    # In production: send email/webhook

# Endpoints
@app.post("/predict/json", response_model=PredictionResult)
async def predict_json(
    features: list[float],
    model_version: str = "latest",
    user_id: Optional[int] = None,
    background_tasks: BackgroundTasks = None
):
    """Predict from JSON input."""
    # Generate prediction
    prediction_id = hashlib.md5(str(features).encode()).hexdigest()[:8]
    prediction = sum(features) / len(features)

    result = PredictionResult(
        prediction_id=prediction_id,
        prediction=prediction,
        confidence=0.95,
        model_version=model_version
    )

    # Log in background
    if background_tasks and user_id:
        background_tasks.add_task(
            log_prediction,
            prediction_id,
            user_id,
            prediction
        )

    return result

@app.post("/predict/file", response_model=PredictionResult)
async def predict_file(
    file: Annotated[UploadFile, File(description="Input data file")],
    model_version: Annotated[str, Form()] = "latest",
    user_id: Annotated[Optional[int], Form()] = None,
    background_tasks: BackgroundTasks = None
):
    """Predict from uploaded file."""
    # Validate file type
    if not file.filename.endswith(('.csv', '.json')):
        raise HTTPException(
            status_code=400,
            detail="File must be CSV or JSON"
        )

    # Read file
    contents = await file.read()
    prediction_id = hashlib.md5(contents).hexdigest()[:8]

    # Simulate prediction
    prediction = 0.75

    result = PredictionResult(
        prediction_id=prediction_id,
        prediction=prediction,
        confidence=0.92,
        model_version=model_version
    )

    # Background tasks
    if background_tasks and user_id:
        background_tasks.add_task(log_prediction, prediction_id, user_id, prediction)
        background_tasks.add_task(send_notification, user_id, prediction_id)

    return result

@app.post("/predict/batch")
async def predict_batch(
    file: Annotated[UploadFile, File()],
    background_tasks: BackgroundTasks
):
    """Process batch predictions in background."""
    # Save file
    file_path = f"uploads/{file.filename}"
    contents = await file.read()

    with open(file_path, "wb") as f:
        f.write(contents)

    # Process in background
    async def process_batch(path: str):
        """Background batch processing."""
        print(f"Processing batch file: {path}")
        # In production: load file, make predictions, save results

    background_tasks.add_task(process_batch, file_path)

    return {
        "status": "processing",
        "message": "Batch prediction started"
    }
```

## Best Practices

1. **Validate file uploads** - Check type, size, content
2. **Use background tasks** - For non-critical operations
3. **Stream large files** - Don't load entire file into memory
4. **Set cookie security flags** - httponly, secure, samesite
5. **Validate headers** - Don't trust client-provided data
6. **Use query params for filtering** - Body for data creation
7. **Limit file sizes** - Prevent DoS attacks
8. **Clean up uploaded files** - In background or with cleanup tasks

## Next Steps

Continue to [API Architecture & Database Integration](./03-api-architecture.md) to learn how to structure production APIs with SQLAlchemy and Alembic.

## Resources

- [FastAPI Request Files](https://fastapi.tiangolo.com/tutorial/request-files/)
- [Background Tasks](https://fastapi.tiangolo.com/tutorial/background-tasks/)
- [Form Data](https://fastapi.tiangolo.com/tutorial/request-forms/)
