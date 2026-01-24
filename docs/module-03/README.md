# Module 3: Deployment and Operation

**Testing, CI/CD pipelines, cloud infrastructure, and monitoring**

## 🎯 Learning Objectives

By the end of this module, you will be able to:

- Design comprehensive testing strategies for ML systems
- Implement unit, integration, and contract tests
- Build CI/CD pipelines with GitHub Actions
- Use LocalStack for local cloud development
- Implement automated testing in deployment pipelines
- Understand observability pillars: Metrics, Logs, Traces, and Profiles
- Deploy and operate monitoring systems with Grafana LGTM+P stack

## 📋 Topics Covered

### 1. Testing ML Systems
- Unit testing for ML code
- Integration testing for APIs
- Contract testing for microservices
- Model validation and data testing

### 2. CI/CD with GitHub Actions
- Building automated pipelines
- Running tests in CI
- Automated deployments
- Environment-specific configurations

### 3. Local Development with LocalStack
- Local AWS service emulation
- Testing cloud infrastructure locally
- Faster development feedback loops

### 4. Monitoring & Observability
- **Grafana** - Visualization and analytics platform
- **Grafana Mimir** - Scalable metrics storage
- **Grafana Loki** - Centralized log aggregation
- **Grafana Tempo** - Distributed tracing
- **Grafana Pyroscope** - Continuous profiling
- Signal correlation and investigation workflows

## 📂 Module Structure

```
module-03/
├── testing/
│   ├── unit/             # Unit testing examples
│   ├── integration/      # Integration testing
│   └── contract/         # Contract testing
├── cicd/
│   ├── github-actions/   # GitHub Actions workflows
│   └── pipelines/        # CI/CD pipeline examples
├── monitoring/
│   └── README.md         # Quickstart with intro-to-mltp
├── exercises/            # Hands-on practice exercises
└── solution/             # Exercise solutions
```

## 🚀 Getting Started

### Prerequisites

- Completed Modules 1 & 2
- Basic understanding of testing concepts
- GitHub account for CI/CD
- Docker installed for monitoring demo

### Setup

1. Install testing dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Run tests:
   ```bash
   pytest
   ```

3. Set up LocalStack (optional):
   ```bash
   docker run -p 4566:4566 localstack/localstack
   ```

## 📖 Lessons

### Lesson 3.1: Unit Testing
Write effective unit tests for ML code.

- [Unit Testing Guide](./testing/unit/README.md)
- Exercise: Test your model code

### Lesson 3.2: Integration Testing
Test your APIs and services.

- [Integration Testing Guide](./testing/integration/README.md)
- Exercise: Test FastAPI endpoints

### Lesson 3.3: CI/CD Pipelines
Build automated deployment pipelines.

- [CI/CD Guide](./cicd/github-actions/README.md)
- Exercise: Create your own pipeline

### Lesson 3.4: Monitoring & Observability
Learn comprehensive observability with the Grafana LGTM+P stack.

- [Monitoring with intro-to-mltp](./monitoring/README.md)
- Exercise: Deploy the demo environment

## 💡 Testing Pyramid for ML

```
                   /\
                  /  \
                 / E2E \        (Few, slow, expensive)
                /--------\
               / Contract \      (Some, medium speed)
              /-----------\
             / Integration \    (More, faster)
            /---------------\
           /     Unit Tests   \ (Many, fast, cheap)
          /-------------------\
```

## 📚 Additional Resources

### Testing & CI/CD
- [pytest Documentation](https://docs.pytest.org/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [LocalStack Documentation](https://docs.localstack.cloud/)
- [Testing Best Practices](https://testing.googleblog.com/)

### Monitoring & Observability
- [Grafana Documentation](https://grafana.com/docs/)
- [intro-to-mltp Repository](https://github.com/grafana/intro-to-mltp)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [Grafana Cloud Free Tier](https://grafana.com/products/cloud/)
- [Grafana Community Slack](https://slack.grafana.com/)
