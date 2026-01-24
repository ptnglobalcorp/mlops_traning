# Grafana - Visualization and Analytics Platform

**Open source visualization and analytics for all your metrics, logs, traces, and profiles**

## Overview

Grafana is the open source analytics and interactive visualization web application at the center of the Grafana LGTM+P stack. It provides a unified interface for querying, visualizing, and alerting on data from all observability signals.

### Key Features

- **Multi-Source Dashboards** - Visualize data from multiple data sources in one dashboard
- **Query Builders** - PromQL, LogQL, TraceQL, and profile query builders
- **Alerting** - Unified alerting across all data sources
- **Annotations** - Mark events on dashboards for context
- **Variables/Templating** - Dynamic dashboards with template variables
- **Plugin Ecosystem** - 100+ data source and panel plugins
- **Teams & Permissions** - Granular access control for enterprise use

## Architecture

```
+-----------------------------------------------------------------------+
|                           Grafana                                     |
+-----------------------------------------------------------------------+
                                   |
        +----------+----------+----------+----------+----------+
        |          |          |          |          |          |
        v          v          v          v          v          v
+--------------+  +--------------+  +--------------+  +--------------+
|  Dashboard   |  |   Explore    |  |  Alerting    |  |   Reports    |
|   Builder    |  |   (Ad-hoc)   |  |   Engine     |  |              |
+--------------+  +--------------+  +--------------+  +--------------+
        |          |          |          |          |          |
        +----------+----------+----------+----------+----------+
                                   |
        +----------+----------+----------+----------+----------+
        |          |          |          |          |          |
        v          v          v          v          v          v
+--------------+  +--------------+  +--------------+  +--------------+
|    Mimir     |  |     Loki     |  |     Tempo    |  |  Pyroscope    |
|  (Metrics)   |  |    (Logs)    |  |   (Traces)   |  |  (Profiles)   |
+--------------+  +--------------+  +--------------+  +--------------+
```

## Core Concepts

### Dashboards

A **dashboard** is a set of one or more panels arranged in rows/columns to visualize data.

```yaml
# Dashboard JSON structure
{
  "title": "API Service Dashboard",
  "panels": [
    {
      "title": "Request Rate",
      "type": "timeseries",
      "targets": [...]
    },
    {
      "title": "Error Log",
      "type": "logs",
      "targets": [...]
    }
  ]
}
```

### Panels

A **panel** displays data from a query. Common panel types:

| Panel Type | Use For |
|------------|---------|
| **Time Series** | Metrics over time |
| **Stat** | Single values with sparklines |
| **Table** | Tabular data |
| **Logs** | Log entries |
| **Trace** | Distributed trace visualization |
| **Flame Graph** | Profile visualization |
| **Gauge** | Single value with range |
| **Pie Chart** | Distribution visualization |

### Data Sources

A **data source** is a repository where Grafana queries data.

| Data Source | Type | Query Language |
|-------------|------|----------------|
| Grafana Mimir | Metrics | PromQL |
| Grafana Loki | Logs | LogQL |
| Grafana Tempo | Traces | TraceQL |
| Grafana Pyroscope | Profiles | UI query |
| Prometheus | Metrics | PromQL |
| Elasticsearch | Logs | Lucene |
| PostgreSQL | Database | SQL |

## Getting Started

### Using intro-to-mltp

The [intro-to-mltp](https://github.com/grafana/intro-to-mltp) repository includes a pre-configured Grafana instance:

```bash
git clone https://github.com/grafana/intro-to-mltp.git
cd intro-to-mltp
docker compose up
```

Access Grafana at `http://localhost:3000` (admin/admin)

### Local Development

```yaml
# docker-compose.yml
version: "3"
services:
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - ./grafana/provisioning:/etc/grafana/provisioning
```

## Provisioning

### Data Sources

```yaml
# grafana/provisioning/datasources/datasources.yml
apiVersion: 1

datasources:
  - name: Mimir
    type: prometheus
    url: http://mimir:9009/prometheus
    isDefault: true

  - name: Loki
    type: loki
    url: http://loki:3100

  - name: Tempo
    type: tempo
    url: http://tempo:3200

  - name: Pyroscope
    type: pyroscope
    url: http://pyroscope:4040
```

### Dashboards

```yaml
# grafana/provisioning/dashboards/dashboards.yml
apiVersion: 1

providers:
  - name: 'Default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
```

## Querying Data

### PromQL (Metrics)

```promql
# Request rate
rate(http_requests_total[5m])

# Error rate
rate(http_requests_total{status=~"5.."}[5m])

# P95 latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

### LogQL (Logs)

```logql
# All logs from service
{job="my-service"}

# Error logs
{job="my-service"} |= "error"

# Parse JSON and filter
{job="my-service"} | json | status >= 400
```

### TraceQL (Traces)

```traceql
# All traces from service
{ span.service.name = "my-service" }

# Error traces
{ span.status = "error" }

# Slow traces
{ span.duration > 100ms }
```

## Building Dashboards

### Dashboard JSON

```json
{
  "dashboard": {
    "title": "Service Overview",
    "tags": ["services"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Request Rate",
        "type": "timeseries",
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
        "targets": [
          {
            "datasource": {"type": "prometheus", "uid": "mimir"},
            "expr": "rate(http_requests_total[5m])"
          }
        ]
      }
    ]
  }
}
```

### Dashboard Variables

```json
{
  "templating": {
    "list": [
      {
        "name": "service",
        "type": "query",
        "query": "label_values(http_requests_total, job)"
      }
    ]
  }
}
```

Use in queries: `rate(http_requests_total{job="$service"}[5m])`

## Explore Mode

**Explore** provides ad-hoc query capabilities for all data sources:

| Data Source | Explore Features |
|-------------|-----------------|
| **Mimir** | PromQL query builder, instant/range queries |
| **Loki** | LogQL query builder, log context |
| **Tempo** | TraceQL search, trace waterfalls |
| **Pyroscope** | Flame graphs, profile comparison |

### Explore to Dashboard

```bash
# In Explore:
# 1. Build your query
# 2. Visualize results
# 3. Click "Save" → "Save as panel"
# 4. Add to existing or new dashboard
```

## Alerting

### Alert Rules

```yaml
# grafana/provisioning/alerting/rules.yml
apiVersion: 1

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

### Notification Channels

```yaml
# grafana/provisioning/alerting/contactpoints.yml
apiVersion: 1

contactpoints:
  - name: Slack
    type: slack
    settings:
      url: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

## Annotations

Mark events on dashboards for context:

```json
{
  "dashboard": {
    "annotations": {
      "list": [
        {
          "name": "Deployment",
          "datasource": "Grafana",
          "enable": true,
          "iconColor": "green",
          "tags": ["deploy"]
        }
      ]
    }
  }
}
```

Add annotations via UI: **Dashboard → Annotations → Add annotation**

## Best Practices

### Dashboard Organization

```
Dashboards/
├── Overview/
│   ├── Cluster Overview
│   └── Service Health
├── Services/
│   ├── API Dashboard
│   └── Worker Dashboard
└── Infrastructure/
    ├── Database Monitoring
    └── Cache Monitoring
```

### Panel Organization

1. **Top row**: High-level KPIs (stat panels)
2. **Middle rows**: Time series trends
3. **Bottom rows**: Detailed logs/traces

### Query Optimization

- Use **rate()** for counters
- Use **recording rules** for complex queries
- Limit query time range in variables
- Use query caching

### Variable Naming

```javascript
// Good - Descriptive
$service
$region
$environment

// Bad - Ambiguous
$var1
$var2
$x
```

## Advanced Features

### Mixed Data Sources

Display metrics, logs, and traces in one dashboard:

```json
{
  "panels": [
    {
      "title": "Metrics",
      "datasource": "Mimir",
      "type": "timeseries"
    },
    {
      "title": "Logs",
      "datasource": "Loki",
      "type": "logs"
    },
    {
      "title": "Traces",
      "datasource": "Tempo",
      "type": "trace"
    }
  ]
}
```

### Data Links

Link from metrics to traces:

```promql
# Add data link in panel settings
# Match: ${__value.raw}
# URL: ${__url.path}/explore?tempo datasource=${__datasource}&left=${__url.encode("${__trace.id}")}...
```

### Transformations

Apply transformations to query results:

| Transformation | Purpose |
|----------------|---------|
| **Join** | Merge results from multiple queries |
| **Organize** | Rearrange data structure |
| **Calculate** | Apply mathematical operations |
| **Partition** | Group data by values |

## Plugins

### Popular Plugins

| Plugin | Type | Purpose |
|--------|------|---------|
| **Piechart Panel** | Panel | Pie/donut charts |
| **Node Graph** | Panel | Network topology |
| **News Panel** | Panel | RSS feed display |
| **PostgreSQL** | Data Source | SQL database |
| **AWS CloudWatch** | Data Source | AWS metrics |

### Installing Plugins

```bash
# Via CLI
grafana-cli plugins install grafana-piechart-panel

# Via Docker
docker run -d \
  -e "GF_INSTALL_PLUGINS=grafana-piechart-panel" \
  grafana/grafana
```

## Monitoring Grafana

### Key Metrics

```promql
# Dashboard load time
histogram_quantile(0.99, rate(grafana_dashboard_load_duration_seconds[5m]))

# Active users
grafana_stats_active_users

# Request rate
rate(grafana_http_request_total[5m])
```

### Pre-built Dashboards

Grafana includes a self-monitoring dashboard:
- **Grafana** datasource
- **Grafana internals** dashboard

## Resources

- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)
- [Grafana GitHub](https://github.com/grafana/grafana)
- [Dashboard Gallery](https://grafana.com/grafana/dashboards/)
- [Community Plugins](https://grafana.com/grafana/plugins/)
- [intro-to-mltp Repository](https://github.com/grafana/intro-to-mltp)
