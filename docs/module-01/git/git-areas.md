# Understanding Git Areas

**How Git manages files through different stages**

## Overview

Git uses four distinct areas to manage your files. Understanding how files move between these areas is essential for effective Git usage.

## The Four Git Areas

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Git Working Areas                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Working Directory    Staging Area    Local Repository    Remote   │
│  (Your Files)         (Index)         (.git folder)       Repository│
│                                                                     │
│  ┌─────────┐        ┌─────────┐      ┌─────────┐         ┌─────────┐│
│  │ file.py │──add──→│ Staged  │─────→│ Committed│──push──→│ Origin  ││
│  │ (modif.)│        │ Changes │      │ Changes │         │  main   ││
│  └─────────┘        └─────────┘      └─────────┘         └─────────┘│
│       ↑                 ↑                 │                    │     │
│       │                 │                 │                    │     │
│    checkout         restore          commit                 pull    │
│     (reset)          (unstage)         (diff)              (fetch)  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## 1. Working Directory

The working directory is where you actually work on your files. These are the files you see in your file system.

```bash
# Edit files in your editor
# Files are in the working directory

# Check working directory status
git status

# See differences from last commit
git diff
```

**Characteristics:**
- Files you can see and edit
- May have uncommitted changes
- Compared against staging area with `git diff`

## 2. Staging Area (Index)

The staging area is where you prepare files for the next commit. It's also called the "index".

```bash
# Add files to staging
git add file.py
git add .

# View staged changes
git diff --staged
git diff --cached

# Remove from staging
git restore --staged file.py
git reset HEAD file.py
```

**Characteristics:**
- Holds files prepared for commit
- Allows selective commits
- Compared to working directory with `git diff --staged`

## 3. Local Repository

The local repository (`.git` folder) stores your committed history.

```bash
# Commit staged changes
git commit -m "message"

# View commit history
git log
git log --oneline

# View repository contents
git ls-tree -r HEAD
```

**Characteristics:**
- Contains all committed snapshots
- Stores entire project history
- Located in `.git` directory

## 4. Remote Repository

The remote repository is a version of your project hosted on a server (GitHub, GitLab, Bitbucket).

```bash
# Show remotes
git remote -v

# Fetch from remote
git fetch origin

# Pull from remote (fetch + merge)
git pull origin main

# Push to remote
git push origin main
```

**Characteristics:**
- Hosted on external server
- Shared with team members
- Synchronized via push/pull

## File Movement Between Areas

### Adding Files to Staging

```bash
# Edit file
echo "new code" >> file.py

# Move to staging
git add file.py

# Now file.py is in staging area
git status
```

### Committing Files

```bash
# Commit staged files
git commit -m "Add new feature"

# Files moved from staging to local repository
# Staging area is now empty
git status
```

### Pushing to Remote

```bash
# Push commits to remote
git push origin main

# Commits now in remote repository
# Available to team members
```

### Pulling from Remote

```bash
# Fetch and merge remote changes
git pull origin main

# Remote commits now in local repository
# Working directory updated if needed
```

## Visual Workflow

### Complete Workflow Example

```bash
# 1. Working Directory: Edit files
echo "print('hello')" > script.py

# Check status
git status
# Output: script.py (modified)

# 2. Staging Area: Stage changes
git add script.py

# Check status
git status
# Output: script.py (staged)

# 3. Local Repository: Commit
git commit -m "Add hello script"

# Check status
git status
# Output: nothing to commit

# 4. Remote Repository: Push
git push origin main

# Now in remote
```

## Understanding `git diff`

### Three Types of Diff

```bash
# Working vs Staging
git diff
# Shows changes you haven't staged

# Staging vs Local Repository
git diff --staged
git diff --cached
# Shows changes you'll commit

# Working vs Local Repository
git diff HEAD
# Shows all changes since last commit
```

### Diff Examples

```bash
# Make some changes
echo "line 1" > file.txt
git add file.txt
git commit -m "Initial commit"

echo "line 2" >> file.txt     # Working change
git add file.txt
echo "line 3" >> file.txt     # Another working change

# Now check diffs
git diff                      # Shows "line 3"
git diff --staged             # Shows "line 2"
git diff HEAD                 # Shows "line 2" and "line 3"
```

## Moving Files Backward

### From Staging to Working

```bash
# Unstage files
git restore --staged file.txt
git reset HEAD file.txt

# File back in working directory
# Changes preserved
```

### From Repository to Working

```bash
# Discard working changes
git restore file.txt
git restore  file.txt

# File back to last committed state
# Working changes lost!
```

### From Repository to Staging

```bash
# Reset staging to last commit
git reset HEAD
git restore --staged .

# Staging cleared
# Working changes preserved
```

## Practical Scenarios

### Scenario 1: Start New Work

```bash
# 1. Start with clean state
git status

# 2. Pull latest changes
git pull origin main

# 3. Create feature branch
git switch -c feature/new-function

# 4. Make changes (working directory)
# ... edit files ...

# 5. Stage changes
git add .

# 6. Commit
git commit -m "Add new function"

# 7. Push to remote
git push origin feature/new-function
```

### Scenario 2: Undo Mistakes

```bash
# Oops! Staged wrong file
git restore --staged wrong-file.py

# Oops! Don't want these changes
git restore file.py

# Oops! Wrong commit message
git commit --amend -m "Correct message"
```

### Scenario 3: Partial Staging

```bash
# Edit file with multiple changes
# file.py has changes in functions A, B, C

# Stage only function A
git add -p file.py
# y - stage this hunk
# n - don't stage this hunk
# s - split into smaller hunks

# Commit just function A
git commit -m "Fix function A"

# Stage function B
git add -p file.py
git commit -m "Improve function B"
```

## Best Practices

1. **Review before staging**
   ```bash
   git diff                    # Review changes
   git add .                   # Then stage
   ```

2. **Review before committing**
   ```bash
   git diff --staged           # Review staged
   git commit -m "message"     # Then commit
   ```

3. **Keep commits focused**
   ```bash
   # Stage related files together
   git add file1.py file2.py
   git commit -m "Add user feature"

   # Stage unrelated files separately
   git add readme.md
   git commit -m "Update documentation"
   ```

4. **Clean staging area**
   ```bash
   # Always check status before commits
   git status

   # Unstage anything accidental
   git restore --staged accidental-file.py
   ```

## Common Pitfalls

### Pitfall 1: Forgetting to Stage

```bash
# Make changes
echo "new code" > file.py

# Try to commit
git commit -m "Add feature"
# Error: nothing to commit

# Need to stage first
git add .
git commit -m "Add feature"
```

### Pitfall 2: Staging Too Much

```bash
# Make changes to multiple files
git add .

# Oops! Including test file
git restore --staged test-file.py
git commit -m "Add feature"
```

### Pitfall 3: Commit Without Review

```bash
# Bad: Don't do this
git add .
git commit -m "updates"

# Good: Review first
git diff --staged
git commit -m "Add user authentication"
```

## Quick Reference

| Area | Command | Description |
|------|---------|-------------|
| Working → Staging | `git add <file>` | Stage changes |
| Staging → Working | `git restore --staged <file>` | Unstage changes |
| Staging → Repository | `git commit -m "msg"` | Commit changes |
| Repository → Working | `git restore <file>` | Discard changes |
| Repository → Remote | `git push` | Push commits |
| Remote → Repository | `git pull` | Pull changes |
| Working vs Staging | `git diff` | Show unstaged changes |
| Staging vs Repository | `git diff --staged` | Show staged changes |

## Next Steps

- [Git Basics & Configuration](./git-basics.md) - Essential commands
- [Branching Strategies](./branching-strategies.md) - Team workflows
- [Remote Operations](./remote-operations.md) - Working with remotes
