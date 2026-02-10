# Async/Await

**Master asynchronous programming for efficient concurrent I/O operations**

## Overview

Asynchronous programming with async/await enables writing concurrent code that looks synchronous. It's essential for I/O-bound operations like network requests, file operations, and database queries where traditional synchronous code would waste CPU time waiting.

Think of async/await as "cooperative multitasking" - your program voluntarily yields control when waiting for I/O, allowing other tasks to run.

## Why Use Async/Await?

### The Problem: Synchronous I/O is Slow

```python
import time

def fetch_data(url):
    time.sleep(1)  # Simulate network delay
    return f"Data from {url}"

def synchronous_example():
    start = time.time()

    # Each call waits for the previous to complete
    data1 = fetch_data("url1")  # Wait 1s
    data2 = fetch_data("url2")  # Wait 1s
    data3 = fetch_data("url3")  # Wait 1s

    print(f"Total time: {time.time() - start:.2f}s")  # ~3 seconds
    return [data1, data2, data3]
```

**Problem:** Total time = sum of all wait times (3 seconds)

### The Solution: Async Concurrent Execution

```python
import asyncio

async def fetch_data_async(url):
    await asyncio.sleep(1)  # Simulate async network delay
    return f"Data from {url}"

async def async_example():
    start = time.time()

    # All calls start simultaneously
    results = await asyncio.gather(
        fetch_data_async("url1"),
        fetch_data_async("url2"),
        fetch_data_async("url3")
    )

    print(f"Total time: {time.time() - start:.2f}s")  # ~1 second
    return results

# Run it
asyncio.run(async_example())
```

**Solution:** Total time ≈ longest single wait time (1 second)

### Benefits

**Better Resource Utilization**
- One thread handles thousands of connections
- No threading overhead
- Lower memory footprint

**Perfect for I/O-Bound Operations**
- Web requests
- Database queries
- File operations
- API calls
- WebSocket connections

**Simpler Than Threading**
- No locks or mutexes
- No race conditions (single-threaded)
- Easier to reason about

## Understanding Concurrency vs Parallelism

### Key Concepts

**Concurrency**: Multiple tasks making progress (but not necessarily simultaneously)
**Parallelism**: Multiple tasks executing simultaneously (requires multiple cores)

### Concurrency: Doing Multiple Things

```python
# Concurrency: One chef managing multiple dishes
# - Starts pasta boiling (I/O: waiting for water)
# - While waiting, chops vegetables (CPU work)
# - Checks pasta, stirs sauce (I/O: waiting for timer)
# - Back to vegetables

# ONE person, MULTIPLE tasks making progress
```

**Async/await is concurrency, not parallelism** - one thread switches between tasks during I/O waits.

### Parallelism: Doing Things Simultaneously

```python
# Parallelism: Multiple chefs, each making a dish
# - Chef 1: Pasta (running on CPU core 1)
# - Chef 2: Vegetables (running on CPU core 2)
# - Chef 3: Dessert (running on CPU core 3)

# MULTIPLE people, working at SAME TIME
```

**For parallelism in Python, use multiprocessing** (not async/await).

### Visual Comparison

**Synchronous (Sequential):**
```
Task A: |████████████| (3s)
Task B:              |████████████| (3s)
Task C:                           |████████████| (3s)
Time:   0s          3s            6s            9s
Total: 9 seconds
```

**Concurrent (Async/await):**
```
Task A: |████████████| (3s)
Task B: |████████████| (3s)
Task C: |████████████| (3s)
Time:   0s          3s
Total: 3 seconds (all waiting simultaneously)
```

**Parallel (Multiprocessing):**
```
Core 1: |████████████| Task A (3s)
Core 2: |████████████| Task B (3s)
Core 3: |████████████| Task C (3s)
Time:   0s          3s
Total: 3 seconds (all executing simultaneously)
```

### When to Use What

**Use Async/Await (Concurrency):**
- ✅ Network requests (HTTP, WebSocket)
- ✅ Database queries
- ✅ File I/O operations
- ✅ API calls
- ✅ Waiting for external services

**Use Multiprocessing (Parallelism):**
- ✅ CPU-intensive computations
- ✅ Image/video processing
- ✅ Data analysis
- ✅ Machine learning inference
- ✅ Cryptographic operations

**Use Threading (Limited Cases):**
- ✅ Legacy libraries without async support
- ✅ Simple concurrent tasks
- ⚠️ Limited by Python's GIL (Global Interpreter Lock)

### The Event Loop

Async/await is powered by the **event loop** - a scheduler that manages task execution:

```python
# Event loop workflow:
# 1. Start Task A
# 2. Task A hits 'await' (I/O) → suspend Task A
# 3. Start Task B
# 4. Task B hits 'await' (I/O) → suspend Task B
# 5. Task A's I/O completes → resume Task A
# 6. Task A finishes → remove from queue
# 7. Task B's I/O completes → resume Task B
# 8. Task B finishes → all done
```

**Key Point:** Only one task executes at a time, but tasks yield control during I/O waits.

## Basic Async/Await Syntax

### Async Functions (Coroutines)

```python
# Regular function
def regular_function():
    return "Hello"

# Async function (coroutine)
async def async_function():
    return "Hello"

# Calling them
result1 = regular_function()  # Returns "Hello"
result2 = async_function()    # Returns coroutine object (not "Hello"!)

# To get the result, you must await it
import asyncio
result3 = asyncio.run(async_function())  # Returns "Hello"
```

### The await Keyword

`await` pauses execution until the awaited operation completes:

```python
import asyncio

async def fetch_data():
    print("Starting fetch...")
    await asyncio.sleep(2)  # Pause here for 2 seconds
    print("Fetch complete!")
    return "Data"

async def main():
    print("Before await")
    result = await fetch_data()  # Wait for fetch_data to complete
    print(f"After await: {result}")

asyncio.run(main())
```

Output:
```
Before await
Starting fetch...
(2 second pause)
Fetch complete!
After await: Data
```

### Rules of Async/Await

1. **`await` only works in `async` functions**
   ```python
   # ❌ Wrong
   def regular_function():
       await something()  # SyntaxError

   # ✅ Correct
   async def async_function():
       await something()  # Works
   ```

2. **`async` functions always return coroutines**
   ```python
   async def example():
       return 42

   # Must use asyncio.run() or await
   result = asyncio.run(example())  # 42
   ```

3. **You can only await coroutines, tasks, or futures**
   ```python
   # ✅ Can await
   await async_function()
   await asyncio.sleep(1)
   await asyncio.create_task(...)

   # ❌ Cannot await
   await regular_function()  # TypeError
   await 42  # TypeError
   ```

## Running Async Code

### Method 1: asyncio.run() (Recommended)

```python
import asyncio

async def main():
    print("Hello")
    await asyncio.sleep(1)
    print("World")

# Run the async function
asyncio.run(main())
```

**Best for:** Top-level entry point, scripts

### Method 2: await (Inside Async Functions)

```python
async def task1():
    return "Task 1"

async def task2():
    result = await task1()  # Await inside another async function
    return f"Task 2 got: {result}"

asyncio.run(task2())
```

**Best for:** Calling async functions from other async functions

### Method 3: Event Loop (Advanced)

```python
import asyncio

async def main():
    return "Result"

# Manual event loop management
loop = asyncio.get_event_loop()
try:
    result = loop.run_until_complete(main())
finally:
    loop.close()
```

**Best for:** Advanced use cases, custom event loops

## Concurrent Execution Patterns

### Pattern 1: asyncio.gather() - Run Multiple Tasks

```python
import asyncio

async def fetch_user(user_id):
    await asyncio.sleep(1)
    return f"User {user_id}"

async def main():
    # Start all tasks concurrently
    results = await asyncio.gather(
        fetch_user(1),
        fetch_user(2),
        fetch_user(3)
    )
    print(results)  # ['User 1', 'User 2', 'User 3']

asyncio.run(main())
```

**Characteristics:**
- All tasks start immediately
- Waits for all to complete
- Returns results in order
- One failure cancels all

### Pattern 2: asyncio.create_task() - Fire and Forget

```python
import asyncio

async def background_task(name):
    await asyncio.sleep(2)
    print(f"{name} completed")

async def main():
    # Create tasks (start immediately)
    task1 = asyncio.create_task(background_task("Task 1"))
    task2 = asyncio.create_task(background_task("Task 2"))

    # Do other work while tasks run
    print("Tasks started, doing other work...")
    await asyncio.sleep(1)
    print("Still doing work...")

    # Wait for tasks to complete
    await task1
    await task2

asyncio.run(main())
```

**Characteristics:**
- Tasks start immediately
- More control over task lifecycle
- Can await tasks individually
- Can cancel tasks

### Pattern 3: asyncio.wait() - Advanced Control

```python
import asyncio

async def task(n):
    await asyncio.sleep(n)
    return n

async def main():
    tasks = [asyncio.create_task(task(i)) for i in [1, 2, 3]]

    # Wait for first task to complete
    done, pending = await asyncio.wait(
        tasks,
        return_when=asyncio.FIRST_COMPLETED
    )

    print(f"First completed: {done.pop().result()}")

    # Cancel remaining tasks
    for task in pending:
        task.cancel()

asyncio.run(main())
```

**Characteristics:**
- Fine-grained control
- Can wait for first/all/any completion
- Returns done and pending sets
- Useful for timeouts

### Pattern 4: asyncio.as_completed() - Process Results as They Arrive

```python
import asyncio

async def fetch_data(url, delay):
    await asyncio.sleep(delay)
    return f"Data from {url}"

async def main():
    tasks = [
        fetch_data("url1", 3),
        fetch_data("url2", 1),
        fetch_data("url3", 2)
    ]

    # Process results as they complete
    for coro in asyncio.as_completed(tasks):
        result = await coro
        print(f"Got: {result}")

asyncio.run(main())
```

Output (order based on completion):
```
Got: Data from url2  # Completed first (1s)
Got: Data from url3  # Completed second (2s)
Got: Data from url1  # Completed last (3s)
```

## Async Context Managers

### Basic Async Context Manager

```python
import asyncio

class AsyncDatabaseConnection:
    async def __aenter__(self):
        print("Connecting to database...")
        await asyncio.sleep(1)  # Simulate connection time
        print("Connected!")
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        print("Closing connection...")
        await asyncio.sleep(0.5)  # Simulate cleanup
        print("Connection closed")

    async def query(self, sql):
        await asyncio.sleep(0.1)
        return f"Results for: {sql}"

async def main():
    async with AsyncDatabaseConnection() as db:
        result = await db.query("SELECT * FROM users")
        print(result)

asyncio.run(main())
```

Output:
```
Connecting to database...
Connected!
Results for: SELECT * FROM users
Closing connection...
Connection closed
```

### Real-World Example: Async HTTP Session

```python
import aiohttp
import asyncio

async def fetch_url(session, url):
    async with session.get(url) as response:
        return await response.text()

async def main():
    # Session manages connection pooling
    async with aiohttp.ClientSession() as session:
        html1 = await fetch_url(session, "https://example.com")
        html2 = await fetch_url(session, "https://example.org")
        print(f"Fetched {len(html1)} and {len(html2)} bytes")

asyncio.run(main())
```

## Async Iterators and Generators

### Async Iterator

```python
import asyncio

class AsyncRange:
    def __init__(self, start, end):
        self.current = start
        self.end = end

    def __aiter__(self):
        return self

    async def __anext__(self):
        if self.current >= self.end:
            raise StopAsyncIteration

        await asyncio.sleep(0.1)  # Simulate async operation
        self.current += 1
        return self.current - 1

async def main():
    async for number in AsyncRange(0, 5):
        print(number)

asyncio.run(main())
```

### Async Generator

```python
import asyncio

async def async_range(start, end):
    """Async generator - simpler than async iterator."""
    for i in range(start, end):
        await asyncio.sleep(0.1)
        yield i

async def main():
    async for number in async_range(0, 5):
        print(number)

asyncio.run(main())
```

## Working with Async Libraries

### aiohttp - Async HTTP Client

```python
import aiohttp
import asyncio

async def fetch_multiple_urls(urls):
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(session, url) for url in urls]
        return await asyncio.gather(*tasks)

async def fetch_url(session, url):
    async with session.get(url) as response:
        return {
            'url': url,
            'status': response.status,
            'length': len(await response.text())
        }

async def main():
    urls = [
        'https://example.com',
        'https://example.org',
        'https://example.net'
    ]
    results = await fetch_multiple_urls(urls)
    for result in results:
        print(f"{result['url']}: {result['status']} ({result['length']} bytes)")

asyncio.run(main())
```

### aiofiles - Async File I/O

```python
import aiofiles
import asyncio

async def read_file(filename):
    async with aiofiles.open(filename, mode='r') as f:
        contents = await f.read()
    return contents

async def write_file(filename, content):
    async with aiofiles.open(filename, mode='w') as f:
        await f.write(content)

async def process_files():
    # Read multiple files concurrently
    contents = await asyncio.gather(
        read_file('file1.txt'),
        read_file('file2.txt'),
        read_file('file3.txt')
    )

    # Process and write results
    processed = [c.upper() for c in contents]
    await asyncio.gather(*[
        write_file(f'output{i}.txt', data)
        for i, data in enumerate(processed)
    ])

asyncio.run(process_files())
```

## Common Async Patterns

### Pattern 1: Timeout

```python
import asyncio

async def slow_operation():
    await asyncio.sleep(10)
    return "Done"

async def main():
    try:
        result = await asyncio.wait_for(slow_operation(), timeout=3.0)
    except asyncio.TimeoutError:
        print("Operation timed out!")

asyncio.run(main())
```

### Pattern 2: Retry Logic

```python
import asyncio

async def unstable_operation():
    import random
    if random.random() < 0.7:
        raise Exception("Failed!")
    return "Success"

async def retry_operation(max_attempts=3):
    for attempt in range(max_attempts):
        try:
            return await unstable_operation()
        except Exception as e:
            if attempt == max_attempts - 1:
                raise
            print(f"Attempt {attempt + 1} failed, retrying...")
            await asyncio.sleep(1)

asyncio.run(retry_operation())
```

### Pattern 3: Rate Limiting

```python
import asyncio
from asyncio import Semaphore

async def fetch_data(sem, url):
    async with sem:  # Limit concurrent operations
        print(f"Fetching {url}")
        await asyncio.sleep(1)
        return f"Data from {url}"

async def main():
    # Only 3 concurrent requests
    sem = Semaphore(3)

    urls = [f"url{i}" for i in range(10)]
    tasks = [fetch_data(sem, url) for url in urls]

    results = await asyncio.gather(*tasks)
    print(f"Fetched {len(results)} URLs")

asyncio.run(main())
```

### Pattern 4: Producer-Consumer

```python
import asyncio
from asyncio import Queue

async def producer(queue, n):
    for i in range(n):
        await asyncio.sleep(0.1)
        await queue.put(i)
        print(f"Produced: {i}")
    await queue.put(None)  # Sentinel value

async def consumer(queue):
    while True:
        item = await queue.get()
        if item is None:
            break
        await asyncio.sleep(0.2)
        print(f"Consumed: {item}")

async def main():
    queue = Queue()

    await asyncio.gather(
        producer(queue, 5),
        consumer(queue)
    )

asyncio.run(main())
```

## Mixing Sync and Async Code

### Running Sync Code in Async Context

```python
import asyncio
from concurrent.futures import ThreadPoolExecutor

def blocking_io():
    """Synchronous blocking function."""
    import time
    time.sleep(2)
    return "Blocking result"

async def main():
    loop = asyncio.get_event_loop()

    # Run blocking code in thread pool
    result = await loop.run_in_executor(
        None,  # Use default executor
        blocking_io
    )
    print(result)

asyncio.run(main())
```

### Running Async Code from Sync Context

```python
import asyncio

async def async_task():
    await asyncio.sleep(1)
    return "Async result"

def sync_function():
    """Synchronous function that needs to call async code."""
    # Create new event loop
    result = asyncio.run(async_task())
    return result

# Call from synchronous code
print(sync_function())
```

## Error Handling

### Try-Except in Async Functions

```python
import asyncio

async def risky_operation():
    await asyncio.sleep(1)
    raise ValueError("Something went wrong!")

async def main():
    try:
        await risky_operation()
    except ValueError as e:
        print(f"Caught error: {e}")

asyncio.run(main())
```

### Handling Errors in gather()

```python
import asyncio

async def task(n):
    if n == 2:
        raise ValueError(f"Task {n} failed!")
    await asyncio.sleep(1)
    return n

async def main():
    # return_exceptions=True returns exceptions instead of raising
    results = await asyncio.gather(
        task(1),
        task(2),
        task(3),
        return_exceptions=True
    )

    for i, result in enumerate(results):
        if isinstance(result, Exception):
            print(f"Task {i} failed: {result}")
        else:
            print(f"Task {i} succeeded: {result}")

asyncio.run(main())
```

## Performance Considerations

### When Async is Faster

```python
import asyncio
import time

# I/O-bound: async is MUCH faster
async def async_io_bound():
    tasks = [asyncio.sleep(0.1) for _ in range(100)]
    await asyncio.gather(*tasks)

# ~0.1s (concurrent)
start = time.time()
asyncio.run(async_io_bound())
print(f"Async: {time.time() - start:.2f}s")

# ~10s (sequential)
def sync_io_bound():
    for _ in range(100):
        time.sleep(0.1)

start = time.time()
sync_io_bound()
print(f"Sync: {time.time() - start:.2f}s")
```

### When Async is NOT Faster

```python
import asyncio
import time

# CPU-bound: async doesn't help (single-threaded)
async def async_cpu_bound():
    def compute():
        return sum(i * i for i in range(1000000))

    tasks = [asyncio.to_thread(compute) for _ in range(4)]
    await asyncio.gather(*tasks)

# Use multiprocessing instead for CPU-bound work
from multiprocessing import Pool

def cpu_bound_parallel():
    def compute():
        return sum(i * i for i in range(1000000))

    with Pool(4) as pool:
        results = pool.map(compute, range(4))
```

## Best Practices

### 1. Use asyncio.run() for Entry Point

```python
# ✅ Good
async def main():
    # Your async code
    pass

asyncio.run(main())

# ❌ Bad
async def main():
    pass

loop = asyncio.get_event_loop()
loop.run_until_complete(main())
```

### 2. Don't Block the Event Loop

```python
# ❌ Bad - blocks event loop
async def bad():
    import time
    time.sleep(10)  # Blocks everything!

# ✅ Good - yields control
async def good():
    await asyncio.sleep(10)  # Other tasks can run
```

### 3. Use Context Managers for Resources

```python
# ✅ Good - automatic cleanup
async def good():
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.text()

# ❌ Bad - manual cleanup
async def bad():
    session = aiohttp.ClientSession()
    response = await session.get(url)
    text = await response.text()
    await session.close()
    return text
```

### 4. Handle Cancellation Gracefully

```python
async def cancellable_task():
    try:
        while True:
            await asyncio.sleep(1)
            print("Working...")
    except asyncio.CancelledError:
        print("Task cancelled, cleaning up...")
        # Cleanup code here
        raise  # Re-raise to propagate cancellation
```

### 5. Use Type Hints

```python
from typing import List

async def fetch_users(user_ids: List[int]) -> List[dict]:
    """Fetch user data for given IDs."""
    tasks = [fetch_user(uid) for uid in user_ids]
    return await asyncio.gather(*tasks)
```

## Common Pitfalls

### Pitfall 1: Forgetting await

```python
# ❌ Wrong - returns coroutine, doesn't execute
async def wrong():
    result = async_function()  # Missing await!
    return result

# ✅ Correct
async def correct():
    result = await async_function()
    return result
```

### Pitfall 2: Using Blocking Operations

```python
import asyncio
import time

# ❌ Wrong - blocks event loop
async def wrong():
    time.sleep(1)  # Blocks!

# ✅ Correct
async def correct():
    await asyncio.sleep(1)  # Non-blocking
```

### Pitfall 3: Not Using gather() for Concurrent Tasks

```python
# ❌ Slow - sequential execution
async def slow():
    result1 = await fetch1()  # Wait
    result2 = await fetch2()  # Wait
    return result1, result2

# ✅ Fast - concurrent execution
async def fast():
    result1, result2 = await asyncio.gather(
        fetch1(),
        fetch2()
    )
    return result1, result2
```

## Debugging Async Code

### Enable Debug Mode

```python
import asyncio

asyncio.run(main(), debug=True)
```

### Detect Unawaited Coroutines

```python
import warnings

# This will warn about unawaited coroutines
warnings.simplefilter('always', ResourceWarning)

async def example():
    async_function()  # Warning: coroutine was never awaited

asyncio.run(example())
```

### Logging Slow Callbacks

```python
import asyncio
import logging

logging.basicConfig(level=logging.DEBUG)

# Log callbacks taking > 100ms
asyncio.run(main(), debug=True)
```

## Summary

Async/await enables efficient concurrent I/O operations by:

- **Concurrency**: Multiple tasks making progress (not true parallelism)
- **Event loop**: Manages task scheduling and execution
- **Non-blocking**: Tasks yield control during I/O waits
- **Single-threaded**: No threading complexity or race conditions

**Key concepts:**
- `async def` creates coroutines
- `await` pauses execution until operation completes
- `asyncio.gather()` runs multiple tasks concurrently
- `asyncio.run()` is the entry point
- Perfect for I/O-bound operations (HTTP, files, databases)

## Next Steps

Ready to practice? Head to the [Async/Await Hands-On Lab](../../module-02/advanced-python/05-async-await/README.md).

## Additional Resources

- [Official asyncio documentation](https://docs.python.org/3/library/asyncio.html)
- [Real Python: Async IO in Python](https://realpython.com/async-io-python/)
- [aiohttp documentation](https://docs.aiohttp.org/)
- [PEP 492 - Coroutines with async and await](https://peps.python.org/pep-0492/)
