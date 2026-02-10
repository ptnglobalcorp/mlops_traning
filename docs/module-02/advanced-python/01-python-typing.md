# Python Typing

**Master type hints and static type checking for safer, more maintainable Python code**

## Overview

Type hints (also called type annotations) allow you to specify the expected types of variables, function parameters, and return values in your Python code. While Python remains dynamically typed at runtime, type hints enable static type checkers like `mypy` and `pyright` to catch type-related errors before your code runs.

Think of type hints as documentation that your IDE and tools can understand and verify. They make your code self-documenting, catch bugs early, and improve code completion in modern IDEs.

## Why Use Type Hints?

### Benefits

**Catch Errors Early**

```python
def calculate_discount(price: float, discount: float) -> float:
    return price * discount

# Type checker catches this before runtime
result = calculate_discount("100", 0.1)  # Error: Expected float, got str
```

**Better IDE Support**

Your IDE can provide accurate autocomplete and inline documentation when it knows the types.

**Self-Documenting Code**

Type hints make function signatures clearer without needing to read docstrings.

```python
# Without types - what do these parameters mean?
def process_user(data, active, tags):
    pass

# With types - crystal clear
def process_user(data: dict[str, Any], active: bool, tags: list[str]) -> User:
    pass
```

**Easier Refactoring**

Type checkers help you find all the places that need updating when you change a function signature or data structure.

**Team Collaboration**

Type hints establish a contract between code components, making it easier for teams to work together on large codebases.

## Basic Type Annotations

### Simple Types

```python
# Variable annotations
name: str = "Alice"
age: int = 30
height: float = 5.8
is_active: bool = True

# Function parameters and return types
def greet(name: str) -> str:
    return f"Hello, {name}!"

# No return value
def log_message(message: str) -> None:
    print(message)
```

### The `None` Type

```python
from typing import Optional

# Function that might return None
def find_user(user_id: int) -> Optional[str]:
    if user_id == 1:
        return "Alice"
    return None

# Equivalent modern syntax (Python 3.10+)
def find_user(user_id: int) -> str | None:
    if user_id == 1:
        return "Alice"
    return None
```

## Collection Types

### Built-in Collection Annotations

Python 3.9+ allows using built-in collection types directly for annotations:

```python
# Lists
def process_names(names: list[str]) -> list[str]:
    return [name.upper() for name in names]

# Dictionaries
def get_user_scores() -> dict[str, int]:
    return {"Alice": 95, "Bob": 87}

# Sets
def unique_tags() -> set[str]:
    return {"python", "typing", "tutorial"}

# Tuples with fixed size
def get_coordinates() -> tuple[float, float]:
    return (40.7128, -74.0060)

# Tuples with variable size
def get_values() -> tuple[int, ...]:
    return (1, 2, 3, 4, 5)
```

### The `typing` Module (Pre-3.9 or Complex Types)

```python
from typing import List, Dict, Set, Tuple

# Same as above, but works in Python 3.7-3.8
def process_names(names: List[str]) -> List[str]:
    return [name.upper() for name in names]
```

### Nested Collections

```python
# List of dictionaries
def get_users() -> list[dict[str, str]]:
    return [
        {"name": "Alice", "email": "alice@example.com"},
        {"name": "Bob", "email": "bob@example.com"},
    ]

# Dictionary with list values
def get_user_tags() -> dict[str, list[str]]:
    return {
        "Alice": ["python", "docker"],
        "Bob": ["kubernetes", "terraform"],
    }
```

## Optional and Union Types

### Optional Values

```python
from typing import Optional

# These two are equivalent
def find_user(user_id: int) -> Optional[str]:
    pass

def find_user(user_id: int) -> str | None:
    pass
```

### Union Types

```python
from typing import Union

# Accept multiple types (old syntax)
def process_id(id: Union[int, str]) -> str:
    return str(id)

# Modern syntax (Python 3.10+)
def process_id(id: int | str) -> str:
    return str(id)

# Multiple unions
def parse_value(value: int | float | str | None) -> float:
    if value is None:
        return 0.0
    return float(value)
```

## Type Aliases

Type aliases make complex types more readable and reusable.

```python
from typing import TypeAlias

# Simple alias
UserID: TypeAlias = int
Username: TypeAlias = str

def get_user(user_id: UserID) -> Username:
    return "Alice"

# Complex alias
UserData: TypeAlias = dict[str, int | str | list[str]]

def process_user(data: UserData) -> None:
    print(data)

# Usage
user: UserData = {
    "name": "Alice",
    "age": 30,
    "tags": ["python", "mlops"]
}
```

### NewType

`NewType` creates a distinct type that prevents accidental mixing:

```python
from typing import NewType

# Create distinct types
UserID = NewType('UserID', int)
OrderID = NewType('OrderID', int)

def get_user(user_id: UserID) -> str:
    return f"User {user_id}"

def get_order(order_id: OrderID) -> str:
    return f"Order {order_id}"

# Create values
user_id = UserID(123)
order_id = OrderID(456)

# This works
get_user(user_id)

# Type checker catches this error
get_user(order_id)  # Error: Expected UserID, got OrderID
get_user(123)       # Error: Expected UserID, got int
```

## Generic Types and TypeVar

Generics allow you to write functions and classes that work with any type while maintaining type safety.

### Basic TypeVar

```python
from typing import TypeVar

# Define a type variable
T = TypeVar('T')

def first_element(items: list[T]) -> T:
    return items[0]

# Type checker infers return type based on input
numbers: list[int] = [1, 2, 3]
first_num: int = first_element(numbers)  # Returns int

names: list[str] = ["Alice", "Bob"]
first_name: str = first_element(names)   # Returns str
```

### Constrained TypeVar

```python
from typing import TypeVar

# Constrain to specific types
NumberType = TypeVar('NumberType', int, float)

def add_numbers(a: NumberType, b: NumberType) -> NumberType:
    return a + b

# Works with int or float
result1 = add_numbers(1, 2)      # OK: int
result2 = add_numbers(1.5, 2.5)  # OK: float
result3 = add_numbers("a", "b")  # Error: str not allowed
```

### Bounded TypeVar

```python
from typing import TypeVar

class Animal:
    def speak(self) -> str:
        return "Some sound"

class Dog(Animal):
    def speak(self) -> str:
        return "Woof"

# T must be Animal or a subclass
T = TypeVar('T', bound=Animal)

def make_speak(animal: T) -> T:
    print(animal.speak())
    return animal

dog = Dog()
make_speak(dog)  # OK: Dog is subclass of Animal
```

### Generic Classes

```python
from typing import Generic, TypeVar

T = TypeVar('T')

class Stack(Generic[T]):
    def __init__(self) -> None:
        self._items: list[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

    def pop(self) -> T:
        return self._items.pop()

# Create type-specific stacks
int_stack: Stack[int] = Stack()
int_stack.push(1)
int_stack.push(2)
value: int = int_stack.pop()

str_stack: Stack[str] = Stack()
str_stack.push("hello")
str_stack.push(123)  # Error: Expected str, got int
```

## Protocol and Structural Subtyping

Protocols define interfaces based on structure, not inheritance (duck typing with type safety).

```python
from typing import Protocol

class Drawable(Protocol):
    def draw(self) -> str:
        ...

class Circle:
    def draw(self) -> str:
        return "Drawing circle"

class Square:
    def draw(self) -> str:
        return "Drawing square"

# Function accepts anything with a draw() method
def render(shape: Drawable) -> None:
    print(shape.draw())

# Both work without inheriting from Drawable
render(Circle())  # OK
render(Square())  # OK
```

### Protocol with Properties

```python
from typing import Protocol

class Sized(Protocol):
    @property
    def size(self) -> int:
        ...

class File:
    def __init__(self, content: str) -> None:
        self._content = content

    @property
    def size(self) -> int:
        return len(self._content)

def log_size(obj: Sized) -> None:
    print(f"Size: {obj.size}")

file = File("hello")
log_size(file)  # OK: File implements the Sized protocol
```

## The `Any` Type

`Any` disables type checking for a value. Use sparingly.

```python
from typing import Any

def process_data(data: Any) -> Any:
    # Type checker won't complain about anything here
    return data.whatever.method()  # No error even if this is wrong

# Better: Use specific types when possible
def process_user(data: dict[str, Any]) -> str:
    # At least we know it's a dict
    return data["name"]
```

## Runtime Type Checking

Type hints don't affect runtime behavior, but you can check them programmatically.

```python
from typing import get_type_hints

def calculate_price(base: float, tax: float) -> float:
    return base * (1 + tax)

# Get type hints as a dictionary
hints = get_type_hints(calculate_price)
print(hints)
# Output: {'base': <class 'float'>, 'tax': <class 'float'>, 'return': <class 'float'>}
```

## Integration with Static Type Checkers

### Using mypy

**Install mypy:**

```bash
pip install mypy
```

**Check your code:**

```bash
mypy your_script.py
```

**Example output:**

```
your_script.py:10: error: Argument 1 to "calculate_discount" has incompatible type "str"; expected "float"
Found 1 error in 1 file (checked 1 source file)
```

### Using pyright

**Install pyright:**

```bash
npm install -g pyright
# or
pip install pyright
```

**Check your code:**

```bash
pyright your_script.py
```

### Configuration

**mypy.ini or pypy.ini:**

```ini
[mypy]
python_version = 3.10
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True
```

**pyproject.toml:**

```toml
[tool.mypy]
python_version = "3.10"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

[tool.pyright]
pythonVersion = "3.10"
typeCheckingMode = "strict"
```

## Best Practices

### Start Gradually

You don't need to type everything at once. Start with public APIs and gradually add types to internal code.

```python
# Start here: Type public function signatures
def calculate_price(base: float, tax: float) -> float:
    return _apply_discount(base, tax)

# Can add types to private functions later
def _apply_discount(base, tax):
    return base * (1 - tax)
```

### Use Type Checkers in CI/CD

Add type checking to your continuous integration pipeline:

```yaml
# .github/workflows/ci.yml
- name: Type check with mypy
  run: mypy src/
```

### Prefer Specific Types Over Any

```python
# Bad: Too vague
def process(data: Any) -> Any:
    return data["result"]

# Good: Specific and safe
def process(data: dict[str, int]) -> int:
    return data["result"]
```

### Use Union Sparingly

If you find yourself using many unions, consider refactoring:

```python
# Bad: Too many unions
def process(value: int | str | list | dict | None) -> str:
    pass

# Better: Use a common protocol or base class
from typing import Protocol

class Serializable(Protocol):
    def to_string(self) -> str:
        ...

def process(value: Serializable) -> str:
    return value.to_string()
```

### Annotate Complex Return Types

```python
# Unclear
def get_user():
    return {"name": "Alice", "scores": [95, 87, 92]}

# Clear
def get_user() -> dict[str, str | list[int]]:
    return {"name": "Alice", "scores": [95, 87, 92]}
```

## Common Pitfalls

### Mutable Default Arguments

```python
# Bad: Mutable default argument
def add_item(items: list[str] = []) -> list[str]:
    items.append("new")
    return items

# Good: Use None and create new list
def add_item(items: list[str] | None = None) -> list[str]:
    if items is None:
        items = []
    items.append("new")
    return items
```

### Circular Imports

Use forward references for types defined later:

```python
from __future__ import annotations
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from my_module import MyClass

def process(obj: MyClass) -> None:
    pass
```

### Over-Specifying Types

```python
# Bad: Too specific, hard to extend
def process(numbers: list[int]) -> list[int]:
    return [n * 2 for n in numbers]

# Good: More flexible with protocols
from typing import Sequence

def process(numbers: Sequence[int]) -> list[int]:
    return [n * 2 for n in numbers]
```

## Advanced Topics

### Callable Types

```python
from typing import Callable

# Function that takes a function
def apply_operation(
    value: int,
    operation: Callable[[int], int]
) -> int:
    return operation(value)

def double(x: int) -> int:
    return x * 2

result = apply_operation(5, double)  # 10
```

### Literal Types

```python
from typing import Literal

def set_log_level(level: Literal["DEBUG", "INFO", "WARNING", "ERROR"]) -> None:
    print(f"Log level set to {level}")

set_log_level("INFO")    # OK
set_log_level("TRACE")   # Error: Not a valid literal
```

### TypedDict

```python
from typing import TypedDict

class UserDict(TypedDict):
    name: str
    age: int
    email: str

def create_user(user: UserDict) -> None:
    print(f"Creating user: {user['name']}")

# Valid
user: UserDict = {"name": "Alice", "age": 30, "email": "alice@example.com"}
create_user(user)

# Type checker catches missing keys
invalid_user: UserDict = {"name": "Bob"}  # Error: Missing 'age' and 'email'
```

## Summary

Type hints are a powerful tool for writing more maintainable Python code. They provide documentation, enable better tooling, and catch errors early. Start by adding types to your function signatures, then gradually expand to more complex scenarios.

## Next Steps

Ready to practice? Head to the [Python Typing Lab](../../module-02/advanced-python/01-typing/README.md) to work through hands-on exercises.

## Additional Resources

- [Official Python typing documentation](https://docs.python.org/3/library/typing.html)
- [mypy documentation](https://mypy.readthedocs.io/)
- [Pyright documentation](https://github.com/microsoft/pyright)
- [PEP 484 - Type Hints](https://peps.python.org/pep-0484/)
- [PEP 585 - Type Hinting Generics In Standard Collections](https://peps.python.org/pep-0585/)
