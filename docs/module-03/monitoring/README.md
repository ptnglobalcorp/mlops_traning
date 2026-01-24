# Monitoring with Grafana Stack

**Implement comprehensive observability with LGTM+P Stack**

##  Learning Objectives

By the end of this module, you will be able to:

- Understand the four pillars of observability: Metrics, Logs, Traces, and Profiles
- Deploy and configure Grafana Mimir for scalable metrics storage
- Implement centralized logging with Grafana Loki
- Set up distributed tracing with Grafana Tempo
- Enable continuous profiling with Grafana Pyroscope
- Correlate telemetry data across all signals for faster incident resolution
- Use the [intro-to-mltp](https://github.com/grafana/intro-to-mltp) repository for hands-on practice

##  Topics Covered

### 1. Observability Fundamentals
- The Three Pillars of Observability (Metrics, Logs, Traces)
- The Fourth Pillar: Continuous Profiling
- Signal correlation and context switching
- RED method (Rate, Errors, Duration)
- USE method (Utilization, Saturation, Errors)

### 2. Grafana (Visualization)
- Unified dashboard and visualization platform
- Multi-source data querying and exploration
- Alerting and notification management
- Panel types and visualizations
- [Grafana Guide](./grafana.md)

### 3. Grafana Mimir (Metrics)
- Scalable Prometheus-compatible metrics backend
- Long-term metrics storage and retention
- High availability and multi-tenancy
- Native histograms support
- [Grafana Mimir Guide](./mimir.md)

### 3. Grafana Loki (Logs)
- Label-based log aggregation system
- LogQL query language
- Efficient log storage and indexing
- Metrics from logs
- [Grafana Loki Guide](./loki.md)

### 4. Grafana Tempo (Traces)
- High-scale distributed tracing backend
- TraceQL query language
- Metrics from traces
- Service graph generation
- Span metadata and attributes
- [Grafana Tempo Guide](./tempo.md)

### 5. Grafana Pyroscope (Profiles)
- Continuous profiling platform
- CPU, memory, and IO profiling
- Flame graph visualization
- Traces to profiles correlation
- [Grafana Pyroscope Guide](./pyroscope.md)

### 6. Grafana Alloy
- OpenTelemetry Collector distribution
- Unified telemetry pipeline
- Flow configuration language
- Metrics, logs, traces, and profiles processing

##  Module Structure

```
module-03/monitoring/
├── README.md              # This file - Monitoring overview
├── grafana.md             # Grafana (Visualization) guide
├── mimir.md              # Grafana Mimir (Metrics) guide
├── loki.md               # Grafana Loki (Logs) guide
├── tempo.md              # Grafana Tempo (Traces) guide
├── pyroscope.md          # Grafana Pyroscope (Profiles) guide
├── quickstart.md         # Quickstart with intro-to-mltp
└── exercises/            # Hands-on exercises
```

##  Prerequisites

- Completed Module 1 (Infrastructure)
- Basic understanding of Prometheus metrics
- Docker and Docker Compose installed
- Basic knowledge of containerization

##  Quick Start

### Using intro-to-mltp Repository

The [intro-to-mltp](https://github.com/grafana/intro-to-mltp) repository provides a complete demonstration environment with all Grafana observability components:

```bash
# Clone the repository
git clone https://github.com/grafana/intro-to-mltp.git
cd intro-to-mltp

# Start the complete stack
docker compose up

# Access Grafana
open http://localhost:3000
# Default credentials: admin / admin
```

See [Quickstart Guide](./quickstart.md) for detailed instructions.

##  The LGTM+P Stack Architecture

```
+-----------------------------------------------------------------------+
|                           Grafana                                     |
+-----------------------------------------------------------------------+
                                   |
        +----------+----------+----------+----------+
        |          |          |          |          |
        v          v          v          v          v
+--------------+  +--------------+  +--------------+  +--------------+
|    Mimir     |  |     Loki     |  |     Tempo    |  |  Pyroscope    |
|   (Metrics)  |  |    (Logs)    |  |   (Traces)   |  |  (Profiles)   |
+--------------+  +--------------+  +--------------+  +--------------+
        |          |          |          |          |
        +----------+----------+----------+----------+
                                   |
                        +-------------------------+
                        |    Grafana Alloy        |
                        |  (Telemetry Pipeline)   |
                        +-------------------------+
                                   |
        +----------+----------+----------+----------+
        |          |          |          |          |
        v          v          v          v          v
+----------+  +----------+  +----------+  +----------+
| Services |  | Services |  | Services |  | Services |
|   App 1  |  |   App 2  |  |   App 3  |  |   App N  |
+----------+  +----------+  +----------+  +----------+
```

##  Signal Correlation

One of the key benefits of the Grafana stack is the ability to correlate data across all observability signals:

| Signal | Question | Tool |
|--------|----------|------|
| Metrics | "How many?" | PromQL |
| Logs | "Why?" | LogQL |
| Traces | "Where?" | TraceQL |
| Profiles | "What code?" | Pyroscope UI |

### Example Workflow

1. **Alert triggers** on high error rate (Mimir)
2. **Jump to logs** for specific error context (Loki)
3. **Follow trace** to identify failing service (Tempo)
4. **View profile** to find inefficient code (Pyroscope)

##  Lessons

### Lesson 3.4: Metrics with Mimir
Set up scalable metrics storage and querying.

- [Mimir Guide](./mimir.md)
- Exercise: Deploy Mimir and ingest metrics

### Lesson 3.5: Logs with Loki
Implement centralized log aggregation.

- [Loki Guide](./loki.md)
- Exercise: Configure Promtail and query logs

### Lesson 3.6: Traces with Tempo
Enable distributed tracing for microservices.

- [Tempo Guide](./tempo.md)
- Exercise: Instrument applications with OpenTelemetry

### Lesson 3.7: Profiles with Pyroscope
Add continuous profiling to your observability stack.

- [Pyroscope Guide](./pyroscope.md)
- Exercise: Profile an application and find bottlenecks

##  Resources

- [Grafana Documentation](https://grafana.com/docs/)
- [intro-to-mltp Repository](https://github.com/grafana/intro-to-mltp)
- [Grafana Cloud](https://grafana.com/products/cloud/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [Observability Best Practices](https://grafana.com/blog/category/observability/)
