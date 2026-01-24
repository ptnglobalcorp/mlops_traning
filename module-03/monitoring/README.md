# Monitoring & Observability

**Hands-on practice with the Grafana LGTM+P Stack**

This section provides a practical introduction to monitoring and observability using the Grafana stack. For detailed documentation on each component, refer to the [full monitoring guides](../../../docs/module-03/monitoring/README.md).

## 🎯 What You'll Learn

- Deploy a complete monitoring stack with Docker Compose
- Explore metrics, logs, traces, and profiles
- Correlate telemetry data for incident investigation
- Use Grafana for visualization and dashboards

## 🚀 Quick Start with intro-to-mltp

The [intro-to-mltp](https://github.com/grafana/intro-to-mltp) repository from Grafana provides a complete demonstration environment with all observability components running together.

### Prerequisites

- Docker Desktop or Docker Engine with Docker Compose
- At least 8GB RAM available for Docker
- Modern web browser (Chrome, Firefox, Edge)

### Setup

```bash
# Clone the repository
git clone https://github.com/grafana/intro-to-mltp.git
cd intro-to-mltp

# Start the complete stack
docker compose up

# Or run in background
docker compose up -d
```

### Access the Components

| Component | URL | Purpose |
|-----------|-----|---------|
| **Grafana** | http://localhost:3000 | Visualization dashboards (admin/admin) |
| **Mimir** | http://localhost:9009 | Metrics storage |
| **Loki** | http://localhost:3100 | Log aggregation |
| **Tempo** | http://localhost:3200 | Distributed tracing |
| **Pyroscope** | http://localhost:4040 | Continuous profiling |
| **Frontend App** | http://localhost:3001 | Demo application |

## 📖 Exercise: Explore the Monitoring Stack

### Step 1: Access Grafana

```bash
# Open Grafana in your browser
open http://localhost:3000

# Login with credentials
Username: admin
Password: admin
```

### Step 2: View Pre-configured Dashboards

Navigate to **Dashboards → Browse → MLT Dashboard**

The dashboard shows:
- RED metrics (Rate, Errors, Duration) derived from traces
- Request rate by service
- Error rate by status code
- Latency percentiles

### Step 3: Query Metrics with PromQL

Open **Explore** and select the **Mimir** data source:

```promql
# Request rate
rate(http_requests_total[5m])

# Error rate
rate(http_requests_total{status=~"5.."}[5m])

# P95 latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

### Step 4: Query Logs with LogQL

Open **Explore** and select the **Loki** data source:

```logql
# All logs from API
{job="mythical-server"}

# Error logs
{job="mythical-server"} |= "error"

# Logs by status code
{job="mythical-server"} | json | status >= 400
```

### Step 5: Explore Traces with TraceQL

Open **Explore** and select the **Tempo** data source:

```traceql
# All traces from API
{ span.service.name = "mythical-server" }

# Error traces
{ span.status = "error" }

# Slow traces
{ span.duration > 100ms }
```

Click on a trace to see:
- Service map (which services were involved)
- Span timeline (when each operation occurred)
- Span attributes (metadata for each span)

### Step 6: View Profiles

Open **Explore** and select the **Pyroscope** data source:

```python
# CPU profiles
{service="mythical-server"}{type="cpu"}

# Memory profiles
{service="mythical-server"}{type="inuse_space"}
```

In the flame graph:
- Hover over sections to see function names
- Click to drill down into call stacks
- Wide sections indicate hot paths (more resource usage)

## 🔗 Signal Correlation

Follow this investigation workflow:

```
1. Alert triggers (Mimir metrics show high error rate)
        ↓
2. Check logs (Loki shows specific error messages)
        ↓
3. Follow trace (Tempo shows the request flow)
        ↓
4. View profile (Pyroscope identifies slow function)
```

### Data Links in Grafana

- **From metrics**: Click exemplars to jump to traces
- **From traces**: Jump to logs with trace ID, view related metrics
- **From logs**: Click trace ID to view trace, view related metrics

## 🛠️ Component Overview

| Component | Signal | Query Language | Use For |
|-----------|--------|----------------|---------|
| **Grafana** | Visualization | PromQL, LogQL, TraceQL | "Visualize" - Dashboards, alerts |
| **Grafana Mimir** | Metrics | PromQL | "How many?" - Counting, measuring |
| **Grafana Loki** | Logs | LogQL | "Why?" - Context, debugging |
| **Grafana Tempo** | Traces | TraceQL | "Where?" - Distributed flow |
| **Grafana Pyroscope** | Profiles | UI-based | "What code?" - Performance analysis |

## 🛑 Stopping the Stack

```bash
# Stop all services
docker compose down

# Remove volumes (delete all data)
docker compose down -v

# View logs
docker compose logs -f grafana
```

## 📚 Further Learning

For comprehensive documentation on each component, see:

- [Full Monitoring Guide](../../../docs/module-03/monitoring/README.md)
- [Grafana (Visualization)](../../../docs/module-03/monitoring/grafana.md)
- [Grafana Mimir (Metrics)](../../../docs/module-03/monitoring/mimir.md)
- [Grafana Loki (Logs)](../../../docs/module-03/monitoring/loki.md)
- [Grafana Tempo (Traces)](../../../docs/module-03/monitoring/tempo.md)
- [Grafana Pyroscope (Profiles)](../../../docs/module-03/monitoring/pyroscope.md)
- [Quickstart Guide](../../../docs/module-03/monitoring/quickstart.md)

## 🔗 Resources

- [intro-to-mltp Repository](https://github.com/grafana/intro-to-mltp)
- [Grafana Documentation](https://grafana.com/docs/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [Grafana Community Slack](https://slack.grafana.com/)
