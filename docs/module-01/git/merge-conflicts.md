# Merge Conflicts

**Resolving conflicts when combining changes**

## Overview

Merge conflicts occur when Git cannot automatically reconcile differences between branches. This guide explains how to resolve conflicts effectively and maintain project integrity.

## What Causes Conflicts?

### Common Scenarios

1. **Same Line Modified**
   ```
   Branch A:    const user = getUser();
   Branch B:    const user = await getUserAsync();
   ```

2. **Same File Modified in Different Places**
   ```
   Branch A:    Modifies lines 10-20
   Branch B:    Modifies lines 15-25
   ```

3. **File Deleted vs Modified**
   ```
   Branch A:    Deletes file.py
   Branch B:    Modifies file.py
   ```

4. **File Renamed vs Modified**
   ```
   Branch A:    Renames old.py → new.py
   Branch B:    Modifies old.py
   ```

## Understanding Conflict Markers

```python
# Conflict markers in files

<<<<<<< HEAD
# Your changes (current branch)
def authenticate():
    return basic_auth()

=======
# Their changes (incoming branch)
def authenticate():
    return oauth_auth()

>>>>>>> feature/oauth-improvements
```

### Marker Breakdown

- `<<<<<<< HEAD`: Start of your changes
- `=======`: Separator between your and their changes
- `>>>>>>> branch-name`: End of their changes

## Resolving Conflicts

### Method 1: Manual Resolution

```bash
# 1. Attempt merge
git switch main
git merge feature/new-auth

# 2. Identify conflicts
git status
# Output: both modified: src/auth.py

# 3. Open conflicted file
vim src/auth.py

# 4. Resolve conflicts manually
def authenticate():
<<<<<<< HEAD
    return basic_auth()
=======
    return oauth_auth()
>>>>>>> feature/new-auth

# Choose one or combine:
def authenticate():
    return oauth_auth()  # Use oauth

# 5. Mark as resolved
git add src/auth.py

# 6. Complete merge
git commit
```

### Method 2: Using Merge Tools

```bash
# Configure merge tool
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'

# Use merge tool
git mergetool

# Tool will open with:
# - Left: Your changes
# - Right: Their changes
# - Center: Merged result (edit this)

# Save and close tool
git add resolved-file.py
git commit
```

### Method 3: Accept One Side

```bash
# Accept all your changes
git restore ours path/to/file
git add path/to/file

# Accept all their changes
git restore theirs path/to/file
git add path/to/file

# Accept ours for all conflicts
git merge -X ours feature-branch

# Accept theirs for all conflicts
git merge -X theirs feature-branch
```

## Conflict Resolution Strategies

### Strategy 1: Combine Changes

```python
# Before conflict:
<<<<<<< HEAD
def authenticate(username, password):
    return basic_auth(username, password)
=======
def authenticate():
    return oauth_auth()
>>>>>>> feature/oauth

# After combining:
def authenticate(username=None, password=None, token=None):
    if token:
        return oauth_auth(token)
    elif username and password:
        return basic_auth(username, password)
    else:
        raise ValueError("Invalid credentials")
```

### Strategy 2: Choose One

```python
# Choose one approach:
def authenticate():
    return oauth_auth()  # Keep oauth, remove basic
```

### Strategy 3: Refactor Both

```python
# Create new approach:
def authenticate(credentials):
    """Unified authentication interface"""
    if isinstance(credentials, BasicCredentials):
        return basic_auth(credentials)
    elif isinstance(credentials, OAuthCredentials):
        return oauth_auth(credentials)
    else:
        raise TypeError("Invalid credentials type")
```

## Conflict Scenarios

### Scenario 1: Merge Conflict

```bash
# Attempt merge
git merge feature/new-auth

# Conflict detected
Auto-merging src/auth.py
CONFLICT (content): Merge conflict in src/auth.py
Automatic merge failed; fix conflicts and then commit the result.

# View conflicts
git status
# both modified:   src/auth.py

# Edit file
vim src/auth.py

# Mark as resolved
git add src/auth.py

# Complete merge
git commit -m "Merge feature/new-auth - resolved conflicts in auth module"
```

### Scenario 2: Rebase Conflict

```bash
# Rebase onto main
git checkout feature/new-auth
git rebase main

# Conflict during rebase
error: could not apply 1234567... Add authentication
CONFLICT (content): Merge conflict in src/auth.py

# Resolve conflict
vim src/auth.py

# Continue rebase
git add src/auth.py
git rebase --continue

# If needed, skip commit
git rebase --skip

# Or abort rebase
git rebase --abort
```

### Scenario 3: Pull Conflict

```bash
# Pull changes
git pull origin main

# Conflict
CONFLICT (content): Merge conflict in src/auth.py

# Resolve and commit
vim src/auth.py
git add src/auth.py
git commit -m "Merge remote-tracking branch 'origin/main'"
```

### Scenario 4: Cherry-Pick Conflict

```bash
# Cherry-pick commit
git cherry-pick abc123

# Conflict
error: could not apply abc123... Add feature

# Resolve conflict
vim src/auth.py
git add src/auth.py
git cherry-pick --continue
```

## Binary File Conflicts

### Handling Binary Files

```bash
# Conflict in binary file (e.g., image, PDF)
CONFLICT (content): Merge conflict in logo.png

# Choose one version
git restore ours logo.png    # Keep your version
git restore theirs logo.png  # Keep their version

# Mark as resolved
git add logo.png
git commit
```

### Using Binary Merge Tools

```bash
# Configure binary merge tool
git config mergetool.png.cmd "meld $LOCAL $REMOTE $MERGED"

# Use tool
git mergetool logo.png
```

## Preventing Conflicts

### Best Practices

1. **Communicate Early**
   ```bash
   # Tell team what you're working on
   "I'm modifying auth.py this week"
   ```

2. **Pull Frequently**
   ```bash
   # Pull before starting work
   git pull origin main

   # Pull during work
   git pull origin main
   ```

3. **Small, Focused Changes**
   ```bash
   # Good: Small PR
   feature/add-login-button

   # Bad: Large PR touching many files
   feature/complete-redesign
   ```

4. **Modular Code**
   ```python
   # Good: Separate modules
   # auth.py
   # user.py
   # session.py

   # Bad: Monolithic file
   # everything.py
   ```

5. **Feature Flags**
   ```python
   # Use flags instead of conflicts
   if FEATURE_NEW_AUTH:
       new_auth()
   else:
       old_auth()
   ```

### Code Organization

```bash
# Organize to minimize conflicts
project/
├── src/
│   ├── auth/         # Team A works here
│   ├── user/         # Team B works here
│   └── shared/       # Both coordinate
└── tests/
```

## Advanced Conflict Resolution

### Using git rerere

```bash
# Enable reuse of recorded resolutions
git config --global rerere.enabled true

# Git remembers how you resolved conflicts
# Next time, auto-resolves same conflicts
```

### Recursive Merge Strategy

```bash
# Use recursive strategy (default)
git merge -s recursive branch-name

# With patience (handles renames better)
git merge -s recursive -X patience branch-name

# With theirs (prefer their changes)
git merge -s recursive -X theirs branch-name

# With ours (prefer our changes)
git merge -s recursive -X ours branch-name
```

### Octopus Merge

```bash
# Merge multiple branches at once
git merge branch1 branch2 branch3

# Good for integrating multiple features
```

## Troubleshooting

### Issue: Can't Resolve Conflict

```bash
# If stuck, abort and try different approach
git merge --abort

# Or for rebase
git rebase --abort

# Start fresh
git pull origin main
```

### Issue: Accidental Resolution

```bash
# If you resolved conflict incorrectly
git reset --hard HEAD~1

# Try again
git merge branch-name
```

### Issue: Complex Conflicts

```bash
# For many files with conflicts
git status | grep 'both modified'

# Resolve systematically
for file in $(git diff --name-only --diff-filter=U); do
    vim "$file"
    git add "$file"
done
```

## Team Strategies

### Strategy 1: Code Owners

```bash
# .github/CODEOWNERS
# Assign responsibility

/auth/ @auth-team
/ui/ @ui-team

# Fewer conflicts with clear ownership
```

### Strategy 2: Coordination

```bash
# Daily standup: discuss work
# Slack channel: announce changes
# Code review: catch conflicts early
```

### Strategy 3: Branching Strategy

```bash
# Trunk-Based: Short branches, fewer conflicts
# GitHub Flow: PRs catch conflicts early
# Git Flow: Long-lived branches, more conflicts
```

## Conflict Prevention Checklist

### Before Starting Work

- [ ] Pull latest changes
- [ ] Check what others are working on
- [ ] Plan your changes
- [ ] Identify potential conflicts

### During Development

- [ ] Pull frequently
- [ ] Communicate with team
- [ ] Make small commits
- [ ] Test regularly

### Before Merging

- [ ] Rebase with latest main
- [ ] Resolve conflicts locally
- [ ] Run tests
- [ ] Request review

## Quick Reference

| Command | Description |
|---------|-------------|
| `git status` | Show conflicted files |
| `git diff` | Show conflict markers |
| `git merge --abort` | Cancel merge |
| `git rebase --abort` | Cancel rebase |
| `git restore ours file` | Accept your changes |
| `git restore theirs file` | Accept their changes |
| `git add file` | Mark as resolved |
| `git mergetool` | Open merge tool |
| `git log --merge` | Show conflicted commits |

## Example Workflow

### Complete Conflict Resolution

```bash
#!/bin/bash
# resolve-conflict.sh

# 1. Start merge
git merge feature/new-auth

# 2. Check if conflicts
if [ $? -ne 0 ]; then
    echo "Conflicts detected!"

    # 3. List conflicted files
    git status | grep 'both modified'

    # 4. Open each file in editor
    git status --short | grep '^UU' | awk '{print $2}' | xargs vim

    # 5. Mark as resolved
    git status --short | grep '^UU' | awk '{print $2}' | xargs git add

    # 6. Complete merge
    git commit -m "Merge feature/new-auth with resolved conflicts"

    echo "Conflicts resolved!"
else
    echo "No conflicts, clean merge!"
fi
```

## Next Steps

- [Git Basics](./git-basics.md) - Essential commands
- [Branching Strategies](./branching-strategies.md) - Team workflows
- [Remote Operations](./remote-operations.md) - Working with remotes
- [Team Conventions](./team-conventions.md) - Preventing conflicts
