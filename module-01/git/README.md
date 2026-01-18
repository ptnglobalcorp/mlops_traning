# Git for Teams - Practical Examples

**Hands-on practice labs for Git team collaboration**

## Overview

This directory contains practical examples and exercises for practicing Git workflows used in team development.

## Prerequisites

- Git installed locally
- Basic understanding of Git commands
- Completed [Git documentation](../../docs/module-01/git/)

## Lab Structure

```
module-01/git/
├── README.md                    # This file
├── examples/                    # Example configurations and workflows
│   ├── .gitmessage             # Commit message template
│   ├── .gitignore              # Ignore patterns
│   ├── .gitattributes          # Git attributes
│   └── branch-protection.yml   # Branch protection rules
└── exercises/                  # Practice exercises
    ├── 01-basic-workflow.md    # Basic branching exercise
    ├── 02-merge-conflicts.md   # Conflict resolution exercise
    ├── 03-pull-requests.md     # PR workflow exercise
    └── 04-team-collaboration.md # Team collaboration exercise
```

## Getting Started

### 1. Clone and Setup

```bash
# If you haven't already, navigate to module-01
cd module-01/git

# Create a practice repository
mkdir git-practice
cd git-practice
git init
```

### 2. Configure Git

```bash
# Set your identity
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Set up aliases
git config alias.co checkout
git config alias.br branch
git config alias.ci commit
git config alias.st status
```

### 3. Copy Configuration Files

```bash
# Copy example configurations
cp ../examples/.gitmessage .gitmessage
cp ../examples/.gitignore .gitignore
cp ../examples/.gitattributes .gitattributes

# Configure Git to use commit template
git config commit.template .gitmessage
```

## Practice Exercises

### Exercise 1: Basic Workflow

```bash
# Create feature branch
git checkout -b feature/hello-world

# Create a file
echo "print('Hello, World!')" > hello.py

# Stage and commit
git add hello.py
git commit -m "feat: add hello world script"

# Create another file
echo "# Git Practice" > README.md

# Stage and commit
git add README.md
git commit -m "docs: add project readme"

# View log
git log --oneline
```

**Expected Output:**
```
abc1234 docs: add project readme
def5678 feat: add hello world script
```

### Exercise 2: Branching and Merging

```bash
# Start from main
git checkout main

# Create feature branch
git checkout -b feature/calculator

# Create calculator
cat > calculator.py << 'EOF'
def add(a, b):
    return a + b

def subtract(a, b):
    return a - b
EOF

git add calculator.py
git commit -m "feat: add calculator with add and subtract"

# Create another feature branch
git checkout main
git checkout -b feature/multiplier

# Add multiply function
cat > calculator.py << 'EOF'
def multiply(a, b):
    return a * b
EOF

git add calculator.py
git commit -m "feat: add multiply function"

# Merge multiplier to main
git checkout main
git merge feature/multiplier

# Merge calculator (conflict!)
git merge feature/calculator

# Resolve conflict
cat > calculator.py << 'EOF'
def add(a, b):
    return a + b

def subtract(a, b):
    return a - b

def multiply(a, b):
    return a * b
EOF

git add calculator.py
git commit -m "Merge feature/calculator - resolved conflicts"

# Clean up
git branch -d feature/calculator
git branch -d feature/multiplier
```

### Exercise 3: Remote Operations

```bash
# Create a bare repository to act as remote
cd ..
git init --bare remote-repo.git
cd git-practice

# Add remote
git remote add origin ../remote-repo.git

# Push main branch
git push -u origin main

# Create and push feature branch
git checkout -b feature/division
echo "def divide(a, b): return a / b" >> calculator.py
git add calculator.py
git commit -m "feat: add divide function"
git push -u origin feature/division

# Simulate another developer
cd ..
mkdir another-dev
cd another-dev
git clone ../remote-repo.git
cd remote-repo

# Create feature branch
git checkout -b feature/modulo
echo "def modulo(a, b): return a % b" >> calculator.py
git add calculator.py
git commit -m "feat: add modulo function"
git push -u origin feature/modulo

# Return to original repository
cd ../git-practice

# Pull changes
git fetch origin
git log --oneline --graph --all

# Merge modulo feature
git checkout main
git merge origin/modulo
git push origin main
```

### Exercise 4: Interactive Rebase

```bash
# Create several commits
git checkout -b feature/rebase-practice

echo "print('Line 1')" >> script.py
git add script.py
git commit -m "wip: add line 1"

echo "print('Line 2')" >> script.py
git add script.py
git commit -m "wip: add line 2"

echo "print('Line 3')" >> script.py
git add script.py
git commit -m "feat: add line 3"

echo "print('Line 4')" >> script.py
git add script.py
git commit -m "wip: add line 4"

# View commits
git log --oneline

# Interactive rebase to clean up
git rebase -i HEAD~4

# In editor, change:
# pick abc1234 wip: add line 1    -> fixup abc1234 wip: add line 1
# pick def5678 wip: add line 2    -> fixup def5678 wip: add line 2
# pick ghi9012 feat: add line 3   -> keep as is
# pick jkl3456 wip: add line 4    -> fixup jkl3456 wip: add line 4

# View cleaned up history
git log --oneline
```

## Common Git Commands Reference

### Configuration

```bash
# Set user info
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# Set editor
git config --global core.editor "code --wait"

# Set aliases
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
```

### Branching

```bash
# List branches
git branch
git branch -r          # Remote branches
git branch -a          # All branches

# Create branch
git branch <name>

# Switch branch
git checkout <name>
git switch <name>      # Git 2.23+

# Create and switch
git checkout -b <name>
git switch -c <name>   # Git 2.23+

# Delete branch
git branch -d <name>
git branch -D <name>   # Force delete

# Rename branch
git branch -m <old> <new>
```

### Merging

```bash
# Merge branch
git merge <branch>

# Merge with no fast-forward
git merge --no-ff <branch>

# Abort merge
git merge --abort

# Resolve conflicts
# 1. Edit conflicted files
# 2. git add <files>
# 3. git commit
```

### Rebasing

```bash
# Rebase onto main
git rebase main

# Interactive rebase
git rebase -i HEAD~3

# Continue rebase
git rebase --continue

# Abort rebase
git rebase --abort

# Skip commit
git rebase --skip
```

### Remote Operations

```bash
# Add remote
git remote add <name> <url>

# Show remotes
git remote -v

# Fetch changes
git fetch origin
git fetch --all

# Pull changes
git pull
git pull --rebase

# Push changes
git push
git push -u origin <branch>

# Force push (careful!)
git push --force-with-lease
```

### Stashing

```bash
# Stash changes
git stash
git stash push -m "message"

# List stashes
git stash list

# Apply stash
git stash pop
git stash apply

# Drop stash
git stash drop
```

### Viewing History

```bash
# Show log
git log
git log --oneline
git log --graph
git log --graph --oneline --all

# Show diff
git diff
git diff --staged
git diff HEAD

# Show file at commit
git show <commit>:<file>
```

## Troubleshooting

### Undo Changes

```bash
# Undo working directory changes
git restore <file>
git checkout -- <file>

# Unstage file
git restore --staged <file>
git reset HEAD <file>

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Revert commit
git revert <commit>
```

### Recover Lost Work

```bash
# View reflog
git reflog

# Restore lost commit
git checkout <hash>
git checkout -b recover-branch
```

## Next Steps

1. Complete all practice exercises
2. Review [Git documentation](../../docs/module-01/git/)
3. Practice with real projects
4. Learn [branching strategies](../../docs/module-01/git/branching-strategies.md)

## Additional Resources

- [Git Documentation](https://git-scm.com/doc)
- [GitHub Flow Guide](https://guides.github.com/introduction/flow/)
- [Git Flow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)

## Tips for Success

1. **Start small**: Practice with simple repositories
2. **Commit often**: Small, focused commits are easier to manage
3. **Pull before push**: Always sync before pushing
4. **Read commit messages**: Clear messages help everyone
5. **Use branches**: Experiment safely with feature branches
6. **Don't panic**: Most operations can be undone

Happy practicing! 🚀
