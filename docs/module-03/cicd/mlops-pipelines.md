# MLOps CI/CD Pipelines

**Building CI/CD pipelines specifically for machine learning systems**

## Overview

ML systems have unique requirements beyond traditional software:

| Traditional CI/CD | ML CI/CD |
|-------------------|----------|
| Code changes | Code + Data + Model changes |
| Compile & test | Train + validate + evaluate |
| Deploy binary | Deploy model + serving infrastructure |
| Monitor uptime | Monitor data drift + model decay |
| Rollback code | Rollback model + retrain |

## CI/CD/CT for ML

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          MLOps Pipeline                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  CI: Continuous Integration                                      │   │
│  │  • Code quality checks (lint, type check)                        │   │
│  │  • Unit tests for data processing                                │   │
│  │  • Integration tests for model components                        │   │
│  │  • Data validation tests (schema, stats, quality)                │   │
│  │  • Security scans (dependencies, vulnerabilities)                 │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                 │                                        │
│                                 ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  CT: Continuous Training                                         │   │
│  │  • Data preprocessing pipeline                                    │   │
│  │  • Feature engineering                                            │   │
│  │  • Model training (automated hyperparameter tuning)               │   │
│  │  • Model evaluation (metrics, benchmarks)                         │   │
│  │  • Model validation (against baseline, bias checks)               │   │
│  │  • Model registration (version, metadata)                         │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                 │                                        │
│                                 ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  CD: Continuous Delivery/Deployment                              │   │
│  │  • Model packaging (Docker, serialized format)                    │   │
│  │  • Deploy to staging (shadow mode, canary)                        │   │
│  │  • A/B testing (compare models)                                   │   │
│  │  • Progressive rollout to production                              │   │
│  │  • Monitoring (data drift, prediction distribution)               │   │
│  │  • Automated rollback on degradation                              │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Pipeline 1: ML Model CI Pipeline

**Purpose**: Validate code, data, and model changes

```yaml
# .github/workflows/ml-ci.yml
name: ML CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  PYTHON_VERSION: '3.11'

jobs:
  # Stage 1: Code Quality
  code-quality:
    name: Code Quality Checks
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          pip install --upgrade pip
          pip install black flake8 mypy pylint
          pip install -r requirements.txt

      - name: Check formatting with black
        run: black --check .

      - name: Lint with flake8
        run: flake8 . --count --select=E9,F63,F7,F82 --show-source

      - name: Type check with mypy
        run: mypy src/

  # Stage 2: Data Validation
  data-validation:
    name: Data Validation
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install great-expectations pandas

      - name: Run data validation tests
        run: |
          python tests/data_validation.py

      - name: Upload data docs
        uses: actions/upload-artifact@v4
        with:
          name: data-docs
          path: great_expectations/uncommitted/data_docs/

  # Stage 3: Model Unit Tests
  model-tests:
    name: Model Unit Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov

      - name: Run model tests
        run: |
          pytest tests/models/ -v \
            --cov=src/models \
            --cov-report=xml \
            --cov-report=html

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml

      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage-report
          path: htmlcov/

  # Stage 4: Training Pipeline Test
  training-test:
    name: Training Pipeline Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt

      - name: Run quick training test
        run: |
          python train.py \
            --max-epochs 1 \
            --batch-size 32 \
            --sample-data \
            --output-dir ./test-run

      - name: Verify model output
        run: |
          python -m pytest tests/test_training.py -v

      - name: Upload test model
        uses: actions/upload-artifact@v4
        with:
          name: test-model
          path: test-run/
```

## Pipeline 2: Model Training and Registration

**Purpose**: Train and register models automatically

```yaml
# .github/workflows/train-model.yml
name: Train and Register Model

on:
  push:
    branches: [main]
    paths:
      - 'src/models/**'
      - 'data/**'
      - 'train.py'
  workflow_dispatch:
    inputs:
      epochs:
        description: 'Number of training epochs'
        required: false
        default: '100'
      batch-size:
        description: 'Batch size for training'
        required: false
        default: '32'

env:
  PYTHON_VERSION: '3.11'
  MLFLOW_TRACKING_URI: ${{ secrets.MLFLOW_TRACKING_URI }}

jobs:
  train:
    name: Train Model
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install mlflow boto3

      - name: Configure MLflow
        run: |
          mlflow login --username ${{ secrets.MLFLOW_USERNAME }} \
                       --password ${{ secrets.MLFLOW_PASSWORD }}

      - name: Download training data
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          aws s3 sync s3://my-bucket/training-data/ ./data/

      - name: Train model
        env:
          MLFLOW_EXPERIMENT_NAME: production-models
        run: |
          python train.py \
            --epochs ${{ github.event.inputs.epochs || '100' }} \
            --batch-size ${{ github.event.inputs['batch-size'] || '32' }} \
            --output-dir ./model-artifacts \
            --register-model

      - name: Log model metrics
        run: |
          python -c "
          import json
          with open('./model-artifacts/metrics.json', 'r') as f:
            metrics = json.load(f)
          print('Metrics:', json.dumps(metrics, indent=2))
          "

      - name: Upload model artifacts
        uses: actions/upload-artifact@v4
        with:
          name: model-artifacts
          path: model-artifacts/

      - name: Create GitHub Release
        if: success()
        uses: softprops/action-gh-release@v1
        with:
          tag_name: v${{ github.run_number }}
          name: Model v${{ github.run_number }}
          body: |
            Model trained successfully
            Metrics: ${{ steps.train.outputs.metrics }}
          files: |
            model-artifacts/model.pkl
            model-artifacts/metrics.json
```

## Pipeline 3: Model Deployment

**Purpose**: Deploy models to production with safety checks

```yaml
# .github/workflows/deploy-model.yml
name: Deploy Model

on:
  push:
    tags:
      - 'model-v*'
  workflow_dispatch:
    inputs:
      model-version:
        description: 'Model version to deploy'
        required: true
      environment:
        description: 'Target environment'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production

env:
  AWS_REGION: us-east-1
  ECR_REGISTRY: ${{ secrets.AWS_ECR_REGISTRY }}
  MODEL_NAME: ml-model

jobs:
  deploy:
    name: Deploy to ${{ github.event.inputs.environment || 'staging' }}
    runs-on: ubuntu-latest
    environment:
      name: ${{ github.event.inputs.environment || 'staging' }}
      url: https://${{ github.event.inputs.environment || 'staging' }}.example.com

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

      - name: Download model from MLflow
        env:
          MLFLOW_TRACKING_URI: ${{ secrets.MLFLOW_TRACKING_URI }}
        run: |
          pip install mlflow
          mlflow models download \
            -m "models:/${{ env.MODEL_NAME }}/${{ github.event.inputs['model-version'] || 'latest' }}" \
            -d ./model

      - name: Build Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          file: ./docker/Dockerfile.serving
          push: true
          tags: |
            ${{ env.ECR_REGISTRY }}/${{ env.MODEL_NAME }}:${{ github.sha }}
            ${{ env.ECR_REGISTRY }}/${{ env.MODEL_NAME }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Deploy to ECS
        run: |
          TASK_DEFINITION=$(aws ecs describe-task-definition \
            --cluster ${{ github.event.inputs.environment || 'staging' }}-cluster \
            --service ${{ env.MODEL_NAME }}-service \
            --query 'taskDefinition' \
            --output text)

          aws ecs update-service \
            --cluster ${{ github.event.inputs.environment || 'staging' }}-cluster \
            --service ${{ env.MODEL_NAME }}-service \
            --task-definition $TASK_DEFINITION \
            --force-new-deployment

      - name: Wait for deployment
        run: |
          aws ecs wait services-stable \
            --cluster ${{ github.event.inputs.environment || 'staging' }}-cluster \
            --services ${{ env.MODEL_NAME }}-service

      - name: Run smoke tests
        run: |
          python tests/smoke_test.py \
            --endpoint https://${{ github.event.inputs.environment || 'staging' }}.example.com/predict

      - name: Rollback on failure
        if: failure()
        run: |
          aws ecs update-service \
            --cluster ${{ github.event.inputs.environment || 'staging' }}-cluster \
            --service ${{ env.MODEL_NAME }}-service \
            --task-definition $TASK_DEFINITION \
            --force-new-deployment
```

## Pipeline 4: Batch Inference

**Purpose**: Run batch predictions on schedule

```yaml
# .github/workflows/batch-inference.yml
name: Batch Inference

on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM UTC
  workflow_dispatch:

env:
  PYTHON_VERSION: '3.11'
  AWS_REGION: us-east-1

jobs:
  batch-predict:
    name: Run Batch Predictions
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install boto3 mlflow

      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Download latest model
        env:
          MLFLOW_TRACKING_URI: ${{ secrets.MLFLOW_TRACKING_URI }}
        run: |
          mlflow models download \
            -m "models:/ml-model/Production" \
            -d ./model

      - name: Fetch input data
        run: |
          aws s3 sync s3://my-bucket/batch-input/ ./input-data/

      - name: Run batch inference
        env:
          BATCH_SIZE: 1000
        run: |
          python batch_inference.py \
            --model-dir ./model \
            --input-dir ./input-data \
            --output-dir ./output \
            --batch-size ${{ env.BATCH_SIZE }}

      - name: Upload predictions
        run: |
          aws s3 sync ./output/ s3://my-bucket/batch-output/${{ github.run_number }}/

      - name: Create prediction report
        run: |
          python generate_report.py \
            --input-dir ./output \
            --output ./prediction-report.html

      - name: Upload report as artifact
        uses: actions/upload-artifact@v4
        with:
          name: prediction-report
          path: prediction-report.html

      - name: Notify on failure
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          webhook-url: ${{ secrets.SLACK_WEBHOOK }}
          payload: |
            {
              "text": "Batch inference failed!",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "Batch inference pipeline *failed*.\nRun: <https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }}|View>"
                  }
                }
              ]
            }
```

## Pipeline 5: Model Monitoring

**Purpose**: Check for data drift and model degradation

```yaml
# .github/workflows/model-monitoring.yml
name: Model Monitoring

on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  workflow_dispatch:

env:
  PYTHON_VERSION: '3.11'

jobs:
  monitor:
    name: Check Model Health
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install alibi-detect evidently pandas boto3

      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Fetch recent predictions
        run: |
          aws s3 sync s3://my-bucket/predictions/ ./predictions/ \
            --exclude "*" --include "last-24h/*"

      - name: Fetch training baseline
        run: |
          aws s3 sync s3://my-bucket/baseline/ ./baseline/

      - name: Check for data drift
        run: |
          python detect_drift.py \
            --baseline ./baseline/train_stats.json \
            --current ./predictions/last-24h/ \
            --threshold 0.6 \
            --output ./drift_report.json

      - name: Check model performance
        run: |
          python check_performance.py \
            --predictions ./predictions/last-24h/ \
            --ground-truth ./ground-truth/ \
            --threshold 0.75 \
            --output ./performance_report.json

      - name: Generate monitoring report
        if: always()
        run: |
          python generate_monitoring_report.py \
            --drift ./drift_report.json \
            --performance ./performance_report.json \
            --output ./monitoring_dashboard.html

      - name: Upload monitoring report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: monitoring-report
          path: |
            monitoring_dashboard.html
            drift_report.json
            performance_report.json

      - name: Create issue if drift detected
        if: failure()
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: '⚠️ Model Drift Detected',
              body: 'Data drift or performance degradation detected. See monitoring report for details.',
              labels: ['monitoring', 'model-drift']
            })
```

## Best Practices for ML CI/CD

### 1. Separate Code and Data Triggers

```yaml
# Code changes - run CI
on:
  push:
    branches: [main]
    paths-ignore:
      - 'data/**'
      - 'notebooks/**'

# Data changes - run validation + retrain decision
on:
  push:
    branches: [main]
    paths:
      - 'data/**'
```

### 2. Use Feature Flags for Model Rollout

```python
# In your serving code
import os

NEW_MODEL_ENABLED = os.getenv('NEW_MODEL_ENABLED', 'false') == 'true'

def predict(features):
    if NEW_MODEL_ENABLED:
        return new_model.predict(features)
    return old_model.predict(features)
```

### 3. Implement Shadow Mode

```yaml
# Deploy new model alongside old
# Both predict, but only old model's output is used
- name: Enable shadow mode
  run: |
    kubectl set env deployment/model-server \
      SHADOW_MODEL_ENABLED=true \
      NEW_MODEL_VERSION=${{ github.sha }}
```

### 4. Model Registry Integration

```python
# Register model with MLflow
import mlflow

with mlflow.start_run():
    mlflow.log_params(params)
    mlflow.log_metrics(metrics)
    mlflow.sklearn.log_model(model, "model")
    mlflow.register_model(
        model_uri="sklearn-model",
        name="production-model",
        tags={"version": github.sha}
    )
```

### 5. Automated Rollback

```yaml
- name: Deploy with rollback
  run: |
    # Deploy new version
    kubectl set image deployment/model \
      model=${{ env.IMAGE }}:${{ github.sha }}

    # Wait for readiness
    kubectl wait --for=ready pods -l app=model --timeout=60s

    # Run smoke test
    python smoke_test.py || {
      kubectl rollout undo deployment/model
      exit 1
    }
```

## Study Path

1. ✅ **CI/CD Fundamentals** - Core concepts
2. ✅ **GitHub Actions** - Platform basics
3. ✅ **MLOps Pipelines** (this document) - ML-specific patterns
4. 💻 **[Hands-on Exercises](../../../module-03/cicd/)** - Practice workflows

## Additional Resources

### Tools & Platforms
- [MLflow](https://mlflow.org/) - Model lifecycle management
- [Kubeflow Pipelines](https://www.kubeflow.org/docs/components/pipelines/) - ML workflow orchestration
- [Prefect](https://www.prefect.io/) - Data workflow automation
- [Airflow](https://airflow.apache.org/) - Pipeline orchestration

### Articles
- [Continuous Delivery for Machine Learning](https://martinfowler.com/articles/cd4ml.html)
- [ML Ops: How to Build and Operate Machine Learning Systems](https://www.youtube.com/watch?v=68p-YNlz8T4)
- [Machine Learning Operations (MLOps): Overview, Definition, and Process](https://www.ibm.com/cloud/learn/mlops)
