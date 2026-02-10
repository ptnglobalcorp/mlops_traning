# FastAPI Fundamentals

**Master the core concepts of FastAPI for building ML APIs**

## Why FastAPI for MLOps?

FastAPI is the ideal framework for MLOps applications because it combines:

- **Performance**: Built on Starlette and Pydantic, one of the fastest Python frameworks
- **Type Safety**: Native Python type hints with runtime validation
- **Async Support**: First-class async/await for concurrent ML workloads
- **Auto Documentation**: OpenAPI (Swagger) docs generated automatically
- **Developer Experience**: Excellent IDE support with autocomplete
- **Production Ready**: Battle-tested in companies like Microsoft, Uber, Netflix

### FastAPI vs Alternatives

| Feature | FastAPI | Flask | Django REST |
|---------|---------|-------|-------------|
| Performance | Very High | Medium | Medium |
| Async Support | Native | Limited | Limited |
| Type Safety | Built-in | Manual | Manual |
| Auto Docs | Yes | No | Manual |
| Data Validation | Pydantic | Manual | DRF Serializers |
| Learning Curve | Low | Very Low | High |

For ML APIs handling concurrent inference requests, FastAPI's async capabilities and automatic validation make it the clear choice.

## Your First FastAPI Application

### Hello World

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}
```

Run with:

```bash
uvicorn main:app --reload
```

Visit:
- `http://localhost:8000/` - Your API
- `http://localhost:8000/docs` - Interactive Swagger UI
- `http://localhost:8000/redoc` - Alternative documentation

### Understanding the Basics

```python
from fastapi import FastAPI

# Create app instance with metadata
app = FastAPI(
    title="ML API",
    description="Production ML model serving",
    version="1.0.0"
)

# Define endpoint with decorator
@app.get("/")  # HTTP method + path
async def root():  # Async function
    return {"message": "Hello"}  # Auto-converted to JSON
```

**Key concepts:**
- `@app.get()` - Decorator defines HTTP method and path
- `async def` - Enables concurrent request handling
- Return value - Automatically serialized to JSON

## Path Operations

Path operations connect HTTP methods to Python functions.

### HTTP Methods

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/items")
async def read_items():
    """Retrieve items."""
    return {"items": []}

@app.post("/items")
async def create_item():
    """Create new item."""
    return {"created": True}

@app.put("/items/{item_id}")
async def update_item(item_id: int):
    """Update existing item."""
    return {"updated": item_id}

@app.delete("/items/{item_id}")
async def delete_item(item_id: int):
    """Delete item."""
    return {"deleted": item_id}

@app.patch("/items/{item_id}")
async def partial_update(item_id: int):
    """Partially update item."""
    return {"patched": item_id}
```

**Method Selection Guide:**
- `GET` - Retrieve data (idempotent, cacheable)
- `POST` - Create resources or trigger actions
- `PUT` - Full resource replacement
- `PATCH` - Partial resource update
- `DELETE` - Remove resources

### Path Parameters

Extract values from URL paths:

```python
@app.get("/models/{model_id}")
async def get_model(model_id: int):
    """Path parameter with type validation."""
    return {"model_id": model_id, "type": "classifier"}

@app.get("/models/{model_id}/versions/{version}")
async def get_model_version(model_id: int, version: str):
    """Multiple path parameters."""
    return {
        "model_id": model_id,
        "version": version
    }
```

**Type validation is automatic:**

```bash
# Valid: /models/123
# Invalid: /models/abc (422 Unprocessable Entity)
```

### Path Parameter Validation

Use Pydantic's `Path` for advanced validation:

```python
from fastapi import Path
from typing import Annotated

@app.get("/models/{model_id}")
async def get_model(
    model_id: Annotated[int, Path(
        title="Model ID",
        description="Unique identifier for the model",
        ge=1,  # Greater than or equal to 1
        le=1000  # Less than or equal to 1000
    )]
):
    return {"model_id": model_id}
```

## Request and Response Models

Use Pydantic models for type-safe request/response handling.

### Request Body Models

```python
from pydantic import BaseModel, Field

class PredictionInput(BaseModel):
    """Input schema for predictions."""
    features: list[float] = Field(
        min_length=1,
        max_length=100,
        description="Feature vector for prediction"
    )
    model_version: str = Field(
        default="latest",
        description="Model version to use"
    )

@app.post("/predict")
async def predict(data: PredictionInput):
    """Type-safe prediction endpoint."""
    # data is validated automatically
    return {
        "features_count": len(data.features),
        "model": data.model_version
    }
```

**Benefits:**
- Automatic validation before function executes
- Clear error messages for invalid data
- Auto-generated API documentation
- IDE autocomplete support

### Response Models

Define explicit response schemas:

```python
from pydantic import BaseModel

class PredictionOutput(BaseModel):
    """Output schema for predictions."""
    prediction: float
    confidence: float
    model_version: str

@app.post("/predict", response_model=PredictionOutput)
async def predict(data: PredictionInput) -> PredictionOutput:
    """Endpoint with explicit response type."""
    # Simulate prediction
    prediction = sum(data.features) / len(data.features)

    return PredictionOutput(
        prediction=prediction,
        confidence=0.95,
        model_version=data.model_version
    )
```

**Response model benefits:**
- Validates output data
- Filters extra fields (security)
- Documents response schema
- Enables response_model_exclude_unset

### Complex Models

```python
from pydantic import BaseModel, validator
from typing import Literal

class ImageInput(BaseModel):
    """Image classification input."""
    image_url: str
    preprocessing: Literal["resize", "crop", "pad"] = "resize"
    target_size: tuple[int, int] = (224, 224)

    @validator("image_url")
    def validate_url(cls, v):
        """Custom validation for URLs."""
        if not v.startswith(("http://", "https://")):
            raise ValueError("Must be valid HTTP(S) URL")
        return v

class ClassificationOutput(BaseModel):
    """Classification result."""
    class_name: str
    confidence: float
    top_k: list[dict[str, float]]

@app.post("/classify", response_model=ClassificationOutput)
async def classify_image(data: ImageInput) -> ClassificationOutput:
    """Image classification endpoint."""
    return ClassificationOutput(
        class_name="cat",
        confidence=0.98,
        top_k=[
            {"cat": 0.98},
            {"dog": 0.01},
            {"bird": 0.01}
        ]
    )
```

## Dependency Injection

FastAPI's dependency injection system manages shared resources and logic.

### Basic Dependencies

```python
from fastapi import Depends
from typing import Annotated

async def get_api_key(api_key: str) -> str:
    """Validate API key."""
    if api_key != "secret":
        raise HTTPException(status_code=401, detail="Invalid API key")
    return api_key

@app.get("/protected")
async def protected_route(
    api_key: Annotated[str, Depends(get_api_key)]
):
    """Route protected by API key."""
    return {"status": "authenticated"}
```

### Class-Based Dependencies

```python
from fastapi import Depends

class ModelDependency:
    """Dependency that loads ML model."""

    def __init__(self):
        self.model = None

    async def __call__(self):
        """Load model on first call."""
        if self.model is None:
            # Simulate model loading
            self.model = {"type": "classifier", "loaded": True}
        return self.model

get_model = ModelDependency()

@app.post("/predict")
async def predict(
    data: PredictionInput,
    model: Annotated[dict, Depends(get_model)]
):
    """Use model dependency."""
    return {
        "model_loaded": model["loaded"],
        "prediction": 0.5
    }
```

### Dependency Chains

Dependencies can depend on other dependencies:

```python
from typing import Annotated

async def get_db_connection():
    """Database connection dependency."""
    # Simulate DB connection
    return {"db": "connected"}

async def get_user(
    db: Annotated[dict, Depends(get_db_connection)],
    user_id: int
):
    """User lookup depends on DB."""
    return {"user_id": user_id, "db": db}

@app.get("/users/{user_id}")
async def read_user(
    user: Annotated[dict, Depends(get_user)]
):
    """Endpoint uses chained dependencies."""
    return user
```

### Application-Wide Dependencies

Apply dependencies to all routes:

```python
async def verify_token(token: str):
    """Validate authentication token."""
    if token != "valid":
        raise HTTPException(status_code=401)
    return token

# Apply to all routes
app = FastAPI(dependencies=[Depends(verify_token)])
```

## Error Handling

### HTTP Exceptions

```python
from fastapi import HTTPException, status

@app.get("/models/{model_id}")
async def get_model(model_id: int):
    """Get model with error handling."""
    if model_id > 100:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Model {model_id} not found"
        )
    return {"model_id": model_id}
```

### Custom Exception Handlers

```python
from fastapi import Request
from fastapi.responses import JSONResponse

class ModelNotFoundError(Exception):
    """Custom exception for missing models."""
    def __init__(self, model_id: int):
        self.model_id = model_id

@app.exception_handler(ModelNotFoundError)
async def model_not_found_handler(
    request: Request,
    exc: ModelNotFoundError
):
    """Handle custom exception."""
    return JSONResponse(
        status_code=404,
        content={
            "error": "Model not found",
            "model_id": exc.model_id
        }
    )

@app.get("/models/{model_id}")
async def get_model(model_id: int):
    """Raise custom exception."""
    if model_id > 100:
        raise ModelNotFoundError(model_id=model_id)
    return {"model_id": model_id}
```

### Validation Error Handling

FastAPI automatically handles Pydantic validation errors, but you can customize:

```python
from fastapi.exceptions import RequestValidationError
from fastapi.responses import PlainTextResponse

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """Custom validation error format."""
    return PlainTextResponse(
        str(exc),
        status_code=422
    )
```

## Status Codes

Use semantic HTTP status codes:

```python
from fastapi import status

@app.post("/models", status_code=status.HTTP_201_CREATED)
async def create_model(model: ModelInput):
    """Create model with 201 status."""
    return {"created": True}

@app.delete("/models/{model_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_model(model_id: int):
    """Delete with 204 (no content)."""
    pass  # No return value

@app.get("/health", status_code=status.HTTP_200_OK)
async def health_check():
    """Health check with explicit 200."""
    return {"status": "healthy"}
```

**Common status codes:**
- `200 OK` - Successful GET, PUT, PATCH
- `201 Created` - Successful POST
- `204 No Content` - Successful DELETE
- `400 Bad Request` - Invalid input
- `401 Unauthorized` - Missing/invalid auth
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource doesn't exist
- `422 Unprocessable Entity` - Validation error
- `500 Internal Server Error` - Server error

## Response Types

### JSON Responses (Default)

```python
@app.get("/data")
async def get_data():
    """Default JSON response."""
    return {"key": "value"}  # Automatically converted to JSON
```

### Custom Response Classes

```python
from fastapi.responses import JSONResponse, PlainTextResponse, HTMLResponse

@app.get("/custom-json")
async def custom_json():
    """Custom JSON with headers."""
    return JSONResponse(
        content={"message": "Custom"},
        headers={"X-Custom-Header": "value"}
    )

@app.get("/text", response_class=PlainTextResponse)
async def get_text():
    """Plain text response."""
    return "This is plain text"

@app.get("/html", response_class=HTMLResponse)
async def get_html():
    """HTML response."""
    return "<html><body><h1>Hello</h1></body></html>"
```

## API Documentation

FastAPI generates interactive documentation automatically.

### Customizing Documentation

```python
from fastapi import FastAPI

app = FastAPI(
    title="ML Model API",
    description="Production ML model serving API",
    version="2.0.0",
    docs_url="/api/docs",  # Custom docs URL
    redoc_url="/api/redoc",  # Custom ReDoc URL
    openapi_url="/api/openapi.json"  # OpenAPI schema URL
)
```

### Documenting Endpoints

```python
@app.post(
    "/predict",
    response_model=PredictionOutput,
    summary="Make a prediction",
    description="Generate predictions using the trained model",
    response_description="Prediction result with confidence score",
    tags=["predictions"]
)
async def predict(data: PredictionInput) -> PredictionOutput:
    """
    Make a prediction using the ML model.

    - **features**: Input feature vector
    - **model_version**: Which model version to use

    Returns prediction with confidence score.
    """
    return PredictionOutput(
        prediction=0.5,
        confidence=0.95,
        model_version=data.model_version
    )
```

### Organizing with Tags

```python
@app.get("/models", tags=["models"])
async def list_models():
    """List available models."""
    return []

@app.post("/predict", tags=["predictions"])
async def predict(data: PredictionInput):
    """Make prediction."""
    return {}

@app.get("/health", tags=["monitoring"])
async def health():
    """Health check."""
    return {"status": "healthy"}
```

## Complete Example: ML Prediction API

```python
from fastapi import FastAPI, HTTPException, status, Depends
from pydantic import BaseModel, Field
from typing import Annotated
import numpy as np

app = FastAPI(
    title="ML Prediction API",
    description="Production-ready ML model serving",
    version="1.0.0"
)

# Models
class PredictionInput(BaseModel):
    """Input for prediction."""
    features: list[float] = Field(
        min_length=4,
        max_length=4,
        description="4 feature values"
    )

class PredictionOutput(BaseModel):
    """Prediction result."""
    prediction: float
    confidence: float
    model_version: str

# Dependencies
class MLModel:
    """ML model singleton."""
    _instance = None

    def __init__(self):
        # Simulate model loading
        self.weights = np.array([0.5, -0.3, 0.2, 0.8])
        self.version = "1.0.0"

    @classmethod
    def get_instance(cls):
        """Get model instance."""
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    def predict(self, features: list[float]) -> tuple[float, float]:
        """Make prediction."""
        features_array = np.array(features)
        prediction = np.dot(features_array, self.weights)
        confidence = 0.95  # Simulate confidence
        return float(prediction), confidence

async def get_model() -> MLModel:
    """Dependency to get model."""
    return MLModel.get_instance()

# Endpoints
@app.get("/", tags=["root"])
async def root():
    """API root."""
    return {
        "name": "ML Prediction API",
        "version": "1.0.0",
        "docs": "/docs"
    }

@app.get("/health", tags=["monitoring"])
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy"}

@app.post(
    "/predict",
    response_model=PredictionOutput,
    tags=["predictions"],
    summary="Make a prediction"
)
async def predict(
    data: PredictionInput,
    model: Annotated[MLModel, Depends(get_model)]
) -> PredictionOutput:
    """
    Generate prediction from input features.

    The model expects exactly 4 numerical features.
    Returns prediction value and confidence score.
    """
    try:
        prediction, confidence = model.predict(data.features)

        return PredictionOutput(
            prediction=prediction,
            confidence=confidence,
            model_version=model.version
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Prediction failed: {str(e)}"
        )

@app.get("/models/info", tags=["models"])
async def model_info(
    model: Annotated[MLModel, Depends(get_model)]
):
    """Get model information."""
    return {
        "version": model.version,
        "input_features": 4,
        "output_type": "regression"
    }
```

## Best Practices

1. **Use async/await consistently** - Don't mix sync and async unnecessarily
2. **Define response models** - Explicit contracts prevent bugs
3. **Validate early** - Use Pydantic for all inputs
4. **Use dependency injection** - Share logic and resources cleanly
5. **Document with docstrings** - They appear in auto-generated docs
6. **Use tags** - Organize endpoints logically
7. **Handle errors explicitly** - Don't let exceptions bubble up
8. **Use type hints everywhere** - Enable IDE support and validation

## Next Steps

Now that you understand FastAPI fundamentals:

1. **Practice**: Build a simple ML API with your own model
2. **Next**: Learn [Advanced Request Handling](./02-advanced-requests.md)
3. **Explore**: FastAPI interactive docs at `/docs`

## Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Pydantic Documentation](https://docs.pydantic.dev/)
- [Starlette Documentation](https://www.starlette.io/)
