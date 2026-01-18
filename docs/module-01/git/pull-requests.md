# Pull Requests & Code Review

**Effective collaboration through pull requests**

## Overview

Pull requests (PRs) are the primary mechanism for code review and collaboration in Git. They enable teams to discuss changes, review code, and ensure quality before merging.

## What is a Pull Request?

A pull request is a request to merge changes from one branch into another. It includes:
- The commits to be merged
- Files changed (diff)
- Discussion/comments
- CI/CD status checks
- Review approvals

## Creating Pull Requests

### Basic PR Creation

```bash
# 1. Push your branch
git switch -c feature/user-auth
# ... make changes ...
git push -u origin feature/user-auth

# 2. Create PR via GitHub CLI
gh pr create \
  --title "feat(auth): add user authentication" \
  --body "Implement OAuth2 authentication flow"

# 3. Or create via GitHub web interface
# Visit: https://github.com/username/repo/compare
```

### PR Template

Create `.github/pull_request_template.md`:

```markdown
## Description
Brief description of the changes and their purpose.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work)
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring

## Related Issues
Fixes #123
Relates to #456
Closes #789

## Changes Made
- Added OAuth2 authentication flow
- Implemented user session management
- Created authentication middleware
- Added unit tests

## Testing
- [ ] Unit tests written and passing
- [ ] Integration tests written and passing
- [ ] Manual testing completed
- [ ] Edge cases tested

## Checklist
- [ ] My code follows the project style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented complex code sections
- [ ] I have updated the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective
- [ ] New and existing tests pass locally
- [ ] Any dependent changes have been merged

## Screenshots (if applicable)
[Upload screenshots for UI changes]

## Deployment Notes
- [ ] Requires database migration
- [ ] Requires configuration changes
- [ ] Requires cache invalidation
- [ ] Breaking changes documented
```

## PR Titles

### Conventional Commits Format

```bash
# Format: <type>(<scope>): <subject>

# Examples
feat(auth): add OAuth2 authentication
fix(api): resolve timeout issue
docs(readme): update installation instructions
test(auth): add authentication unit tests
refactor(user): simplify user model
perf(api): optimize database queries
chore(deps): upgrade dependencies
```

### Type Categories

| Type | When to Use | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(auth): add user login` |
| `fix` | Bug fix | `fix(api): resolve timeout` |
| `docs` | Documentation only | `docs(readme): update setup` |
| `style` | Style changes | `style(ui): format css files` |
| `refactor` | Code refactoring | `refactor(auth): simplify flow` |
| `test` | Test changes | `test(auth): add unit tests` |
| `chore` | Maintenance | `chore(deps): update packages` |
| `perf` | Performance | `perf(api): cache responses` |

### Good vs Bad Titles

```bash
# Bad
"update"
"fix stuff"
"changes"
"work in progress"

# Good
"feat(auth): add OAuth2 authentication"
"fix(api): resolve rate limiting issue"
"docs(readme): update deployment steps"
```

## PR Descriptions

### Essential Elements

```markdown
## Summary
One or two sentences explaining what this PR does and why.

## Context
Background information about why this change is needed.
Link to related design docs or issues.

## Changes
Bullet list of significant changes:
- Added X
- Modified Y
- Removed Z

## Testing
How you tested this change:
- Unit tests: `pytest tests/auth_test.py`
- Integration: Tested in staging environment
- Manual: Verified UI changes

## Breaking Changes
List any breaking changes and migration steps.

## Screenshots/GIFs
[Attach for UI changes]

## Checklist
- [ ] Tests pass
- [ ] Documentation updated
- [ ] No console errors
```

### Example PR Description

```markdown
## Add OAuth2 Authentication

### Summary
Implements OAuth2 authentication flow allowing users to sign in with Google and GitHub accounts. This addresses issue #123.

### Context
Currently, users can only sign in with email/password. Adding OAuth2 improves user experience and security. See design doc: [link](https://docs.google.com/...).

### Changes
- Added OAuth2 client implementation (`src/auth/oauth.py`)
- Integrated Google OAuth2 provider
- Integrated GitHub OAuth2 provider
- Updated user model to store OAuth accounts
- Modified login UI to include OAuth buttons
- Added OAuth callback endpoint
- Created database migration for OAuth accounts

### Testing
- Unit tests for OAuth client
- Integration tests with test OAuth apps
- Manual testing in staging:
  - ✅ Google login works
  - ✅ GitHub login works
  - ✅ Account linking works
  - ✅ Error handling tested

### Breaking Changes
None. OAuth is an additional authentication method.

### Configuration
Required environment variables:
```
OAUTH_GOOGLE_CLIENT_ID=...
OAUTH_GOOGLE_CLIENT_SECRET=...
OAUTH_GITHUB_CLIENT_ID=...
OAUTH_GITHUB_CLIENT_SECRET=...
```

### Deployment Notes
- Run migrations: `alembic upgrade head`
- Add OAuth environment variables to production
- Update OAuth callback URLs in provider dashboards

### Checklist
- [x] Code follows style guidelines
- [x] Self-review completed
- [x] Tests added/updated
- [x] Documentation updated
- [x] All tests passing

### Related Issues
Fixes #123
Related to #456
```

## Code Review Process

### Requesting Reviewers

```bash
# Via GitHub CLI
gh pr create \
  --title "feat(auth): add OAuth2" \
  --body "..." \
  --reviewer johndoe,janesmith

# Request team review
gh pr edit 123 --add-reviewer backend-team

# Via web interface
# 1. Open PR
# 2. Click "Reviewers"
# 3. Select reviewers
```

### Review Workflow

```bash
# 1. Create PR
git push -u origin feature/oauth
gh pr create

# 2. Request review
gh pr edit 123 --add-reviewer johndoe

# 3. Wait for review
# ... reviewer reviews ...

# 4. Address comments
# ... make changes ...
git commit -m "fix: address review comments"
git push

# 5. Request re-review
gh pr edit 123 --add-reviewer johndoe

# 6. Get approval
# ... reviewer approves ...

# 7. Merge PR
gh pr merge 123 --squash
```

## Review Guidelines

### For Reviewers

#### What to Look For

1. **Correctness**
   - Does the code work as intended?
   - Are there bugs or logic errors?
   - Are edge cases handled?

2. **Design**
   - Is the solution well-designed?
   - Does it follow best practices?
   - Is it maintainable?

3. **Style**
   - Does it follow project conventions?
   - Is naming consistent?
   - Is code readable?

4. **Testing**
   - Are tests adequate?
   - Do tests cover edge cases?
   - Are tests well-written?

5. **Documentation**
   - Is code documented?
   - Are complex parts explained?
   - Is user documentation updated?

#### Providing Feedback

```markdown
## Must Fix
- Line 45: Null pointer exception possible
- Line 78: SQL injection vulnerability

## Should Fix
- Line 23: Consider renaming for clarity
- Line 56: Add error handling

## Suggestions
- Line 34: Could use async/await for better performance
- Line 67: Extract to separate function for reusability

## Questions
- Why use X instead of Y?
- Have you considered Z approach?

## Overall
Good work! Just address the "Must Fix" items and we're good to go.
```

### For Authors

#### Responding to Feedback

```bash
# 1. Acknowledge feedback
# Respond to comments on GitHub

# 2. Make changes
vim src/auth.py

# 3. Commit changes
git add src/auth.py
git commit -m "fix: address review feedback"

# 4. Push updates
git push

# 5. Notify reviewers
gh pr comment 123 --body "Ready for re-review"
```

#### Handling Different Feedback Types

```markdown
# For "Must Fix" items:
# Make changes immediately

# For "Should Fix" items:
# Discuss if you disagree, or fix if you agree

# For "Suggestions":
# Consider implementing, or explain why not

# For "Questions":
# Provide clear explanations
```

## Review States

### GitHub Review States

```bash
# Comment: General feedback
# No merge impact

# Approve: Approve changes
# Allows merge (if other requirements met)

# Request Changes: Block merge
# Requires changes before merging
```

### Setting Review State

```bash
# Via GitHub CLI
gh pr review 123 --approve
gh pr review 123 --request-changes
gh pr review 123 --comment -b "Looks good!"

# Via web interface
# 1. Open PR
# 2. Click "Files changed"
# 3. Click "Review changes"
# 4. Select: Comment / Approve / Request changes
# 5. Submit review
```

## Draft Pull Requests

### Creating Draft PRs

```bash
# Create draft PR (not ready for review)
gh pr create --draft \
  --title "WIP: Add OAuth2 authentication" \
  --body "Working on OAuth integration"

# Or via web: "Create draft pull request"
```

### Converting to Regular PR

```bash
# Mark as ready for review
gh pr ready 123

# Or via web: "Ready for review" button
```

### When to Use Draft PRs

- Work in progress
- Early feedback needed
- Complex features (multiple phases)
- Collaborative development

## CI/CD Integration

### Required Status Checks

Configure in repository settings:

```yaml
Required checks:
  - ci-tests
  - code-quality
  - security-scan
  - coverage-check

Require branches to be up-to-date before merging: Yes
```

### Blocking Merge on Failures

```yaml
# Repository settings > Branches > Branch protection

Branch: main

✅ Require status checks to pass before merging
  - ci-tests (Required)
  - code-quality (Required)
  - security-scan (Required)

✅ Require branches to be up to date before merging

✅ Require pull request reviews before merging
  - Require approvals: 1
  - Dismiss stale reviews
```

## Merge Strategies

### Choosing Merge Method

```bash
# 1. Create merge commit
# Preserves all commit history
# Creates merge commit
gh pr merge 123 --merge

# 2. Squash and merge (Recommended for features)
# Combines all commits into one
# Clean history
gh pr merge 123 --squash

# 3. Rebase and merge
# Linear history
# Preserves individual commits
gh pr merge 123 --rebase
```

### When to Use Each Method

| Method | When to Use |
|--------|-------------|
| Merge commit | When commit history matters |
| Squash and merge | Most PRs (cleanest history) |
| Rebase and merge | When linear history required |

## PR Etiquette

### For Authors

1. **Keep PRs small**: Smaller PRs review faster
2. **Clear descriptions**: Explain what and why
3. **Self-review**: Review your own code first
4. **Respond promptly**: Address feedback quickly
5. **Update PRs**: Keep PR in sync with main
6. **Clean up**: Delete branch after merge

### For Reviewers

1. **Review promptly**: Don't leave PRs waiting
2. **Be constructive**: Provide helpful feedback
3. **Explain why**: Give reasons for changes
4. **Approve good work**: Don't delay approval
5. **Ask questions**: Clarify unclear code
6. **Be respectful**: Professional communication

### Communication Tips

```markdown
# Good
"Great work! Just one small thing: could we rename this variable to be more descriptive?"

# Bad
"This is wrong. Fix it."

# Good
"I'm not sure I understand this part. Could you explain the approach here?"

# Bad
"Why did you do this?"
```

## Common Scenarios

### Scenario 1: Addressing Review Comments

```bash
# 1. Reviewer leaves comments
# "Line 45: Add error handling"

# 2. Make changes
vim src/auth.py  # Add error handling

# 3. Commit and push
git add src/auth.py
git commit -m "fix: add error handling"
git push

# 4. Respond to comment
# "Done! Added try-catch block with proper error handling."
```

### Scenario 2: Syncing with Main

```bash
# PR is behind main
gh pr status 123

# Update your branch
git switch feature/oauth
git fetch origin
git rebase origin/main

# Push updates
git push --force-with-lease

# PR is now up to date
```

### Scenario 3: Conflicts in PR

```bash
# PR has conflicts with main

# Resolve conflicts
git switch feature/oauth
git fetch origin
git rebase origin/main

# Fix conflicts
vim conflicted-file.py
git add conflicted-file.py
git rebase --continue

# Push updates
git push --force-with-lease
```

### Auto-Assign Reviewers

```yaml
# .github/CODEOWNERS
# Code owners file

# Backend team owns backend code
/src/backend/ @backend-team

# Frontend team owns frontend code
/src/frontend/ @frontend-team

# Specific file owners
/docs/api.md @johndoe
```

## Metrics and Improvement

### Tracking PR Metrics

```bash
# Average PR size
gh pr list --state closed --json additions,deletions \
  | jq '[.[] | .additions + .deletions] | add/length'

# Average time to merge
# Use GitHub Insights or third-party tools

# Review coverage
gh pr list --json reviews | jq '.[] | .reviews | length'
```

### Improving PR Process

1. **Reduce PR size**: Smaller PRs review faster
2. **Automate checks**: Faster CI feedback
3. **Clear templates**: Standardize PR descriptions
4. **Regular training**: Team workshops on best practices
5. **Tooling**: Use GitHub integrations and apps

## Best Practices Summary

### Before Creating PR

- [ ] Code tested locally
- [ ] Follows style guidelines
- [ ] Self-reviewed
- [ ] Documentation updated
- [ ] PR description written
- [ ] Linked to issues

### During Review

- [ ] Respond to comments promptly
- [ ] Make requested changes
- [ ] Update PR with latest main
- [ ] Keep PR focused
- [ ] Communicate delays

### After Merge

- [ ] Delete local branch
- [ ] Delete remote branch
- [ ] Update related issues
- [ ] Notify stakeholders
- [ ] Document decisions

## Next Steps

- [Branching Strategies](./branching-strategies.md) - Team workflows
- [Merge Conflicts](./merge-conflicts.md) - Resolving conflicts
- [Team Conventions](./team-conventions.md) - Team standards
