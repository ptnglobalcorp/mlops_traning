# Grafana Mimir - Scalable Metrics Backend

**Long-term Prometheus-compatible metrics storage**

## Overview

Grafana Mimir is a horizontally scalable, highly available, multi-tenant metrics backend that provides long-term storage for Prometheus metrics. It overcomes the scalability limitations of standalone Prometheus while maintaining full compatibility with PromQL and the Prometheus ecosystem.

### Key Features

- **Horizontal Scalability**: Scale metrics ingestion and querying independently
- **High Availability**: Replicated ingesters ensure no data loss
- **Multi-tenancy**: Isolate metrics from different teams or customers
- **Long-term Retention**: Cost-effective storage using object storage
- **Native Histograms**: Efficient histogram storage and querying
- **Global View**: Query metrics across all Prometheus instances
- **Exemplars**: Link metrics to traces for detailed investigation

## Architecture

Grafana Mimir has a **microservices-based architecture** with multiple horizontally scalable components:

```
+-----------------------------------------------------------------------+
|                         Grafana Mimir                                 |
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
          | Store-Gateway|  |  Compactor   |  |Alertmanager  |
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
| **Distributor** | Receives write requests, validates, and routes to ingesters |
| **Ingester** | Receives and writes time series data, builds TSDB blocks |
| **Querier** | Queries ingesters for recent data and storage for historical data |
| **Query Frontend** | Splits queries, caches results, handles query parallelization |
| **Store Gateway** | Serves queries from long-term storage |
| **Compactor** | Compacts TSDB blocks, manages retention and downsampling |
| **Alertmanager** | Evaluates alerting rules and manages notifications |
| **Ruler** | Stores and evaluates recording and alerting rules |

### Deployment Modes

Mimir 3.0 introduced two architecture options:

#### Ingest Storage (Preferred)

Uses Kafka as a central pipeline to decouple read and write operations.

```
Distributor -> Kafka -> Ingester -> Object Storage
                        |
                        v
                   Query Path
```

#### Classic

Uses stateful ingesters with local write-ahead logs.

```
Distributor -> Ingester (with WAL) -> Object Storage
                     |
                     v
                Query Path
```

## Storage Format

Mimir uses the **Prometheus TSDB storage format**:

- Each tenant's time series stored in separate TSDB
- On-disk blocks with 2-hour ranges (default)
- Per-block index for metric names and labels
- Chunks organize samples by time range

### Block Structure

```
tenant-id/
  blocks/
    01AZAV/
      index
      meta.json
      chunks/
        000001
        000002
```

## Getting Started

### Using intro-to-mltp

The [intro-to-mltp](https://github.com/grafana/intro-to-mltp) repository includes a complete Mimir setup:

```bash
git clone https://github.com/grafana/intro-to-mltp.git
cd intro-to-mltp
docker compose up
```

Access Mimir at `http://localhost:9009`

### Local Development

```yaml
# docker-compose.yml
version: "3"
services:
  mimir:
    image: grafana/mimir:latest
    command: "-config.file=/etc/mimir.yaml"
    ports:
      - "9009:9009"
    volumes:
      - ./mimir.yaml:/etc/mimir.yaml
```

### Basic Configuration

```yaml
# mimir.yaml
limits:
  max_series_per_metric: 100000
  max_series_per_user: 0
  max_global_series_per_user: 0

ingester:
  ring:
    instance_addr: "mimir"
    instance_port: 9095

storage:
  backend: "s3"
  s3:
    endpoint: "s3.amazonaws.com"
    bucket_name: "mimir-data"
    access_key_id: "your-access-key"
    secret_access_key: "your-secret-key"

block_storage:
  backend: "s3"
  s3:
    endpoint: "s3.amazonaws.com"
    bucket_name: "mimir-blocks"
```

## Ingesting Metrics

### Remote Write from Prometheus

```yaml
# prometheus.yml
remote_write:
  - url: http://mimir:9009/api/v1/push
    headers:
      X-Scope-OrgID: "tenant-1"
```

### Using Grafana Alloy

```alloy
// config.alloy
prometheus.scrape "default" {
  targets = [{
    __address__ = "localhost:9090",
  }]
  forward_to = [prometheus.remote_write.mimir.receiver]
}

prometheus.remote_write "mimir" {
  endpoint {
    url = "http://mimir:9009/api/v1/push"
    headers = {
      "X-Scope-OrgID" = "tenant-1",
    }
  }
}
```

## Querying Metrics

### PromQL Queries

Mimir supports all PromQL functions and operators:

```promql
# Rate of requests
rate(http_requests_total[5m])

# Errors by service
sum by (service) (rate(http_requests_total{status=~"5.."}[5m]))

# P99 latency
histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))
```

### Query Frontend API

```bash
# Query with tenant ID
curl -H "X-Scope-OrgID: tenant-1" \
  'http://mimir:9009/prometheus/api/v1/query?query=up'

# Range query
curl -H "X-Scope-OrgID: tenant-1" \
  'http://mimir:9009/prometheus/api/v1/query_range?query=up&start=...&end=...&step=15'
```

## Advanced Features

### Exemplars

Link metrics to traces for investigation:

```yaml
# prometheus.yml
global:
  exemplars:
    trace_id_label: trace_id
```

### Native Histograms

```yaml
# prometheus.yml
# Enable native histograms
enable_feature: native-histograms

# Query
rate(http_request_duration_seconds[5m])
```

### Recording Rules

```yaml
# Recording rules
groups:
  - name: api_rules
    interval: 30s
    rules:
      - record: job:http_requests:rate5m
        expr: sum by (job) (rate(http_requests_total[5m]))
```

### Alerting Rules

```yaml
# Alerting rules
groups:
  - name: api_alerts
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 10m
        annotations:
          summary: "High error rate on {{ $labels.instance }}"
```

## Best Practices

### Label Cardinality Management

```yaml
limits:
  # Limit cardinality per metric
  max_series_per_metric: 10000

  # Limit total series per tenant
  max_series_per_user: 1000000

  # Reject high cardinality labels
  max_label_names_per_series: 30
```

### Query Optimization

```yaml
query_frontend:
  # Split queries for parallel execution
  max_query_length: 1000h
  max_query_length_created_by: 48h

  # Cache query results
  results_cache:
    backend: "redis"
```

### Retention Configuration

```yaml
compactor:
  # Delete blocks older than 30 days
  deletion_mode: "filter-and-delete"
  retention_delete_delay: 2h

limits:
  # Per-tenant retention
  retention_period: 30d
```

## Monitoring Mimir

### Key Metrics

```promql
# Ingestion rate
sum by (job) (rate(mimir_distributor_samples_received_total[5m]))

# Query performance
histogram_quantile(0.99, rate(mimir_frontend_query_duration_seconds[5m]))

# Storage operations
rate(mimir_ingester_ring_members[5m])
```

### Pre-built Dashboards

Grafana provides monitoring dashboards for Mimir:
- Mimir Operations Dashboard
- Mimir Overview Dashboard

## Resources

- [Grafana Mimir Documentation](https://grafana.com/docs/mimir/latest/)
- [Grafana Mimir GitHub](https://github.com/grafana/mimir)
- [Mimir Architecture](https://grafana.com/docs/mimir/latest/get-started/about-grafana-mimir-architecture/)
- [intro-to-mltp Repository](https://github.com/grafana/intro-to-mltp)
