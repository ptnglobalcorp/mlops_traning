# Grafana Tempo - Distributed Tracing Backend

**High-scale, cost-effective distributed tracing**

## Overview

Grafana Tempo is an open source, easy-to-use, and high-scale distributed tracing backend. Tempo requires only object storage to operate, making it significantly more cost-effective than other tracing solutions that rely on expensive databases like Elasticsearch or Cassandra.

### Key Features

- **No Dependencies**: Only requires object storage (S3, GCS, Azure)
- **Multiple Formats**: Supports OpenTelemetry, Jaeger, Zipkin, and OpenTracing
- **TraceQL**: Powerful query language for searching traces
- **Metrics from Traces**: Generate RED (Rate, Errors, Duration) metrics automatically
- **Service Graphs**: Visualize service dependencies and traffic flow
- **Cost-effective**: No indexing required, uses Parquet for efficient storage
- **Microservices or Monolithic**: Deploy based on your scale requirements

## Architecture

Tempo is designed as a horizontally scalable distributed tracing system:

```
+-----------------------------------------------------------------------+
|                          Grafana Tempo                                |
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
          |Metrics-Gen    |  |  Compactor   |  | Span Metrics |
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
| **Distributor** | Receives spans in multiple formats, routes to ingesters via consistent hashing |
| **Ingester** | Sorts spans into Parquet columns, creates blocks, writes to object storage |
| **Querier** | Queries ingesters for recent data and storage for historical traces |
| **Query Frontend** | Parallelizes queries, combines results |
| **Compactor** | Compacts and deduplicates blocks, manages retention |
| **Metrics Generator** | Derives metrics from spans (RED metrics, service graphs) |

### Trace Journey

```
Application
    |
    v (Instrumentation)
OpenTelemetry SDK
    |
    v (OTLP)
Grafana Alloy / Collector
    |
    v (Remote Write)
Tempo Distributor
    |
    v (Hash traceID)
Tempo Ingester
    |
    v (Parquet + Bloom Filters)
Object Storage
    |
    v (Query via TraceQL)
Tempo Querier
    |
    v (Visualization)
Grafana
```

## Data Model

### Trace Structure

A **trace** represents the entire journey of a request through your distributed system:

```
Trace: Root Span
  ├── Child Span 1 (Service A)
  │   ├── Grandchild Span 1.1 (Service B)
  │   └── Grandchild Span 1.2 (Service C)
  ├── Child Span 2 (Service D)
  └── Child Span 3 (Service A)
```

### Span Attributes

Each span contains:

| Attribute | Description |
|-----------|-------------|
| **Trace ID** | Unique identifier for the entire trace |
| **Span ID** | Unique identifier for this span |
| **Parent ID** | ID of parent span (null for root) |
| **Operation Name** | Name of the operation (e.g., "HTTP GET /users") |
| **Start Time** | Timestamp when span started |
| **Duration** | Length of time in nanoseconds |
| **Service Name** | Name of the service generating the span |
| **Attributes** | Key-value pairs with metadata |
| **Events** | Time-stamped events within the span |
| **Links** | Links to related spans |
| **Status** | Status code (OK, ERROR, UNSET) |

## Storage Format

### Apache Parquet Layout

Tempo organizes data in object storage as:

```
<bucketname>/
  <tenantID>/
    <blockID>/
      meta.json
      index
      data
      bloom_0
      bloom_1
      ...
      bloom_n
```

### Parquet Schema

Spans are organized into columns for efficient querying:

```parquet
trace_id         | span_id | parent_id | service_name | span_name | ...
-----------------|---------|-----------|--------------|------------|----
abc123           | def456  | null      | api-gateway  | GET /api   | ...
abc123           | ghi789  | def456    | users-svc    | query_db   | ...
```

### Bloom Filters

Tempo uses Bloom filters for fast lookups without indexing:
- **Trace ID Bloom Filters**: Quickly determine if a trace exists in a block
- **Attribute Bloom Filters**: Enable searching by span attributes

## Getting Started

### Using intro-to-mltp

The [intro-to-mltp](https://github.com/grafana/intro-to-mltp) repository includes a complete Tempo setup:

```bash
git clone https://github.com/grafana/intro-to-mltp.git
cd intro-to-mltp
docker compose up
```

Access Tempo at `http://localhost:4318` (OTLP HTTP)

### Local Development

```yaml
# docker-compose.yml
version: "3"
services:
  tempo:
    image: grafana/tempo:latest
    command: -config.file=/etc/tempo.yaml
    ports:
      - "4317:4317"  # OTLP gRPC
      - "4318:4318"  # OTLP HTTP
      - "3200:3200"  # Tempo
    volumes:
      - ./tempo.yaml:/etc/tempo.yaml
```

### Basic Configuration

```yaml
# tempo.yaml
server:
  http_listen_port: 3200

distributor:
  receivers:
    otlp:
      protocols:
        grpc:
          endpoint: 0.0.0.0:4317
        http:
          endpoint: 0.0.0.0:4318

ingester:
  trace_idle_period: 10s
  max_block_bytes: 1_000_000
  max_block_duration: 1m

compactor:
  compaction:
    block_retention: 48h

storage:
  trace:
    backend: local
    local:
      path: /tmp/tempo
```

## Instrumentation

### OpenTelemetry Python

```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

# Setup
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

# Export to Tempo
otlp_exporter = OTLPSpanExporter(endpoint="http://localhost:4317", insecure=True)
trace.get_tracer_provider().add_span_processor(BatchSpanProcessor(otlp_exporter))

# Create spans
with tracer.start_as_current_span("operation-name") as span:
    span.set_attribute("key", "value")
    # Your code here
```

### OpenTelemetry JavaScript

```javascript
const { trace } = require('@opentelemetry/api');
const { NodeTracerProvider } = require('@opentelemetry/sdk-trace-node');
const { Resource } = require('@opentelemetry/resources');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-grpc');
const { BatchSpanProcessor } = require('@opentelemetry/sdk-trace-base');

// Setup
const provider = new NodeTracerProvider({
  resource: new Resource({ service: 'my-service' })
});

const exporter = new OTLPTraceExporter({
  url: 'http://localhost:4317'
});

provider.addSpanProcessor(new BatchSpanProcessor(exporter));
provider.register();

// Create spans
const tracer = trace.getTracer('example');
const span = tracer.startSpan('operation-name');
span.setAttribute('key', 'value');
// Your code here
span.end();
```

### OpenTelemetry Go

```go
import (
    "context"
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
    "go.opentelemetry.io/otel/sdk/resource"
    sdktrace "go.opentelemetry.io/otel/sdk/trace"
    semconv "go.opentelemetry.io/otel/semconv/v1.4.0"
)

// Setup
exporter, _ := otlptracegrpc.New(context.Background(),
    otlptracegrpc.WithEndpoint("localhost:4317"),
    otlptracegrpc.WithInsecure(),
)

tp := sdktrace.NewTracerProvider(
    sdktrace.WithBatcher(exporter),
    sdktrace.WithResource(resource.NewWithAttributes(
        semconv.SchemaURL,
        semconv.ServiceNameKey.String("my-service"),
    )),
)
otel.SetTracerProvider(tp)

// Create spans
ctx, span := otel.Tracer("example").Start(context.Background(), "operation-name")
span.SetAttributes(attribute.Key("key").String("value"))
// Your code here
span.End()
```

## Querying Traces

### TraceQL Basics

TraceQL is a powerful query language for searching traces:

```traceql
# Find all traces
{ span.http.method = "GET" }

# Find errors
{ span.status = "error" }

# Find slow requests
{ span.duration > 100ms }

# Combine conditions
{ .http.method = "POST" && .http.status_code >= 400 }

# Search by attribute
{ span.user_id = "12345" }
```

### TraceQL Operators

| Operator | Description |
|----------|-------------|
| `=` | Exact match |
| `!=` | Not equal |
| `=~` | Regex match |
| `!~` | Regex not match |
| `>`, `<`, `>=`, `<=` | Numeric comparison |
| `&&`, `\|\|` | Boolean operators |

### TraceQL Examples

```traceql
# Find all errors from payment service
{ span.service.name = "payment" && span.status = "error" }

# Find slow database queries
{ span.name = "db.query" && span.duration > 500ms }

# Find traces with specific user
{ .user_id = "12345" }

# Find HTTP 5xx errors
{ .http.method =~ ".*" && .http.status_code >= 500 }

# Find spans with specific attribute
{ span.custom.attribute = "value" }
```

### API Queries

```bash
# Get trace by ID
curl http://localhost:3200/api/traces/abc123def456

# Search with TraceQL
curl -G http://localhost:3200/api/search \
  --data-urlencode 'query={ span.service.name = "api" }'

# Search by tags
curl -G http://localhost:3200/api/search \
  --data-urlencode 'tags=service.name:api'
```

## Advanced Features

### Metrics from Traces

Tempo can automatically generate metrics from trace spans:

```yaml
# tempo.yaml
metrics_generator:
  processor:
    # Service graph metrics
    service_graph:
      enabled: true
      dimensions:
        - http.method
        - http.status_code

    # Span metrics
    spans:
      enabled: true
      dimensions:
        - http.method
        - http.status_code
        - service.name
```

Generated metrics:
```promql
# RED method metrics
traces_spanmetrics_latency_bucket
traces_spanmetrics_calls_total
traces_spanmetrics_errors_total

# Service graph metrics
traces_service_graph_request_total
traces_service_graph_request_server_duration
```

### Service Graphs

Visualize service dependencies and traffic:

```yaml
metrics_generator:
  service_graph:
    enabled: true
    max_connections: 1000
    wait:
      duration: 10s
      max_duration: 30s
```

### Tail-based Sampling

Sample traces after they're complete:

```yaml
# tempo.yaml
distributor:
  receivers:
    otlp:
      protocols:
        grpc:

tail_sampling:
  policies:
    - type: string_match
      value:
        attribute_values:
          - key: http.status_code
            values: ["500", "503"]
        min_sampling_rate: 1.0
        max_sampling_rate: 1.0

    - type: rate_tail
      value:
        sampling_rate: 0.1
```

## Best Practices

### Instrumentation Best Practices

1. **Always propagate context** across service boundaries
2. **Use semantic attributes** (OpenTelemetry semantic conventions)
3. **Add relevant attributes** to spans (user IDs, request IDs, etc.)
4. **Avoid high cardinality** in frequently queried attributes
5. **Set span status** appropriately (OK, ERROR)

### Attribute Naming

```javascript
// Good - Semantic conventions
span.setAttribute('http.method', 'GET');
span.setAttribute('http.status_code', 200);
span.setAttribute('http.url', '/api/users');

// Bad - Custom naming
span.setAttribute('method', 'GET');
span.setAttribute('status', 200);
```

### Sampling Configuration

```yaml
# Always sample errors
# Sample 1% of successful requests
distributor:
  receivers:
    otlp:
      protocols:
        grpc:

# Head-based sampling at the client
# Use probabilistic sampling for load reduction
```

### Batch Configuration

```yaml
ingester:
  trace_idle_period: 10s       # How long to wait for complete trace
  max_block_bytes: 1_000_000   # Max block size before flush
  max_block_duration: 30s      # Max time before flush
  flush_check_period: 5s       # How often to check for flush
```

## Monitoring Tempo

### Key Metrics

```promql
# Ingestion rate
rate(tempo_distributor_spans_received_total[5m])

# Query performance
histogram_quantile(0.99, rate(tempo_query_frontend_request_duration_seconds[5m]))

# Block operations
rate(tempo_ingester_blocks_created[5m])

# Search latency
histogram_quantile(0.99, rate(tempo_query_frontend_search_duration_seconds[5m]))
```

## Resources

- [Grafana Tempo Documentation](https://grafana.com/docs/tempo/latest/)
- [Grafana Tempo GitHub](https://github.com/grafana/tempo)
- [Tempo Architecture](https://grafana.com/docs/tempo/latest/introduction/architecture/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [intro-to-mltp Repository](https://github.com/grafana/intro-to-mltp)
