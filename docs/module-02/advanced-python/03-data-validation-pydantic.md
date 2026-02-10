# Data Validation with Pydantic

**Build robust, type-safe data models with automatic validation**

## Overview

Pydantic is a data validation library that uses Python type hints to validate data at runtime. It's the foundation of FastAPI and used extensively in modern Python applications for API validation, configuration management, and data parsing.

Think of Pydantic as "types that actually work at runtime" - it catches data errors before they cause problems in your application.

## Why Use Pydantic?

### Runtime Validation

Type hints alone don't prevent bad data at runtime. Pydantic does:

```python
from pydantic import BaseModel

class User(BaseModel):
    name: str
    age: int

# This raises a validation error immediately
try:
    user = User(name="Alice", age="not a number")
except ValidationError as e:
    print("Caught invalid data!")
```

### Automatic Parsing

Pydantic converts data to the correct types automatically:

```python
user = User(name="Alice", age="30")  # String "30" becomes int 30
print(user.age)  # 30 (int, not str)
```

### Clear Error Messages

When validation fails, you get helpful error messages:

```python
from pydantic import ValidationError

try:
    User(name=123, age="invalid")
except ValidationError as e:
    print(e)
```

Output:

```
2 validation errors for User
name
  Input should be a valid string [type=string_type, input_value=123, input_type=int]
age
  Input should be a valid integer [type=int_type, input_value='invalid', input_type=str]
```

### JSON Serialization

Built-in JSON support:

```python
user = User(name="Alice", age=30)
print(user.model_dump_json())  # {"name":"Alice","age":30}
```

### IDE Support

Works seamlessly with type checkers and IDEs for autocomplete and type checking.

## Installation

```bash
# With uv
uv add pydantic

# With pip
pip install pydantic

# With email validation support
uv add "pydantic[email]"
```

## BaseModel Fundamentals

### Creating Your First Model

```python
from pydantic import BaseModel

class User(BaseModel):
    id: int
    name: str
    email: str
    is_active: bool = True  # Default value

# Create instance
user = User(id=1, name="Alice", email="alice@example.com")

# Access fields
print(user.name)  # Alice
print(user.is_active)  # True (default)
```

### Model Methods

```python
# Convert to dictionary
user_dict = user.model_dump()
print(user_dict)
# {'id': 1, 'name': 'Alice', 'email': 'alice@example.com', 'is_active': True}

# Convert to JSON string
user_json = user.model_dump_json()
print(user_json)
# {"id":1,"name":"Alice","email":"alice@example.com","is_active":true}

# Create from dictionary
user2 = User(**user_dict)

# Create from JSON string
import json
user3 = User(**json.loads(user_json))
```

### Accessing Model Fields

```python
# Dot notation
print(user.name)

# Dictionary-style (not recommended)
print(user.model_dump()['name'])

# Get all field names
print(user.model_fields.keys())
# dict_keys(['id', 'name', 'email', 'is_active'])
```

## Field Validation and Constraints

### Basic Constraints

```python
from pydantic import BaseModel, Field

class Product(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    price: float = Field(gt=0, le=1000000)  # Greater than 0, less/equal 1M
    quantity: int = Field(ge=0)  # Greater or equal to 0
    description: str | None = Field(default=None, max_length=500)

# Valid
product = Product(name="Laptop", price=999.99, quantity=5)

# Invalid - raises ValidationError
try:
    Product(name="", price=-10, quantity=-1)
except ValidationError as e:
    print(e)
```

### Field Constraints

| Constraint | Description | Example |
|------------|-------------|---------|
| `min_length` | Minimum string length | `Field(min_length=3)` |
| `max_length` | Maximum string length | `Field(max_length=50)` |
| `gt` | Greater than | `Field(gt=0)` |
| `ge` | Greater than or equal | `Field(ge=0)` |
| `lt` | Less than | `Field(lt=100)` |
| `le` | Less than or equal | `Field(le=100)` |
| `pattern` | Regex pattern | `Field(pattern=r'^\d{3}-\d{3}$')` |
| `default` | Default value | `Field(default="N/A")` |
| `default_factory` | Default factory function | `Field(default_factory=list)` |

### String Validation

```python
from pydantic import BaseModel, Field

class Account(BaseModel):
    username: str = Field(min_length=3, max_length=20, pattern=r'^[a-zA-Z0-9_]+$')
    password: str = Field(min_length=8)
    bio: str = Field(default="", max_length=500)

# Valid
account = Account(username="alice_123", password="SecurePass123")

# Invalid username (has spaces)
try:
    Account(username="alice 123", password="SecurePass123")
except ValidationError as e:
    print("Invalid username format")
```

### Numeric Validation

```python
from pydantic import BaseModel, Field

class Measurement(BaseModel):
    temperature: float = Field(ge=-273.15, le=1000)  # Kelvin min, reasonable max
    humidity: float = Field(ge=0, le=100)  # Percentage
    pressure: int = Field(gt=0)

measurement = Measurement(temperature=25.5, humidity=60.0, pressure=1013)
```

## Custom Validators

### Field Validators (Pydantic v2)

```python
from pydantic import BaseModel, field_validator

class User(BaseModel):
    username: str
    email: str
    age: int

    @field_validator('username')
    @classmethod
    def username_alphanumeric(cls, v: str) -> str:
        if not v.isalnum():
            raise ValueError('Username must be alphanumeric')
        return v

    @field_validator('email')
    @classmethod
    def email_must_have_at(cls, v: str) -> str:
        if '@' not in v:
            raise ValueError('Invalid email format')
        return v.lower()  # Normalize to lowercase

    @field_validator('age')
    @classmethod
    def age_must_be_adult(cls, v: int) -> int:
        if v < 18:
            raise ValueError('Must be 18 or older')
        return v

# Valid
user = User(username="alice123", email="Alice@Example.com", age=25)
print(user.email)  # alice@example.com (normalized)

# Invalid
try:
    User(username="alice-123", email="invalid", age=15)
except ValidationError as e:
    print(e)
```

### Model Validators

Validate across multiple fields:

```python
from pydantic import BaseModel, model_validator

class DateRange(BaseModel):
    start_date: str
    end_date: str

    @model_validator(mode='after')
    def check_dates(self) -> 'DateRange':
        if self.start_date >= self.end_date:
            raise ValueError('end_date must be after start_date')
        return self

# Valid
date_range = DateRange(start_date="2024-01-01", end_date="2024-12-31")

# Invalid
try:
    DateRange(start_date="2024-12-31", end_date="2024-01-01")
except ValidationError as e:
    print("Date range validation failed")
```

### Before and After Validators

```python
from pydantic import BaseModel, field_validator

class Password(BaseModel):
    value: str

    @field_validator('value', mode='before')
    @classmethod
    def strip_whitespace(cls, v):
        # Runs before type validation
        if isinstance(v, str):
            return v.strip()
        return v

    @field_validator('value', mode='after')
    @classmethod
    def check_strength(cls, v: str) -> str:
        # Runs after type validation
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        if not any(c.isupper() for c in v):
            raise ValueError('Password must contain uppercase letter')
        if not any(c.isdigit() for c in v):
            raise ValueError('Password must contain digit')
        return v

# Whitespace is stripped automatically
password = Password(value="  SecurePass123  ")
print(password.value)  # "SecurePass123"
```

## Nested Models

### Basic Nesting

```python
from pydantic import BaseModel

class Address(BaseModel):
    street: str
    city: str
    country: str
    postal_code: str

class Person(BaseModel):
    name: str
    age: int
    address: Address  # Nested model

# Create with nested data
person = Person(
    name="Alice",
    age=30,
    address={
        "street": "123 Main St",
        "city": "New York",
        "country": "USA",
        "postal_code": "10001"
    }
)

# Access nested fields
print(person.address.city)  # New York

# Export to dict preserves structure
print(person.model_dump())
```

### Lists of Models

```python
from pydantic import BaseModel

class Item(BaseModel):
    name: str
    price: float
    quantity: int

class Order(BaseModel):
    order_id: int
    items: list[Item]  # List of nested models

order = Order(
    order_id=1001,
    items=[
        {"name": "Laptop", "price": 999.99, "quantity": 1},
        {"name": "Mouse", "price": 29.99, "quantity": 2},
    ]
)

# Calculate total
total = sum(item.price * item.quantity for item in order.items)
print(f"Total: ${total:.2f}")  # Total: $1059.97
```

### Complex Nesting

```python
from pydantic import BaseModel

class Tag(BaseModel):
    name: str
    color: str

class Comment(BaseModel):
    author: str
    text: str
    likes: int = 0

class Post(BaseModel):
    title: str
    content: str
    tags: list[Tag]
    comments: list[Comment]
    metadata: dict[str, str | int]

post = Post(
    title="Python Tips",
    content="Learn Pydantic...",
    tags=[
        {"name": "python", "color": "blue"},
        {"name": "tutorial", "color": "green"}
    ],
    comments=[
        {"author": "Bob", "text": "Great post!", "likes": 5}
    ],
    metadata={"views": 1000, "category": "tutorial"}
)
```

## Special Field Types

### EmailStr

```python
from pydantic import BaseModel, EmailStr

class User(BaseModel):
    email: EmailStr  # Validates email format

# Requires: uv add "pydantic[email]"

user = User(email="alice@example.com")  # Valid

try:
    User(email="not-an-email")  # Invalid
except ValidationError as e:
    print("Invalid email")
```

### HttpUrl

```python
from pydantic import BaseModel, HttpUrl

class Website(BaseModel):
    url: HttpUrl

site = Website(url="https://example.com")
print(site.url)  # https://example.com/

try:
    Website(url="not a url")
except ValidationError as e:
    print("Invalid URL")
```

### UUID

```python
from pydantic import BaseModel
from uuid import UUID

class Resource(BaseModel):
    id: UUID
    name: str

import uuid
resource = Resource(
    id=uuid.uuid4(),
    name="My Resource"
)

# Also accepts UUID strings
resource2 = Resource(
    id="123e4567-e89b-12d3-a456-426614174000",
    name="Another Resource"
)
```

### DateTime

```python
from pydantic import BaseModel
from datetime import datetime

class Event(BaseModel):
    name: str
    timestamp: datetime

# Accepts ISO format strings
event = Event(
    name="Conference",
    timestamp="2024-03-15T10:00:00"
)

# Also accepts datetime objects
from datetime import datetime
event2 = Event(
    name="Meeting",
    timestamp=datetime.now()
)
```

### Literal

```python
from pydantic import BaseModel
from typing import Literal

class Config(BaseModel):
    env: Literal["dev", "staging", "prod"]
    log_level: Literal["DEBUG", "INFO", "WARNING", "ERROR"]

config = Config(env="prod", log_level="INFO")  # Valid

try:
    Config(env="production", log_level="TRACE")  # Invalid
except ValidationError as e:
    print("Must use exact literal values")
```

## Model Configuration

### Config Class

```python
from pydantic import BaseModel, ConfigDict

class User(BaseModel):
    model_config = ConfigDict(
        str_strip_whitespace=True,  # Strip strings
        str_to_lower=False,  # Don't lowercase
        validate_assignment=True,  # Validate on attribute assignment
        frozen=False,  # Allow mutation
    )

    name: str
    email: str

user = User(name="  Alice  ", email="alice@example.com")
print(user.name)  # "Alice" (stripped)

# With validate_assignment=True
user.name = "Bob"  # This triggers validation
```

### Frozen Models (Immutable)

```python
from pydantic import BaseModel, ConfigDict

class ImmutableUser(BaseModel):
    model_config = ConfigDict(frozen=True)

    id: int
    name: str

user = ImmutableUser(id=1, name="Alice")

try:
    user.name = "Bob"  # Error: model is frozen
except ValidationError:
    print("Cannot modify frozen model")
```

### Arbitrary Types

```python
from pydantic import BaseModel, ConfigDict
import numpy as np

class DataModel(BaseModel):
    model_config = ConfigDict(arbitrary_types_allowed=True)

    data: np.ndarray  # Non-Pydantic type

model = DataModel(data=np.array([1, 2, 3]))
```

## JSON Serialization

### Basic Serialization

```python
from pydantic import BaseModel

class User(BaseModel):
    id: int
    name: str
    tags: list[str]

user = User(id=1, name="Alice", tags=["python", "ml"])

# To dict
print(user.model_dump())
# {'id': 1, 'name': 'Alice', 'tags': ['python', 'ml']}

# To JSON string
print(user.model_dump_json())
# {"id":1,"name":"Alice","tags":["python","ml"]}

# From JSON
import json
json_str = '{"id": 2, "name": "Bob", "tags": ["data"]}'
user2 = User(**json.loads(json_str))
```

### Exclude Fields

```python
from pydantic import BaseModel, Field

class User(BaseModel):
    id: int
    name: str
    password: str = Field(exclude=True)  # Never serialize
    api_key: str

user = User(id=1, name="Alice", password="secret", api_key="key123")

# Password is excluded
print(user.model_dump())
# {'id': 1, 'name': 'Alice', 'api_key': 'key123'}

# Exclude additional fields dynamically
print(user.model_dump(exclude={'api_key'}))
# {'id': 1, 'name': 'Alice'}
```

### Include Only Specific Fields

```python
user_summary = user.model_dump(include={'id', 'name'})
print(user_summary)
# {'id': 1, 'name': 'Alice'}
```

### Custom Serialization

```python
from pydantic import BaseModel, field_serializer

class User(BaseModel):
    name: str
    email: str

    @field_serializer('email')
    def mask_email(self, value: str) -> str:
        # Mask email for privacy
        username, domain = value.split('@')
        return f"{username[0]}***@{domain}"

user = User(name="Alice", email="alice@example.com")
print(user.model_dump_json())
# {"name":"Alice","email":"a***@example.com"}
```

## Integration with FastAPI

Pydantic is the foundation of FastAPI:

```python
from fastapi import FastAPI
from pydantic import BaseModel, Field

app = FastAPI()

class UserCreate(BaseModel):
    username: str = Field(min_length=3, max_length=50)
    email: str
    age: int = Field(ge=18)

class UserResponse(BaseModel):
    id: int
    username: str
    email: str

@app.post("/users/", response_model=UserResponse)
def create_user(user: UserCreate):
    # user is automatically validated
    # Invalid data returns 422 error automatically
    new_user = UserResponse(
        id=1,
        username=user.username,
        email=user.email
    )
    return new_user
```

Benefits:
- **Automatic validation**: FastAPI validates request bodies
- **Auto-generated docs**: OpenAPI schema from models
- **Type safety**: End-to-end type checking
- **Clear errors**: Detailed validation error responses

## Pydantic v2 Features

### Computed Fields

```python
from pydantic import BaseModel, computed_field

class Product(BaseModel):
    name: str
    price: float
    tax_rate: float = 0.1

    @computed_field
    @property
    def price_with_tax(self) -> float:
        return self.price * (1 + self.tax_rate)

product = Product(name="Laptop", price=1000)
print(product.price_with_tax)  # 1100.0
print(product.model_dump())
# {'name': 'Laptop', 'price': 1000.0, 'tax_rate': 0.1, 'price_with_tax': 1100.0}
```

### Field Aliases

```python
from pydantic import BaseModel, Field

class APIResponse(BaseModel):
    user_id: int = Field(alias="userId")  # Accept camelCase from API
    user_name: str = Field(alias="userName")

# Parse camelCase JSON
data = {"userId": 123, "userName": "alice"}
response = APIResponse(**data)

print(response.user_id)  # 123
print(response.user_name)  # alice
```

### Model Inheritance

```python
from pydantic import BaseModel

class BaseUser(BaseModel):
    id: int
    username: str

class AdminUser(BaseUser):
    is_admin: bool = True
    permissions: list[str]

admin = AdminUser(
    id=1,
    username="admin",
    permissions=["read", "write", "delete"]
)
```

## Performance Considerations

### Pydantic is Fast

Pydantic v2 is written in Rust and is extremely fast:

- 5-50x faster than Pydantic v1
- Comparable to hand-written validation code
- Minimal overhead for most applications

### Optimization Tips

```python
# 1. Use model_construct for trusted data (skips validation)
user = User.model_construct(id=1, name="Alice")

# 2. Validate only once
users = [User(**data) for data in bulk_data]  # Each validated

# 3. Use TypeAdapter for list validation
from pydantic import TypeAdapter

UserList = TypeAdapter(list[User])
users = UserList.validate_python(bulk_data)
```

## Best Practices

### 1. Use Field Descriptions

```python
from pydantic import BaseModel, Field

class User(BaseModel):
    """User model with validated fields."""

    id: int = Field(description="Unique user identifier")
    username: str = Field(
        min_length=3,
        max_length=50,
        description="Username (3-50 alphanumeric characters)"
    )
    email: str = Field(description="User email address")
```

### 2. Separate Input and Output Models

```python
class UserCreate(BaseModel):
    """Model for creating users."""
    username: str
    email: str
    password: str

class User(BaseModel):
    """Model for user responses (no password)."""
    id: int
    username: str
    email: str
    created_at: datetime
```

### 3. Use Validators for Business Logic

```python
from pydantic import BaseModel, field_validator

class Order(BaseModel):
    items: list[str]
    total: float

    @field_validator('items')
    @classmethod
    def items_not_empty(cls, v):
        if not v:
            raise ValueError('Order must have at least one item')
        return v

    @field_validator('total')
    @classmethod
    def total_positive(cls, v):
        if v <= 0:
            raise ValueError('Total must be positive')
        return v
```

### 4. Document with Examples

```python
from pydantic import BaseModel, Field

class Product(BaseModel):
    """Product information.

    Example:
        ```python
        product = Product(
            name="Laptop",
            price=999.99,
            in_stock=True
        )
        ```
    """
    name: str = Field(examples=["Laptop", "Mouse", "Keyboard"])
    price: float = Field(gt=0, examples=[999.99, 29.99])
    in_stock: bool = Field(default=True)
```

## Common Pitfalls

### Mutable Defaults

```python
# Bad: Mutable default is shared across instances
class BadModel(BaseModel):
    tags: list[str] = []  # DON'T DO THIS

# Good: Use default_factory
from pydantic import Field

class GoodModel(BaseModel):
    tags: list[str] = Field(default_factory=list)
```

### Overvalidation

```python
# Bad: Too strict, limits flexibility
class StrictUser(BaseModel):
    email: str = Field(pattern=r'^[a-z]+@[a-z]+\.[a-z]+$')  # Too restrictive

# Good: Use appropriate validators
from pydantic import EmailStr

class FlexibleUser(BaseModel):
    email: EmailStr  # Handles most valid emails
```

## Summary

Pydantic provides:

- **Runtime validation** with type hints
- **Automatic type conversion** and parsing
- **Clear error messages** for debugging
- **JSON serialization** out of the box
- **Custom validators** for business logic
- **Nested models** for complex data
- **FastAPI integration** for web APIs

It's essential for building robust Python applications that handle external data.

## Next Steps

Ready to practice? Head to the [Pydantic Hands-On Lab](../../module-02/advanced-python/03-pydantic/README.md) to work through exercises.

## Additional Resources

- [Official Pydantic documentation](https://docs.pydantic.dev/)
- [Pydantic v2 migration guide](https://docs.pydantic.dev/latest/migration/)
- [FastAPI with Pydantic](https://fastapi.tiangolo.com/)
- [Pydantic GitHub](https://github.com/pydantic/pydantic)
