# Grafana Pyroscope - Continuous Profiling Platform

**Always-on profiling for production systems**

## Overview

Grafana Pyroscope is an open source continuous profiling platform that provides fast, scalable, highly available, and efficient storage and querying of profiling data. Unlike traditional profiling which is done manually during debugging, continuous profiling runs constantly in production with minimal overhead (typically 1-5%).

### Key Features

- **Always-on Profiling**: Collect profiles continuously in production
- **Low Overhead**: Typically 1-5% performance impact
- **Multi-language Support**: Go, Java, .NET, Python, Ruby, Rust, Node.js, eBPF
- **Flame Graphs**: Visualize CPU and memory usage down to line number
- **Time-based Queries**: Compare performance over time
- **Traces to Profiles**: Link traces to profiles for deeper investigation
- **Scalable Storage**: Uses object storage for long-term retention

## What is Profiling?

Profiling is the process of measuring the behavior of a program to understand where it's spending its resources (CPU, memory, I/O).

### Traditional vs Continuous Profiling

| Aspect | Traditional Profiling | Continuous Profiling |
|--------|----------------------|----------------------|
| When | On-demand during debugging | Always running in production |
| Overhead | High (can degrade performance) | Low (1-5%) |
| Context | Development/staging | Production workloads |
| Visibility | Snapshot in time | Historical trends |
| Use Case | Debugging known issues | Discovering unknown problems |

### Profiling Types

| Type | What it Measures | Use Case |
|------|-----------------|----------|
| **CPU Profiling** | Where CPU time is spent | Find slow functions, optimize performance |
| **Memory Profiling** | Memory allocations | Find memory leaks, optimize allocations |
| **Block Profiling** | Goroutine/thread blocking | Find concurrency bottlenecks |
| **Mutex Profiling** | Lock contention | Find synchronization issues |
| **eBPF Profiling** | Kernel and system calls | Low-overhead system-wide profiling |

## Architecture

Pyroscope follows the same architectural patterns as Mimir, Loki, and Tempo:

```
+-----------------------------------------------------------------------+
|                        Grafana Pyroscope                              |
+-----------------------------------------------------------------------+
                                   |
        +----------+----------+----------+----------+----------+
        |          |          |          |          |          |
        v          v          v          v          v          v
+--------------+  +--------------+  +--------------+  +--------------+
|  Distributor  |  |   Ingester   |  | Querier      |  | Query-Frontend|
+--------------+  +--------------+  +--------------+  +--------------+
        |                  |                  |                 |
        +----------+-------+--------+---------+--------+--------+
                   |                |                  |
                   v                v                  v
          +--------------+  +--------------+  +--------------+
          |Store-Gateway  |  |  Compactor   |  |  Components  |
          +--------------+  +--------------+  +--------------+
                   |
                   v
          +------------------+
          |  Object Storage  |
          | (S3/GCS/Azure)   |
          +------------------+
```

### Components

| Component | Responsibility |
|-----------|----------------|
| **Distributor** | Receives profile data, routes to ingesters |
| **Ingester** | Receives and writes profile data, builds blocks |
| **Querier** | Queries ingesters for recent data and storage for historical |
| **Query Frontend** | Splits queries, handles parallel execution |
| **Store Gateway** | Serves queries from long-term storage |
| **Compactor** | Compacts blocks, manages retention |

## Data Model

### Profile Structure

A profile is a collection of stack samples over a time period:

```
Profile:
  Service: my-api
  Start Time: 2024-01-01 12:00:00
  Duration: 10s

  Samples:
    - main.myFunction (100ms)
      ├── api.handleRequest (80ms)
      │   ├── db.queryUser (60ms)
      │   └── cache.get (20ms)
      └── metrics.record (20ms)
```

### Labels and Attributes

**Labels** - Indexed metadata for filtering:
```yaml
service: "my-api"
job: "production"
profile_type: "cpu"
```

**Attributes** - Non-indexed metadata:
```yaml
version: "v1.2.3"
region: "us-east-1"
instance: "api-1"
```

## Getting Started

### Using intro-to-mltp

The [intro-to-mltp](https://github.com/grafana/intro-to-mltp) repository includes a complete Pyroscope setup:

```bash
git clone https://github.com/grafana/intro-to-mltp.git
cd intro-to-mltp
docker compose up
```

Access Pyroscope at `http://localhost:4040`

### Local Development

```yaml
# docker-compose.yml
version: "3"
services:
  pyroscope:
    image: grafana/pyroscope:latest
    ports:
      - "4040:4040"
    command:
      - server
```

### Basic Configuration

```yaml
# pyroscope.yml
server:
  http_listen_port: 4040

distributor:
  receivers:
    otlp:
      protocols:
        grpc:
          endpoint: 0.0.0.0:4317

ingester:
  lifecycler:
    ring:
      replication_factor: 1

storage:
  trace:
    backend: local
    local:
      path: /tmp/pyroscope
```

## Instrumentation

### Go

```go
package main

import (
    "github.com/grafana/pyroscope-go"
)

func main() {
    // Start Pyroscope profiler
    pyroscope.Start(pyroscope.Config{
        ApplicationName: "my-app",
        ServerAddress:   "http://localhost:4040",

        // Profile types
        ProfileTypes: []pyroscope.ProfileType{
            pyroscope.ProfileCPU,
            pyroscope.ProfileInuseObjects,
            pyroscope.ProfileAllocObjects,
            pyroscope.ProfileInuseSpace,
            pyroscope.ProfileAllocSpace,
            pyroscope.ProfileGoroutines,
        },
    })

    // Your application code
}
```

### Python

```python
import pyroscope

pyroscope.configure(
    application_name="my-app",
    server_address="http://localhost:4040",
)

# Your application code
@app.route('/')
def hello():
    return "Hello, World!"
```

### Java

```java
import io.pyroscope.javaagent.EventType;
import io.pyroscope.javaagent.PyroscopeAgent;

public class MyApp {
    public static void main(String[] args) {
        PyroscopeAgent.start(
            "my-app",
            "http://localhost:4040",
            EventType.ITIMER,
            EventType.ALLOC
        );

        // Your application code
    }
}
```

### Node.js

```javascript
const pyroscope = require('@pyroscope/nodejs');

pyroscope.init({
    serverAddress: 'http://localhost:4040',
    appName: 'my-app',
});

// Your application code
```

### .NET

```csharp
using Pyroscope;

public class Program
{
    public static void Main(string[] args)
    {
        PyroscopeAgent.Start(
            applicationName: "my-app",
            serverAddress: "http://localhost:4040"
        );

        // Your application code
    }
}
```

### eBPF (No Code Changes)

```yaml
# pyroscope.yml
pyroscope:
  scrape_profiles:
    - enabled: true
      profile_id: "my-app"
      targets:
        - process_name: "my-process"
          profile_types: [cpu, memory]
```

## Querying Profiles

### Query Language

Pyroscope uses a simple query language for selecting profiles:

```
# Basic query
{service="my-api", job="production"}

# With profile type
{service="my-api"}{type="cpu"}

# With label filter
{service="my-api", region="us-east-1"}
```

### Flame Graph Basics

Flame graphs visualize profile data:

```
                    main (100%)
          ┌──────────┴──────────┐
    handleRequest (80%)    log (20%)
    ┌──────┴──────┐
  db (60%)  cache (20%)
```

- **Width**: Represents CPU time or memory usage
- **Height**: Stack depth
- **Color**: Often indicates "hot" paths (higher usage)
- **Self vs Total**:
  - **Self**: Time spent in function itself
  - **Total**: Time spent in function + children

### Comparison Queries

Compare profiles across time periods:

```
# Compare with previous period
{service="my-api"} vs {service="my-api", offset=7d}

# Compare between services
{service="api-v1"} vs {service="api-v2"}
```

## Advanced Features

### Traces to Profiles

Link traces to profiles for investigation:

```javascript
// Set trace ID on profile
pyroscope.setContext({
    trace_id: "abc123",
    span_id: "def456"
});
```

Then in Grafana, jump from a trace to the corresponding profile.

### Profile Types

| Type | Description | Language |
|------|-------------|----------|
| **cpu** | CPU time | All |
| **inuse_objects** | Live objects count | Go, Java, Python |
| **alloc_objects** | Allocated objects count | Go, Java, Python |
| **inuse_space** | Live memory size | Go, Java, Python |
| **alloc_space** | Allocated memory size | Go, Java, Python |
| **goroutines** | Goroutine count | Go |
| **mutex** | Lock contention | Go |
| **block** | Blocking time | Go |

### Sampling Configuration

```yaml
# pyroscope.yml
distributor:
  receivers:
    otlp:
      protocols:
        grpc:
          endpoint: 0.0.0.0:4317
          # Sample rate
          sample_rate: 100
```

## Best Practices

### Overhead Management

1. **Profile in production**: Small overhead (1-5%) provides constant visibility
2. **Choose relevant types**: Don't enable all profile types
3. **Sample rate adjustment**: Reduce sample rate if overhead is too high
4. **Filter by service**: Profile only critical services

### Label Strategy

```go
// Good - Low cardinality
pyroscope.Start(pyroscope.Config{
    ApplicationName: "my-api",
    Tags: map[string]string{
        "env": "production",
        "region": "us-east-1",
    },
})

// Bad - High cardinality
pyroscope.Start(pyroscope.Config{
    ApplicationName: "my-api",
    Tags: map[string]string{
        "user_id": "12345",  // Too many unique values
        "request_id": "...",  // Changes for every request
    },
})
```

### Query Optimization

```yaml
# Limit query time range
query:
  max_duration: 24h

# Limit result size
query:
  max_nodes: 10000
```

## Interpreting Profiles

### Reading Flame Graphs

1. **Look for wide bars**: These consume the most resources
2. **Check depth**: Deep stacks may indicate complex call chains
3. **Compare versions**: Before/after optimization
4. **Focus on hot paths**: Where most time is spent

### Common Patterns

| Pattern | Likely Issue | Solution |
|---------|--------------|----------|
| Wide bar at top | Hot function in this service | Optimize this function |
| Wide bar deep in stack | Dependency is slow | Optimize external call |
| Many narrow bars | Many small operations | Consider batching |
| Spiky pattern | Periodic heavy work | Consider caching |

## Monitoring Pyroscope

### Key Metrics

```promql
# Ingestion rate
rate(pyroscope_ingester_profile_samples_received_total[5m])

# Query performance
histogram_quantile(0.99, rate(pyroscope_query_frontend_duration_seconds[5m]))

# Block operations
rate(pyroscope_compactor_compactions_total[5m])
```

## Use Cases

1. **Performance Optimization**: Find slow functions and optimize
2. **Memory Leaks**: Identify growing memory allocations over time
3. **Capacity Planning**: Understand resource usage patterns
4. **Incident Investigation**: Correlate performance with issues
5. **Code Review**: See impact of changes on performance

## Resources

- [Grafana Pyroscope Documentation](https://grafana.com/docs/pyroscope/latest/)
- [Grafana Pyroscope GitHub](https://github.com/grafana/pyroscope)
- [Pyroscope Architecture](https://grafana.com/docs/pyroscope/latest/reference-pyroscope-architecture/)
- [Continuous Profiling Guide](https://grafana.com/docs/grafana/latest/visualizations/simplified-exploration/profiles/concepts/continuous-profiling/)
- [intro-to-mltp Repository](https://github.com/grafana/intro-to-mltp)
