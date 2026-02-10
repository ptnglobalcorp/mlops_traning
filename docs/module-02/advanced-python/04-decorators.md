# Decorators

**Master Python decorators for cleaner, more maintainable code**

## Overview

Decorators are a powerful Python feature that allows you to modify or enhance functions and classes without changing their source code. They wrap functions with additional functionality, following the decorator design pattern.

Think of decorators as "function modifiers" - they take a function, add behavior to it, and return the enhanced version.

## Why Use Decorators?

### Code Reusability

Write functionality once, apply it anywhere:

```python
@log_execution
def process_data(data):
    return data.upper()

@log_execution
def calculate_total(items):
    return sum(items)
```

### Separation of Concerns

Keep business logic separate from cross-cutting concerns (logging, timing, caching):

```python
# Business logic stays clean
@cache
@timing
def expensive_computation(n):
    return sum(i**2 for i in range(n))
```

### Cleaner Code

Decorators reduce boilerplate and make intent clear:

```python
# Without decorator (verbose)
def process():
    start = time.time()
    # logic here
    print(f"Took {time.time() - start}s")

# With decorator (clean)
@timing
def process():
    # logic here
    pass
```

## Basic Decorator Syntax

### Understanding the @ Symbol

The `@` symbol is syntactic sugar for function wrapping:

```python
# These are equivalent:
@decorator
def function():
    pass

# Same as:
def function():
    pass
function = decorator(function)
```

### Your First Decorator

```python
def my_decorator(func):
    """A simple decorator."""
    def wrapper():
        print("Before function")
        func()
        print("After function")
    return wrapper

@my_decorator
def say_hello():
    print("Hello!")

say_hello()
```

Output:

```
Before function
Hello!
After function
```

## Function Decorators

### Basic Function Decorator

```python
def timing_decorator(func):
    """Measure function execution time."""
    import time

    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} took {end - start:.4f}s")
        return result
    return wrapper

@timing_decorator
def slow_function():
    import time
    time.sleep(1)
    return "Done"

result = slow_function()  # Prints timing info
```

### Accepting Arguments

Decorators must handle function arguments:

```python
def log_args(func):
    """Log function arguments."""
    def wrapper(*args, **kwargs):
        print(f"Called {func.__name__} with args={args}, kwargs={kwargs}")
        return func(*args, **kwargs)
    return wrapper

@log_args
def add(a, b):
    return a + b

result = add(3, 5)  # Logs: Called add with args=(3, 5), kwargs={}
```

### Preserving Metadata with functools.wraps

Without `@wraps`, decorated functions lose their metadata:

```python
from functools import wraps

def my_decorator(func):
    @wraps(func)  # Preserves func's name, docstring, etc.
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper

@my_decorator
def documented_function():
    """This function has documentation."""
    pass

print(documented_function.__name__)  # 'documented_function' (not 'wrapper')
print(documented_function.__doc__)   # 'This function has documentation.'
```

**Always use `@wraps` in your decorators!**

## Decorators with Arguments

### Creating Parameterized Decorators

Decorators with arguments require an additional layer:

```python
def repeat(times):
    """Decorator that repeats function execution."""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            results = []
            for _ in range(times):
                results.append(func(*args, **kwargs))
            return results
        return wrapper
    return decorator

@repeat(times=3)
def greet(name):
    return f"Hello, {name}!"

result = greet("Alice")  # Returns list with 3 greetings
print(result)  # ['Hello, Alice!', 'Hello, Alice!', 'Hello, Alice!']
```

### Decorator Factory Pattern

```python
def retry(max_attempts=3, delay=1):
    """Retry failed function calls."""
    import time

    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts - 1:
                        raise
                    print(f"Attempt {attempt + 1} failed: {e}")
                    time.sleep(delay)
        return wrapper
    return decorator

@retry(max_attempts=3, delay=0.5)
def unstable_api_call():
    import random
    if random.random() < 0.7:
        raise ConnectionError("API unavailable")
    return "Success"
```

## Stacking Decorators

### Multiple Decorators

Decorators are applied bottom-to-top:

```python
def bold(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        return f"<b>{func(*args, **kwargs)}</b>"
    return wrapper

def italic(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        return f"<i>{func(*args, **kwargs)}</i>"
    return wrapper

@bold
@italic
def greet():
    return "Hello"

print(greet())  # <b><i>Hello</i></b>

# Order matters! This is equivalent to:
# greet = bold(italic(greet))
```

### Decorator Order Matters

```python
@decorator_a  # Applied last (outermost)
@decorator_b  # Applied first (innermost)
def function():
    pass

# Equivalent to:
function = decorator_a(decorator_b(function))
```

## Class Decorators

### Decorating Classes

```python
def singleton(cls):
    """Ensure only one instance of a class exists."""
    instances = {}

    @wraps(cls)
    def get_instance(*args, **kwargs):
        if cls not in instances:
            instances[cls] = cls(*args, **kwargs)
        return instances[cls]

    return get_instance

@singleton
class Database:
    def __init__(self):
        print("Database initialized")

db1 = Database()  # Prints: Database initialized
db2 = Database()  # Returns same instance (no print)
print(db1 is db2)  # True
```

### Class-Based Decorators

Using a class as a decorator:

```python
class CountCalls:
    """Count how many times a function is called."""

    def __init__(self, func):
        self.func = func
        self.count = 0

    def __call__(self, *args, **kwargs):
        self.count += 1
        print(f"Call {self.count} of {self.func.__name__}")
        return self.func(*args, **kwargs)

@CountCalls
def say_hello():
    print("Hello!")

say_hello()  # Call 1 of say_hello
say_hello()  # Call 2 of say_hello
```

## Built-in Decorators

### @property

Convert methods to computed attributes:

```python
class Circle:
    def __init__(self, radius):
        self._radius = radius

    @property
    def radius(self):
        """Get radius."""
        return self._radius

    @radius.setter
    def radius(self, value):
        """Set radius with validation."""
        if value < 0:
            raise ValueError("Radius must be positive")
        self._radius = value

    @property
    def area(self):
        """Computed property."""
        return 3.14159 * self._radius ** 2

circle = Circle(5)
print(circle.radius)  # 5 (looks like attribute)
print(circle.area)    # 78.53975 (computed)
circle.radius = 10    # Use setter
```

### @staticmethod

Methods that don't access instance or class:

```python
class MathUtils:
    @staticmethod
    def add(a, b):
        """No self or cls needed."""
        return a + b

# Can call without instance
result = MathUtils.add(3, 5)
```

### @classmethod

Methods that receive the class as first argument:

```python
class Date:
    def __init__(self, year, month, day):
        self.year = year
        self.month = month
        self.day = day

    @classmethod
    def from_string(cls, date_string):
        """Alternative constructor."""
        year, month, day = map(int, date_string.split('-'))
        return cls(year, month, day)

date = Date.from_string("2024-03-15")
print(f"{date.year}-{date.month}-{date.day}")
```

## Practical Use Cases

### Logging Decorator

```python
import logging
from functools import wraps

def log_function_call(func):
    """Log function calls with arguments and results."""
    @wraps(func)
    def wrapper(*args, **kwargs):
        logging.info(f"Calling {func.__name__}")
        logging.debug(f"  args={args}, kwargs={kwargs}")
        try:
            result = func(*args, **kwargs)
            logging.info(f"{func.__name__} returned {result}")
            return result
        except Exception as e:
            logging.error(f"{func.__name__} raised {e}")
            raise
    return wrapper

@log_function_call
def divide(a, b):
    return a / b
```

### Caching Decorator (Memoization)

```python
from functools import wraps

def cache(func):
    """Cache function results."""
    cached_results = {}

    @wraps(func)
    def wrapper(*args):
        if args not in cached_results:
            cached_results[args] = func(*args)
        return cached_results[args]

    return wrapper

@cache
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)

print(fibonacci(100))  # Fast due to caching
```

**Note:** Python's `functools.lru_cache` is a better built-in option:

```python
from functools import lru_cache

@lru_cache(maxsize=128)
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)
```

### Authentication Decorator

```python
from functools import wraps

def require_auth(func):
    """Check if user is authenticated."""
    @wraps(func)
    def wrapper(*args, **kwargs):
        # In real app, check session/token
        is_authenticated = kwargs.get('authenticated', False)

        if not is_authenticated:
            raise PermissionError("Authentication required")

        return func(*args, **kwargs)
    return wrapper

@require_auth
def view_dashboard(user_id, authenticated=False):
    return f"Dashboard for user {user_id}"

# Raises PermissionError
# view_dashboard(123)

# Works
view_dashboard(123, authenticated=True)
```

### Rate Limiting Decorator

```python
import time
from functools import wraps

def rate_limit(max_calls, period):
    """Limit function calls to max_calls per period (seconds)."""
    calls = []

    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            now = time.time()
            # Remove old calls outside the period
            calls[:] = [call for call in calls if call > now - period]

            if len(calls) >= max_calls:
                raise RuntimeError(f"Rate limit exceeded: {max_calls} calls per {period}s")

            calls.append(now)
            return func(*args, **kwargs)
        return wrapper
    return decorator

@rate_limit(max_calls=3, period=60)
def api_call():
    print("API called")
```

### Validation Decorator

```python
from functools import wraps

def validate_positive(func):
    """Ensure all arguments are positive numbers."""
    @wraps(func)
    def wrapper(*args, **kwargs):
        for arg in args:
            if not isinstance(arg, (int, float)) or arg <= 0:
                raise ValueError(f"All arguments must be positive numbers")
        return func(*args, **kwargs)
    return wrapper

@validate_positive
def calculate_area(length, width):
    return length * width

area = calculate_area(5, 10)  # Works
# calculate_area(-5, 10)  # Raises ValueError
```

## Advanced Patterns

### Decorators that Store State

```python
from functools import wraps

def count_calls(func):
    """Count and display function call statistics."""
    @wraps(func)
    def wrapper(*args, **kwargs):
        wrapper.call_count += 1
        return func(*args, **kwargs)

    wrapper.call_count = 0
    wrapper.get_stats = lambda: f"{func.__name__} called {wrapper.call_count} times"
    return wrapper

@count_calls
def process():
    pass

process()
process()
process()
print(process.get_stats())  # process called 3 times
```

### Conditional Decorators

```python
import os
from functools import wraps

def debug_only(func):
    """Only apply in debug mode."""
    if os.environ.get('DEBUG') == '1':
        @wraps(func)
        def wrapper(*args, **kwargs):
            print(f"DEBUG: Calling {func.__name__}")
            result = func(*args, **kwargs)
            print(f"DEBUG: {func.__name__} returned {result}")
            return result
        return wrapper
    return func  # Return unmodified in production

@debug_only
def compute(x):
    return x * 2
```

### Decorator with Optional Arguments

```python
from functools import wraps

def repeat(func=None, *, times=2):
    """Decorator that works with or without arguments."""
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            for _ in range(times):
                result = f(*args, **kwargs)
            return result
        return wrapper

    if func is None:
        # Called with arguments: @repeat(times=3)
        return decorator
    else:
        # Called without arguments: @repeat
        return decorator(func)

@repeat
def greet():
    print("Hello")

@repeat(times=3)
def wave():
    print("Wave")

greet()  # Prints Hello twice (default)
wave()   # Prints Wave three times
```

## Best Practices

### 1. Always Use @wraps

```python
from functools import wraps

def my_decorator(func):
    @wraps(func)  # IMPORTANT!
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper
```

### 2. Handle Arguments Properly

```python
def my_decorator(func):
    @wraps(func)
    def wrapper(*args, **kwargs):  # Accept any arguments
        return func(*args, **kwargs)  # Pass them through
    return wrapper
```

### 3. Make Decorators Composable

Design decorators to work well together:

```python
@cache
@timing
@log
def function():
    pass
```

### 4. Document Decorator Behavior

```python
def my_decorator(func):
    """Decorator that does X.

    This decorator wraps functions to provide Y functionality.

    Note:
        - Requirement A
        - Requirement B

    Example:
        @my_decorator
        def example():
            pass
    """
    @wraps(func)
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper
```

### 5. Consider Performance

Decorators add overhead - measure if it matters:

```python
# Avoid heavy operations in wrapper
def bad_decorator(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        # Don't do expensive work on every call!
        config = load_config_from_file()  # BAD
        return func(*args, **kwargs)
    return wrapper

# Move expensive operations outside
def good_decorator(func):
    config = load_config_from_file()  # GOOD - once at decoration time

    @wraps(func)
    def wrapper(*args, **kwargs):
        # Use preloaded config
        return func(*args, **kwargs)
    return wrapper
```

## Common Pitfalls

### Forgetting to Return the Function

```python
# Wrong
def broken_decorator(func):
    def wrapper(*args, **kwargs):
        func(*args, **kwargs)
    # Missing: return wrapper

# Correct
def working_decorator(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper  # Don't forget this!
```

### Not Preserving Return Values

```python
# Wrong
def broken_decorator(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        func(*args, **kwargs)  # Result is lost!
    return wrapper

# Correct
def working_decorator(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        result = func(*args, **kwargs)
        return result  # Preserve result
    return wrapper
```

### Decorator vs Decorator Factory Confusion

```python
# Decorator (no arguments)
def simple(func):
    return func

@simple
def function1():
    pass

# Decorator factory (with arguments)
def with_args(value):
    def decorator(func):
        return func
    return decorator

@with_args(42)  # Note the call
def function2():
    pass
```

## Summary

Decorators are a powerful tool for:

- **Code reuse**: Apply common functionality across functions
- **Separation of concerns**: Keep cross-cutting concerns separate
- **Clean code**: Reduce boilerplate and improve readability
- **Aspect-oriented programming**: Handle logging, caching, validation, etc.

Key concepts:

- Decorators wrap functions with additional behavior
- Use `@wraps` to preserve function metadata
- Decorators can accept arguments (decorator factories)
- Multiple decorators can be stacked
- Common uses: logging, timing, caching, authentication, validation

## Next Steps

Ready to practice? Head to the [Decorators Hands-On Lab](../../module-02/advanced-python/04-decorators/README.md).

## Additional Resources

- [PEP 318 - Decorators](https://peps.python.org/pep-0318/)
- [Python Decorator Library](https://wiki.python.org/moin/PythonDecoratorLibrary)
- [Real Python: Primer on Python Decorators](https://realpython.com/primer-on-python-decorators/)
- [functools documentation](https://docs.python.org/3/library/functools.html)
