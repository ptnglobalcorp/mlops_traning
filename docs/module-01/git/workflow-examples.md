# Git Workflow Examples

**Real-world scenarios and practical workflows**

## Overview

This guide provides practical, step-by-step examples of common Git workflows you'll encounter in team development.

## Example 1: Feature Development Workflow

### Scenario: Add New User Authentication Feature

```bash
# 1. Start with clean main branch
git switch main
git pull origin main

# 2. Create feature branch
git switch -c feature/user-authentication

# 3. Implement authentication (multiple commits)
# Add OAuth client
vim src/auth/oauth.py
git add src/auth/oauth.py
git commit -m "feat(auth): add OAuth2 client"

# Add authentication middleware
vim src/auth/middleware.py
git add src/auth/middleware.py
git commit -m "feat(auth): add authentication middleware"

# Add tests
vim tests/test_auth.py
git add tests/test_auth.py
git commit -m "test(auth): add authentication tests"

# 4. Push to remote
git push -u origin feature/user-authentication

# 5. Create pull request
gh pr create \
  --title "feat(auth): add user authentication with OAuth2" \
  --body "Implement OAuth2 authentication for Google and GitHub providers"

# 6. Address review feedback
vim src/auth/oauth.py  # Make changes
git add src/auth/oauth.py
git commit -m "fix: address review feedback - improve error handling"
git push

# 7. After approval, merge PR
gh pr merge 123 --squash

# 8. Update local main
git switch main
git pull origin main

# 9. Clean up
git branch -d feature/user-authentication
git push origin --delete feature/user-authentication
```

## Example 2: Bug Fix Workflow

### Scenario: Fix Critical Production Bug

```bash
# 1. Create hotfix branch from main
git switch main
git pull origin main
git switch -c hotfix/crash-on-login

# 2. Reproduce bug locally
# Run tests, debug, identify issue

# 3. Fix bug
vim src/auth/login.py
git add src/auth/login.py
git commit -m "hotfix: prevent crash when user has invalid session"

# 4. Add test for bug
vim tests/test_login.py
git add tests/test_login.py
git commit -m "test: add regression test for login crash"

# 5. Run tests
pytest

# 6. Push and create urgent PR
git push -u origin hotfix/crash-on-login
gh pr create \
  --title "hotfix: prevent crash on login" \
  --body "Urgent: Fixes production crash when users have invalid sessions\n\nFixes #456"

# 7. Request expedited review
gh pr edit 456 --add-reviewer @on-call

# 8. Merge quickly after approval
gh pr merge 456 --squash

# 9. Deploy to production immediately
./deploy.sh production

# 10. Clean up
git switch main
git pull origin main
git branch -d hotfix/crash-on-login
git push origin --delete hotfix/crash-on-login
```

## Example 3: Collaborative Development

### Scenario: Two Developers Working on Same Feature

**Developer A:**

```bash
# 1. Start feature
git switch main
git pull origin main
git switch -c feature/payment-system
git push -u origin feature/payment-system

# 2. Implement core payment logic
vim src/payment/core.py
git add src/payment/core.py
git commit -m "feat: implement payment processing core"
git push

# 3. Create PR
gh pr create --draft --title "WIP: Payment System"
```

**Developer B:**

```bash
# 1. Checkout existing feature branch
git fetch origin
git switch feature/payment-system

# 2. Create sub-branch for specific work
git switch -c feature/payment-gateway

# 3. Implement payment gateway integration
vim src/payment/gateway.py
git add src/payment/gateway.py
git commit -m "feat: add Stripe gateway integration"
git push -u origin feature/payment-gateway

# 4. Create PR to feature branch
gh pr create \
  --base feature/payment-system \
  --title "feat: add Stripe gateway" \
  --body "Integrate Stripe payment gateway into payment system"
```

**Developer A:**

```bash
# 1. Review and merge B's PR
gh pr merge 789 --squash

# 2. Pull latest changes
git switch feature/payment-system
git pull origin feature/payment-system

# 3. Continue work
vim src/payment/ui.py
git add src/payment/ui.py
git commit -m "feat: add payment UI components"
git push
```

## Example 4: Syncing with Main During Development

### Scenario: Keep Feature Branch Updated

```bash
# 1. Start feature branch
git switch main
git pull origin main
git switch -c feature/new-dashboard

# 2. Work on feature (make several commits)
vim src/dashboard/widgets.py
git commit -m "feat: add dashboard widgets"

# 3. Next morning, sync with main
git fetch origin
git rebase origin/main
# If conflicts: resolve and continue
git push --force-with-lease

# 4. Continue working
vim src/dashboard/charts.py
git commit -m "feat: add dashboard charts"

# 5. Before lunch, sync again
git fetch origin
git rebase origin/main
git push

# 6. At end of day, sync and push
git fetch origin
git rebase origin/main
git push
```

## Example 5: Resolving Merge Conflicts

### Scenario: Conflict During Merge

```bash
# 1. Attempt merge
git switch main
git pull origin main
git merge feature/user-auth

# 2. Conflict occurs
# Auto-merging src/auth.py
# CONFLICT (content): Merge conflict in src/auth.py

# 3. View conflicts
git status
# both modified:   src/auth.py

# 4. Open file in editor
vim src/auth.py

# 5. Resolve conflicts
# <<<<<<< HEAD
# def authenticate():
#     return basic_auth()
# =======
# def authenticate():
#     return oauth_auth()
# >>>>>>> feature/user-auth

# Choose one or combine:
def authenticate():
    if oauth_token:
        return oauth_auth()
    return basic_auth()

# 6. Mark as resolved
git add src/auth.py

# 7. Complete merge
git commit -m "Merge feature/user-auth - resolved conflicts in auth module"

# 8. Push
git push origin main
```

## Example 6: Reverting a Bad Commit

### Scenario: Revert Broken Feature

```bash
# 1. Identify bad commit
git log --oneline
# abc1234 feat: add new feature
# def5678 fix: previous commit

# 2. Revert commit (creates new commit)
git revert abc1234

# 3. Resolve conflicts if any
vim conflicted-file.py
git add conflicted-file.py
git revert --continue

# 4. Push revert
git push origin main

# Alternative: If commit not pushed yet
git reset --hard HEAD~1
git push --force-with-lease
```

## Example 7: Using Git Stash

### Scenario: Temporary Context Switch

```bash
# 1. Working on feature A
git switch feature-a
vim file.py
# Make changes...

# 2. Urgent bug comes in, need to switch
git stash push -m "WIP on feature A - half done"

# 3. Switch to bug fix
git switch main
git pull origin main
git switch -c hotfix/urgent-bug

# 4. Fix bug
vim file.py
git commit -am "hotfix: urgent bug fix"
git push
gh pr create --title "hotfix: urgent bug"
gh pr merge --squash

# 5. Return to feature A
git switch feature-a
git stash pop

# 6. Continue working on feature A
# Changes are restored
```

## Example 8: Cherry-Picking Commits

### Scenario: Apply Specific Commit to Another Branch

```bash
# 1. Commit exists on feature branch
git switch feature/auth
git log
# abc1234 fix: improve error handling

# 2. Need this fix on main now
git switch main
git pull origin main

# 3. Cherry-pick the commit
git cherry-pick abc1234

# 4. If conflicts, resolve
vim conflicted-file.py
git add conflicted-file.py
git cherry-pick --continue

# 5. Push to main
git push origin main
```

## Example 9: Release Workflow (Git Flow)

### Scenario: Prepare and Deploy Release

```bash
# 1. Start from develop
git switch develop
git pull origin develop

# 2. Create release branch
git switch -c release/v2.0.0

# 3. Bump version numbers
vim package.json  # Change "version": "1.2.0" to "2.0.0"
vim src/version.py  # Update version
git add package.json src/version.py
git commit -m "chore: bump version to 2.0.0"

# 4. Update CHANGELOG
vim CHANGELOG.md
git add CHANGELOG.md
git commit -m "docs: update CHANGELOG for v2.0.0"

# 5. Fix any release-specific bugs
vim src/bug.py
git commit -m "fix: release-specific bug"

# 6. Merge to main and tag
git switch main
git merge --no-ff release/v2.0.0
git tag -a v2.0.0 -m "Release version 2.0.0"
git push origin main --tags

# 7. Deploy to production
./deploy.sh production

# 8. Merge back to develop
git switch develop
git merge --no-ff release/v2.0.0
git push origin develop

# 9. Delete release branch
git branch -d release/v2.0.0
```

## Example 10: Interactive Rebase

### Scenario: Clean Up Commit History

```bash
# 1. View recent commits
git log --oneline -10
# abc1234 fix: typo
# def5678 feat: add feature
# ghi9012 fix: another typo
# jkl3456 wip
# mno6789 wip

# 2. Interactive rebase last 5 commits
git rebase -i HEAD~5

# 3. Editor opens with:
# pick abc1234 fix: typo
# pick def5678 feat: add feature
# pick ghi9012 fix: another typo
# pick jkl3456 wip
# pick mno6789 wip

# 4. Edit to:
# fixup abc1234 fix: typo          # Combine with previous
# pick def5678 feat: add feature   # Keep
# fixup ghi9012 fix: another typo  # Combine with previous
# squash jkl3456 wip               # Combine into one
# squash mno6789 wip               # Combine into one

# 5. Save and close
# Git will combine commits as requested

# 6. Force push (careful!)
git push --force-with-lease
```

## Example 11: Bisecting to Find Bug

### Scenario: Find Which Commit Introduced Bug

```bash
# 1. Start bisect
git bisect start

# 2. Mark current as bad (bug present)
git bisect bad

# 3. Mark known good commit
git bisect good v1.0.0

# 4. Git will checkout commits to test
# Bisecting: 5 revisions left to test
git switch --detach <revision>

# 5. Test the code
npm test
# If tests pass: git bisect good
# If tests fail: git bisect bad

# 6. Repeat until found
# abc1234 is the first bad commit

# 7. View culprit
git show abc1234

# 8. Fix the bug
git switch main
# ... fix bug ...
git commit -m "fix: resolve issue introduced in abc1234"

# 9. Reset bisect
git bisect reset
```

## Example 12: Working with Submodules

### Scenario: Manage External Dependencies

```bash
# 1. Add submodule
git submodule add https://github.com/example/library.git lib/library

# 2. Commit submodule addition
git add .gitmodules lib/library
git commit -m "chore: add library submodule"

# 3. Clone repository with submodules
git clone --recurse-submodules https://github.com/user/repo.git

# 4. Update submodules
git submodule update --remote

# 5. Commit submodule update
git add lib/library
git commit -m "chore: update library to latest version"
```

## Example 13: Partial Commit (Interactive Add)

### Scenario: Commit Only Parts of a File

```bash
# 1. Make multiple changes in file
vim large-file.py
# Change function A (ready to commit)
# Change function B (not ready)
# Change function C (ready to commit)

# 2. Interactive add
git add -p large-file.py

# 3. Git shows each hunk:
# Stage this hunk [y,n,q,a,d,/,e,?]?

# 4. Choose for each hunk:
# y - stage this hunk
# n - don't stage this hunk
# s - split into smaller hunks

# 5. Commit staged changes
git commit -m "feat: improve functions A and C"

# 6. Function B changes remain unstaged
git status
```

## Example 14: Using Git Hooks

### Scenario: Automate Pre-commit Checks

```bash
# 1. Create pre-commit hook
vim .git/hooks/pre-commit

#!/bin/bash
# Run tests
npm test || exit 1

# Run linter
npm run lint || exit 1

# Check for large files
if find . -type f -size +5M; then
    echo "Error: Files larger than 5MB detected"
    exit 1
fi

# 2. Make executable
chmod +x .git/hooks/pre-commit

# 3. Now commits will automatically run checks
git commit -m "feat: add feature"
# Pre-commit hook runs...
```

## Example 15: Collaborating with Fork

### Scenario: Contribute to Open Source

```bash
# 1. Fork repository on GitHub

# 2. Clone your fork
git clone https://github.com/yourusername/original-repo.git
cd original-repo

# 3. Add upstream remote
git remote add upstream https://github.com/original/original-repo.git

# 4. Create feature branch
git switch -c feature/new-feature

# 5. Make changes
vim file.py
git add file.py
git commit -m "feat: add new feature"

# 6. Push to your fork
git push origin feature/new-feature

# 7. Create PR from your fork to original repo

# 8. Keep your fork updated
git fetch upstream
git switch main
git merge upstream/main
git push origin main

# 9. After PR merged, update your fork again
git fetch upstream
git switch main
git merge upstream/main
git push origin main
```

## Troubleshooting Examples

### Undo Last Commit (Keep Changes)

```bash
git reset --soft HEAD~1
# Changes remain staged
```

### Undo Last Commit (Discard Changes)

```bash
git reset --hard HEAD~1
# Changes are gone
```

### Recover Lost Commit

```bash
git reflog
# Find commit hash
abc1234 HEAD@{2}: commit: feat: add feature

git switch --detach abc1234
git switch -c recover-branch
```

## Quick Workflows Reference

| Task | Commands |
|------|----------|
| Start feature | `git switch main && git pull && git switch -c feature/name` |
| Save work temporarily | `git stash push -m "message"` |
| Restore work | `git stash pop` |
| Sync with main | `git fetch origin && git rebase origin/main` |
| Resolve conflicts | `edit file && git add file && git commit` |
| Revert commit | `git revert <hash>` |
| Clean history | `git rebase -i HEAD~n` |

## Next Steps

- [Git Basics](./git-basics.md) - Essential commands
- [Branching Strategies](./branching-strategies.md) - Choose workflow
- [Remote Operations](./remote-operations.md) - Team collaboration
- [Pull Requests](./pull-requests.md) - Code review process
