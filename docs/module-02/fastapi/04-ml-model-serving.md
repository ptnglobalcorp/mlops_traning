# ML Model Serving & Streaming

**Serve ML models efficiently with streaming responses**

## Overview

Production ML APIs need efficient model serving: loading models at startup, managing multiple versions, handling batch predictions, and streaming responses for real-time applications. This guide covers practical patterns for serving ML models with FastAPI.

## Model Loading and Caching

### Application Startup Loading

Load models during application startup for optimal performance:

```python
from fastapi import FastAPI
from contextlib import asynccontextmanager
import joblib
from pathlib import Path

# Global model storage
models = {}

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Load models on startup, clean up on shutdown."""
    # Startup: Load models
    print("Loading ML models...")

    models["classifier_v1"] = joblib.load("models/classifier_v1.pkl")
    models["classifier_v2"] = joblib.load("models/classifier_v2.pkl")
    models["regressor"] = joblib.load("models/regressor.pkl")

    print(f"Loaded {len(models)} models")

    yield  # Application runs

    # Shutdown: Clean up
    print("Cleaning up models...")
    models.clear()

app = FastAPI(lifespan=lifespan)
```

### Dependency Injection for Models

```python
from fastapi import Depends, HTTPException
from typing import Annotated

def get_model(model_name: str):
    """Get model by name from global cache."""
    if model_name not in models:
        raise HTTPException(
            status_code=404,
            detail=f"Model '{model_name}' not found"
        )
    return models[model_name]

@app.post("/predict/{model_name}")
async def predict(
    model_name: str,
    features: list[float],
    model: Annotated[object, Depends(lambda: get_model(model_name))]
):
    """Use dependency injection for model access."""
    prediction = model.predict([features])[0]
    return {"prediction": float(prediction)}
```

## Prediction Endpoints

### Single Prediction

```python
from pydantic import BaseModel, Field

class PredictionInput(BaseModel):
    """Single prediction input."""
    features: list[float] = Field(min_length=1)

class PredictionOutput(BaseModel):
    """Prediction result."""
    prediction: float
    model_version: str
    confidence: float | None = None

@app.post("/predict", response_model=PredictionOutput)
async def predict_single(
    data: PredictionInput,
    model_version: str = "v1"
) -> PredictionOutput:
    """Make single prediction."""
    model = model_manager.get_model("classifier", model_version)

    # Predict
    prediction = model.predict([data.features])[0]

    # Get confidence if available
    confidence = None
    if hasattr(model, "predict_proba"):
        proba = model.predict_proba([data.features])[0]
        confidence = float(max(proba))

    return PredictionOutput(
        prediction=float(prediction),
        model_version=model_version,
        confidence=confidence
    )
```

### Batch Predictions

```python
from typing import List

class BatchPredictionInput(BaseModel):
    """Batch prediction input."""
    instances: list[list[float]] = Field(min_length=1, max_length=1000)

class BatchPredictionOutput(BaseModel):
    """Batch prediction output."""
    predictions: list[float]
    count: int
    model_version: str

@app.post("/predict/batch", response_model=BatchPredictionOutput)
async def predict_batch(
    data: BatchPredictionInput,
    model_version: str = "v1"
) -> BatchPredictionOutput:
    """Make batch predictions."""
    model = model_manager.get_model("classifier", model_version)

    # Batch predict
    predictions = model.predict(data.instances)

    return BatchPredictionOutput(
        predictions=[float(p) for p in predictions],
        count=len(predictions),
        model_version=model_version
    )
```

### Async Batch Processing

```python
import asyncio
from typing import List

async def predict_async(model: Any, features: list[float]) -> float:
    """Async prediction wrapper."""
    # Run blocking predict in thread pool
    return await asyncio.to_thread(model.predict, [features])

@app.post("/predict/batch/async")
async def predict_batch_async(
    data: BatchPredictionInput,
    model_version: str = "v1"
):
    """Process batch predictions concurrently."""
    model = model_manager.get_model("classifier", model_version)

    # Create tasks for concurrent execution
    tasks = [
        predict_async(model, features)
        for features in data.instances
    ]

    # Wait for all predictions
    results = await asyncio.gather(*tasks)

    return {
        "predictions": [float(r[0]) for r in results],
        "count": len(results),
        "model_version": model_version
    }
```

## Model Versioning

### Version Management

```python
from enum import Enum

class ModelVersion(str, Enum):
    """Available model versions."""
    V1 = "v1"
    V2 = "v2"
    LATEST = "latest"

@app.post("/predict")
async def predict_versioned(
    features: list[float],
    version: ModelVersion = ModelVersion.LATEST
):
    """Predict with version enum."""
    # Map 'latest' to actual version
    actual_version = "v2" if version == ModelVersion.LATEST else version.value

    model = model_manager.get_model("classifier", actual_version)
    prediction = model.predict([features])[0]

    return {
        "prediction": float(prediction),
        "version_requested": version.value,
        "version_used": actual_version
    }
```

### A/B Testing

```python
import random

@app.post("/predict/ab-test")
async def predict_ab_test(
    features: list[float],
    user_id: str
):
    """A/B test between model versions."""
    # Deterministic assignment based on user_id
    version = "v2" if hash(user_id) % 2 == 0 else "v1"

    model = model_manager.get_model("classifier", version)
    prediction = model.predict([features])[0]

    return {
        "prediction": float(prediction),
        "model_version": version,
        "user_id": user_id
    }
```

## Server-Sent Events (SSE)

SSE enables server-to-client streaming for real-time updates.

### Basic SSE Implementation

```python
from fastapi.responses import StreamingResponse
import asyncio

async def event_generator(count: int):
    """Generate server-sent events."""
    for i in range(count):
        # Simulate processing
        await asyncio.sleep(0.5)

        # Yield SSE formatted data
        yield f"data: {i}\n\n"

@app.get("/stream/events")
async def stream_events(count: int = 10):
    """Stream events to client."""
    return StreamingResponse(
        event_generator(count),
        media_type="text/event-stream"
    )
```

**Client consumption (JavaScript):**

```javascript
const eventSource = new EventSource("/stream/events?count=10");

eventSource.onmessage = (event) => {
  console.log("Received:", event.data);
};

eventSource.onerror = () => {
  eventSource.close();
};
```

### Streaming Predictions

```python
from typing import AsyncGenerator

async def stream_predictions(
    features_list: list[list[float]],
    model: Any
) -> AsyncGenerator[str, None]:
    """Stream predictions as they complete."""
    for idx, features in enumerate(features_list):
        # Make prediction
        prediction = await asyncio.to_thread(
            model.predict,
            [features]
        )

        # Format as SSE
        result = {
            "index": idx,
            "prediction": float(prediction[0])
        }
        yield f"data: {json.dumps(result)}\n\n"

        # Small delay between predictions
        await asyncio.sleep(0.1)

@app.post("/predict/stream")
async def predict_stream(data: BatchPredictionInput, model_version: str = "v1"):
    """Stream batch predictions."""
    model = model_manager.get_model("classifier", model_version)

    return StreamingResponse(
        stream_predictions(data.instances, model),
        media_type="text/event-stream"
    )
```

### Streaming LLM Responses

Perfect for token-by-token text generation:

```python
async def generate_text_stream(prompt: str) -> AsyncGenerator[str, None]:
    """Simulate LLM streaming generation."""
    tokens = [
        "The", "quick", "brown", "fox", "jumps",
        "over", "the", "lazy", "dog"
    ]

    for token in tokens:
        await asyncio.sleep(0.2)  # Simulate generation time

        # Stream each token
        yield f"data: {json.dumps({'token': token})}\n\n"

    # Send completion signal
    yield f"data: {json.dumps({'done': True})}\n\n"

@app.post("/generate/stream")
async def stream_generation(prompt: str):
    """Stream LLM token generation."""
    return StreamingResponse(
        generate_text_stream(prompt),
        media_type="text/event-stream"
    )
```

### Progress Updates

```python
async def training_progress(epochs: int) -> AsyncGenerator[str, None]:
    """Stream training progress."""
    for epoch in range(1, epochs + 1):
        await asyncio.sleep(1)  # Simulate epoch

        progress = {
            "epoch": epoch,
            "total_epochs": epochs,
            "loss": 1.0 / epoch,  # Simulated loss
            "accuracy": 1.0 - (1.0 / epoch)  # Simulated accuracy
        }

        yield f"data: {json.dumps(progress)}\n\n"

    # Final message
    yield f"data: {json.dumps({'status': 'complete'})}\n\n"

@app.post("/train/stream")
async def stream_training(epochs: int = 10):
    """Stream training progress."""
    return StreamingResponse(
        training_progress(epochs),
        media_type="text/event-stream"
    )
```

## WebSocket for Real-Time Predictions

WebSocket enables bidirectional communication for interactive ML applications.

### Basic WebSocket

```python
from fastapi import WebSocket, WebSocketDisconnect

@app.websocket("/ws/predict")
async def websocket_predict(websocket: WebSocket):
    """WebSocket prediction endpoint."""
    await websocket.accept()

    try:
        while True:
            # Receive data from client
            data = await websocket.receive_json()

            features = data.get("features", [])
            model_version = data.get("version", "v1")

            # Make prediction
            model = model_manager.get_model("classifier", model_version)
            prediction = model.predict([features])[0]

            # Send response
            await websocket.send_json({
                "prediction": float(prediction),
                "model_version": model_version
            })

    except WebSocketDisconnect:
        print("Client disconnected")
```

**Client usage (JavaScript):**

```javascript
const ws = new WebSocket("ws://localhost:8000/ws/predict");

ws.onopen = () => {
  ws.send(
    JSON.stringify({
      features: [1.0, 2.0, 3.0],
      version: "v1",
    }),
  );
};

ws.onmessage = (event) => {
  const result = JSON.parse(event.data);
  console.log("Prediction:", result.prediction);
};
```

### Connection Manager

```python
from typing import List

class ConnectionManager:
    """Manage WebSocket connections."""

    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        """Accept and store connection."""
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        """Remove connection."""
        self.active_connections.remove(websocket)

    async def send_personal(self, message: dict, websocket: WebSocket):
        """Send to specific connection."""
        await websocket.send_json(message)

    async def broadcast(self, message: dict):
        """Send to all connections."""
        for connection in self.active_connections:
            await connection.send_json(message)

manager = ConnectionManager()

@app.websocket("/ws/predictions")
async def websocket_endpoint(websocket: WebSocket):
    """Managed WebSocket connection."""
    await manager.connect(websocket)

    try:
        while True:
            data = await websocket.receive_json()

            # Process prediction
            features = data["features"]
            model = model_manager.get_model("classifier", "v1")
            prediction = model.predict([features])[0]

            # Send back to client
            await manager.send_personal(
                {"prediction": float(prediction)},
                websocket
            )

    except WebSocketDisconnect:
        manager.disconnect(websocket)
```

### Real-Time Monitoring

```python
import time

@app.websocket("/ws/monitor")
async def monitor_stream(websocket: WebSocket):
    """Stream real-time model metrics."""
    await websocket.accept()

    try:
        while True:
            # Collect metrics
            metrics = {
                "timestamp": time.time(),
                "active_models": len(model_manager.models),
                "memory_mb": 128.5,  # Placeholder
                "requests_per_sec": 45.2  # Placeholder
            }

            await websocket.send_json(metrics)
            await asyncio.sleep(1)  # Update every second

    except WebSocketDisconnect:
        pass
```

## Streaming File Uploads/Downloads

### Stream File Upload

```python
from fastapi import UploadFile

@app.post("/upload/stream")
async def upload_stream(file: UploadFile):
    """Stream file upload processing."""
    chunk_size = 1024 * 1024  # 1MB chunks
    total_size = 0

    async def process_chunks():
        """Process file in chunks."""
        nonlocal total_size

        while chunk := await file.read(chunk_size):
            total_size += len(chunk)
            # Process chunk (e.g., save to disk, upload to S3)
            yield f"data: {json.dumps({'bytes_processed': total_size})}\n\n"

    return StreamingResponse(
        process_chunks(),
        media_type="text/event-stream"
    )
```

### Stream File Download

```python
from pathlib import Path

async def file_stream(file_path: Path):
    """Stream file download in chunks."""
    chunk_size = 1024 * 1024  # 1MB

    with open(file_path, "rb") as f:
        while chunk := f.read(chunk_size):
            yield chunk

@app.get("/download/model/{model_name}")
async def download_model(model_name: str):
    """Stream model file download."""
    file_path = Path(f"models/{model_name}.pkl")

    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Model not found")

    return StreamingResponse(
        file_stream(file_path),
        media_type="application/octet-stream",
        headers={
            "Content-Disposition": f"attachment; filename={model_name}.pkl"
        }
    )
```

## When to Use Each Streaming Method

### Server-Sent Events (SSE)

**Use when:**

- Server pushes updates to client
- One-way communication (server → client)
- Progress updates, notifications, logs
- LLM token streaming
- Training progress monitoring

**Advantages:**

- Simple to implement
- Automatic reconnection
- Works over HTTP
- Native browser support

### WebSocket

**Use when:**

- Bidirectional communication needed
- Real-time interactive applications
- Chat, collaborative editing
- Gaming, live predictions
- Low latency required

**Advantages:**

- Full-duplex communication
- Lower overhead than SSE
- Better for high-frequency updates

### Regular HTTP Streaming

**Use when:**

- File uploads/downloads
- Large data transfers
- Video/audio streaming

## Complete Example: Real-Time Prediction Service

```python
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Depends
from fastapi.responses import StreamingResponse
from contextlib import asynccontextmanager
from typing import AsyncGenerator
import asyncio
import json

# Model manager (from previous examples)
model_manager = ModelManager()

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Load models on startup."""
    await model_manager.load_model("classifier", "v1")
    await model_manager.load_model("classifier", "v2")
    yield
    model_manager.models.clear()

app = FastAPI(lifespan=lifespan)

# SSE: Stream batch predictions
@app.post("/predict/stream")
async def stream_predictions(data: BatchPredictionInput):
    """Stream predictions as SSE."""

    async def predict_stream() -> AsyncGenerator[str, None]:
        model = model_manager.get_model("classifier", "v1")

        for idx, features in enumerate(data.instances):
            prediction = await asyncio.to_thread(
                model.predict,
                [features]
            )

            result = {
                "index": idx,
                "prediction": float(prediction[0])
            }

            yield f"data: {json.dumps(result)}\n\n"
            await asyncio.sleep(0.05)

    return StreamingResponse(
        predict_stream(),
        media_type="text/event-stream"
    )

# WebSocket: Interactive predictions
@app.websocket("/ws/predict")
async def websocket_predict(websocket: WebSocket):
    """Real-time prediction over WebSocket."""
    await websocket.accept()

    try:
        while True:
            data = await websocket.receive_json()
            features = data["features"]
            version = data.get("version", "v1")

            model = model_manager.get_model("classifier", version)
            prediction = await asyncio.to_thread(
                model.predict,
                [features]
            )

            await websocket.send_json({
                "prediction": float(prediction[0]),
                "version": version
            })

    except WebSocketDisconnect:
        pass
```

## Best Practices

1. **Load models at startup** - Don't reload on each request
2. **Use async for I/O** - Model loading, file operations
3. **Cache predictions** - For identical inputs
4. **Batch when possible** - More efficient than single predictions
5. **Choose right streaming method** - SSE for push, WebSocket for bidirectional
6. **Handle disconnections** - Clean up resources properly
7. **Monitor memory** - Unload unused models
8. **Version models** - Support multiple versions simultaneously

## Next Steps

Continue to [Testing FastAPI](./05-testing.md) to learn how to test your ML APIs comprehensively.

## Resources

- [FastAPI WebSocket](https://fastapi.tiangolo.com/advanced/websockets/)
- [StreamingResponse](https://fastapi.tiangolo.com/advanced/custom-response/#streamingresponse)
- [Server-Sent Events Spec](https://html.spec.whatwg.org/multipage/server-sent-events.html)
