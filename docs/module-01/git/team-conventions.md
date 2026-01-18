# Team Conventions

**Establishing Git standards for team consistency**

## Overview

Team conventions ensure everyone uses Git consistently, making collaboration smoother and reducing misunderstandings. This guide covers essential conventions for team-based development.

## Commit Message Conventions

### Conventional Commits Format

```bash
# Format: <type>(<scope>): <subject>

# Type categories:
feat:     New feature
fix:      Bug fix
docs:     Documentation changes
style:    Code style (formatting, etc.)
refactor: Code refactoring
test:     Test changes
chore:    Build process, auxiliary tools
perf:     Performance improvements

# Examples
feat(auth): add OAuth2 authentication
fix(api): resolve timeout issue
docs(readme): update installation instructions
test(auth): add authentication unit tests
```

### Commit Message Structure

```bash
# First line: subject (50 chars or less)
feat(auth): add user authentication

# Blank line

# Body: detailed explanation (wrap at 72 chars)
Implement OAuth2 authentication flow with support for
Google and GitHub providers. Includes user session
management and secure token storage.

# Blank line

# Footer: references and breaking changes
Closes #123
Breaking Change: Authentication endpoint now requires
OAuth2 tokens instead of basic auth
```

### Good vs Bad Examples

```bash
# Bad
"update"
"fix stuff"
"work in progress"
"changes"

# Good
"feat(auth): add user authentication"
"fix(api): resolve rate limiting issue"
"docs(readme): update deployment steps"
```

### Commit Message Template

Create `.gitmessage`:

```
# <type>(<scope>): <subject>
# |<----  Using a Maximum Of 50 Characters  ---->|

# Explain why this change is being made
# |<----   Try To Limit Each Line to a Maximum Of 72 Characters   ---->|

# Provide links or keys to any relevant tickets, articles or other resources
# Example: Fixes #23

# --- COMMIT END ---
# Type can be:
#   feat     (new feature)
#   fix      (bug fix)
#   docs     (changes to documentation)
#   style    (formatting, missing semi colons, etc; no code change)
#   refactor (refactoring production code)
#   test     (adding missing tests, refactoring tests; no production code change)
#   chore    (updating build tasks, package manager configs, etc; no production code change)
#   perf     (performance improvement)
# --------------------
# Remember to:
#    - Capitalize the subject line
#    - Use the imperative mood in the subject line
#    - Do not end the subject line with a period
#    - Separate subject from body with a blank line
#    - Use the body to explain what and why vs. how
#    - Can use multiple lines with "-" for bullet points in body
# --------------------
```

Configure Git to use template:

```bash
git config --global commit.template ~/.gitmessage
```

## Branch Naming Conventions

### Standard Patterns

```bash
# Feature branches
feature/<feature-name>
feature/user-auth
feature/payment-gateway
feature/dashboard-redesign

# Bug fix branches
bugfix/<issue-description>
bugfix/login-timeout
bugfix/memory-leak
bugfix/api-error

# Hotfix branches
hotfix/<urgent-issue>
hotfix/security-patch
hotfix/critical-bug-123

# Release branches
release/<version>
release/v2.0.0
release/v1.5.0

# Experiment branches
experiment/<experiment-name>
experiment/new-ui
experiment/alternative-algo
```

### Branch Name Guidelines

```bash
# Good names
feature/oauth2-integration
bugfix/database-connection-pool
hotfix/security-vulnerability-CVE-2025-1234
release/v2.1.0

# Bad names
stuff
new-thing
branch-1
test
wip
```

### Configuring Branch Rules

```bash
# .github/rulesets.yml (if using GitHub)
rulesets:
  - name: Branch naming
    conditions:
      - pattern: '^(feature|bugfix|hotfix|release|experiment)/'
        negate: false
    enforcement: error
```

## .gitignore Conventions

### Project Structure

```bash
# .gitignore should be organized:

# 1. OS files
.DS_Store
Thumbs.db
*.swp
*.swo

# 2. IDE files
.vscode/
.idea/
*.iml

# 3. Dependencies
node_modules/
venv/
__pycache__/
*.pyc

# 4. Build artifacts
dist/
build/
*.egg-info/

# 5. Environment files
.env
.env.local
.env.*.local

# 6. Logs
*.log
logs/

# 7. Database
*.db
*.sqlite
*.sqlite3

# 8. Temporary files
tmp/
temp/
*.tmp

# 9. Generated files
*.min.js
*.min.css
```

### Global .gitignore

```bash
# Create global ignore file
git config --global core.excludesfile ~/.gitignore_global

# ~/.gitignore_global
.DS_Store
Thumbs.db
*.swp
.vscode/
.idea/
```

### Project-Specific .gitignore

```bash
# Python .gitignore
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
ENV/
.venv

# Node.js .gitignore
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
package-lock.json

# Java .gitignore
*.class
*.jar
*.war
*.ear
target/
```

## File Conventions

### Repository Structure

```bash
project-root/
├── .github/              # GitHub-specific files
│   ├── workflows/        # CI/CD workflows
│   ├── pull_request_template.md
│   └── CODEOWNERS
├── docs/                 # Documentation
├── src/                  # Source code
├── tests/                # Tests
├── .gitignore           # Ignore patterns
├── .gitattributes       # Git attributes
├── README.md            # Project overview
├── CHANGELOG.md         # Version history
├── LICENSE              # License file
└── .gitmessage          # Commit template
```

### README.md Structure

```markdown
# Project Name

## Overview
Brief description of the project

## Features
- Feature 1
- Feature 2

## Installation
\`\`\`bash
npm install
\`\`\`

## Usage
\`\`\`bash
npm start
\`\`\`

## Contributing
[Link to contributing guide]

## License
MIT
```

### CHANGELOG.md Format

```markdown
# Changelog

## [Unreleased]
### Added
- New feature X
- New feature Y

### Changed
- Improved performance of Z

### Fixed
- Bug fix A

## [1.2.0] - 2025-01-18
### Added
- OAuth2 authentication
- User dashboard

### Fixed
- Login timeout issue
```

## Configuration Conventions

### Repository Configuration

```bash
# .gitattributes (handles line endings and diffs)

# Auto detect text files
* text=auto

# Declare files that will always have CRLF line endings on checkout
*.sln text eol=crlf

# Declare files that will always have LF line endings on checkout
*.sh text eol=lf
*.py text eol=lf

# Denote all files that are truly binary and should not be modified
*.png binary
*.jpg binary
*.pdf binary
```

### Team Git Configuration

```bash
# Shared configuration file in repo
# .gitconfig

[core]
    autocrlf = input
    editor = code --wait

[commit]
    template = .gitmessage

[merge]
    tool = vscode

[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
```

Include in project:

```bash
# Add to .git/config
[include]
    path = ../.gitconfig
```

## Code Review Conventions

### Review Checklist

```markdown
## Code Review Checklist

### Functionality
- [ ] Code works as intended
- [ ] Edge cases handled
- [ ] Error handling present
- [ ] No obvious bugs

### Design
- [ ] Follows project architecture
- [ ] Code is maintainable
- [ ] No unnecessary complexity
- [ ] Proper abstractions

### Testing
- [ ] Tests added/updated
- [ ] Tests cover edge cases
- [ ] Tests are meaningful

### Documentation
- [ ] Code is commented where needed
- [ ] Complex logic explained
- [ ] API documentation updated

### Style
- [ ] Follows style guide
- [ ] Naming is consistent
- [ ] Formatting is correct

### Security
- [ ] No security vulnerabilities
- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] Output encoding correct
```

### Review Turnaround Times

```markdown
## Target Response Times

- **Quick reviews**: Within 2 hours
- **Standard reviews**: Within 1 business day
- **Complex reviews**: Within 2 business days

## Escalation

If review takes longer than targets:
1. Ping reviewer on Slack
2. @mention team lead
3. Request different reviewer
```

## Release Conventions

### Version Numbering

```bash
# Semantic Versioning: MAJOR.MINOR.PATCH

MAJOR: Breaking changes
MINOR: New features (backward compatible)
PATCH: Bug fixes (backward compatible)

# Examples
1.0.0 → Initial release
1.1.0 → Add new feature
1.1.1 → Fix bug
2.0.0 → Breaking changes
```

### Release Checklist

```markdown
## Release Checklist

### Before Release
- [ ] All planned features merged
- [ ] All tests passing
- [ ] Documentation updated
- [ ] CHANGELOG updated
- [ ] Version number bumped
- [ ] Security scan completed

### Release Process
- [ ] Create release branch
- [ ] Run final tests
- [ ] Deploy to staging
- [ ] Smoke tests passed
- [ ] Tag release
- [ ] Deploy to production
- [ ] Verify deployment

### After Release
- [ ] Monitor for issues
- [ ] Update documentation
- [ ] Notify stakeholders
- [ ] Create release notes
- [ ] Archive release branch
```

### Release Notes Template

```markdown
## Release X.Y.Z

### Highlights
- Major feature 1
- Major feature 2

### Added
- New feature A
- New feature B

### Changed
- Improved performance of X

### Fixed
- Bug fix Y
- Bug fix Z

### Security
- Security patch for CVE-2025-1234

### Known Issues
- Known issue 1

### Migration Guide
#### Breaking Changes
If any breaking changes, explain migration path:
\`\`\`bash
# Old way
old_function()

# New way
new_function()
\`\`\`

### Upgrade Instructions
\`\`\`bash
npm update package-name
# or
pip install package-name==X.Y.Z
\`\`\`
```

## Workflow Conventions

### Daily Workflow

```bash
# Morning routine
git switch main
git pull origin main

# Create feature branch
git switch -c feature/todays-work

# During day
# Make changes, commit frequently

# Before lunch
git fetch origin
git rebase origin/main
git push

# End of day
git fetch origin
git rebase origin/main
git push
```

### Push Protocol

```bash
# Before pushing
1. Pull latest changes
2. Rebase with main
3. Run tests
4. Check status

# Push
git push

# After pushing
1. Create/update PR
2. Request review
3. Monitor CI
```

### Code Freezes

```markdown
## Code Freeze Policy

### Before Major Release
- **1 week before**: No new features
- **3 days before**: Only critical fixes
- **1 day before**: Code freeze (emergency only)

### During Code Freeze
- Hotfixes require approval
- All changes to main require +2 reviews
- Deployments require team lead approval

### After Release
- Normal workflow resumes
- Post-release monitoring for 1 week
```

## Communication Conventions

### Branch Communication

```markdown
# When starting work on shared code:
"Hey team, I'm working on auth.py this week. Plan to refactor the login flow."

# When done:
"Finished auth.py refactor. PR is up for review."

# When blocked:
"Blocked on feature X. Need help from frontend team."
```

### PR Communication

```markdown
# PR Title
"feat(auth): add OAuth2 authentication"

# PR Body
Clear description, testing notes, breaking changes

# Comments
Respond to all review comments within 24 hours

# Merging
Wait for approval and CI pass before merging
```

### Issue Tracking

```markdown
# Link commits to issues
git commit -m "feat(auth): add OAuth2

Closes #123"

# Reference multiple issues
git commit -m "fix: resolve multiple issues

Fixes #123, #456, #789"

# Reference in PR description
"Relates to #123
Addresses #456"
```

## Tool Conventions

### Shared Tools

```bash
# Linting
npm run lint        # JavaScript
black .             # Python
gofmt .             # Go

# Formatting
npm run format      # JavaScript
black .             # Python

# Testing
npm test            # JavaScript
pytest              # Python

# Type Checking
npm run type-check  # TypeScript
mypy .              # Python
```

### CI/CD Conventions

```yaml
# Required checks for all PRs
required-checks:
  - lint
  - test
  - type-check
  - security-scan

# Deployment checks
deploy-checks:
  - integration-tests
  - smoke-tests
```

## Documentation Conventions

### Code Documentation

```python
# Function docstring format
def authenticate_user(username, password):
    """
    Authenticate user with username and password.

    Args:
        username (str): User's username
        password (str): User's password

    Returns:
        bool: True if authentication successful, False otherwise

    Raises:
        ValueError: If username or password is empty
        AuthenticationError: If authentication fails

    Example:
        >>> authenticate_user("john", "pass123")
        True
    """
    pass
```

### README Standards

```markdown
# Required sections in README
1. Project title and tagline
2. Overview/description
3. Features list
4. Installation instructions
5. Usage examples
6. Configuration guide
7. Contributing guidelines
8. License information
9. Contact/support information
```

## Enforcement

### Pre-commit Hooks

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run linter
npm run lint || exit 1

# Run tests
npm test || exit 1

# Check formatting
npm run format:check || exit 1

# Check for large files
if find . -type f -size +5M; then
    echo "Error: Files larger than 5MB detected"
    exit 1
fi
```

### Commit-msg Hook

```bash
#!/bin/bash
# .git/hooks/commit-msg

# Check commit message format
commit_regex='^(feat|fix|docs|style|refactor|test|chore|perf)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "Invalid commit message format"
    echo "Format: <type>(<scope>): <subject>"
    exit 1
fi
```

### Branch Protection Rules

```yaml
# GitHub branch protection rules
main:
  require_pull_request: true
  required_approving_review_count: 1
  require_status_checks: true
  required_status_checks:
    - ci-tests
    - code-quality
  enforce_admins: true
  allow_deletions: false
```

## Best Practices Summary

### Do's ✅

- **Follow conventions**: Stick to agreed patterns
- **Write clear messages**: Explain what and why
- **Review code**: Help maintain quality
- **Communicate**: Keep team informed
- **Test thoroughly**: Ensure quality
- **Document**: Share knowledge

### Don'ts ❌

- **Don't break conventions**: Consistency matters
- **Don't skip reviews**: Quality is important
- **Don't commit secrets**: Security is critical
- **Don't ignore feedback**: Improve your code
- **Don't work in isolation**: Collaboration is key
- **Don't break main**: Protect production

## Onboarding New Team Members

### Checklist for New Members

```markdown
## Git Setup for New Team Members

### Day 1
- [ ] Install Git
- [ ] Configure Git (name, email)
- [ ] Generate SSH key
- [ ] Add SSH key to GitHub
- [ ] Clone repository
- [ ] Install project dependencies
- [ ] Run tests locally

### Day 2
- [ ] Read team conventions
- [ ] Set up Git aliases
- [ ] Configure commit template
- [ ] Set up pre-commit hooks
- [ ] Create first branch
- [ ] Make first commit
- [ ] Create first PR

### Week 1
- [ ] Complete first PR review
- [ ] Get first PR merged
- [ ] Attend code review session
- [ ] Read project documentation
- [ ] Set up development environment

### Ongoing
- [ ] Participate in code reviews
- [ ] Follow team conventions
- [ ] Improve documentation
- [ ] Share knowledge
```

## Quick Reference Card

### Common Conventions

| Area | Convention | Example |
|------|------------|---------|
| Commits | Conventional Commits | `feat(auth): add login` |
| Branches | type/description | `feature/oauth` |
| PRs | Descriptive title | `feat: add OAuth2` |
| Files | kebab-case | `user-service.py` |
| Variables | snake_case | `user_id` |
| Classes | PascalCase | `UserService` |

## Next Steps

- [Git Basics](./git-basics.md) - Essential commands
- [Branching Strategies](./branching-strategies.md) - Team workflows
- [Pull Requests](./pull-requests.md) - Code review process
- [Merge Conflicts](./merge-conflicts.md) - Resolving conflicts
