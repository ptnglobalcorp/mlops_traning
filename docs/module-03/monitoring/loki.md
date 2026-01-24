# Grafana Loki - Log Aggregation System

**Cost-effective, horizontally scalable log management**

## Overview

Grafana Loki is a horizontally scalable, highly available, multi-tenant log aggregation system inspired by Prometheus. Unlike traditional logging systems, Loki indexes only the **labels** (metadata) of your logs, not the full log content. This design makes Loki extremely cost-effective while still providing powerful log querying capabilities.

### Key Features

- **Label-based Indexing**: Only indexes metadata, not full log content
- **Full-text Search**: Search within log content without full-text index
- **LogQL Query Language**: Prometheus-like query language for logs
- **Multi-tenancy**: Isolate logs from different teams or customers
- **Horizontal Scalability**: Distribute load across multiple instances
- **Metrics from Logs**: Generate metrics from log streams
- **Trace Integration**: Link logs to traces for context

## Architecture

Loki has a **microservices-based architecture** designed for horizontal scaling:

```
+-----------------------------------------------------------------------+
|                          Grafana Loki                                  |
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
          |Index Gateway  |  |  Compactor   |  |  Ruler       |
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
| **Distributor** | Receives log streams, validates, routes to ingesters |
| **Ingester** | Receives and writes log data, builds chunks |
| **Querier** | Queries ingesters for recent data and storage for historical |
| **Query Frontend** | Splits queries, handles parallel query execution |
| **Index Gateway** | Index file management and caching |
| **Compactor** | Compacts index files, manages retention |
| **Ruler** | Evaluates alerting rules on logs |

## Data Model

### Labels vs. Structured Metadata

Loki uses two types of data:

**Labels** - Indexed, high-cardinality metadata
```log
level="error"
service="api"
cluster="us-east-1"
```

**Structured Metadata** - Non-indexed, attached to log entries
```json
{
  "user_id": "12345",
  "request_id": "abc-def",
  "custom_field": "value"
}
```

### Data Format

Loki stores two main file types:

| Type | Purpose |
|------|---------|
| **Index** | Table of contents for finding logs by labels |
| **Chunk** | Container for actual log entries with same labels |

### Chunk Format

```
----------------------------------------------------------------------------
| Magic(4b) | Version(1b) | Encoding(1b) |
----------------------------------------------------------------------------
| #structuredMetadata | len(label-1) | label-1 | len(label-2) | label-2 |
----------------------------------------------------------------------------
| checksum | block-1 | checksum | block-2 | checksum | ... | block-n |
----------------------------------------------------------------------------
| #blocks | entries | mint, maxt | offset, len |
----------------------------------------------------------------------------
```

## Write Path

1. **Distributor** receives HTTP POST with log streams
2. **Distributor** hashes each stream to determine target ingester
3. **Distributor** sends to ingester(s) based on replication factor
4. **Ingester** creates or appends to chunk for stream
5. **Ingester** acknowledges write
6. **Distributor** waits for quorum, responds to client

```
Client -> Distributor -> Ingester -> Memory -> Chunk -> Object Storage
```

## Read Path

1. **Query Frontend** receives LogQL query
2. **Query Frontend** splits query into sub-queries
3. **Queriers** pull sub-queries from scheduler
4. **Queriers** query ingesters for in-memory data
5. **Queriers** lazy-load from object storage if needed
6. **Queriers** deduplicate and return results
7. **Query Frontend** merges results and responds

```
Client -> Query Frontend -> Queriers -> [Ingesters | Object Storage] -> Result
```

## Getting Started

### Using intro-to-mltp

The [intro-to-mltp](https://github.com/grafana/intro-to-mltp) repository includes a complete Loki setup:

```bash
git clone https://github.com/grafana/intro-to-mltp.git
cd intro-to-mltp
docker compose up
```

Access Loki at `http://localhost:3100`

### Local Development

```yaml
# docker-compose.yml
version: "3"
services:
  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    command: -config.file=/etc/loki/local-config.yaml
```

### Basic Configuration

```yaml
# loki-config.yaml
auth_enabled: false

server:
  http_listen_port: 3100

common:
  path_prefix: /loki
  storage:
    filesystem:
      chunks_directory: /loki/chunks
      rules_directory: /loki/rules
  replication_factor: 1
  ring:
    instance_addr: 127.0.0.1

schema_config:
  configs:
    - from: 2024-01-01
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h
```

## Sending Logs

### Using Promtail

```yaml
# promtail-config.yml
server:
  http_listen_port: 9080

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://localhost:3100/loki/api/v1/push

scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          __path__: /var/log/*log
```

### Using Grafana Alloy

```alloy
// config.alloy
loki.write "grafana_loki" {
  endpoint {
    url = "http://loki:3100/loki/api/v1/push"
  }
}

loki.source.file "log_files" {
  targets = [{
    __address__ = "localhost",
    __path__    = "/var/log/*.log",
  }]
  forward_to = [loki.write.grafana_loki.receiver]
}
```

### Direct API

```bash
curl -X POST http://localhost:3100/loki/api/v1/push \
  -H 'Content-Type: application/json' \
  -d '{
    "streams": [{
      "stream": {
        "job": "test",
        "level": "info"
      },
      "values": [
        ["1699999999999999999", "This is a log line"]
      ]
    }]
  }'
```

## Querying Logs

### LogQL Basics

LogQL has two types of queries:

**Log Queries** - Return log entries
```logql
{job="api"} |= "error"
{service="app"} |~ `error.*\d+`
{level="warn"} != "timeout"
```

**Metric Queries** - Return metrics from logs
```logql
# Count logs
count_over_time({job="api"}[5m])

# Rate of errors
rate({job="api", level="error"}[5m])

# Bytes per second
bytes_rate({job="api"}[5m])
```

### LogQL Operators

| Operator | Description |
|----------|-------------|
| `|= text` | Line contains text |
| `!= text` | Line does not contain text |
| `|~ regex` | Line matches regex |
| `!~ regex` | Line does not match regex |

### LogQL Pipeline

```logql
# Label filter
{job="api"} | json | line_format "{{.status}}: {{.message}}"

# Parse JSON
{job="api"} | json | status >= 400

# Label extraction
{job="api"} | regexp "(?P<status>\d+)" | status >= 400

# Metrics from logs
sum by (status) (count_over_time({job="api"} | json [5m]))
```

### Queries in Grafana

```bash
# Search for errors in last hour
curl -G 'http://localhost:3100/loki/api/v1/query_range' \
  --data-urlencode 'query={level="error"}' \
  --data-urlencode 'start=1699999999999999999' \
  --data-urlencode 'end=1700000000000000000' \
  --data-urlencode 'limit=100'
```

## Advanced Features

### Metrics from Logs

Generate Prometheus-style metrics from log streams:

```logql
# Count of logs by level
sum by (level) (count_over_time({job="api"}[5m]))

# Error rate
rate({job="api", status=~"5.."}[5m])

# Bytes per second
sum(bytes_over_time({job="api"}[5m]))
```

### Recording Rules

```yaml
groups:
  - name: log_recording_rules
    interval: 30s
    rules:
      - record: job:api:error:rate5m
        expr: sum by (job) (rate({job="api", status=~"5.."}[5m]))
```

### Alerting Rules

```yaml
groups:
  - name: log_alerts
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: sum by (job) (rate({job="api", status=~"5.."}[5m])) > 0.05
        for: 10m
        annotations:
          summary: "High error rate in logs"
```

### Log to Trace Integration

Link logs to traces:

```logql
# Query logs with trace ID
{trace_id="abc123"}

# Jump from log to trace
# In Grafana, click the trace ID in a log entry
```

## Best Practices

### Label Cardinality

```yaml
limits_config:
  # Limit streams per tenant
  max_streams_per_user: 10000

  # Reject high cardinality labels
  max_label_names_per_series: 30

  # Limit ingestion rate
  ingestion_rate_mb: 10
  ingestion_burst_size_mb: 20
```

### Log Retention

```yaml
compactor:
  retention_enabled: true
  delete_interval: 2h
  retention_delete_delay: 2h

limits_config:
  retention_period: 30d
```

### Query Optimization

```yaml
limits_config:
  # Split queries for parallel execution
  max_query_length: 0
  max_query_parallelism: 32

  # Cache query results
  max_cache_freshness_per_query: 10m
```

## Monitoring Loki

### Key Metrics

```promql
# Ingestion rate
sum(rate(loki_distributor_lines_received_total[5m]))

# Query performance
histogram_quantile(0.99, rate(loki_query_range_duration_seconds[5m]))

# Storage operations
rate(loki_ingester_streams_created[5m])
```

### Pre-built Dashboards

Grafana provides monitoring dashboards for Loki:
- Loki Overview Dashboard
- Loki Operations Dashboard

## Resources

- [Grafana Loki Documentation](https://grafana.com/docs/loki/latest/)
- [Grafana Loki GitHub](https://github.com/grafana/loki)
- [Loki Architecture](https://grafana.com/docs/loki/latest/get-started/architecture/)
- [intro-to-mltp Repository](https://github.com/grafana/intro-to-mltp)
