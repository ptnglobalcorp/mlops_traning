# Branching Strategies

**Choosing the right workflow for your team**

## Overview

Branching strategies define how teams use Git branches to collaborate on features, fixes, and releases. The right strategy depends on team size, release frequency, and deployment patterns.

## Key Concepts

All branching strategies share these principles:

1. **Main branch** is always deployable
2. **Feature branches** isolate work in progress
3. **Code review** happens before merging
4. **Continuous integration** validates changes

## Comparison of Strategies

| Strategy | Complexity | Release Cadence | Best For |
|----------|-----------|-----------------|----------|
| Trunk-Based | Low | Continuous | Small teams, CI/CD, fast iterations |
| GitHub Flow | Low | As needed | SaaS, cloud apps, frequent deployments |
| Git Flow | High | Scheduled releases | Enterprise, versioned software, multiple environments |

## Strategy Decision Tree

```
Need to support multiple versions in production?
├── Yes → Git Flow
└── No
    ├── Deploy to production multiple times per day?
    │   ├── Yes → Trunk-Based Development
    │   └── No → GitHub Flow
```

## Trunk-Based Development

### Overview

All developers work on a single branch (trunk/main) with short-lived feature branches that are merged daily.

### Branch Structure

```
main (trunk)
├── feature/auth (1 day)
├── feature/login (few hours)
└── feature/ui (few hours)
```

### Workflow

```bash
# 1. Create short-lived branch
git switch -c feature/auth

# 2. Make changes (few hours to 1 day)
git add .
git commit -m "Add authentication"

# 3. Update with latest main
git fetch origin
git rebase origin/main

# 4. Merge to main (via PR or direct)
git switch main
git merge feature/auth
git push origin main

# 5. Delete feature branch
git branch -d feature/auth
```

### Pros

- ✅ Simple to understand
- ✅ Minimal merge conflicts
- ✅ Always releasable
- ✅ Fast integration
- ✅ Encourages small changes

### Cons

- ❌ Requires strong CI/CD
- ❌ Needs automated testing
- ❌ High coordination overhead
- ❌ No separate production versions

### Best Practices

1. **Branch lifetime**: Keep branches under 1 day
2. **Small commits**: Break features into small pieces
3. **Feature flags**: Use toggles for incomplete features
4. **Continuous integration**: Test every commit
5. **Automated deployment**: Deploy main to production

### When to Use

- Small to medium teams (2-10 developers)
- Continuous deployment (multiple times per day)
- Strong automated testing
- Cloud-native applications

### Example with Feature Flags

```python
# feature_flag.py
FEATURE_AUTH_ENABLED = True

# main.py
if FEATURE_AUTH_ENABLED:
    authenticate_user()
else:
    skip_authentication()
```

## GitHub Flow

### Overview

Simplified workflow with long-lived main branch and short-lived feature branches. Main is always deployed.

### Branch Structure

```
main (deployed to production)
├── feature/new-ui (few days)
├── bugfix/login-error (1 day)
└── feature/api-integration (few days)
```

### Workflow

```bash
# 1. Create feature branch from main
git switch main
git pull origin main
git switch -c feature/user-dashboard

# 2. Make changes and commit
git add .
git commit -m "Add user dashboard"

# 3. Push to remote
git push origin feature/user-dashboard

# 4. Create Pull Request on GitHub
# - Add description
# - Request review
# - Run CI checks

# 5. Address review feedback
git add .
git commit -m "Address review comments"
git push origin feature/user-dashboard

# 6. Merge PR after approval
# - Use "Squash and merge" or "Merge commit"
# - Delete branch after merge

# 7. Update local main
git switch main
git pull origin main
```

### Pros

- ✅ Simple and easy to learn
- ✅ Continuous deployment friendly
- ✅ Clear code review process
- ✅ No long-lived dev branches
- ✅ Easy to revert changes

### Cons

- ❌ No staging environment branch
- ❌ Difficult for hotfixes
- ❌ Requires good CI/CD
- ❌ No release branches

### Best Practices

1. **Pull requests required**: All changes via PR
2. **Code review mandatory**: At least one approval
3. **CI must pass**: Tests required before merge
4. **Delete branches**: Clean up after merge
5. **Descriptive PR titles**: Use conventional commits

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Manual testing completed
- [ ] All tests passing

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added to complex code
- [ ] Documentation updated
```

### When to Use

- Web applications
- SaaS products
- Continuous deployment (weekly or more frequent)
- Teams with good CI/CD practices

## Git Flow

### Overview

Strict branching model with dedicated branches for features, releases, and hotfixes. Ideal for versioned releases.

### Branch Structure

```
main (production releases)
├── develop (development branch)
│   ├── feature/user-auth (days to weeks)
│   └── feature/database (days to weeks)
└── release/v1.2.0 (release preparation)
    └── hotfix/v1.2.1 (production hotfix)
```

### Workflow

#### Feature Development

```bash
# 1. Start from develop
git switch develop
git pull origin develop

# 2. Create feature branch
git switch -c feature/user-auth

# 3. Develop and commit
git add .
git commit -m "Add user authentication"

# 4. Merge back to develop
git switch develop
git merge feature/user-auth
git push origin develop

# 5. Delete feature branch
git branch -d feature/user-auth
```

#### Release Preparation

```bash
# 1. Create release branch from develop
git switch develop
git switch -c release/v1.2.0

# 2. Bump version, update docs
# Change version.txt: 1.2.0

# 3. Test and fix
git add .
git commit -m "Bump version to 1.2.0"

# 4. Merge to main (production)
git switch main
git merge release/v1.2.0
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin main --tags

# 5. Merge back to develop
git switch develop
git merge release/v1.2.0
git push origin develop

# 6. Delete release branch
git branch -d release/v1.2.0
```

#### Hotfix Production

```bash
# 1. Create hotfix from main
git switch main
git switch -c hotfix/v1.2.1

# 2. Fix critical bug
git add .
git commit -m "Fix critical security issue"

# 3. Merge to main and tag
git switch main
git merge hotfix/v1.2.1
git tag -a v1.2.1 -m "Hotfix v1.2.1"

# 4. Merge to develop
git switch develop
git merge hotfix/v1.2.1

# 5. Delete hotfix branch
git branch -d hotfix/v1.2.1
```

### Pros

- ✅ Clear separation of concerns
- ✅ Support for multiple versions
- ✅ Parallel development
- ✅ Structured release process
- ✅ Easy hotfix management

### Cons

- ❌ Complex to learn and maintain
- ❌ Overhead for small teams
- ❌ Merge conflicts on release branches
- ❌ Can slow down development
- ❌ Requires strict discipline

### Branch Types

| Branch | Purpose | Lifetime | Merge Target |
|--------|---------|----------|--------------|
| `main` | Production releases | Indefinite | - |
| `develop` | Integration branch | Indefinite | - |
| `feature/*` | New features | Days-weeks | develop |
| `release/*` | Release preparation | Days-weeks | main + develop |
| `hotfix/*` | Production fixes | Hours-days | main + develop |

### Branch Naming Conventions

```bash
# Features
feature/user-authentication
feature/payment-gateway
feature/dashboard-redesign

# Releases
release/v2.0.0
release/v1.5.3

# Hotfixes
hotfix/critical-security-fix
hotfix/v1.2.4
hotfix/production-bug-123
```

### When to Use

- Enterprise software
- Scheduled releases (monthly/quarterly)
- Multiple versions in production
- Large teams (10+ developers)
- Complex release requirements

### Example Project Structure

```
my-project/
├── .git/
├── src/
├── tests/
└── version.txt          # Current version
```

```bash
# version.txt
1.2.0
```

## Choosing the Right Strategy

### Decision Framework

**Use Trunk-Based if:**
- ✅ Deploy multiple times daily
- ✅ Strong automated testing
- ✅ Small team (2-10)
- ✅ Cloud-native application

**Use GitHub Flow if:**
- ✅ Deploy weekly or more frequently
- ✅ Good CI/CD pipeline
- ✅ Any team size
- ✅ Single production version

**Use Git Flow if:**
- ✅ Scheduled releases
- ✅ Support multiple versions
- ✅ Large team (10+)
- ✅ Enterprise requirements

### Migration Path

```
Start with GitHub Flow
↓
Add more branches as needed
↓
Adopt Git Flow for complexity
↓
Simplify to Trunk-Based with mature CI/CD
```

## Hybrid Approaches

### Modified GitHub Flow with Environment Branches

```
main (production)
├── staging (pre-production)
└── feature/*
```

```bash
# Feature → Staging → Production
git switch staging
git merge feature/new-api
# Test in staging

git switch main
git merge staging
# Deploy to production
```

### Git Flow without Release Branches

```
main (production)
└── develop (development)
    ├── feature/*
    └── hotfix/*
```

## Best Practices Across All Strategies

1. **Protect main branch**: Require pull requests and reviews
2. **Automate testing**: Run CI on every branch
3. **Small commits**: Keep changes focused and reviewable
4. **Clear messages**: Use conventional commit format
5. **Delete branches**: Clean up merged branches
6. **Document decisions**: Record strategy choices
7. **Use tools**: Leverage branch protection, status checks

## Tools and Automation

### Branch Protection Rules

```yaml
# .github/branch-protection.yml
main:
  require_pull_request: true
  required_approving_review_count: 1
  require_status_checks: true
  required_status_checks:
    - ci-tests
    - code-quality
  enforce_admins: true
```

## Next Steps

- [Trunk-Based Development](./trunk-based.md) - Detailed guide
- [Git Flow](./git-flow.md) - Implementation guide
- [GitHub Flow](./github-flow.md) - Workflow details
- [Pull Requests & Code Review](./pull-requests.md)
