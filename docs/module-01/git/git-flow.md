# Git Flow

**Structured branching model for versioned releases**

## Overview

Git Flow is a branching model that provides a strict framework for managing features, releases, and hotfixes. It's ideal for projects with scheduled releases and multiple environments.

## Branch Structure

```
main (production releases)
│
├── develop (development integration)
│   ├── feature/user-auth
│   ├── feature/payment-gateway
│   └── feature/dashboard-update
│
├── release/v1.2.0
│   └── (release preparation)
│
└── hotfix/v1.1.5
    └── (production hotfix)
```

## Core Branches

### Main Branch (`main`)

- **Purpose**: Production-ready code
- **Stability**: Always deployable
- **Commits**: Merges from `release/*` and `hotfix/*` only
- **Tags**: Every merge is tagged with version number

```bash
git switch main
git pull origin main

# View production releases
git tag
```

### Develop Branch (`develop`)

- **Purpose**: Integration branch for features
- **Stability**: Pre-production state
- **Commits**: Merges from `feature/*` and `release/*`
- **Deployment**: Deployed to staging/development environment

```bash
git switch develop
git pull origin develop

# Deploy to staging
# Deploy develop branch to staging environment
```

## Supporting Branches

### Feature Branches (`feature/*`)

- **Source**: `develop`
- **Target**: `develop`
- **Naming**: `feature/<feature-name>`
- **Lifetime**: Days to weeks

```bash
# Create feature branch
git switch develop
git pull origin develop
git switch -c feature/user-authentication

# Work on feature
git add .
git commit -m "feat: add login form"

# Finish feature
git switch develop
git merge feature/user-authentication
git push origin develop
git branch -d feature/user-authentication
```

### Release Branches (`release/*`)

- **Source**: `develop`
- **Target**: `main` AND `develop`
- **Naming**: `release/<version>`
- **Lifetime**: Days to weeks

```bash
# Start release
git switch develop
git pull origin develop
git switch -c release/v1.2.0

# Prepare release
# - Bump version numbers
# - Update CHANGELOG
# - Fix release-specific bugs

vim version.txt          # Change to 1.2.0
vim CHANGELOG.md         # Add release notes
git add .
git commit -m "chore: prepare release v1.2.0"

# Finish release - merge to main
git switch main
git merge release/v1.2.0
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin main --tags

# Merge back to develop
git switch develop
git merge release/v1.2.0
git push origin develop

# Delete release branch
git branch -d release/v1.2.0
```

### Hotfix Branches (`hotfix/*`)

- **Source**: `main`
- **Target**: `main` AND `develop`
- **Naming**: `hotfix/<version>` or `hotfix/<issue>`
- **Lifetime**: Hours to days

```bash
# Start hotfix from production
git switch main
git pull origin main
git switch -c hotfix/v1.2.1

# Fix critical bug
vim src/auth.py          # Fix security issue
git add src/auth.py
git commit -m "hotfix: patch SQL injection vulnerability"

# Finish hotfix - merge to main
git switch main
git merge hotfix/v1.2.1
git tag -a v1.2.1 -m "Hotfix v1.2.1"
git push origin main --tags

# Merge to develop
git switch develop
git merge hotfix/v1.2.1
git push origin develop

# Delete hotfix branch
git branch -d hotfix/v1.2.1
```

## Complete Workflow Example

### Scenario: New Feature Development

```bash
# 1. Start from develop
git switch develop
git pull origin develop

# 2. Create feature branch
git switch -c feature/oauth-integration

# 3. Develop feature (multiple commits)
git add src/oauth.py
git commit -m "feat: add OAuth client"

git add src/auth.py
git commit -m "feat: integrate OAuth with authentication"

git add tests/test_oauth.py
git commit -m "test: add OAuth tests"

# 4. Update with latest develop
git fetch origin
git rebase origin/develop

# 5. Merge to develop
git switch develop
git merge --no-ff feature/oauth-integration
git push origin develop

# 6. Delete feature branch
git branch -d feature/oauth-integration
```

### Scenario: Release Process

```bash
# 1. Start release when develop is ready
git switch develop
git pull origin develop
git switch -c release/v2.0.0

# 2. Prepare release
# Update version in all files
echo "2.0.0" > version.txt

# Update CHANGELOG
cat >> CHANGELOG.md << EOF
## Version 2.0.0 (2025-01-18)

### Added
- OAuth integration
- User dashboard
- API rate limiting

### Fixed
- Login timeout issue
- Database connection pool

### Changed
- Upgraded to React 18
- Migrated to new database schema
EOF

git add .
git commit -m "chore: prepare release v2.0.0"

# 3. Create release on main
git switch main
git merge --no-ff release/v2.0.0
git tag -a v2.0.0 -m "Release version 2.0.0"
git push origin main --tags

# 4. Merge back to develop
git switch develop
git merge --no-ff release/v2.0.0
git push origin develop

# 5. Delete release branch
git branch -d release/v2.0.0

# 6. Deploy main to production
# Deploy tagged version v2.0.0 to production environment
```

### Scenario: Production Hotfix

```bash
# 1. Production issue discovered!
# Critical bug in v2.0.0

# 2. Create hotfix from main
git switch main
git pull origin main
git switch -c hotfix/v2.0.1

# 3. Fix the bug
vim src/payment.py
git add src/payment.py
git commit -m "hotfix: fix payment calculation bug"

# 4. Test hotfix
npm test
# Run manual QA if needed

# 5. Merge to main and tag
git switch main
git merge --no-ff hotfix/v2.0.1
git tag -a v2.0.1 -m "Hotfix v2.0.1"
git push origin main --tags

# 6. Deploy to production immediately
# Deploy v2.0.1 to production

# 7. Merge to develop (so fix isn't lost)
git switch develop
git merge --no-ff hotfix/v2.0.1
git push origin develop

# 8. Delete hotfix branch
git branch -d hotfix/v2.0.1
```

## Version Management

### Version Number Format

```bash
# Semantic Versioning: MAJOR.MINOR.PATCH
# MAJOR: Breaking changes
# MINOR: New features (backward compatible)
# PATCH: Bug fixes (backward compatible)

v1.2.3  →  Major: 1, Minor: 2, Patch: 3
v2.0.0  →  Breaking changes
v1.3.0  →  New features
v1.2.4  →  Bug fix
```

### Version Files

```bash
# version.txt
1.2.0

# package.json
{
  "name": "my-project",
  "version": "1.2.0",
  ...
}

# __init__.py
__version__ = "1.2.0"
```

### Tagging Best Practices

```bash
# Annotated tags (recommended)
git tag -a v1.2.0 -m "Release version 1.2.0"

# Lightweight tags
git tag v1.2.0

# Signed tags (GPG)
git tag -s v1.2.0 -m "Release version 1.2.0"

# Push tags
git push origin v1.2.0      # Single tag
git push origin --tags      # All tags

# Delete tags
git tag -d v1.2.0           # Local
git push origin :refs/tags/v1.2.0  # Remote

# List tags
git tag                     # All tags
git tag -l "v1.*"           # Pattern match
git show v1.2.0             # Show tag details
```

## Branch Naming Conventions

### Feature Branches

```bash
# Good names
feature/user-authentication
feature/payment-gateway
feature/dashboard-redesign
feature/api-rate-limiting
feature/oauth-integration

# Avoid
stuff
new-feature
feature-1
test
```

### Release Branches

```bash
# Format: release/vX.Y.Z
release/v1.0.0
release/v2.1.0
release/v3.5.0
```

### Hotfix Branches

```bash
# Format: hotfix/vX.Y.Z or hotfix/issue-description
hotfix/v1.0.1
hotfix/security-patch
hotfix/critical-bug-123
hotfix/database-corruption
```

## Merge Strategies

### Feature to Develop

```bash
# Use --no-ff to preserve feature history
git switch develop
git merge --no-ff feature/new-feature

# This creates a merge commit even if fast-forward is possible
# Keeps feature history clear
```

### Release to Main

```bash
# Always use --no-ff for releases
git switch main
git merge --no-ff release/v2.0.0
git tag -a v2.0.0 -m "Release version 2.0.0"
```

### Hotfix to Main

```bash
# Use --no-ff for hotfixes
git switch main
git merge --no-ff hotfix/v2.0.1
git tag -a v2.0.1 -m "Hotfix v2.0.1"
```

## Conflict Resolution

### Feature Branch Conflicts

```bash
# When merging feature to develop
git switch develop
git merge feature/new-feature

# If conflicts occur:
# 1. Resolve conflicts in files
# 2. Mark as resolved
git add resolved-file.py

# 3. Complete merge
git commit  # (or git merge --continue)

# 4. Push
git push origin develop
```

### Release Branch Conflicts

```bash
# Release branch conflicts need careful handling
git switch release/v2.0.0

# Resolve with develop
git merge develop
# Resolve conflicts...

# Resolve with main
git switch main
git merge release/v2.0.0
# Resolve conflicts...
```

### Hotfix Conflicts

```bash
# Hotfix merged to main first
git switch main
git merge hotfix/v2.0.1
git push origin main

# Then merge to develop (may have conflicts)
git switch develop
git merge hotfix/v2.0.1
# Resolve conflicts (hotfix takes precedence)
git push origin develop
```

## Automation Tools

### Git Flow AVH (Recommended Tool)

```bash
# Install git-flow
# macOS
brew install git-flow-avh

# Ubuntu/Debian
apt-get install git-flow

# Windows (with Git for Windows)
# Already included

# Initialize git-flow
git flow init

# Follow prompts:
# Branch name for production releases: [main]
# Branch name for "next release" development: [develop]
# Branch name for feature branches: [feature/]
# Branch name for release branches: [release/]
# Branch name for hotfix branches: [hotfix/]
# Branch name for support branches: [support/]
# Feature branch prefix: [feature/]
# Release branch prefix: [release/]
# Hotfix branch prefix: [hotfix/]
# Support branch prefix: [support/]
# Version tag prefix: []
```

### Using Git Flow Commands

```bash
# Start feature
git flow feature start user-auth

# Finish feature
git flow feature finish user-auth

# Publish feature (push to remote)
git flow feature publish user-auth

# Track remote feature
git flow feature track user-auth

# Start release
git flow release start v1.2.0

# Finish release
git flow release finish v1.2.0

# Start hotfix
git flow hotfix start v1.2.1

# Finish hotfix
git flow hotfix finish v1.2.1
```

### Hooks for Automation

```bash
# .git/hooks/post-merge
#!/bin/bash
# Auto-update version after merge to main
branch=$(git symbolic-ref --short HEAD)

if [ "$branch" = "main" ]; then
    # Trigger deployment
    ./deploy.sh production
fi
```

## Best Practices

### Do's ✅

- **Use strict naming**: Follow `feature/*`, `release/*`, `hotfix/*` convention
- **Merge with --no-ff**: Preserve branch history
- **Tag releases**: Every merge to main gets a tag
- **Update develop**: Always merge release branches back to develop
- **Test hotfixes**: Validate hotfixes before merging
- **Document releases**: Maintain CHANGELOG.md

### Don'ts ❌

- **Don't commit directly to main**: Always use branches
- **Don't skip hotfix merge to develop**: Keep develop updated
- **Don't forget tags**: Tag all production releases
- **Don't break develop**: Ensure develop is always buildable
- **Don't leave stale branches**: Clean up merged branches
- **Don't work on release for too long**: Keep releases focused

## Release Checklist

### Before Creating Release Branch

- [ ] All planned features merged to develop
- [ ] All tests passing on develop
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version number bumped
- [ ] Security scan completed

### During Release Branch

- [ ] Version files updated
- [ ] Release notes finalized
- [ ] Release-specific bugs fixed
- [ ] Testing completed in staging
- [ ] Stakeholders notified

### After Merging to Main

- [ ] Tag created with version number
- [ ] Deployed to production
- [ ] Smoke tests passed
- [ ] Monitoring active
- [ ] Release announcement sent

### After Merging to Develop

- [ ] Changes merged back
- [ ] No conflicts introduced
- [ ] Develop still buildable
- [ ] Tests passing
- [ ] Team notified

## Comparison with GitHub Flow

| Aspect | Git Flow | GitHub Flow |
|--------|----------|-------------|
| Main branch | Protected, production | Protected, production |
| Development branch | Yes (develop) | No |
| Feature branches | Merge to develop | Merge to main |
| Release branches | Yes | No |
| Hotfix branches | Yes | From main, to main |
| Branch lifetime | Weeks | Days |
| Complexity | High | Low |
| Learning curve | Steep | Gentle |
| CI/CD requirement | Optional | Important |
| Release management | Structured | On-demand |

## When to Use Git Flow

### Ideal For

- ✅ Enterprise software
- ✅ Scheduled releases (weekly, monthly, quarterly)
- ✅ Multiple versions in production
- ✅ Strict release management
- ✅ Large teams (10+ developers)
- ✅ Complex deployment processes
- ✅ Need for release stabilization period

### Not Ideal For

- ❌ Small teams
- ❌ Continuous deployment
- ❌ Simple SaaS applications
- ❌ Fast iteration required
- ❌ Limited DevOps resources

## Common Pitfalls

### Pitfall 1: Forgetting to Merge Release Back to Develop

```bash
# Wrong: Only merge to main
git switch main
git merge release/v2.0.0
git push origin main
# ❌ Forgot develop!

# Correct: Merge to both
git switch main
git merge release/v2.0.0
git push origin main

git switch develop
git merge release/v2.0.0
git push origin develop
```

### Pitfall 2: Hotfix Not in Develop

```bash
# Wrong: Hotfix only in main
git switch main
git merge hotfix/v2.0.1
git push origin main
# ❌ Develop doesn't have the fix!

# Correct: Merge to both
git switch main
git merge hotfix/v2.0.1
git push origin main

git switch develop
git merge hotfix/v2.0.1
git push origin develop
```

### Pitfall 3: Long-Lived Release Branches

```bash
# Bad: Release branch for weeks
git switch -c release/v2.0.0
# ... work on release for 3 weeks ...
# ❌ Falls behind develop

# Good: Short release branches
git switch -c release/v2.0.0
# ... stabilization only (1-2 days) ...
```

## Next Steps

- [Branching Strategies Overview](./branching-strategies.md) - Compare strategies
- [Trunk-Based Development](./trunk-based.md) - Simpler alternative
- [GitHub Flow](./github-flow.md) - Simplified workflow
- [Remote Operations](./remote-operations.md) - Working with remotes
