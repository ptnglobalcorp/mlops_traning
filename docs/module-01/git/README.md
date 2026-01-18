# Git for Teams

**Collaborative version control for software development teams**

## Overview

This section covers Git best practices for team collaboration, including branching strategies, workflows, and conventions that enable multiple developers to work together efficiently on the same codebase.

## Learning Objectives

By the end of this section, you will be able to:
- Understand Git's four working areas and how files move between them
- Configure Git for team collaboration
- Implement effective branching strategies
- Handle merge conflicts and remote operations
- Use pull requests for code review
- Follow team collaboration best practices

## Prerequisites

- Basic understanding of Git commands
- Git installed on your local machine
- A GitHub/GitLab/Bitbucket account

## Study Path

### 1. Git Fundamentals for Teams
- [Git Basics & Configuration](./git-basics.md) - Setup and essential commands
- [Understanding Git Areas](./git-areas.md) - Working, staging, and repository areas

### 2. Team Organization & Governance
- [Repository Governance](./repository-governance.md) - Team contribution models and ownership strategies
  - Dispersed Contributors (open source model)
  - Collocated Contributors (team ownership)
  - Shared Maintenance (multi-team ownership)

### 3. Branching Strategies
- [Branching Strategies Overview](./branching-strategies.md) - Compare different workflows
- [Trunk-Based Development](./trunk-based.md) - Continuous integration approach
- [Git Flow](./git-flow.md) - Structured release management
- [GitHub Flow](./github-flow.md) - Simplified deployment workflow

### 4. Team Collaboration
- [Remote Operations](./remote-operations.md) - Fetch, pull, push, and synchronization
- [Pull Requests & Code Review](./pull-requests.md) - Collaboration and review process
- [Merge Conflicts](./merge-conflicts.md) - Resolving conflicts effectively
- [Team Conventions](./team-conventions.md) - Commit messages, .gitignore, and best practices

### 5. Practical Examples
- [Git Workflow Examples](./workflow-examples.md) - Real-world workflow scenarios

## Quick Reference

### Essential Commands

```bash
# Configuration
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Branching
git branch                    # List branches
git branch <name>             # Create branch
git checkout -b <name>        # Create and switch branch
git merge <branch>            # Merge branch

# Remote Operations
git remote -v                 # List remotes
git fetch origin              # Fetch changes
git pull origin main          # Pull and merge
git push origin feature       # Push branch

# Collaboration
git stash                     # Stash changes
git stash pop                 # Apply stashed changes
git rebase main               # Rebase onto main
git cherry-pick <commit>      # Apply specific commit
```

## Git Workflow Diagram

```
Working Directory → Staging Area → Local Repository → Remote Repository
        |                 |                   |                    |
    git add          git commit          git push            git pull
        |                 |                   |                    |
        ←─────────────────←───────────────────←────────────────────←
                           git pull
```

## Best Practices Summary

1. **Commit Often**: Small, focused commits are easier to review and revert
2. **Write Clear Messages**: Use imperative mood and describe why, not what
3. **Pull Before Push**: Always sync with remote before pushing changes
4. **Review Code**: Use pull requests for all non-trivial changes
5. **Resolve Conflicts Locally**: Fix merge conflicts on your machine
6. **Protect Main Branch**: Use branch protection rules
7. **Use .gitignore**: Exclude generated files and sensitive data
8. **Tag Releases**: Mark important milestones with version tags

## Common Team Scenarios

### Scenario 1: Feature Development
```bash
git switch -c feature/user-auth
# Make changes
git add .
git commit -m "feat: implement user authentication"
git push origin feature/user-auth
# Create pull request for review
```

### Scenario 2: Bug Fix
```bash
git switch -c bugfix/login-error
# Fix bug
git add .
git commit -m "fix: resolve login validation error"
git push origin bugfix/login-error
# Request urgent review
```

### Scenario 3: Hotfix in Production
```bash
git switch main
git pull origin main
git switch -c hotfix/critical-bug
# Quick fix
git add .
git commit -m "hotfix: patch security vulnerability"
git push origin hotfix/critical-bug
# Merge directly to main and production
```

## Additional Resources

### External References
- [Git Documentation](https://git-scm.com/doc)
- [GitHub Flow Guide](https://guides.github.com/introduction/flow/)
- [Git Flow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
- [Trunk-Based Development](https://trunkbaseddevelopment.com/)

### Internal Documentation
- [Complete Study Guide](../../README.md) - Overall training navigation
- [Module 1 Labs](../../../module-01/) - Hands-on practice folders

## Next Steps

After completing this section:
1. Practice branching strategies with team scenarios
2. Set up branch protection rules in your repository
3. Establish team conventions for commit messages
4. Implement code review processes
5. Return to [Module 1 Overview](../README.md)

---

**Practice Labs:** [../../../module-01/git/](../../../module-01/git/)
