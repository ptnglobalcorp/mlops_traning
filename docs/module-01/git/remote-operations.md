# Remote Operations

**Working with remote repositories and team collaboration**

## Overview

Remote operations enable collaboration with team members through shared repositories on platforms like GitHub, GitLab, and Bitbucket. Understanding these operations is essential for team-based development.

## Understanding Remotes

### What is a Remote?

A remote is a version of your repository hosted on a server (GitHub, GitLab, Bitbucket, or private server).

```bash
# View remotes
git remote -v

# Example output:
# origin  https://github.com/username/repo.git (fetch)
# origin  https://github.com/username/repo.git (push)
# upstream https://github.com/original/repo.git (fetch)
# upstream https://github.com/original/repo.git (push)
```

### Remote Naming Conventions

- **`origin`**: Your fork or repository (default)
- **`upstream`**: Original repository (for forks)
- **Custom**: Any descriptive name

```bash
# Add a remote
git remote add <name> <url>

# Example: Add upstream
git remote add upstream https://github.com/original/repo.git

# Add custom remote
git remote add team https://github.com/team/shared-repo.git
```

## Managing Remotes

### Adding Remotes

```bash
# Add remote
git remote add origin https://github.com/username/repo.git

# Add with different name
git remote add upstream https://github.com/original/repo.git

# Add with SSH
git remote add origin git@github.com:username/repo.git
```

### Viewing Remotes

```bash
# List all remotes
git remote

# List with URLs
git remote -v

# Show detailed information
git remote show origin

# Show remote branches
git remote show origin | grep "heads"
```

### Removing and Renaming

```bash
# Remove remote
git remote remove origin

# Rename remote
git remote rename origin old-origin

# Change remote URL
git remote set-url origin https://github.com/newuser/repo.git
```

## Fetching Changes

### Basic Fetch

```bash
# Fetch all branches from remote
git fetch origin

# Fetch specific branch
git fetch origin main

# Fetch all remotes
git fetch --all

# Fetch with prune (delete stale branches)
git fetch -p
git fetch --prune
```

### Understanding FETCH_HEAD

```bash
# Fetch without merging
git fetch origin

# View fetched commits
git log FETCH_HEAD

# Compare with your branch
git log HEAD..FETCH_HEAD
```

### Fetch Workflow

```bash
# 1. Fetch latest changes
git fetch origin

# 2. View what changed
git log HEAD..origin/main

# 3. Inspect specific commit
git show origin/main

# 4. Decide to merge or rebase
git merge origin/main
# or
git rebase origin/main
```

## Pulling Changes

### Basic Pull

```bash
# Pull current branch
git pull

# Pull from specific remote/branch
git pull origin main

# Pull with rebase instead of merge
git pull --rebase
git pull --rebase origin main
```

### Pull vs Fetch + Merge

```bash
# These are equivalent:
git pull origin main

git fetch origin main
git merge origin/main
```

### Configuring Default Pull Behavior

```bash
# Set pull to rebase by default
git config --global pull.rebase true

# Set pull to merge (default)
git config --global pull.rebase false

# Check current setting
git config pull.rebase
```

### Pull Scenarios

#### Scenario 1: Fast-Forward

```bash
# Your branch is behind remote
# Remote has commits you don't have

git pull
# Fast-forward merge
# Your branch moves forward
```

#### Scenario 2: Diverged History

```bash
# You and others have different commits

git pull
# Creates merge commit
# Or use --rebase for linear history
git pull --rebase
```

#### Scenario 3: Conflicts

```bash
git pull
# Auto-merge fails; conflicts!

# Resolve conflicts
vim conflicted-file.py

# Mark as resolved
git add conflicted-file.py

# Complete merge
git commit
# Or for rebase:
git rebase --continue
```

## Pushing Changes

### Basic Push

```bash
# Push current branch
git push

# Push to specific remote/branch
git push origin main

# Push all branches
git push --all

# Push tags
git push --tags

# Push specific branch
git push origin feature/new-feature
```

### Setting Upstream

```bash
# First time pushing new branch
git push -u origin feature-new

# Now can just use:
git push
```

### Force Push

**Warning: Use with caution!**

```bash
# Force push (dangerous!)
git push --force

# Safer force push
git push --force-with-lease

# Force push specific branch
git push --force origin feature-branch
```

### When to Use Force Push

**Safe scenarios:**
- You're the only one working on the branch
- You're fixing a commit before anyone pulls
- You intentionally rewrote history

**Unsafe scenarios:**
- Others have already pulled the branch
- Shared branches like main/develop
- Public repositories

## Synchronization Workflows

### Syncing with Main Branch

```bash
# Method 1: Merge
git switch feature-branch
git fetch origin
git merge origin/main

# Method 2: Rebase (preferred)
git switch feature-branch
git fetch origin
git rebase origin/main
```

### Keeping Fork Updated

```bash
# 1. Add upstream remote
git remote add upstream https://github.com/original/repo.git

# 2. Fetch upstream
git fetch upstream

# 3. Merge upstream/main to your local main
git switch main
git merge upstream/main

# 4. Push to your fork
git push origin main
```

### Daily Sync Routine

```bash
#!/bin/bash
# sync.sh - Daily sync script

# Fetch all remotes
git fetch --all --prune

# Update main
git switch main
git pull origin main

# If using fork, update from upstream
git merge upstream/main
git push origin main

# Return to feature branch
git switch -
```

## Remote Branches

### Listing Remote Branches

```bash
# List all remote branches
git branch -r

# List all branches (local and remote)
git branch -a

# Show remote-tracking branches
git branch -vv
```

### Tracking Remote Branches

```bash
# Set tracking branch
git branch --set-upstream-to=origin/main main

# Checkout with tracking
git switch -c local-branch origin/remote-branch

# Short form
git switch remote-branch
```

### Deleting Remote Branches

```bash
# Delete remote branch
git push origin --delete feature-branch

# Alternative syntax
git push origin :feature-branch

# Delete multiple
git push origin --delete branch1 branch2 branch3
```

## Common Workflows

### Feature Development Workflow

```bash
# 1. Start from clean main
git switch main
git pull origin main

# 2. Create feature branch
git switch -c feature/new-feature

# 3. Work on feature
git add .
git commit -m "feat: add new feature"

# 4. Push to remote
git push -u origin feature/new-feature

# 5. Create pull request
gh pr create --title "feat: add new feature"

# 6. Update with latest main
git fetch origin
git rebase origin/main

# 7. Push updates (if needed)
git push

# 8. After merge, delete branch
git switch main
git pull origin main
git branch -d feature/new-feature
git push origin --delete feature/new-feature
```

### Team Collaboration Workflow

```bash
# Developer A: Start feature
git switch -c feature/auth
git push -u origin feature/auth

# Developer B: Work on same feature
git fetch origin
git switch feature/auth
# ... make changes ...
git push origin feature/auth

# Developer A: Pull changes
git fetch origin
git rebase origin/feature/auth
# Resolve conflicts if any
git push origin feature/auth
```

### Hotfix Workflow

```bash
# 1. Create hotfix from main
git switch main
git pull origin main
git switch -c hotfix/critical-bug

# 2. Fix bug
git add .
git commit -m "hotfix: patch critical bug"

# 3. Push and create PR
git push -u origin hotfix/critical-bug
gh pr create --title "hotfix: critical bug"

# 4. Merge PR (quickly!)

# 5. Update local main
git switch main
git pull origin main

# 6. Clean up
git branch -d hotfix/critical-bug
```

## Troubleshooting

### Issue: Push Rejected

```bash
# Error: failed to push some refs
git push origin main
# ! [rejected] main -> main (fetch first)

# Solution: Pull first
git pull origin main
git push origin main
```

### Issue: Diverged Branches

```bash
# Error: branch diverged
git pull
# CONFLICT (content): Merge conflict

# Solution: Choose strategy

# Option 1: Merge
git pull --no-rebase

# Option 2: Rebase (cleaner history)
git pull --rebase

# Option 3: Reset (use with caution!)
git fetch origin
git reset --hard origin/main
```

### Issue: Remote URL Changed

```bash
# Error: remote repository not found
git push
# fatal: repository 'https://...' not found

# Solution: Update remote URL
git remote set-url origin git@github.com:newuser/newrepo.git

# Verify
git remote -v
```

### Issue: Authentication Failed

```bash
# Error: authentication failed
git push
# fatal: Authentication failed

# Solution: Configure credentials
# For HTTPS:
git config credential.helper store
git push  # Will prompt for username/password

# For SSH (recommended):
ssh-keygen -t ed25519 -C "your@email.com"
# Add SSH key to GitHub/GitLab settings
git remote set-url origin git@github.com:username/repo.git
```

## Best Practices

### Before Pushing

```bash
# 1. Pull latest changes
git pull origin main

# 2. Check status
git status

# 3. Review changes
git diff origin/main

# 4. Ensure tests pass
npm test

# 5. Now push
git push
```

### Daily Routine

```bash
# Morning: Pull latest
git pull origin main

# Before lunch: Push work
git push

# After lunch: Pull again
git pull origin main

# End of day: Push and pull
git push
git pull origin main
```

### Team Coordination

```bash
# 1. Communicate before pushing
# Use Slack/Teams to coordinate

# 2. Pull before pushing
git fetch origin
git rebase origin/main

# 3. Push frequently
# Don't accumulate changes

# 4. Resolve conflicts quickly
# Don't leave branches diverged
```

## SSH vs HTTPS

### SSH (Recommended)

```bash
# Setup
ssh-keygen -t ed25519 -C "your@email.com"
cat ~/.ssh/id_ed25519.pub  # Copy to GitHub/GitLab

# Remote URL
git remote set-url origin git@github.com:username/repo.git

# Benefits:
# - No password needed
# - More secure
# - Faster
```

### HTTPS

```bash
# Remote URL
git remote set-url origin https://github.com/username/repo.git

# Setup credential helper (avoid password prompts)
git config credential.helper store

# Benefits:
# - Easier to setup
# - Works through proxies
# - No SSH key management
```

## Remote Configuration

### Per-Repository Settings

```bash
# Set specific remote for this repository
git config remote.origin.pushurl git@github.com:username/repo.git

# Set push default
git config push.default simple  # Push current branch
git config push.default current  # Push to branch with same name
```

### Global Settings

```bash
# Set default push strategy
git config --global push.default simple

# Set rebase for pull
git config --global pull.rebase true

# Set credential helper
git config --global credential.helper store
```

## Quick Reference

| Command | Description |
|---------|-------------|
| `git remote -v` | List remotes with URLs |
| `git fetch origin` | Fetch changes from remote |
| `git pull` | Fetch and merge changes |
| `git pull --rebase` | Fetch and rebase changes |
| `git push` | Push changes to remote |
| `git push -u origin branch` | Push and set upstream |
| `git push --force-with-lease` | Safer force push |
| `git branch -r` | List remote branches |
| `git push origin --delete branch` | Delete remote branch |

## Next Steps

- [Git Basics & Configuration](./git-basics.md) - Essential commands
- [Branching Strategies](./branching-strategies.md) - Team workflows
- [Pull Requests & Code Review](./pull-requests.md) - Collaboration
- [Merge Conflicts](./merge-conflicts.md) - Resolving conflicts
