# MLOps Training Documentation

**Complete study guide for MLOps infrastructure and deployment**

## Study Path Overview

This documentation follows a **hybrid structure**:
- **`docs/`** (you are here) - Conceptual learning and theory
- **`module-X/`** - Hands-on labs and practice code

## Quick Start

1. **Choose your module** below
2. **Read the conceptual documentation** in `docs/module-X/`
3. **Practice with labs** in `module-X/` folder

---

## Module 1: Infrastructure & Prerequisites

**Goal**: Master Git, AWS, Kubernetes, and Terraform fundamentals for MLOps

### Study Path

| Order | Topic | Description | Lab Location |
|-------|-------|-------------|--------------|
| 1 | Git for Teams | Version control, branching strategies, and team collaboration | [`module-01/git/`](../module-01/git/) |
| 2 | AWS Cloud Services | Cloud services, security, networking, and AI/ML | [`module-01/aws/`](../module-01/aws/) |
| 3 | Kubernetes | Container orchestration for production workloads | [`module-01/k8s/`](../module-01/k8s/) |
| 4 | Terraform | Infrastructure as Code fundamentals | [`module-01/terraform/`](../module-01/terraform/) |

### Module 1 Documentation

**Git for Teams:**
- [Git Overview](module-01/git/README.md) - Complete Git collaboration guide
- [Git Basics & Configuration](module-01/git/git-basics.md) - Essential commands and setup
- [Understanding Git Areas](module-01/git/git-areas.md) - How Git manages files
- [Branching Strategies](module-01/git/branching-strategies.md) - Compare workflows
- [Remote Operations](module-01/git/remote-operations.md) - Working with remotes
- [Pull Requests & Code Review](module-01/git/pull-requests.md) - Collaboration process
- [Merge Conflicts](module-01/git/merge-conflicts.md) - Resolving conflicts
- [Repository Governance](module-01/git/repository-governance.md) - Team contribution models
- [Team Conventions](module-01/git/team-conventions.md) - Standards and best practices
- [Workflow Examples](module-01/git/workflow-examples.md) - Real-world scenarios

**AWS Cloud Services:**
- [AWS Overview Guide](module-01/aws/README.md) - Complete AWS CLF-C02 reference
  - Cloud Concepts & Security
  - Core Services (Compute, Storage, Database, Networking, Analytics)
  - AI/ML Services
  - Deployment Methods
  - Billing & Pricing
  - LocalStack Practice Guides

**Kubernetes:**
- [K8s Overview](module-01/k8s/README.md) - Complete K8s guide
- [Why Kubernetes?](module-01/k8s/01-overview/README.md) - Production orchestration
- [Core Objects](module-01/k8s/02-key-concepts/core-objects/README.md) - Object model, namespaces, pods, labels
- [Workloads](module-01/k8s/02-key-concepts/workloads/README.md) - Deployments, StatefulSets, Jobs
- [Storage](module-01/k8s/02-key-concepts/storage/README.md) - PVs, PVCs, StorageClasses
- [Configuration](module-01/k8s/02-key-concepts/configuration/README.md) - ConfigMaps and Secrets
- [Network](module-01/k8s/02-key-concepts/network/README.md) - Services and Ingress
- [Architecture](module-01/k8s/03-architecture/README.md) - Control plane and nodes
- [Helm](module-01/k8s/04-helm/README.md) - Package management
- [Monitoring](module-01/k8s/05-monitoring/README.md) - Observability

**Terraform:**
- [Terraform Basics Guide](module-01/terraform/basics.md)
- [Terraform Examples](module-01/terraform/examples.md)
- [Terraform Exercises](module-01/terraform/exercises.md)

### Lab Locations

| Lab | Description | Location |
|-----|-------------|----------|
| **Git for Teams** | Git practice exercises and examples | [`module-01/git/`](../module-01/git/) |
| **LocalStack** | AWS services practice locally | [`module-01/aws/localstack/`](../module-01/aws/localstack/) |
| **Kubernetes** | K8s hands-on practice | [`module-01/k8s/`](../module-01/k8s/) |
| **Terraform Basics** | Infrastructure as Code fundamentals | [`module-01/terraform/basics/`](../module-01/terraform/basics/) |
| **Terraform Examples** | Example configurations | [`module-01/terraform/examples/`](../module-01/terraform/examples/) |
| **Terraform Exercises** | Practice exercises | [`module-01/terraform/exercises/`](../module-01/terraform/exercises/) |

---

## Module 2: Model Deployment

**Coming soon** - Batch API deployment with FastAPI

**Lab Location:** [`module-02/batch-api/`](../module-02/batch-api/)

---

## Module 3: Deployment and Operation

**Goal**: Implement automated testing, CI/CD pipelines, and monitoring

### Study Path

| Order | Topic | Description | Lab Location |
|-------|-------|-------------|--------------|
| 1 | Testing | Unit, integration, and contract testing | [`module-03/testing/`](../module-03/testing/) |
| 2 | CI/CD | GitHub Actions workflows and pipelines | [`module-03/cicd/`](../module-03/cicd/) |
| 3 | Monitoring & Observability | Grafana LGTM+P stack | [`module-03/monitoring/`](../module-03/monitoring/) |

### Module 3 Documentation

**Testing:**
- [Unit Testing Overview](module-03/testing/unit/README.md)

**CI/CD:**
- [GitHub Actions Overview](module-03/cicd/github-actions/README.md)

**Monitoring & Observability:**
- [Quick Start with intro-to-mltp](module-03/monitoring/README.md)
- [Grafana Overview](module-03/monitoring/grafana.md) - Visualization platform
- [Grafana Mimir](module-03/monitoring/mimir.md) - Scalable metrics storage
- [Grafana Loki](module-03/monitoring/loki.md) - Centralized log aggregation
- [Grafana Tempo](module-03/monitoring/tempo.md) - Distributed tracing
- [Grafana Pyroscope](module-03/monitoring/pyroscope.md) - Continuous profiling
- [Quickstart Guide](module-03/monitoring/quickstart.md)

### Lab Locations

| Lab | Description | Location |
|-----|-------------|----------|
| **Testing** | Unit, integration, contract testing | [`module-03/testing/`](../module-03/testing/) |
| **CI/CD** | GitHub Actions workflows | [`module-03/cicd/github-actions/`](../module-03/cicd/github-actions/) |
| **Monitoring** | Grafana LGTM+P stack demo | [`module-03/monitoring/`](../module-03/monitoring/) |

---

## Study Tips

### For Each Module

1. **Read first** - Start with the conceptual guide in `docs/`
2. **Practice second** - Run the lab exercises in `module-X/`
3. **Experiment** - Modify configurations and observe changes
4. **Review** - Re-read documentation with practical context

### For Hands-on Skills

1. **Complete all lab exercises** - Don't skip!
2. **Break things intentionally** - Learn to troubleshoot
3. **Build variations** - Modify exercises to solve new problems
4. **Document your learnings** - Keep notes

### Example Study Workflow

```bash
# 1. Read the conceptual guide (Git for Teams)
cat docs/module-01/git/README.md

# 2. Navigate to the lab
cd module-01/git

# 3. Practice Git workflows
# Create a practice repository, branches, merges, etc.

# 4. Read AWS guide
cat docs/module-01/aws/README.md

# 5. Navigate to the lab
cd ../aws/localstack

# 6. Start the lab environment
docker compose up -d

# 7. Practice the exercises
aws --endpoint-url=http://localhost:4566 s3 mb s3://my-bucket

# 8. Clean up
docker compose down -v
```

---

## Additional Resources

### External References

**General:**
- [Git Documentation](https://git-scm.com/doc)
- [GitHub Flow Guide](https://guides.github.com/introduction/flow/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Docker Documentation](https://docs.docker.com/)
- [Terraform Documentation](https://developer.hashicorp.com/terraform)

**AWS (Reference for CLF-C02 Exam):**
- [AWS Certified Cloud Practitioner CLF-C02 Exam Guide](https://aws.amazon.com/certification/certified-cloud-practitioner/)
- [DigitalCloud.training Cheat Sheets](https://digitalcloud.training/)

**Testing & CI/CD:**
- [pytest Documentation](https://docs.pytest.org/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

**Monitoring & Observability:**
- [Grafana Documentation](https://grafana.com/docs/)
- [intro-to-mltp Repository](https://github.com/grafana/intro-to-mltp)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)

### Internal Tools

- [`module-01/git/`](../module-01/git/) - Git practice exercises
- [`module-01/aws/localstack/`](../module-01/aws/localstack/) - LocalStack lab environment
- [`module-01/k8s/`](../module-01/k8s/) - Kubernetes hands-on practice
- [`module-01/terraform/`](../module-01/terraform/) - Terraform practice
- [`module-03/testing/`](../module-03/testing/) - Testing labs
- [`module-03/cicd/github-actions/`](../module-03/cicd/github-actions/) - CI/CD workflows
- [`module-03/monitoring/`](../module-03/monitoring/) - Grafana LGTM+P stack

---

## Progress Tracking

Track your progress by checking off completed modules:

### Module 1: Infrastructure & Prerequisites
- [ ] Git for Teams (Basics, Branching Strategies, Collaboration)
- [ ] AWS Cloud Services (Core Services, Security, AI/ML)
- [ ] Kubernetes (Core Objects, Workloads, Storage, Networking)
- [ ] Terraform Basics
- [ ] LocalStack Practice Labs

### Module 2: Model Deployment
- [ ] Batch API with FastAPI
- [ ] Model Deployment Patterns

### Module 3: Deployment and Operation
- [ ] Testing (Unit, Integration, Contract)
- [ ] CI/CD Pipelines (GitHub Actions)
- [ ] Monitoring & Observability (Grafana LGTM+P)

---

**Last Updated**: January 2026
