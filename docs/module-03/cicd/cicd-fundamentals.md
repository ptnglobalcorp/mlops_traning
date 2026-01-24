# CI/CD Fundamentals

**Understanding the core concepts of continuous integration and delivery**

## Introduction

CI/CD represents a culture, set of operating principles, and a collection of practices that enable development teams to deliver changes more frequently and reliably. This guide covers the fundamental concepts that apply to all CI/CD systems.

## What Problem Does CI/CD Solve?

### Before CI/CD: The "Integration Hell"

```
Developer A                                    Developer B
    │                                              │
    ├── Works on feature X for 2 weeks ───────────┤
    │                                              │
    ├── Commits changes                          │
    │                                              │
    │                         ├── Works on feature Y for 2 weeks
    │                         │
    │                         ├── Commits changes
    │                         │
    │                         └── Everything breaks!
    │
    └── Spends 3 days debugging conflicts
```

**Problems:**
- Code changes accumulate over weeks
- Integration happens late (merge time)
- Conflicts are difficult to resolve
- Bugs discovered only after integration
- Deployments are risky and infrequent

### After CI/CD: Continuous Flow

```
Developer A                                    Developer B
    │                                              │
    ├── Works on feature X for 1 day ─────────────┤
    │                                              │
    ├── Commits to main                           │
    │         │                                    │
    │         ▼                                    │
    │    ┌─────────┐                               │
    │    │   CI    │ ◄── Commits to main          │
    │    │ Builds  │                               │
    │    │  Tests  │                               │
    │    └─────────┘                               │
    │         │                                    │
    │         ▼                                    │
    │    ✓ Pass/Fail (5 min)                      │
    │                                              │
    │                         ├── Works on feature Y for 1 day
    │                         │
    │                         ├── Commits to main
    │                         │
    │                         └── CI validates immediately
```

**Benefits:**
- Integration happens continuously
- Conflicts detected immediately
- Small changes are easy to debug
- Deployments become routine
- Teams move faster with confidence

## The CI/CD Pipeline

### Visual Pipeline Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           CI/CD Pipeline                                │
└─────────────────────────────────────────────────────────────────────────┘

   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
   │   Push   │───▶│   Build  │───▶│   Test   │───▶│  Deploy  │
   │   Code   │    │          │    │          │    │          │
   └──────────┘    └──────────┘    └──────────┘    └──────────┘
         │               │               │               │
         ▼               ▼               ▼               ▼
    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
    │Trigger  │    │Compile  │    │Validate │    │Release │
    │Event    │    │Install  │    │Verify  │    │Monitor │
    └─────────┘    └─────────┘    └─────────┘    └─────────┘
                         │               │               │
                         ▼               ▼               ▼
                    ┌─────────┐    ┌─────────┐    ┌─────────┐
                    │Artifact │    │Coverage │    │ Staging │
                    │Creation │    │Report   │    │   Prod  │
                    └─────────┘    └─────────┘    └─────────┘

    ✓ Continuous: Runs on every code change
    ✓ Automated: No manual intervention required
    ✓ Fast: Feedback in minutes, not hours
    ✓ Reliable: Same steps every time
```

### Pipeline Stages Explained

#### Stage 1: Source (Trigger)

**Purpose:** Detect when code changes and initiate pipeline

**Triggers:**
| Event | Description | Use Case |
|-------|-------------|----------|
| **Push** | Code pushed to branch | Continuous integration |
| **Pull Request** | PR opened/updated | Pre-merge validation |
| **Tag** | Version tag created | Release builds |
| **Manual** | Human triggers | On-demand deployments |
| **Scheduled** | Cron expression | Periodic tasks, nightly builds |

**Best Practices:**
- Run full tests on pull requests
- Run quick tests on every push
- Use protected branches for main
- Require status checks before merge

#### Stage 2: Build

**Purpose:** Prepare code for testing and deployment

**Steps:**
```yaml
1. Checkout: Retrieve source code
2. Setup: Install dependencies, tools
3. Compile: Build binaries, if needed
4. Package: Create deployable artifacts
5. Cache: Store dependencies for speed
```

**Build Artifacts:**
- Docker images
- Compiled binaries
- Python packages (wheels)
- Configuration bundles
- Model files (for ML)

#### Stage 3: Test

**Purpose:** Verify code quality and functionality

**Test Pyramid:**

```
                    ┌─────────┐
                   /    E2E   \           (Slow, expensive)
                  /  (30 min)  \
                 /───────────────\
                /    Contract     \        (Medium speed)
               /     (10 min)      \
              /──────────────────────\
             /     Integration        \     (Faster)
            /       (5 min)            \
           /─────────────────────────────\
          /          Unit Tests          \   (Fast, cheap)
         /           (1 min)              \
        /───────────────────────────────────\
```

**Test Types:**

| Type | Scope | Speed | Examples |
|------|-------|-------|----------|
| **Unit** | Individual functions | Fast (<1 min) | `pytest test_model.py` |
| **Integration** | Component interaction | Medium (5 min) | API endpoint tests |
| **Contract** | Interface compatibility | Medium (5 min) | Schema validation |
| **E2E** | Full system flow | Slow (30 min) | User journey tests |
| **Performance** | Load, stress | Variable | Load testing |
| **Security** | Vulnerability scan | Medium | SAST, dependency scan |

**Quality Gates:**
- Code coverage threshold (e.g., 80%)
- No critical vulnerabilities
- All tests pass
- Performance benchmarks met
- Documentation generated

#### Stage 4: Deploy

**Purpose:** Release validated changes to environments

**Deployment Strategies:**

```
┌─────────────────────────────────────────────────────────────────┐
│                    Deployment Strategies                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Recreate (All at once)                                      │
│     ┌─────────┐                                                 │
│     │  v1.0   │ ◄── Stop v1.0                                   │
│     │    ↓    │                                                │
│     │  v2.0   │ ◄── Start v2.0 (downtime)                       │
│     └─────────┘                                                 │
│                                                                  │
│  2. Rolling Update (Gradual)                                    │
│     ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐                           │
│     │ v1.0│ │ v2.0│ │ v2.0│ │ v2.0│ ◄── Replace one by one      │
│     └─────┘ └─────┘ └─────┘ └─────┘                           │
│                                                                  │
│  3. Blue/Green (Instant switch)                                 │
│     ┌─────────┐      ┌─────────┐                               │
│     │  Blue   │ ───▶ │  Green  │ ◄── Switch traffic            │
│     │  v1.0   │      │  v2.0   │                                │
│     └─────────┘      └─────────┘                               │
│                                                                  │
│  4. Canary (Gradual traffic shift)                              │
│     ┌─────────┐ ┌─────┐ ┌─────────┐                           │
│     │  90%    │ │ 10% │ │  0%     │ ◄── Shift traffic slowly   │
│     │  v1.0   │ │ v2.0│ │  v2.0   │                            │
│     └─────────┘ └─────┘ └─────────┘                           │
│                                                                  │
│  5. A/B Testing (Split traffic)                                 │
│     ┌─────────┐ ┌─────────┐                                   │
│     │  50%    │ │  50%    │ ◄── Compare metrics               │
│     │  Model A│ │  Model B│                                    │
│     └─────────┘ └─────────┘                                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Environments:**

| Environment | Purpose | Trigger | Promotion |
|-------------|---------|---------|-----------|
| **Development** | Feature testing | Every push | Automatic |
| **Staging** | Pre-production | Merge to main | Manual approval |
| **Production** | Live users | Approved staging | Manual/auto |

## Continuous Integration (CI) Deep Dive

### CI Core Principles

1. **Integrate Frequently**
   - Commit multiple times per day
   - Don't let branches diverge
   - Short-lived feature branches

2. **Automate Everything**
   - Build automatically
   - Test automatically
   - Report automatically

3. **Fail Fast**
   - Run quick tests first
   - Stop on first failure
   - Immediate notification

4. **Fix Immediately**
   - Don't build on broken code
   - Fix or revert quickly
   - Keep main green

### What Gets Tested in CI?

```yaml
Code Quality:
  - Linting (flake8, black, pylint)
  - Type checking (mypy)
  - Security scanning (bandit, Snyk)
  - Dependency checks (safety)

Functional Testing:
  - Unit tests (pytest, unittest)
  - Integration tests (API, database)
  - Contract tests (pact)

ML-Specific Testing:
  - Data validation (great expectations)
  - Model unit tests
  - Training pipeline tests
  - Inference tests
```

### CI Pipeline Metrics

| Metric | Target | Why |
|--------|--------|-----|
| **Build Duration** | < 10 minutes | Fast feedback |
| **Test Coverage** | > 80% | Code quality |
| **Success Rate** | > 95% | Pipeline reliability |
| **Time to Fix** | < 1 hour | Team velocity |

## Continuous Delivery (CD) Deep Dive

### CD Core Principles

1. **Deployable at All Times**
   - Every commit is release-ready
   - No hidden manual steps
   - Automated packaging

2. **Automated Promotion**
   - Staged environments
   - Automated handoffs
   - Minimal manual intervention

3. **Rollback Ready**
   - Quick rollback capability
   - Previous version cached
   - Database migrations reversible

4. **Monitor in Production**
   - Health checks
   - Metrics collection
   - Alert on degradation

### Deployment Checklist

```yaml
Pre-Deployment:
  - ✓ All tests pass
  - ✓ Code reviewed
  - ✓ Security scan clean
  - ✓ Documentation updated
  - ✓ Migration scripts ready

Deployment:
  - ✓ Backup current version
  - ✓ Run database migrations
  - ✓ Deploy new version
  - ✓ Run smoke tests
  - ✓ Monitor health

Post-Deployment:
  - ✓ Verify functionality
  - ✓ Check error rates
  - ✓ Monitor performance
  - ✓ User acceptance testing
  - ✓ Clean up old versions
```

## CI/CD for Machine Learning

### ML-Specific Considerations

**Data Versioning:**
```
Code → Git
Data → DVC, S3, Delta Lake
Models → MLflow, S3, Registry
```

**Model Lifecycle:**
```
┌─────────────────────────────────────────────────────────────┐
│                    ML Model Lifecycle                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Data Collection ──► 2. Data Validation                 │
│                             │                               │
│                             ▼                               │
│                    3. Feature Engineering                  │
│                             │                               │
│                             ▼                               │
│                    4. Model Training                       │
│                             │                               │
│                             ▼                               │
│                    5. Model Evaluation                     │
│                             │                               │
│                             ▼                               │
│                    6. Model Registration                   │
│                             │                               │
│                             ▼                               │
│                    7. Model Deployment                     │
│                             │                               │
│                             ▼                               │
│                    8. Monitoring                           │
│                             │                               │
│                             ▼                               │
│              (Loop back if degradation detected)            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### CI/CD/CT for ML

| Concept | Description | Tools |
|---------|-------------|-------|
| **CI** | Code integration, data validation, model tests | pytest, great_expectations |
| **CT** | Continuous Training - automated model retraining | Airflow, Kubeflow, Prefect |
| **CD** | Model deployment, monitoring, rollback | MLflow, Seldon, KServe |

## Key CI/CD Concepts

### Branching Strategies

**Trunk-Based Development:**
```
main (always deployable)
  ├── short-lived feature branches (< 1 day)
  └── direct commits allowed
```

**GitHub Flow:**
```
main (protected)
  ├── feature branches
  ├── pull requests
  └── merge after review + tests
```

**Git Flow:**
```
main (production releases)
  ├── develop (integration branch)
  ├── feature branches
  ├── release branches
  └── hotfix branches
```

### Versioning

**Semantic Versioning (SemVer):**
```
MAJOR.MINOR.PATCH

1.2.3
 │ │ │
 │ │ └── PATCH: Bug fixes
 │ └──── MINOR: New features (backward compatible)
 └─────── MAJOR: Breaking changes

Examples:
  v1.0.0 → First stable release
  v1.1.0 → Added new feature
  v1.1.1 → Bug fix
  v2.0.0 → Breaking changes
```

### Infrastructure as Code (IaC)

**Benefits:**
- Version controlled infrastructure
- Reproducible environments
- Automated provisioning
- Drift detection

**Tools:**
- Terraform (multi-cloud)
- CloudFormation (AWS)
- Pulumi (programming languages)
- Ansible (configuration)

## Best Practices Summary

### Do's ✓

1. **Keep pipelines fast** - Optimize for speed
2. **Fail fast** - Run quick checks first
3. **Use caching** - Cache dependencies
4. **Parallelize** - Run independent jobs in parallel
5. **Secure secrets** - Never commit credentials
6. **Monitor everything** - Track pipeline metrics
7. **Document pipelines** - Comment on complex steps

### Don'ts ✗

1. **Don't commit secrets** - Use secret management
2. **Don't ignore failures** - Fix red builds immediately
3. **Don't skip tests** - All tests must pass
4. **Don't hardcode values** - Use environment variables
5. **Don't deploy from branches** - Use protected main
6. **Don't manual test in CI** - Automate everything
7. **Don't silence errors** - Fail loudly and clearly

## Study Path

1. ✅ **CI/CD Fundamentals** (this document)
2. 📖 **[GitHub Actions Basics](./github-actions/README.md)** - Practical implementation
3. 🚀 **[MLOps Pipeline Examples](./mlops-pipelines.md)** - ML-specific patterns
4. 💻 **[Hands-on Exercises](../../module-03/cicd/)** - Practice workflows

## Additional Resources

### Articles & Documentation
- [GitHub CI/CD Best Practices](https://docs.github.com/en/actions/learn-github-actions/best-practices-for-github-actions)
- [CI/CD Patterns](https://www.patterns.dev/)
- [Testing Best Practices](https://testing.googleblog.com/)

### Videos
- [CI/CD Explained in 10 Minutes](https://www.youtube.com/watch?v=su1uFflWkt4)
- [Continuous Integration Explained](https://www.youtube.com/watch?v=ylZ7ySuqTnQ)

### Tools
- [GitHub Actions](https://github.com/features/actions)
- [GitLab CI/CD](https://docs.gitlab.com/ee/ci/)
- [CircleCI](https://circleci.com/docs/)
