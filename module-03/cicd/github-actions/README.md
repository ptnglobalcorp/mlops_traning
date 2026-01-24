# CI/CD with GitHub Actions

Build automated CI/CD pipelines for ML systems using GitHub Actions.

## 🎯 Learning Objectives

- Understand CI/CD pipeline fundamentals
- Create GitHub Actions workflows
- Automate testing and deployment
- Implement environment-specific pipelines

## 📖 CI/CD Pipeline Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    CI/CD Pipeline                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Push/PR ──► Build ──► Test ──► Package ──► Deploy         │
│                │        │          │           │            │
│                ▼        ▼          ▼           ▼            │
│            Install   Unit      Docker    Dev/Staging/Prod  │
│            Deps      Tests     Build                      │
│                      │                                     │
│                      ▼                                     │
│                  Integration                               │
│                      Tests                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 GitHub Actions Basics

### Workflow File Structure

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

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
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov
      - name: Run tests
        run: pytest --cov=src --cov-report=xml
```

## 📋 Example Workflows

### 1. Basic CI Pipeline

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  lint-and-test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
          cache: 'pip'

      - name: Install dependencies
        run: |
          pip install --upgrade pip
          pip install -r requirements.txt
          pip install flake8 pytest pytest-cov black

      - name: Lint with flake8
        run: |
          flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
          flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

      - name: Check formatting with black
        run: black --check .

      - name: Run tests
        run: |
          pytest --cov=. --cov-report=xml --cov-report=html

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
```

### 2. Docker Build and Push

```yaml
name: Docker Build

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  build-and-push:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: yourusername/mlops-training
          tags: |
            type=ref,event=branch
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### 3. Deploy to AWS (Terraform)

```yaml
name: Deploy to AWS

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.6.0

      - name: Terraform Init
        run: terraform init
        working-directory: ./module-01/terraform/basics

      - name: Terraform Format Check
        run: terraform fmt -check
        working-directory: ./module-01/terraform/basics

      - name: Terraform Plan
        run: terraform plan -out=tfplan
        working-directory: ./module-01/terraform/basics

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve tfplan
        working-directory: ./module-01/terraform/basics
```

### 4. Complete ML Pipeline

```yaml
name: ML CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  PYTHON_VERSION: '3.11'
  AWS_REGION: 'us-east-1'

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          pip install -r module-02/batch-api/fastapi/requirements.txt
          pip install -r module-03/testing/unit/requirements.txt

      - name: Run unit tests
        run: pytest module-03/testing/unit/ -v --cov=.

      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results
          path: |
            htmlcov/
            .coverage

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: ./module-02/batch-api/fastapi
          push: true
          tags: |
            ghcr.io/${{ github.repository }}:latest
            ghcr.io/${{ github.repository }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production

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
            --cluster mlops-cluster \
            --service model-api \
            --force-new-deployment
```

## 🔐 GitHub Secrets

Configure these secrets in your repository settings:

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key for deployment |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub password |
| `SLACK_WEBHOOK` | Slack webhook for notifications |

## 💡 Best Practices

1. **Use environments** for deployment stages (dev, staging, prod)
2. **Require approval** for production deployments
3. **Cache dependencies** to speed up builds
4. **Use matrix builds** for testing multiple Python versions
5. **Separate workflows** for CI and CD
6. **Monitor pipeline duration** and optimize slow steps

## 📁 Workflow Organization

```
.github/
└── workflows/
    ├── ci.yml              # Continuous Integration
    ├── docker-build.yml    # Docker image build
    ├── deploy-dev.yml      # Deploy to dev
    ├── deploy-prod.yml     # Deploy to production
    └── scheduled.yml       # Scheduled tasks
```

## 🔗 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
