# Trunk-Based Development

**Continuous integration through short-lived branches**

## Overview

Trunk-Based Development (TBD) is a branching strategy where developers work on short-lived branches and merge to the main trunk at least daily. This approach enables continuous integration and reduces integration pain.

## Core Principles

1. **Commit to trunk daily**: Merge to main at least once per day
2. **Short-lived branches**: Feature branches last hours, not days
3. **Feature flags**: Use toggles for incomplete features
4. **Automated testing**: Comprehensive test suite is mandatory
5. **Continuous integration**: Every commit is tested

## Branch Structure

```
main (trunk)
├── feature/auth (2 hours) ──┐
├── feature/ui (4 hours) ───┤──→ merged daily
├── feature/api (6 hours) ───┤
└── hotfix/bug (1 hour) ────┘
```

## Workflow

### Basic Feature Workflow

```bash
# 1. Pull latest main
git switch main
git pull origin main

# 2. Create feature branch
git switch -c feature/user-auth

# 3. Make changes (small, focused)
echo "def authenticate():" > auth.py
git add auth.py
git commit -m "feat: add authenticate function"

# 4. Update with latest main (before merging)
git fetch origin
git rebase origin/main

# 5. Resolve any conflicts (if any)
# ... resolve conflicts ...
git rebase --continue

# 6. Merge to main
git switch main
git merge feature/user-auth
git push origin main

# 7. Delete feature branch
git branch -d feature/user-auth
```

### Team Coordination

```bash
# Developer A: Create feature
git switch -c feature/login-ui
# ... make changes ...

# Developer B: Create different feature
git switch --force feature/auth-api
# ... make changes ...

# Both developers update frequently
# Developer A (every 2 hours)
git fetch origin
git rebase origin/main

# Developer B (every 2 hours)
git fetch origin
git rebase origin/main

# Both merge to main when ready
git switch main
git merge feature/login-ui
git push origin main
```

## Feature Flags

Feature flags allow incomplete code to exist in main without being active.

### Implementation Example

```python
# config.py
FEATURE_FLAGS = {
    'NEW_AUTH_ENABLED': False,
    'DASHBOARD_V2': False,
    'API_V2': True
}

# auth.py
from config import FEATURE_FLAGS

def authenticate_user(username, password):
    if FEATURE_FLAGS['NEW_AUTH_ENABLED']:
        return new_auth_method(username, password)
    else:
        return old_auth_method(username, password)

def new_auth_method(username, password):
    # New implementation
    pass

def old_auth_method(username, password):
    # Old implementation
    pass
```

### Using Feature Flags

```bash
# 1. Implement feature with flag disabled
git switch -c feature/new-auth
# ... implement new_auth_method() ...
git commit -m "feat: add new authentication (disabled)"

# 2. Merge to main (still disabled)
git switch main
git merge feature/new-auth
git push origin main

# 3. Test in staging (enable flag)
# Update config.py: NEW_AUTH_ENABLED = True
git commit -m "chore: enable new auth in staging"

# 4. Test thoroughly
# ... automated tests ...
# ... manual QA ...

# 5. Enable in production
# Update config.py: NEW_AUTH_ENABLED = True
git commit -m "chore: enable new authentication"
git push origin main

# 6. Remove old code later
git switch -c cleanup/remove-old-auth
# ... delete old_auth_method() ...
git commit -m "refactor: remove old authentication"
git merge main
```

### Advanced Feature Flags

```python
# feature_flags.py
import os

class FeatureFlags:
    @staticmethod
    def is_enabled(flag_name, user_id=None):
        # Environment-based
        if not os.getenv(f'{flag_name}_ENABLED', 'false').lower() == 'true':
            return False

        # User-based (rollout to specific users)
        if user_id:
            rollout_percent = int(os.getenv(f'{flag_name}_ROLLOUT', '0'))
            if hash(user_id) % 100 < rollout_percent:
                return True

        return False

# usage.py
from feature_flags import FeatureFlags

if FeatureFlags.is_enabled('NEW_DASHBOARD', user.id):
    render_new_dashboard()
else:
    render_old_dashboard()
```

## Branch Protection Rules

Configure these in GitHub repository settings:

```yaml
Required:
  ✅ Pull request before merging
  ✅ At least 1 approval
  ✅ Dismiss stale approvals on new commits
  ✅ Require status checks to pass
  ✅ Require branches to be up to date

Required status checks:
  ✅ test (CI)
  ✅ lint (CI)
  ✅ coverage (CI)

Rules:
  ❌ Do not allow bypassing settings
  ✅ Require linear history
```

## Daily Development Routine

### Morning Routine

```bash
# 1. Pull latest main
git switch main
git pull origin main

# 2. Create new feature branch
git switch -c feature/today-work

# 3. Check if CI is passing
# Visit GitHub: check green checkmarks
```

### During Development

```bash
# Every 2 hours: Rebase with main
git fetch origin
git rebase origin/main

# Make small, focused commits
git add file.py
git commit -m "feat: add user validation"

# Push for visibility
git push origin feature/today-work

# Check CI status
# If failing: fix immediately
```

### Before Lunch

```bash
# Update with main
git fetch origin
git rebase origin/main

# Push changes
git push origin feature/today-work

# Ensure CI is green
```

### End of Day

```bash
# 1. Final rebase
git fetch origin
git rebase origin/main

# 2. Review changes
git log origin/main..HEAD

# 3. Merge to main
git switch main
git merge feature/today-work
git push origin main

# 4. Delete feature branch
git branch -d feature/today-work
git push origin --delete feature/today-work

# 5. Verify all checks pass on main
```

## Handling Conflicts

### Pre-Merge Rebase

```bash
# Before merging, always rebase
git switch feature/my-work
git fetch origin
git rebase origin/main

# If conflicts occur:
# 1. Open conflicted files
# 2. Resolve conflicts
# 3. Mark as resolved
git add resolved-file.py
# 4. Continue rebase
git rebase --continue

# If needed, abort and try again
git rebase --abort
git pull --rebase origin main
```

### Conflict Prevention

```bash
# 1. Communicate with team
# Use Slack/Teams to coordinate

# 2. Update frequently
# Set up alias: git update = !git fetch && git rebase origin/main

# 3. Small changes
# Break features into small pieces

# 4. Clear code ownership
# Document who works on what modules
```

## Testing Strategy

### Test Pyramid

```
        E2E Tests (5%)
       ─────────────
      Integration Tests (15%)
     ─────────────────────
    Unit Tests (80%)
   ──────────────────────
```

### Test Requirements

```python
# tests/test_auth.py
import pytest
from auth import authenticate_user

def test_authenticate_valid_user():
    """Unit test - fast, isolated"""
    result = authenticate_user("user", "pass")
    assert result is True

def test_authenticate_invalid_user():
    """Unit test"""
    result = authenticate_user("invalid", "pass")
    assert result is False

def test_authenticate_with_database():
    """Integration test - slower, uses dependencies"""
    # Test with real database
    result = authenticate_user("user", "pass")
    assert result is True
```

### CI Test Configuration

```bash
# pytest.ini
[pytest]
testpaths = tests
python_files = test_*.py
python_functions = test_*
addopts =
    --cov=.
    --cov-report=term-missing
    --cov-report=html
    --strict-markers
markers =
    slow: marks tests as slow (deselect with CI)
    integration: marks tests as integration
```

## Deployment Pipeline

### Deployment Workflow

```bash
# When main is updated:
git push origin main

# Trigger deployment (automated or manual)
./deploy.sh production

# Verify deployment
curl -f https://api.example.com/health

# Monitor metrics
```

### Progressive Rollout

```bash
# 1. Deploy to canary (5% of traffic)
./deploy.sh --env=production --traffic=5

# 2. Monitor metrics (5 minutes)
# Check error rates, latency

# 3. If good, increase to 50%
./deploy.sh --env=production --traffic=50

# 4. Monitor (10 minutes)

# 5. If good, full rollout (100%)
./deploy.sh --env=production --traffic=100
```

## Best Practices

### Do's ✅

- **Commit small**: Each commit should be independently valuable
- **Merge daily**: Don't let branches accumulate
- **Test everything**: Maintain high test coverage
- **Review code**: Use pull requests even with TBD
- **Communicate**: Let team know what you're working on
- **Automate**: Automate testing, linting, deployment

### Don'ts ❌

- **Don't hold changes**: Merge to main daily
- **Don't create long branches**: Branches < 1 day
- **Don't skip tests**: All tests must pass
- **Don't break main**: Ensure CI passes before merge
- **Don't work in isolation**: Coordinate with team
- **Don't disable CI**: Keep checks running

## Metrics to Track

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Branch lifetime | < 1 day | `git log --format=%cd --date=short | uniq -c` |
| Commit frequency | Daily | Commits per developer per day |
| CI pass rate | > 95% | Test suite success rate |
| Test coverage | > 80% | Coverage reports |
| Merge conflicts | Minimal | Number of conflicts per merge |
| Deployment frequency | Daily | Deployments to production |

## Common Challenges

### Challenge 1: Merge Conflicts

**Solution**: Rebase frequently
```bash
# Set up automatic rebase
git config --global branch.autoSetupRebase always
git config --global pull.rebase true
```

### Challenge 2: Broken Builds

**Solution**: Require CI checks
```yaml
# Branch protection: require status checks
checks: [test, lint, coverage]
```

### Challenge 3: Large Features

**Solution**: Break into smaller pieces
```bash
# Instead of one large branch:
feature/entire-payment-system

# Use multiple small branches:
feature/payment-gateway-client
feature/payment-processing
feature/payment-ui
feature/payment-tests
```

### Challenge 4: Team Coordination

**Solution**: Use team communication
```bash
# Daily standup: discuss what's being worked on
# Slack channel: notify before merging to main
# Code ownership: document module ownership
```

## Tools and Automation

### Useful Git Aliases

```bash
# Quick update with main
git config --global alias.up '!f() { git fetch origin && git rebase origin/main; }; f'

# Show branch age
git config --global alias.branch-age '!for branch in $(git branch | cut -c3-); do echo -n "$branch: "; git log -1 --format=%cd "$branch"; done'

# Quick commit
git config --global alias.qc '!git add -A && git commit -m'

# Rebase interactively last N commits
git config --global alias.rbi '!git rebase -i HEAD~'
```

### Pre-commit Hooks

```bash
# .git/hooks/pre-commit
#!/bin/bash
# Run tests before commit
pytest || exit 1

# Run linter
black --check . || exit 1

# Check coverage
coverage report | grep TOTAL | awk '{if ($4+0 < 80) {exit 1}}'
```

## Comparison with Other Strategies

| Aspect | Trunk-Based | GitHub Flow | Git Flow |
|--------|-------------|-------------|----------|
| Main branch protection | ✅ Strict | ✅ Strict | ⚠️ Relaxed |
| Branch lifetime | Hours | Days | Weeks |
| Release frequency | Continuous | On demand | Scheduled |
| Complexity | Low | Low | High |
| CI/CD requirement | Mandatory | Important | Optional |
| Feature flags | Required | Optional | No |

## When to Use Trunk-Based Development

### Ideal For

- ✅ Small to medium teams (2-10 developers)
- ✅ Strong automated testing culture
- ✅ Continuous deployment (multiple times daily)
- ✅ Cloud-native applications
- ✅ SaaS products
- ✅ Microservices architecture

### Not Ideal For

- ❌ Large teams without good coordination
- ❌ Weak automated testing
- ❌ Manual release processes
- ❌ Complex version requirements
- ❌ On-premise software with infrequent updates

## Getting Started

### Week 1: Foundation

1. Set up CI/CD pipeline
2. Add automated tests
3. Configure branch protection
4. Train team on workflow

### Week 2: Practice

1. Create short-lived branches
2. Practice frequent rebasing
3. Implement feature flags
4. Establish daily routine

### Week 3: Optimize

1. Reduce branch lifetime
2. Increase test coverage
3. Automate deployment
4. Track metrics

### Week 4: Scale

1. Expand to all teams
2. Optimize CI/CD speed
3. Refine processes
4. Share best practices

## Next Steps

- [Branching Strategies Overview](./branching-strategies.md) - Compare strategies
- [GitHub Flow](./github-flow.md) - Alternative simplified workflow
- [Git Flow](./git-flow.md) - Complex enterprise workflow
- [Remote Operations](./remote-operations.md) - Working with remotes
