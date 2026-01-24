# Quickstart with intro-to-mltp

**Hands-on practice with the complete Grafana observability stack**

## Overview

The [intro-to-mltp](https://github.com/grafana/intro-to-mltp) repository provides a complete demonstration environment with all Grafana observability components (Mimir, Loki, Tempo, Pyroscope) running together in Docker Compose. This is an excellent way to learn and experiment with the full stack.

### What's Included

| Component | Port | Purpose |
|-----------|------|---------|
| **Grafana** | 3000 | Visualization and dashboards |
| **Mimir** | 9009 | Metrics storage |
| **Loki** | 3100 | Log aggregation |
| **Tempo** | 3200 | Distributed tracing |
| **Pyroscope** | 4040 | Continuous profiling |
| **Alloy** | 12345 | Telemetry pipeline |
| **Microservices** | 3001+ | Demo application |

## Prerequisites

- Docker Desktop or Docker Engine with Docker Compose
- At least 8GB RAM available for Docker
- Modern web browser (Chrome, Firefox, Edge)

## Getting Started

### Step 1: Clone and Start

```bash
# Clone the repository
git clone https://github.com/grafana/intro-to-mltp.git
cd intro-to-mltp

# Start the complete stack
docker compose up

# Or run in background
docker compose up -d
```

### Step 2: Access Grafana

```bash
# Open Grafana in your browser
open http://localhost:3000

# Default credentials
Username: admin
Password: admin
```

### Step 3: Explore the Application

The demo application includes several microservices:

```bash
# Access the frontend
open http://localhost:3001

# The app includes:
# - mythical-requester: Makes API requests
# - mythical-server: REST API server
# - mythical-recorder: Message queue recorder
# - mythical-frontend: React web interface
```

### Step 4: Generate Load

The stack includes k6 for load testing:

```bash
# k6 automatically runs load tests
# View k6 metrics in Grafana
```

## Component Access

| Component | URL | Credentials |
|-----------|-----|-------------|
| Grafana | http://localhost:3000 | admin/admin |
| Mimir | http://localhost:9009 | N/A (metrics only) |
| Loki | http://localhost:3100 | N/A (logs only) |
| Tempo | http://localhost:3200 | N/A (traces only) |
| Pyroscope | http://localhost:4040 | N/A (profiles only) |
| Alloy UI | http://localhost:12345 | N/A |

## Stack Architecture

```
+-----------------------------------------------------------------------+
|                           Grafana (3000)                              |
|                   - Dashboards - Explore - Alerting                   |
+-----------------------------------------------------------------------+
                                   |
        +----------+----------+----------+----------+----------+
        |          |          |          |          |          |
        v          v          v          v          v          v
+--------------+  +--------------+  +--------------+  +--------------+
|    Mimir     |  |     Loki     |  |     Tempo    |  |  Pyroscope    |
|   (9009)     |  |    (3100)    |  |    (3200)    |  |    (4040)     |
+--------------+  +--------------+  +--------------+  +--------------+
        |          |          |          |          |          |
        +----------+----------+----------+----------+----------+
                                   |
                        +-------------------------+
                        |    Grafana Alloy        |
                        |      (12345)            |
                        +-------------------------+
                                   |
        +----------+----------+----------+----------+----------+
        |          |          |          |          |          |
        v          v          v          v          v          v
+--------------+  +--------------+  +--------------+  +--------------+
|   k6 Load    |  |   Services   |  |   Services   |  |   Services   |
|    Tester    |  |  (requester) |  |   (server)   |  |  (recorder)  |
+--------------+  +--------------+  +--------------+  +--------------+
```

## Exploring Metrics

### 1. View Pre-configured Dashboards

```bash
# Navigate in Grafana:
# Dashboards -> Browse -> MLT Dashboard
```

The MLT Dashboard shows:
- RED metrics (Rate, Errors, Duration) derived from traces
- Request rate by service
- Error rate by status code
- Latency percentiles

### 2. Query Metrics with PromQL

```bash
# Open Grafana Explore
# Select Mimir data source
# Try these queries:

# Request rate
rate(http_requests_total[5m])

# Error rate
rate(http_requests_total{status=~"5.."}[5m])

# P95 latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Requests by service
sum by (service) (rate(http_requests_total[5m]))
```

### 3. View Exemplars

```bash
# In the metrics dashboard:
# - Click on a metric point
# - View exemplars linking to traces
# - Jump to Tempo for detailed trace
```

## Exploring Logs

### 1. Query Logs with LogQL

```bash
# Open Grafana Explore
# Select Loki data source
# Try these queries:

# All logs from API
{job="mythical-server"}

# Error logs
{job="mythical-server"} |= "error"

# Logs by status
{job="mythical-server"} | json | status >= 400

# Full-text search
{job="mythical-server"} |= "database"
```

### 2. View Log Context

```bash
# In log results:
# - Click on any log entry
# - View surrounding logs for context
# - See labels and metadata
```

### 3. Metrics from Logs

```bash
# Convert logs to metrics:
count_over_time({job="mythical-server"}[5m])

# Error rate from logs:
sum by (level) (count_over_time({job="mythical-server", level="error"}[5m]))
```

## Exploring Traces

### 1. View Traces in Tempo

```bash
# Open Grafana Explore
# Select Tempo data source
# Search for traces:

# All traces
{ span.service.name = "mythical-server" }

# Error traces
{ span.status = "error" }

# Slow traces
{ span.duration > 100ms }

# Specific operations
{ .http.method = "GET" && .http.target = "/api/beasts" }
```

### 2. Examine Trace Details

```bash
# Click on a trace to see:
# - Service map (which services were involved)
# - Span timeline (when each operation occurred)
# - Span attributes (metadata for each span)
# - Related logs (if available)
```

### 3. Trace to Logs/Metrics

```bash
# From a trace:
# - Jump to logs for same trace ID
# - View metrics for related service
# - Use exemplars to navigate back and forth
```

## Exploring Profiles

### 1. View Profiles in Pyroscope

```bash
# Open Grafana Explore
# Select Pyroscope data source
# Choose a profile type:

# CPU profiles
{service="mythical-server"}{type="cpu"}

# Memory profiles
{service="mythical-server"}{type="inuse_space"}

# Goroutine profiles
{service="mythical-server"}{type="goroutines"}
```

### 2. Analyze Flame Graphs

```bash
# In the flame graph:
# - Hover over sections to see function names
# - Click to drill down into call stacks
# - Compare time periods
# - Identify hot paths (wide sections)
```

### 3. Compare Profiles

```bash
# Compare before/after:
{service="mythical-server"} vs {service="mythical-server", offset=1h}

# Compare between versions:
{service="mythical-server", version="v1"} vs {service="mythical-server", version="v2"}
```

## Signal Correlation

### End-to-End Investigation

```
1. Alert triggers (Mimir metrics show high error rate)
        ↓
2. Check logs (Loki shows specific error messages)
        ↓
3. Follow trace (Tempo shows the request flow)
        ↓
4. View profile (Pyroscope identifies slow function)
        ↓
5. Fix and verify (all signals show improvement)
```

### Data Links

```bash
# From metrics:
# - Click exemplar to jump to trace
# - Click log link to view related logs

# From traces:
# - Jump to logs with trace ID
# - View profile for service

# From logs:
# - Click trace ID to view trace
# - View related metrics
```

## Alloy Configuration

### View Alloy Pipeline

```bash
# Open Alloy UI
open http://localhost:12345

# See the complete telemetry pipeline:
# - Receivers (where data comes in)
# - Processors (how data is transformed)
# - Exporters (where data goes)
```

### Alloy Configuration

The repository includes sample Alloy configuration in `alloy/config.alloy`:

```alloy
// Metrics scraping
prometheus.scrape "services" {
  targets = [...]
  forward_to = [prometheus.remote_write.mimir.receiver]
}

// Logs collection
loki.source.file "logs" {
  targets = [...]
  forward_to = [loki.write.grafana_loki.receiver]
}

// Traces receiver
otlp.receiver "default" {
  output {
    traces = [otelcol.exporter.otlp.tempo.output]
  }
}
```

## Grafana Cloud Integration

### Send to Grafana Cloud

```bash
# Edit alloy/endpoints-cloud.json:
{
  "metricsUrl": "https://your-mimir-url",
  "logsUrl": "https://your-loki-url",
  "tracesUrl": "https://your-tempo-url",
  "profilesUrl": "https://your-pyroscope-url",
  "metricsUsername": "your-username",
  "metricsPassword": "your-token",
  ...
}

# Use cloud compose file:
docker compose -f docker-compose-cloud.yml up
```

## Stopping the Stack

```bash
# Stop all services
docker compose down

# Remove volumes (delete all data)
docker compose down -v

# View logs
docker compose logs -f

# View logs for specific service
docker compose logs -f grafana
```

## Troubleshooting

### Services Not Starting

```bash
# Check Docker resources
docker stats

# Increase Docker memory allocation to 8GB+

# Check port conflicts
netstat -tuln | grep LISTEN
```

### No Data in Grafana

```bash
# Check data sources are configured
# Settings -> Data sources -> Check each source

# Verify services are running
docker compose ps

# Check logs for errors
docker compose logs mimir
docker compose logs loki
docker compose logs tempo
```

### High CPU/Memory Usage

```bash
# Reduce k6 load
# Edit docker-compose.yml:
K6_VUS: 1  # Reduce from default

# Remove unused services
# Comment out services in docker-compose.yml
```

## Next Steps

1. **Experiment with Queries**: Try different PromQL, LogQL, and TraceQL queries
2. **Create Dashboards**: Build custom dashboards for your use case
3. **Instrument Your App**: Add telemetry to your own applications
4. **Set Up Alerts**: Create alerting rules for proactive monitoring
5. **Deploy to Production**: Use Grafana Cloud or self-hosted deployment

## Resources

- [intro-to-mltp Repository](https://github.com/grafana/intro-to-mltp)
- [Grafana Documentation](https://grafana.com/docs/)
- [Grafana Cloud Free Tier](https://grafana.com/products/cloud/)
- [Grafana Community Slack](https://slack.grafana.com/)
