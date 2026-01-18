# GitHub Flow

**Simplified workflow for continuous deployment**

## Overview

GitHub Flow is a lightweight branching model designed for teams that deploy frequently. It's simple, easy to learn, and works well with continuous deployment practices.

## Core Principles

1. **Main branch is always deployable**
2. **Create branches from main**
3. **Commit to branches**
4. **Open pull requests**
5. **Review and code review**
6. **Merge to main after approval**
7. **Deploy immediately**

## Branch Structure

```
main (deployed to production)
├── feature/user-auth (PR)
├── bugfix/login-error (PR)
└── feature/dashboard (PR)
```

## Complete Workflow

### 1. Create Feature Branch

```bash
# Start from main
git switch main
git pull origin main

# Create feature branch
git switch -c feature/user-authentication

# Verify branch
git branch
# * feature/user-authentication
#   main
```

### 2. Make Changes and Commit

```bash
# Make your changes
# ... edit files ...

# Stage and commit
git add .
git commit -m "feat: add user authentication with OAuth2"

# Continue working
git add tests/auth_test.py
git commit -m "test: add authentication tests"

# Push to remote
git push origin feature/user-authentication
```

### 3. Create Pull Request

Go to GitHub and create a pull request:

```markdown
## Add user authentication with OAuth2

### Changes
- Implemented OAuth2 authentication flow
- Added user session management
- Created authentication middleware

### Testing
- Added unit tests for auth module
- Manual testing completed

### Checklist
- [x] Code follows project style
- [x] Tests added/updated
- [x] Documentation updated
```

### 4. Code Review

Team members review the PR:

```bash
# Address review comments
git add src/auth.py
git commit -m "fix: address review comments - improve error handling"

# Push updates
git push origin feature/user-authentication
```

### 5. Merge After Approval

Once approved and CI passes:

```bash
# Use GitHub UI to merge
# Options:
# - Create merge commit (preserves history)
# - Squash and merge (clean history)
# - Rebase and merge (linear history)

# Or merge via command line
git switch main
git merge feature/user-authentication
git push origin main
```

### 6. Deploy

```bash
# Deploy main to production
./deploy.sh production

# Or automatic deployment via CI/CD
```

### 7. Clean Up

```bash
# Delete local branch
git branch -d feature/user-authentication

# Delete remote branch
git push origin --delete feature/user-authentication
```

## Pull Request Best Practices

### PR Template

Create `.github/pull_request_template.md`:

```markdown
## Description
Brief description of what this PR does and why

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## How Has This Been Tested?
Please describe the tests that you ran to verify your changes.

- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual testing

## Checklist:
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] Any dependent changes have been merged and published

## Screenshots (if appropriate):

## Related Issues:
Fixes #123
Related to #456
```

### Conventional Commit Messages

Use conventional commit format for PR titles:

```bash
# Format: <type>(<scope>): <subject>

# Types
feat:     New feature
fix:      Bug fix
docs:     Documentation changes
style:    Code style changes (formatting, etc.)
refactor: Code refactoring
test:     Test additions or changes
chore:    Build process or auxiliary tool changes
perf:     Performance improvements

# Examples
feat(auth): add OAuth2 authentication
fix(api): resolve timeout issue
docs(readme): update installation instructions
test(auth): add authentication unit tests
refactor(user): simplify user model
```

### PR Description Guidelines

```markdown
## Summary
One or two sentences describing the change

## Changes Made
- Bullet point for each significant change
- Keep descriptions concise

## Testing
Describe how you tested:
- Unit tests: `pytest tests/auth_test.py`
- Manual: Tested in staging environment
- Performance: Verified response times

## Breaking Changes
List any breaking changes:
- API endpoint `/auth/login` now requires `X-API-Key` header

## Migration Guide
If breaking changes:
```bash
# Old way
old_function()

# New way
new_function()
```

## Screenshots
[Attach screenshots if UI changes]

## Related Links
- Issue: #123
- Design doc: link/to/doc
- API spec: link/to/api
```

## Branch Protection Rules

Configure in GitHub repository settings:

```yaml
Branch: main

✅ Require pull request before merging
  - Require approvals: 1
  - Dismiss stale reviews when new commits are pushed

✅ Require status checks to pass before merging
  - Required checks:
    - ci-tests
    - code-quality
    - security-scan

✅ Require branches to be up to date before merging
  - Mark as "required"

✅ Do not allow bypassing the above settings

❌ Restrict who can push to main branch
  - Only: admins, deploy bot
```

## Team Collaboration

### Assigning Reviewers

```bash
# Via GitHub UI:
# - Click "Reviewers"
# - Select team members
# - Optional: Request review from team

# Command line (GitHub CLI):
gh pr create \
  --title "feat(auth): add OAuth2" \
  --body "Add user authentication..." \
  --reviewer johndoe,janesmith \
  --team backend-team
```

### Handling Review Feedback

```bash
# Make changes based on feedback
vim src/auth.py

# Commit and push
git add src/auth.py
git commit -m "fix: address review feedback"
git push origin feature/user-auth

# Respond to comments on GitHub
# Click "Reply" or "Resolve" on each comment
```

### Requesting Changes

As a reviewer:

```markdown
## Review Feedback

### Must Fix
- [ ] Line 45: Add error handling for null values
- [ ] Line 78: Fix potential SQL injection

### Should Fix
- [ ] Consider renaming `getUser()` to `getUserById()` for clarity
- [ ] Add unit tests for edge cases

### Suggestions
- Consider using async/await instead of promises
- Documentation could be expanded

Overall: Looks good, just address the "Must Fix" items.
```

## Merge Strategies

### Create Merge Commit (Recommended)

```bash
# Preserves complete history
# Shows when PR was merged

# Via GitHub UI:
# Select "Create a merge commit"

# Via command line:
git switch main
git merge --no-ff feature/user-auth
git push origin main
```

**Pros:**
- Complete history preserved
- Clear merge points
- Easy to see when features were added

**Cons:**
- More commits in history
- Non-linear history

### Squash and Merge

```bash
# Combines all commits into one
# Clean, linear history

# Via GitHub UI:
# Select "Squash and merge"

# Via command line:
git switch main
git merge --squash feature/user-auth
git commit -m "feat(auth): add user authentication"
git push origin main
```

**Pros:**
- Clean, linear history
- One commit per feature
- Easier to bisect

**Cons:**
- Loses individual commit history
- Harder to see development process

### Rebase and Merge

```bash
# Rebases commits onto main
# Linear history with individual commits

# Via GitHub UI:
# Select "Rebase and merge"

# Via command line:
git switch feature/user-auth
git rebase main
git switch main
git merge feature/user-auth
git push origin main
```

**Pros:**
- Linear history
- Preserves individual commits
- Clean integration

**Cons:**
- Rewrites history
- Can cause conflicts
- Not recommended for shared branches

## Branch Naming Conventions

### Feature Branches

```bash
feature/<feature-name>
feature/user-auth
feature/payment-gateway
feature/dashboard-v2
```

### Bug Fix Branches

```bash
bugfix/<issue-description>
bugfix/login-timeout
bugfix/memory-leak
bugfix/api-error
```

### Hotfix Branches

```bash
hotfix/<urgent-issue>
hotfix/security-patch
hotfix/critical-crash
hotfix/data-corruption
```

### Experiment Branches

```bash
experiment/<experiment-name>
experiment/new-ui-design
experiment/performance-test
experiment/alternative-algo
```

## Working with GitHub CLI

### Creating PRs

```bash
# Install GitHub CLI
# macOS
brew install gh

# Linux
# Download from GitHub releases

# Windows
# Download from GitHub releases

# Authenticate
gh auth login

# Create PR
gh pr create \
  --title "feat(auth): add OAuth2 authentication" \
  --body "Add user authentication with OAuth2 support"

# Create PR with template
gh pr create --template .github/pull_request_template.md

# View PRs
gh pr list

# Checkout PR locally
gh pr checkout 123

# Merge PR
gh pr merge 123 --squash
```

### Managing Issues

```bash
# List issues
gh issue list

# Create issue
gh issue create \
  --title "Add user authentication" \
  --body "Implement OAuth2 authentication flow"

# View issue
gh issue view 123

# Close issue
gh issue close 123
```

## Best Practices

### Do's ✅

- **Keep branches small**: Each branch should do one thing
- **Write good PR descriptions**: Explain what and why
- **Request reviews**: Always get at least one review
- **Run tests locally**: Ensure tests pass before pushing
- **Update documentation**: Keep docs in sync with code
- **Use PR templates**: Standardize PR descriptions
- **Delete branches after merge**: Keep repository clean
- **Use draft PRs**: For work in progress

### Don'ts ❌

- **Don't commit directly to main**: Always use PRs
- **Don't merge without approval**: Follow review process
- **Don't ignore CI failures**: Fix all failing tests
- **Don't write vague PR titles**: Be specific
- **Don't skip code review**: Quality matters
- **Don't leave PRs open**: Close or merge promptly
- **Don't force push to shared branches**: Rewrites history
- **Don't merge broken code**: Ensure quality first

## Common Scenarios

### Scenario 1: Quick Bug Fix

```bash
# Create bugfix branch
git switch main
git pull origin main
git switch -c bugfix/typo-error

# Fix bug
vim README.md
git add README.md
git commit -m "fix: correct typo in installation instructions"

# Push and create PR
git push origin bugfix/typo-error
gh pr create --title "fix: typo in README"

# Merge after approval
gh pr merge --squash
```

### Scenario 2: Complex Feature

```bash
# Start feature
git switch -c feature/payment-system

# Work iteratively
git add src/payment/
git commit -m "feat: add payment client"

git add src/payment/
git commit -m "feat: implement payment processing"

# Push and create draft PR
git push origin feature/payment-system
gh pr create --draft --title "feat: payment system"

# Continue working
# Update PR as you progress

# Convert to regular PR when ready
gh pr ready 123
```

### Scenario 3: Addressing Review Comments

```bash
# Make changes
vim src/auth.py

# Commit changes
git add src/auth.py
git commit -m "fix: address review comments"

# Push updates
git push origin feature/user-auth

# PR automatically updates
# Notify reviewers that changes are ready
gh pr comment 123 --body "Ready for review"
```

### Scenario 4: Resolving Merge Conflicts

```bash
# Update branch with main
git switch feature/user-auth
git fetch origin
git rebase origin/main

# Resolve conflicts if any
# ... edit files ...
git add .
git rebase --continue

# Push updates
git push origin feature/user-auth --force-with-lease

# PR shows conflict resolved
```

## Monitoring and Metrics

### Track PR Metrics

```bash
# Average PR size
gh pr list --state closed --json additions,deletions \
  | jq '[.[] | .additions + .deletions] | add/length'

# Average time to merge
# Use GitHub Insights or third-party tools

# PR count per developer
gh pr list --search "author:johndoe" --json title \
  | jq length
```

### Improve Team Velocity

1. **Reduce PR size**: Smaller PRs review faster
2. **Automate checks**: Faster CI feedback
3. **Clear descriptions**: Less review back-and-forth
4. **Responsive reviews**: Quick turnaround
5. **Automated merges**: For trivial changes

## Comparison with Other Strategies

| Aspect | GitHub Flow | Trunk-Based | Git Flow |
|--------|-------------|-------------|----------|
| Complexity | Low | Medium | High |
| Branch lifetime | Days | Hours | Weeks |
| Release frequency | On-demand | Continuous | Scheduled |
| Code review | Required (PR) | Optional | Optional |
| Main branch | Protected | Protected | Relaxed |
| CI/CD | Important | Critical | Optional |
| Learning curve | Gentle | Moderate | Steep |

## When to Use GitHub Flow

### Ideal For

- ✅ SaaS products
- ✅ Web applications
- ✅ Small to medium teams
- ✅ Continuous deployment
- ✅ Cloud-native applications
- ✅ Fast iteration required

### Not Ideal For

- ❌ Enterprise software with scheduled releases
- ❌ Multiple production versions
- ❌ Complex release management
- ❌ Manual deployment processes
- ❌ Strict change control requirements

## Getting Started

### Week 1: Setup

1. Configure branch protection rules
2. Set up PR template
3. Configure CI/CD pipeline
4. Train team on workflow

### Week 2: Practice

1. Create feature branches
2. Practice code review
3. Merge PRs
4. Deploy to production

### Week 3: Optimize

1. Refine PR template
2. Automate checks
3. Improve CI speed
4. Track metrics

### Week 4: Scale

1. Expand to all projects
2. Optimize processes
3. Share best practices
4. Continuously improve

## Next Steps

- [Branching Strategies Overview](./branching-strategies.md) - Compare strategies
- [Trunk-Based Development](./trunk-based.md) - Continuous integration
- [Git Flow](./git-flow.md) - Enterprise workflow
- [Pull Requests & Code Review](./pull-requests.md) - Detailed review guide
