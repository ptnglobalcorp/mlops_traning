# Git Basics & Configuration

**Setting up Git for team collaboration**

## Overview

Git is a distributed version control system that tracks changes in source code during software development. This guide covers essential Git commands and configuration for team collaboration.

## Getting Help

```bash
# General help
git help

# Help for specific command
git help <command>
git <command> --help
git help -g     # Guide

# Quick reference
git help -a     # List all commands
```

## Initial Configuration

### User Identity

Every commit needs to identify the author. Configure this once:

```bash
# Set your name
git config --global user.name "Your Name"

# Set your email (use your work email for team projects)
git config --global user.email "your.email@example.com"

# Set different email for specific repositories
cd /path/to/repo
git config user.email "personal@email.com"
```

### Default Branch Name

Modern Git uses `main` as the default branch:

```bash
# Check default branch
git config --global init.defaultBranch

# Set to main
git config --global init.defaultBranch main
```

### Editor Configuration

Choose your default editor for commit messages:

```bash
# VS Code
git config --global core.editor "code --wait"

# Vim
git config --global core.editor "vim"

# Notepad++ (Windows)
git config --global core.editor "'C:/Program Files/Notepad++/notepad++.exe' -multiInst -notabbar -nosession -noPlugin"

# Sublime Text
git config --global core.editor "'subl' -n -w"
```

### Line Endings

Prevent line ending issues across platforms:

```bash
# Windows - convert to CRLF on checkout, LF on commit
git config --global core.autocrlf true

# Mac/Linux - convert to LF on commit
git config --global core.autocrlf input
```

### Useful Aliases

Save time with command shortcuts:

```bash
# Common aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual 'log --graph --oneline --all'

# More useful aliases
git config --global alias Amend 'commit --amend --no-edit'
git config --global alias.commits 'log --oneline --graph --decorate'
git config --global alias.untracked 'ls-files --others --exclude-standard'
```

### View Configuration

```bash
# List all configuration
git config --list

# Show specific config
git config user.name

# Show configuration file locations
git config --list --show-origin

# System-wide config
git config --system --list

# Global (user) config
git config --global --list

# Local (repository) config
git config --local --list
```

## Essential Commands

### Repository Operations

```bash
# Initialize new repository
git init

# Clone existing repository
git clone <url>
git clone <url> <directory>      # Clone into specific directory
git clone --depth 1 <url>         # Shallow clone (latest commit only)

# Check repository status
git status
git status -s                     # Short format
git status --ignored              # Show ignored files
```

### Staging Changes

```bash
# Stage specific file
git add <file>

# Stage multiple files
git add <file1> <file2>

# Stage all changes
git add .
git add -A                        # Include deletions
git add -u                        # Only update tracked files

# Stage with patch (interactive)
git add -p                        # Stage parts of files
git add -i                        # Interactive staging

# Unstage files
git reset HEAD <file>
git restore --staged <file>       # Git 2.23+
```

### Committing Changes

```bash
# Commit with message
git commit -m "message"

# Commit staged changes (skip staging)
git commit -am "message"

# Amend last commit (use carefully!)
git commit --amend                # Edit message
git commit --amend --no-edit      # Keep message

# Empty commit (useful for CI triggers)
git commit --allow-empty -m "trigger CI"

# Commit with author info
git commit -m "message" --author="Name <email>"
```

### Viewing History

```bash
# Show commit history
git log
git log --oneline                 # Concise format
git log --graph                   # ASCII graph
git log --decorate                # Show refs

# Limit output
git log -n 5                      # Last 5 commits
git log --since="2 weeks ago"
git log --until="2025-01-01"

# View specific commit
git show <commit>
git show HEAD                     # Latest commit
git show HEAD~2                   # Two commits back

# View changes
git diff                         # Working vs staging
git diff --staged                # Staging vs repository
git diff HEAD                    # Working vs repository
git diff <commit1> <commit2>     # Compare commits
```

### Branching Basics

```bash
# List branches
git branch
git branch -r                     # Remote branches
git branch -a                     # All branches

# Create branch
git branch <name>

# Switch branches
git switch <name>                 # Git 2.23+ (recommended)
git checkout <name>               # Legacy method

# Create and switch
git switch -c <name>              # Git 2.23+ (recommended)
git checkout -b <name>            # Legacy method

# Rename branch
git branch -m <old> <new>

# Delete branch
git branch -d <name>              # Safe delete (merged)
git branch -D <name>              # Force delete
```

## File Operations

### Removing Files

```bash
# Remove from working directory and Git
git rm <file>

# Remove from Git only (keep file)
git rm --cached <file>

# Remove directories
git rm -r <directory>
```

### Moving/Renaming Files

```bash
# Rename file
git mv <old> <new>

# Git tracks this as rename + file change
```

### Ignoring Files

Create `.gitignore` in repository root:

```bash
# Common patterns
*.log                              # All log files
build/                             # Build directory
node_modules/                      # Node dependencies
.DS_Store                          # macOS files
*.swp                              # Vim swap files

# Personal ignores
git config --global core.excludesfile ~/.gitignore_global
```

### Viewing File Content

```bash
# Show file at specific commit
git show <commit>:<file>

# Restore file from previous commit
git restore --source=<commit> <file>  # Git 2.23+ (recommended)
git checkout <commit> -- <file>       # Legacy method

# Blame (show who changed each line)
git blame <file>
git blame -L 10,20 <file>          # Lines 10-20
```

## Undoing Changes

### Working Directory

```bash
# Restore file to last committed state
git restore <file>                 # Git 2.23+ (recommended)
git checkout -- <file>              # Legacy method

# Restore all files
git restore .                      # Git 2.23+ (recommended)
git checkout -- .                  # Legacy method
```

### Staging Area

```bash
# Unstage file
git restore --staged <file>
git reset HEAD <file>              # Traditional method

# Unstage all
git restore --staged .
git reset HEAD                     # Traditional method
```

### Commits

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit and staging
git reset --mixed HEAD~1
git reset HEAD~1                   # Default

# Undo last commit (discard changes!)
git reset --hard HEAD~1

# Revert commit (create new commit)
git revert <commit>
```

## Remote Operations

```bash
# Show remotes
git remote -v

# Add remote
git remote add <name> <url>

# Remove remote
git remote remove <name>

# Fetch changes
git fetch origin                   # Fetch all branches
git fetch origin main              # Fetch specific branch

# Pull changes
git pull                           # Fetch + merge
git pull --rebase                  # Fetch + rebase

# Push changes
git push origin main               # Push to main
git push -u origin feature         # Push and set upstream
git push --all origin              # Push all branches
git push --tags                    # Push tags
git push --force                   # Force push (use carefully!)
git push --force-with-lease        # Safer force push
```

## Stashing Changes

Save work in progress temporarily:

```bash
# Stash changes
git stash

# Stash with message
git stash push -m "work in progress"

# Stash including untracked files
git stash -u

# Stash all files (including ignored)
git stash -a

# List stashes
git stash list

# Apply stash
git stash pop                      # Apply and remove
git stash apply                    # Apply only

# Apply specific stash
git stash apply stash@{2}

# Drop stash
git stash drop
git stash drop stash@{2}

# Clear all stashes
git stash clear
```

## Searching

```bash
# Search in code
git grep "pattern"
git grep -n "pattern"              # With line numbers
git grep --count "pattern"         # Count matches

# Search in commits
git log --grep "pattern"           # Search messages
git log --author="John"            # Search by author
git log --since="1 month" --grep="fix"
```

## Team Configuration Best Practices

### For Team Projects

1. **Use consistent identity**
   ```bash
   git config --global user.name "Team Member Name"
   git config --global user.email "team@company.com"
   ```

2. **Set up useful aliases**
   ```bash
   git config --global alias.lg "log --graph --oneline --all"
   ```

3. **Configure rebase for pull**
   ```bash
   git config --global pull.rebase true
   ```

4. **Set up merge tools**
   ```bash
   git config --global merge.tool vscode
   git config --global mergetool.vscode.cmd 'code --wait $MERGED'
   ```

5. **Configure GPG signing (optional)**
   ```bash
   git config --global commit.gpgsign true
   git config --global gpg.program gpg2
   ```

## Checking Your Configuration

```bash
# Show all settings
git config --list

# Show specific setting
git config user.name

# Show where settings come from
git config --list --show-origin

# Verify Git version
git --version
```

## Quick Reference Card

| Command | Description |
|---------|-------------|
| `git init` | Initialize repository |
| `git clone <url>` | Clone repository |
| `git status` | Check status |
| `git add <file>` | Stage file |
| `git commit -m "msg"` | Commit changes |
| `git log --oneline` | Show history |
| `git branch` | List branches |
| `git switch -c <name>` | Create & switch branch (recommended) |
| `git merge <branch>` | Merge branch |
| `git pull` | Pull changes |
| `git push` | Push changes |
| `git restore <file>` | Restore file (recommended) |

## External Resources

### Official Git Cheat Sheet

::: tip Official Git Reference
Need a quick command reminder? Check out the **[Official Git Cheat Sheet](https://git-scm.com/cheat-sheet)** from git-scm.com for a comprehensive command reference.
:::

### Other Useful Resources

- [Git Documentation](https://git-scm.com/doc) - Complete Git manual
- [Git Book](https://git-scm.com/book) - Pro Git book (free online)
- [Git Glossary](https://git-scm.com/docs/gitglossary) - Git terminology reference

## Next Steps

- [Understanding Git Areas](./git-areas.md) - Learn how Git manages files
- [Branching Strategies](./branching-strategies.md) - Team workflows
- [Remote Operations](./remote-operations.md) - Working with remotes
