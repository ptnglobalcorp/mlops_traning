# Repository Governance Models

**Strategies for organizing team contributions and repository ownership**

## Overview

Repository governance defines how teams collaborate, make decisions, and maintain code quality. Choosing the right model depends on team size, distribution, and organizational structure.

## Governance Models

### 1. Dispersed Contributors Model

**Also known as**: Open source model, distributed contribution

#### Characteristics

- Contributors distributed across organizations/locations
- Minimal coordination overhead
- Pull request driven workflow
- Community-based review process
- Asynchronous communication

#### When to Use

- ✅ Open source projects
- ✅ Cross-team collaboration
- ✅ External contributors
- ✅ Distributed teams
- ✅ Ecosystem libraries

#### Structure

```
Repository: company/shared-library
├── Maintainers: 2-3 core team members
├── Contributors: 50+ external developers
├── Governance: PR-based, meritocratic
└── Communication: GitHub issues, discussions
```

#### Workflow

```bash
# Contributor workflow
1. Fork repository
2. Create feature branch
3. Make changes
4. Create pull request
5. Address review feedback
6. Merge by maintainer
```

#### Example: Shared Library

```bash
# Company shared component library
Repository: company/ui-components

# Maintainers (Core Team)
- @alice (Tech Lead)
- @bob (Senior Dev)

# Contributors (Anyone)
- @charlie (Team A)
- @david (Team B)
- @external-contributor

# Process
# Anyone can fork, branch, and submit PR
# Maintainers review and merge
# CODEOWNERS ensures review from appropriate teams
```

#### CODEOWNERS Example

```
# .github/CODEOWNERS

# Core maintainers review everything
* @alice @bob

# Specific teams own components
/components/buttons/** @frontend-team-a
/components/forms/** @frontend-team-b
/utils/** @shared-utilities-team

# Anyone can contribute tests
**/test/** @alice @bob
```

#### Pros & Cons

| Pros | Cons |
|------|------|
| ✅ Scalable to many contributors | ❌ Slower review process |
| ✅ Encourages innovation | ❌ Inconsistent code style |
| ✅ Reduces bottleneck | ❌ Requires strong process |
| ✅ Community ownership | ❌ Coordination overhead |

### 2. Collocated Contributors Model

**Also known as**: Team ownership, single-team model

#### Characteristics

- Single team owns repository
- All members in same location/organization
- Direct push to main branch (sometimes)
- Synchronous communication possible
- Quick decision making

#### When to Use

- ✅ Small teams (2-8 people)
- ✅ Product-specific code
- ✅ Fast iteration needed
- ✅ Co-located teams
- ✅ Microservices

#### Structure

```
Repository: team-a/payment-service
├── Owners: Team A (all members)
├── Contributors: Team A only
├── Governance: Team consensus
└── Communication: Slack, in-person
```

#### Workflow

```bash
# Team workflow (flexible)
# Option 1: Direct push
git switch main
git pull
git switch -c feature/new-feature
# ... work ...
git push origin feature/new-feature
# Team reviews in person or Slack
# Merge to main

# Option 2: Shared branch
git switch main
git pull
# Direct push for small changes
git push origin main
```

#### Example: Team Microservice

```bash
# Single team owns their service
Repository: payments/api

# Team structure
Team: Payments Squad (5 people)
- @alice (Tech Lead)
- @bob, @charlie, @david, @eve (Devs)

# Access
- All team members: Write access
- Main branch: Protected but team can bypass
- PRs: Optional for small changes
- Reviews: In-person or Slack

# Workflow
1. Daily standup coordinates work
2. Pair programming for complex features
3. Direct to main for trivial changes
4. PRs for larger features
```

#### Pros & Cons

| Pros | Cons |
|------|------|
| ✅ Fast development | ❌ Doesn't scale well |
| ✅ Simple coordination | ❌ Knowledge silos |
| ✅ Team autonomy | ❌ Bus factor risk |
| ✅ Flexibility | ❌ Inconsistent practices |

### 3. Shared Maintenance Model

**Also known as**: Multi-team ownership, joint maintenance

#### Characteristics

- Multiple teams share ownership
- Clear area boundaries
- Rotating maintainers
- Cross-team coordination
- Shared on-call responsibilities

#### When to Use

- ✅ Large monorepositories
- ✅ Platform teams
- ✅ Shared infrastructure
- ✅ Critical systems
- ✅ Cross-functional features

#### Structure

```
Repository: company/platform
├── Owners: Multiple teams
│   ├── Team A: Frontend
│   ├── Team B: Backend
│   └── Team C: DevOps
├── Maintainers: Rotating from each team
├── Governance: Cross-team council
└── Communication: Slack, regular meetings
```

#### Workflow

```bash
# Shared maintenance workflow
# 1. Area-specific changes go to respective team
# 2. Cross-area changes require coordination
# 3. Monthly maintainer rotation
# 4. Weekly sync meeting

# Example change process
1. Identify affected areas
2. Create PR with appropriate reviewers
3. Required approval from all area owners
4. Sync meeting discusses conflicts
5. Maintainer merges after approvals
```

#### Example: Platform Repository

```bash
# Large platform repository
Repository: company/platform

# Team ownership areas
/frontend/** @team-frontend-maintainer
/backend/** @team-backend-maintainer
/infrastructure/** @team-devops-maintainer

# Maintainer rotation (monthly)
January:
- Frontend: @alice
- Backend: @bob
- DevOps: @charlie

February:
- Frontend: @david
- Backend: @eve
- DevOps: @frank

# Cross-team changes
# Require approval from all current maintainers
# Discussed in weekly platform sync
```

#### CODEOWNERS Example

```
# .github/CODEOWNERS

# Team-specific areas
/frontend/** @team-frontend @frontend-maintainer
/backend/** @team-backend @backend-maintainer
/infrastructure/** @team-devops @devops-maintainer

# Shared areas require all maintainers
/README.md @frontend-maintainer @backend-maintainer @devops-maintainer
/docs/** @frontend-maintainer @backend-maintainer @devops-maintainer

# Cross-cutting concerns
/config/** @frontend-maintainer @backend-maintainer @devops-maintainer
/scripts/** @devops-maintainer

# Current maintainer (rotates)
# Update monthly via maintainer script
* @current-maintainer-frontend @current-maintainer-backend @current-maintainer-devops
```

#### Pros & Cons

| Pros | Cons |
|------|------|
| ✅ Shared responsibility | ❌ Coordination overhead |
| ✅ Knowledge sharing | ❌ Slower decisions |
| ✅ Reduced bus factor | ❌ More meetings |
| ✅ Cross-team visibility | ❌ Potential conflicts |

## Choosing the Right Model

### Decision Framework

```
Start here:
    |
    v
Is the code used by multiple teams?
    |
    +-- Yes --> Dispersed Contributors (if external)
    |          Shared Maintenance (if internal)
    |
    +-- No --> Is the team co-located?
               |
               +-- Yes --> Collocated Contributors
               |
               +-- No --> Dispersed Contributors
```

### Comparison Matrix

| Aspect | Dispersed | Collocated | Shared Maintenance |
|--------|-----------|------------|-------------------|
| **Team Size** | Unlimited | 2-8 | Multiple teams |
| **Location** | Anywhere | Same location | Multiple locations |
| **Contributors** | Anyone | Team only | Designated teams |
| **Speed** | Slow | Fast | Medium |
| **Coordination** | Low | Low | High |
| **Scalability** | High | Low | Medium |
| **Bus Factor** | High | Low | High |
| **Decision Making** | Meritocratic | Autocratic | Democratic |

## Hybrid Models

### 1. Tiered Governance

```bash
# Different rules for different areas

# Core: Shared maintenance (strict)
/src/core/** @all-teams
# Requires all team approvals

# Platform: Dispersed contributors (open)
/platform/** @any-contributor
# Anyone can contribute, maintainers review

# Team-specific: Collocated (per team)
/team-a/** @team-a
/team-b/** @team-b
# Teams own their areas
```

### 2. Component-Based Model

```bash
# Repository organized by components

Repository: company/monorepo

# Components have different models
/components/public/**  -> Dispersed (open source)
/components/internal/** -> Shared maintenance (multiple teams)
/components/team-a/**   -> Collocated (single team)
```

### 3. Layered Model

```bash
# Layers with different governance

/interface/** -> Dispersed (anyone can propose)
/business/**  -> Shared maintenance (feature teams)
/infrastructure/** -> Shared maintenance (platform team)
/data/**      -> Collocated (data team only)
```

## Implementation Examples

### Example 1: Microservices Architecture

```bash
# Each service: Collocated model
/payment-service/  -> Payments team
/shipping-service/ -> Logistics team
/user-service/     -> Auth team

# Shared libraries: Dispersed model
/common/utils/     -> Anyone contributes
/common/ui-kit/    -> Anyone contributes

# Platform: Shared maintenance
/infrastructure/    -> DevOps + all teams
/monitoring/        -> SRE + all teams
```

### Example 2: Monorepo Organization

```bash
# Company monorepo
/apps/
  /app-a/  -> Collocated (Team A)
  /app-b/  -> Collocated (Team B)
  /app-c/  -> Collocated (Team C)

/packages/
  /shared-ui/    -> Dispersed (all frontend teams)
  /api-client/   -> Dispersed (all backend teams)
  /utils/        -> Shared maintenance (tech council)

/tools/
  /build/        -> Shared maintenance (DevOps)
  /deploy/       -> Shared maintenance (DevOps)
  /testing/      -> Dispersed (anyone)
```

### Example 3: Open Source with Internal Team

```bash
# Public repository
Repository: company/open-source-lib

# Public contributors: Dispersed model
- Anyone can fork and PR
- Community review
- Maintainer approval required

# Internal team: Faster process
- Direct push to non-release branches
- Internal PRs reviewed internally
- Maintainers merge approved PRs

# Branch protection
main: Protected (maintainers only)
develop: Open to internal team
feature/*: Open to all contributors
```

## Governance Processes

### For Dispersed Contributors

```markdown
## Contribution Process

1. **Fork** the repository
2. **Create branch** with descriptive name
3. **Make changes** following style guide
4. **Add tests** for new functionality
5. **Update documentation**
6. **Create pull request** with template
7. **Address CI failures**
8. **Address review feedback**
9. **Wait for approval** from maintainer
10. **Merged by maintainer**

## Review Timeline
- Small changes: 1-2 days
- Medium changes: 3-5 days
- Large changes: 1-2 weeks

## Maintainer Responsibilities
- Review PRs within 48 hours
- Run full test suite before merge
- Update CHANGELOG
- Tag releases
```

### For Collocated Contributors

```markdown
## Team Workflow

1. **Daily standup** coordinates work
2. **Create branch** for each task
3. **Pair programming** for complex features
4. **Code review** via PR or in-person
5. **Merge to main** after review
6. **Deploy** when ready

## Small Changes
- Can push directly to main
- Must notify team in Slack
- Review next morning

## Large Changes
- Use PR process
- Team reviews together
- Merge after consensus

## Decision Making
- Technical disagreements: Tech lead decides
- Product decisions: Product owner decides
- Architecture changes: Team consensus
```

### For Shared Maintenance

```markdown
## Cross-Team Process

1. **Weekly sync** meeting
2. **Monthly maintainer** rotation
3. **Area-specific changes**: Team decides
4. **Cross-area changes**: All affected teams review
5. **Breaking changes**: Requires all teams
6. **Deprecation**: 3-month notice required

## Change Categories

### Green Changes (Single team)
- Affects only team's area
- Team can approve and merge
- Example: Bug fix in team's module

### Yellow Changes (Multiple teams)
- Affects multiple areas
- Requires all team approvals
- Discussed in weekly sync
- Example: API change between modules

### Red Changes (All teams)
- Affects platform/infrastructure
- Requires unanimous approval
- Requires planning meeting
- Example: Database migration, framework upgrade

## Monthly Rotation
- Week 1: Handover meeting
- Week 2-3: New maintainers active
- Week 4: Retiring maintainers available
```

## Communication Strategies

### Dispersed Model

- **Async first**: GitHub issues, PRs, discussions
- **Public roadmap**: Visible to all contributors
- **RFC process**: For major changes
- **Community meetings**: Monthly video call
- **Documentation**: Comprehensive and up-to-date

### Collocated Model

- **Sync communication**: In-person, Slack
- **Daily standup**: Coordinate work
- **Pair programming**: Knowledge sharing
- **Team chat**: Quick decisions
- **Whiteboard sessions**: Architecture discussions

### Shared Maintenance Model

- **Weekly sync**: All maintainers
- **Monthly rotation**: Handover process
- **Slack channels**: Per-team and shared
- **Documentation**: Runbooks, playbooks
- **Escalation path**: Clear decision makers

## CODEOWNERS Examples by Model

### Dispersed Contributors

```
# Open source library
* @core-maintainers
/docs/** @doc-team
**/test/** @qa-team

# Anyone can propose
# Maintainers review and merge
```

### Collocated Contributors

```
# Single team
* @team-a

# Or even simpler - no CODEOWNERS
# Team handles everything informally
```

### Shared Maintenance

```
# Multiple teams
/frontend/** @team-frontend @frontend-maintainer
/backend/** @team-backend @backend-maintainer
/infrastructure/** @team-devops @devops-maintainer

# Cross-cutting
/README.md @all-maintainers
/config/** @all-maintainers

# Current maintainers (rotating)
* @current-maintainer-fe @current-maintainer-be @current-maintainer-de
```

## Transitioning Between Models

### From Collocated to Dispersed

```bash
# Phase 1: Prepare (1 month)
# - Add CODEOWNERS
# - Set up branch protection
# - Document contribution process
# - Create PR templates

# Phase 2: Pilot (1 month)
# - Allow external contributors
# - Maintain current team process
# - Gather feedback

# Phase 3: Transition (1 month)
# - Implement full PR workflow
# - Train new contributors
# - Establish review SLA

# Phase 4: Full dispersed (ongoing)
# - Open to all contributors
# - Community-driven development
```

### From Dispersed to Shared Maintenance

```bash
# Phase 1: Identify areas (2 weeks)
# - Map repository sections
# - Identify owning teams
# - Define boundaries

# Phase 2: Establish maintainers (1 month)
# - Select initial maintainers
# - Set up rotation schedule
# - Create escalation path

# Phase 3: Process update (1 month)
# - Implement area-specific rules
# - Update CODEOWNERS
# - Train teams

# Phase 4: Full shared maintenance (ongoing)
# - Rotating maintainers
# - Cross-team sync meetings
# - Continuous improvement
```

## Best Practices

### For Dispersed Contributors

1. **Clear contribution guide** - How to contribute
2. **Automated checks** - CI must pass
3. **Response SLA** - Review within 48 hours
4. **Public roadmap** - Show direction
5. **Welcome contributors** - Be friendly
6. **Recognize contributions** - Credit contributors
7. **Document everything** - Reduce questions

### For Collocated Contributors

1. **Daily communication** - Stay in sync
2. **Pair programming** - Share knowledge
3. **Code reviews** - Even if quick
4. **Automated testing** - Fast feedback
5. **Simple process** - Don't overcomplicate
6. **Team agreements** - How we work
7. **Celebrate together** - Build morale

### For Shared Maintenance

1. **Clear boundaries** - Who owns what
2. **Regular sync** - Weekly meetings
3. **Rotate maintainers** - Share load
4. **Document processes** - Runbooks
5. **Escalation path** - Clear decisions
6. **Be respectful** - Others' areas
7. **Communicate early** - Before breaking changes

## Common Pitfalls

### Dispersed Model

❌ **Ignoring contributors** - Unreviewed PRs
❌ **Inconsistent standards** - Code style varies
❌ **Slow reviews** - Contributors lose interest
❌ **Poor documentation** - Same questions repeatedly
❌ **Toxic community** - Driving contributors away

### Collocated Model

❌ **Key person risk** - Only one knows area
❌ **No reviews** - Poor code quality
❌ **Hero culture** - Burnout risk
❌ **Information silo** - Team doesn't share
❌ **No documentation** - Knowledge lost

### Shared Maintenance Model

❌ **Unclear ownership** - "Not my job"
❌ **Too many meetings** - Wasting time
❌ **Slow decisions** - Waiting for consensus
❌ **Boundary conflicts** - Who owns this?
❌ **Uneven load** - Some teams overworked

## Monitoring and Metrics

### Dispersed Model

```bash
# Track these metrics:
- Number of contributors
- PRs open vs merged
- Average review time
- Contributor retention
- PR abandonment rate
- Time to first response
```

### Collocated Model

```bash
# Track these metrics:
- Deployment frequency
- Lead time for changes
- Bug rate
- Team velocity
- Knowledge coverage
- Bus factor
```

### Shared Maintenance Model

```bash
# Track these metrics:
- Cross-team PRs
- Time to cross-team merge
- Meeting effectiveness
- Maintainer rotation
- Conflict rate
- Overall satisfaction
```

## Quick Reference

| Model | Best For | Team Size | Coordination | Speed |
|-------|----------|-----------|--------------|-------|
| **Dispersed** | Open source, distributed | Unlimited | Low | Slow |
| **Collocated** | Small teams, products | 2-8 | Low | Fast |
| **Shared** | Platform, critical systems | Multiple teams | High | Medium |

## Next Steps

- [Branching Strategies](./branching-strategies.md) - Workflow selection
- [Pull Requests](./pull-requests.md) - Code review process
- [Team Conventions](./team-conventions.md) - Team standards
- [Remote Operations](./remote-operations.md) - Working with remotes
