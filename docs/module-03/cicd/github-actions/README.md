# GitHub Actions for CI/CD

**Build automated CI/CD pipelines using GitHub Actions**

## Introduction

GitHub Actions is a CI/CD platform that allows you to automate workflows directly in your GitHub repository. Workflows are defined as YAML files in `.github/workflows/` and can be triggered by events like pushes, pull requests, or schedules.

## Why GitHub Actions?

| Feature | Benefit |
|---------|---------|
| **Native to GitHub** | No external service needed |
| **YAML-based** | Easy to read and version control |
| **Free for public repos** | Generous free tier for private repos |
| **Huge marketplace** | Pre-built actions for common tasks |
| **Matrix builds** | Test multiple versions in parallel |
| **Self-hosted runners** | Use your own infrastructure |
| **Secrets management** | Built-in secure credential storage |

## GitHub Actions Core Concepts

### 1. Workflow

A **workflow** is an automated process that runs one or more jobs.

```yaml
# .github/workflows/my-workflow.yml
name: My Workflow  # Workflow name
run-name: Deploy by @${{ github.actor }}  # Display name in UI
```

### 2. Event

An **event** is what triggers the workflow.

```yaml
on:
  push:                    # Trigger on push
    branches: [main, dev]  # Only on these branches
  pull_request:            # Trigger on PR
    branches: [main]
  workflow_dispatch:       # Allow manual trigger
  schedule:                # Cron trigger
    - cron: '0 0 * * *'    # Daily at midnight UTC
  release:                 # Trigger on release
    types: [published]
```

### 3. Job

A **job** is a set of steps that run on the same runner.

```yaml
jobs:
  build:                   # Job ID
    name: Build Job        # Job name (optional)
    runs-on: ubuntu-latest # Runner type
```

### 4. Step

A **step** is an individual task in a job.

```yaml
steps:
  - name: Checkout code    # Step name
    uses: actions/checkout@v4  # Use an action
  - name: Run tests
    run: pytest            # Run a command
```

### 5. Action

An **action** is a reusable command or script.

```yaml
# Pre-built actions from GitHub marketplace
uses: actions/checkout@v4
uses: actions/setup-python@v5
uses: docker/login-action@v3

# Custom action in your repo
uses: ./.github/actions/my-action
```

## Workflow File Structure

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

# Triggers
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

# Environment variables (global)
env:
  NODE_VERSION: '20.x'
  PYTHON_VERSION: '3.11'

# Jobs
jobs:
  test:
    runs-on: ubuntu-latest
    # Environment variables (job-level)
    env:
      TEST_ENV: 'testing'
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      - name: Install deps
        run: pip install -r requirements.txt
      - name: Run tests
        run: pytest
```

## Syntax Deep Dive

### Runs-on (Runner Selection)

```yaml
# GitHub-hosted runners
runs-on: ubuntu-latest  # Linux
runs-on: macos-latest   # macOS
runs-on: windows-latest # Windows

# Specific versions
runs-on: ubuntu-22.04
runs-on: macos-13
runs-on: windows-2022

# Self-hosted runners
runs-on: self-hosted
runs-on: [self-hosted, linux, x64]

# Matrix with different runners
runs-on: ${{ matrix.os }}
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest, windows-latest]
```

### Steps and Actions

```yaml
steps:
  # Checkout action (required to use repo code)
  - uses: actions/checkout@v4
    with:
      fetch-depth: 0    # Fetch all history
      token: ${{ secrets.GITHUB_TOKEN }}

  # Setup language
  - uses: actions/setup-python@v5
    with:
      python-version: '3.11'
      cache: 'pip'      # Cache pip dependencies

  # Run shell commands
  - name: Install dependencies
    run: pip install -r requirements.txt

  # Multi-line script
  - name: Run tests
    run: |
      echo "Running tests..."
      pytest
      echo "Tests complete!"

  # Use action from marketplace
  - uses: codecov/codecov-action@v3
    with:
      file: ./coverage.xml
```

### Contexts

Contexts provide information about the workflow run.

```yaml
# GitHub context
${{ github.ref }}              # Branch/tag reference
${{ github.sha }}              # Commit SHA
${{ github.repository }}       # owner/repo
${{ github.actor }}            # Trigger user
${{ github.event_name }}       # Event that triggered
${{ github.token }}            # Authentication token

# Runner context
${{ runner.os }}               # Operating system
${{ runner.temp }}             # Temp directory

# Secrets context
${{ secrets.MY_SECRET }}       # Repository secret

# Env context
${{ env.VAR_NAME }}           # Environment variable

# Variables context
${{ variables.MY_VAR }}       # Workflow variable
```

### Expressions

```yaml
# Conditional execution
- name: Deploy
  if: github.ref == 'refs/heads/main'
  run: ./deploy.sh

# String operations
- name: Checkout
  run: echo "Branch is ${{ github.ref_name }}"

# Functions
- name: Format output
  run: echo "${{ format('Hello {0}!', github.actor) }}"

# Status check functions
if: success()                    # Previous steps succeeded
if: failure()                    # Previous step failed
if: always()                     # Always run
if: cancelled()                  # Workflow was cancelled
```

## Common Workflow Patterns

### Pattern 1: Simple CI Pipeline

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
          cache: 'pip'

      - name: Install dependencies
        run: |
          pip install --upgrade pip
          pip install -r requirements.txt
          pip install pytest pytest-cov flake8 black

      - name: Lint with flake8
        run: flake8 . --count --select=E9,F63,F7,F82 --show-source

      - name: Check formatting
        run: black --check .

      - name: Run tests
        run: pytest --cov=. --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

### Pattern 2: Matrix Build

```yaml
name: Test Matrix

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false           # Don't cancel all on failure
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        python: ['3.10', '3.11', '3.12']
        exclude:
          # Exclude specific combinations
          - os: windows-latest
            python: '3.12'

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python }}

      - name: Run tests
        run: pytest
```

### Pattern 3: Docker Build and Push

```yaml
name: Docker Build

on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:

jobs:
  docker:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Docker Hub
        if: github.event_name != 'pull_request'
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: docker.io/myorg/myapp
          tags: |
            type=ref,event=branch
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,prefix={{branch}}-

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Pattern 4: Multi-Stage Deployment

```yaml
name: Deploy

on:
  push:
    branches: [main]

env:
  AWS_REGION: us-east-1
  ECR_REGISTRY: ${{ secrets.AWS_ECR_REGISTRY }}
  IMAGE_NAME: myapp

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.meta.outputs.version }}
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to ECR
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ${{ env.ECR_REGISTRY }}/${{ env.IMAGE_NAME }}:latest
            ${{ env.ECR_REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}

      - name: Extract version
        id: meta
        run: echo "version=${{ github.sha }}" >> $GITHUB_OUTPUT

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: staging
      url: https://staging.example.com
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Deploy to ECS
        run: |
          aws ecs update-service \
            --cluster staging-cluster \
            --service myapp-service \
            --force-new-deployment

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://example.com
    steps:
      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Deploy to ECS
        run: |
          aws ecs update-service \
            --cluster production-cluster \
            --service myapp-service \
            --force-new-deployment
```

### Pattern 5: Reusable Workflow

```yaml
# .github/workflows/reusable-ci.yml
name: Reusable CI

on:
  workflow_call:
    inputs:
      python-version:
        required: true
        type: string
    secrets:
      token:
        required: true

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          token: ${{ secrets.token }}

      - uses: actions/setup-python@v5
        with:
          python-version: ${{ inputs.python-version }}

      - name: Run tests
        run: pytest

# Calling workflow
# .github/workflows/call-ci.yml
name: Call CI

on: [push]

jobs:
  call-ci:
    uses: ./.github/workflows/reusable-ci.yml
    with:
      python-version: '3.11'
    secrets:
      token: ${{ secrets.GITHUB_TOKEN }}
```

## Caching Strategies

### Dependency Caching

```yaml
# Python pip cache
- uses: actions/setup-python@v5
  with:
    python-version: '3.11'
    cache: 'pip'                    # Auto-cache requirements.txt

# Manual pip cache
- uses: actions/cache@v4
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
    restore-keys: |
      ${{ runner.os }}-pip-

# Node.js npm cache
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'

# Docker layer cache
- uses: docker/build-push-action@v5
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

## Artifacts and Caching

```yaml
# Upload artifacts (files from workflow)
- name: Upload test results
  uses: actions/upload-artifact@v4
  if: always()
  with:
    name: test-results
    path: |
      htmlcov/
      coverage.xml
    retention-days: 30

# Download artifacts (from previous job)
- name: Download artifacts
  uses: actions/download-artifact@v4
  with:
    name: test-results
    path: ./test-results

# Cache data between workflows
- name: Cache mycache
  uses: actions/cache@v4
  with:
    path: path/to/cache
    key: ${{ runner.os }}-cache-${{ github.sha }}
    restore-keys: |
      ${{ runner.os }}-cache-
```

## Secrets and Security

### Repository Secrets

```yaml
# Set secrets in: Settings > Secrets and variables > Actions

- name: Deploy
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  run: |
    aws s3 sync ./dist s3://my-bucket

# Use with action
- uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

### Environment Secrets

```yaml
# Environment-specific secrets
jobs:
  deploy:
    environment: production
    env:
      DATABASE_URL: ${{ secrets.PROD_DATABASE_URL }}
```

## Best Practices

### 1. Use Latest Actions
```yaml
# Good - Use major version
uses: actions/checkout@v4

# Bad - Pin specific commit
uses: actions/checkout@a81bbbf8298c0fa03ea29cdc473d45769f953675

# Acceptable - Pin specific version for stability
uses: actions/checkout@v4.1.1
```

### 2. Fail Fast
```yaml
# Good - Run quick checks first
steps:
  - name: Quick lint
    run: black --check .
  - name: Longer tests
    run: pytest
```

### 3. Use Matrix Efficiently
```yaml
# Good - Run quick tests on all, slow on one
strategy:
  matrix:
    python: ['3.10', '3.11', '3.12']
    test:
      - quick
      - slow
    exclude:
      - python: '3.10'
        test: slow
      - python: '3.11'
        test: slow
```

### 4. Conditional Jobs
```yaml
# Only deploy on main branch
deploy:
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  runs-on: ubuntu-latest
```

### 5. Workflow Organization
```
.github/
├── workflows/
│   ├── ci.yml              # Continuous Integration
│   ├── docker-build.yml    # Docker image build
│   ├── deploy-staging.yml  # Deploy to staging
│   ├── deploy-prod.yml     # Deploy to production
│   └── scheduled.yml       # Scheduled tasks
└── actions/
    └── custom-action/      # Custom reusable actions
```

## Study Path

1. ✅ **CI/CD Fundamentals** - Core concepts
2. ✅ **GitHub Actions** (this document) - Platform-specific
3. 📖 **[MLOps Pipeline Examples](./mlops-pipelines.md)** - ML-specific workflows
4. 💻 **[Hands-on Exercises](../../../module-03/cicd/)** - Practice workflows

## Additional Resources

### Official Documentation
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [Contexts](https://docs.github.com/en/actions/learn-github-actions/contexts)
- [Expressions](https://docs.github.com/en/actions/learn-github-actions/expressions)

### Marketplace
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)

### Examples
- [Awesome Actions](https://github.com/sdras/awesome-actions)
- [GitHub Actions Examples](https://github.com/actions/examples)
