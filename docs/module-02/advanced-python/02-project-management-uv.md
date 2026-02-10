# Project Management with uv

**Master modern Python project management with uv - the fast, unified package manager**

## Overview

`uv` is a blazingly fast Python package and project manager written in Rust. It replaces multiple tools (pip, pip-tools, virtualenv, pyenv) with a single, unified interface that's up to 10-100x faster than traditional tools.

Think of `uv` as the "cargo for Python" - it handles everything from creating projects to managing dependencies, virtual environments, and Python versions.

## Why Use uv?

### Speed

`uv` is written in Rust and uses advanced caching strategies. Operations that take minutes with pip complete in seconds with uv.

```bash
# Traditional approach (slow)
pip install pandas numpy scikit-learn  # ~45 seconds

# With uv (fast)
uv pip install pandas numpy scikit-learn  # ~3 seconds
```

### Unified Interface

One tool for everything:

- **Package installation** (replaces pip)
- **Dependency locking** (replaces pip-tools)
- **Virtual environments** (replaces virtualenv, venv)
- **Python version management** (replaces pyenv)
- **Project scaffolding** (replaces poetry/hatch init)

### Reliability

`uv` creates reproducible environments with lock files that capture exact dependency versions, ensuring consistent builds across teams and environments.

### Modern Workflow

Built for modern Python development with first-class support for `pyproject.toml` and PEP 517/518 standards.

## Installation

### Install uv

**Windows (PowerShell):**

```powershell
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

**macOS/Linux:**

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**With pip (if you have Python already):**

```bash
pip install uv
```

### Verify Installation

```bash
uv --version
```

Expected output:

```
uv 0.1.x (or later)
```

### Update uv

```bash
uv self update
```

## Creating New Projects

### Initialize a New Project

```bash
uv init my-project
cd my-project
```

This creates:

```
my-project/
├── .python-version      # Python version specification
├── pyproject.toml       # Project configuration
├── README.md            # Project documentation
└── hello.py             # Sample Python file
```

### Project Structure

**`.python-version`** - Specifies Python version:

```
3.11
```

**`pyproject.toml`** - Project metadata and dependencies:

```toml
[project]
name = "my-project"
version = "0.1.0"
description = "Add your description here"
readme = "README.md"
requires-python = ">=3.11"
dependencies = []

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

## Understanding pyproject.toml

The `pyproject.toml` file is the heart of your Python project. It defines everything about your project using the standard PEP 518/621 format.

### Basic Structure

```toml
[project]
name = "my-mlops-project"
version = "0.1.0"
description = "MLOps training project"
readme = "README.md"
requires-python = ">=3.10"
authors = [
    {name = "Your Name", email = "you@example.com"}
]
dependencies = [
    "numpy>=1.24.0",
    "pandas>=2.0.0",
    "scikit-learn>=1.3.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "black>=23.7.0",
    "mypy>=1.5.0",
]

[project.scripts]
train = "my_mlops_project.train:main"
predict = "my_mlops_project.predict:main"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

### Key Sections

**`[project]`** - Core project metadata:
- `name`: Package name (used for distribution)
- `version`: Semantic version number
- `requires-python`: Minimum Python version
- `dependencies`: Required packages for runtime

**`[project.optional-dependencies]`** - Optional dependency groups:
- `dev`: Development tools (testing, linting)
- `docs`: Documentation generators
- `test`: Testing frameworks

**`[project.scripts]`** - Command-line entry points:
- Creates executable commands that run Python functions

## Understanding uv.lock

When you add dependencies, `uv` creates a `uv.lock` file that captures:

- **Exact versions** of all dependencies
- **Transitive dependencies** (dependencies of dependencies)
- **Hashes** for security verification
- **Platform-specific** requirements

**Benefits:**

- **Reproducibility**: Everyone gets identical dependency versions
- **Security**: Hashes prevent tampering
- **Speed**: uv resolves from lock file instead of querying PyPI

**Important:**

- ✅ **Commit `uv.lock` to git** for reproducible builds
- ✅ **Update lock file** when adding/removing dependencies
- ❌ **Don't edit manually** - let uv manage it

## Managing Dependencies

### Adding Packages

**Add a runtime dependency:**

```bash
uv add pandas
```

**Add multiple packages:**

```bash
uv add numpy pandas scikit-learn
```

**Add with version constraint:**

```bash
uv add "requests>=2.31.0"
uv add "fastapi>=0.100.0,<1.0.0"
```

### Adding Dev Dependencies

Development dependencies (testing, linting, etc.) should be separate from runtime dependencies:

```bash
uv add --dev pytest
uv add --dev black mypy ruff
```

This adds them to `[project.optional-dependencies.dev]` in `pyproject.toml`.

### Removing Packages

```bash
uv remove pandas
uv remove --dev pytest
```

### Installing Dependencies

**Install all dependencies from `pyproject.toml`:**

```bash
uv sync
```

**Install including dev dependencies:**

```bash
uv sync --dev
```

**Install only specific groups:**

```bash
uv sync --group dev
uv sync --group docs
```

### Updating Dependencies

**Update all packages to latest compatible versions:**

```bash
uv lock --upgrade
```

**Update specific package:**

```bash
uv lock --upgrade-package pandas
```

**See outdated packages:**

```bash
uv pip list --outdated
```

## Virtual Environment Management

`uv` automatically creates and manages virtual environments.

### Automatic Virtual Environments

When you run `uv sync` or `uv run`, uv automatically:
1. Creates a `.venv` directory if it doesn't exist
2. Installs Python if needed
3. Installs all dependencies
4. Activates the environment

### Manual Virtual Environment Operations

**Create a virtual environment explicitly:**

```bash
uv venv
```

**Create with specific Python version:**

```bash
uv venv --python 3.11
```

**Activate manually (if needed):**

```bash
# Windows
.venv\Scripts\activate

# macOS/Linux
source .venv/bin/activate
```

**Note:** With `uv run`, activation is handled automatically!

## Python Version Management

`uv` can install and manage multiple Python versions.

### Specify Python Version

**In `.python-version` file:**

```
3.11
```

**In `pyproject.toml`:**

```toml
[project]
requires-python = ">=3.10"
```

### Install Specific Python Version

```bash
uv python install 3.11
uv python install 3.12
```

### List Available Python Versions

```bash
uv python list
```

### Use Specific Python Version

**For current project:**

```bash
echo "3.11" > .python-version
```

**For single command:**

```bash
uv run --python 3.12 python script.py
```

## Running Scripts and Commands

### Using uv run

`uv run` automatically activates the virtual environment and runs commands:

```bash
# Run Python script
uv run python train.py

# Run Python module
uv run -m pytest

# Run installed command-line tool
uv run black .
```

### Defining Project Scripts

Add scripts to `pyproject.toml`:

```toml
[project.scripts]
train = "my_project.train:main"
predict = "my_project.predict:main"
serve = "my_project.api:start_server"
```

Run them with:

```bash
uv run train
uv run predict
uv run serve
```

### Task Runner Pattern

Create common development tasks:

```toml
[project.scripts]
test = "pytest:main"
lint = "ruff:main"
format = "black:main"
typecheck = "mypy:main"
```

Or use a task runner like `just` or `make` with uv:

```makefile
# Makefile
.PHONY: test
test:
	uv run pytest

.PHONY: lint
lint:
	uv run ruff check .
	uv run black --check .

.PHONY: format
format:
	uv run black .
```

## Workspace Configuration

For monorepos with multiple packages:

### Workspace Structure

```
my-workspace/
├── pyproject.toml          # Workspace root
├── packages/
│   ├── core/
│   │   └── pyproject.toml
│   ├── api/
│   │   └── pyproject.toml
│   └── cli/
│       └── pyproject.toml
```

### Root pyproject.toml

```toml
[tool.uv.workspace]
members = ["packages/*"]

[tool.uv]
dev-dependencies = [
    "pytest>=7.4.0",
    "ruff>=0.1.0",
]
```

### Benefits

- **Shared dependencies** across workspace
- **Consistent tooling** (same linter, formatter for all packages)
- **Cross-package development** without publishing

## Integration with CI/CD

### GitHub Actions

```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install uv
        run: curl -LsSf https://astral.sh/uv/install.sh | sh

      - name: Set up Python
        run: uv python install 3.11

      - name: Install dependencies
        run: uv sync --dev

      - name: Run tests
        run: uv run pytest

      - name: Run linter
        run: uv run ruff check .

      - name: Type check
        run: uv run mypy .
```

### GitLab CI

```yaml
test:
  image: python:3.11
  before_script:
    - curl -LsSf https://astral.sh/uv/install.sh | sh
    - export PATH="/root/.cargo/bin:$PATH"
  script:
    - uv sync --dev
    - uv run pytest
    - uv run ruff check .
```

### Docker

```dockerfile
FROM python:3.11-slim

# Install uv
RUN pip install uv

WORKDIR /app

# Copy project files
COPY pyproject.toml uv.lock ./
COPY src ./src

# Install dependencies
RUN uv sync --no-dev

# Run application
CMD ["uv", "run", "python", "-m", "my_app"]
```

## Common Workflows

### Starting a New Project

```bash
# Create project
uv init my-project
cd my-project

# Add dependencies
uv add fastapi uvicorn pydantic

# Add dev dependencies
uv add --dev pytest black mypy ruff

# Run your application
uv run python main.py
```

### Working on Existing Project

```bash
# Clone repository
git clone https://github.com/user/project
cd project

# Install all dependencies (including dev)
uv sync --dev

# Run tests
uv run pytest

# Format code
uv run black .
```

### Adding a New Feature

```bash
# Add required package
uv add redis

# Update lock file
uv lock

# Install updated dependencies
uv sync

# Commit changes
git add pyproject.toml uv.lock
git commit -m "Add Redis support"
```

## Comparison with Other Tools

### uv vs pip

| Feature | pip | uv |
|---------|-----|-----|
| Speed | Baseline | 10-100x faster |
| Lock files | Manual (pip-tools) | Built-in (uv.lock) |
| Resolution | Sequential | Parallel |
| Virtual envs | Manual (venv) | Automatic |

### uv vs Poetry

| Feature | Poetry | uv |
|---------|---------|-----|
| Speed | Moderate | Very fast |
| Python management | No | Yes (built-in) |
| Standards | Custom | PEP 517/621 |
| Learning curve | Moderate | Low |

### uv vs pipenv

| Feature | Pipenv | uv |
|---------|---------|-----|
| Speed | Slow | Very fast |
| Lock file | Pipfile.lock | uv.lock |
| Maintained | Less active | Very active |

## Best Practices

### Always Use Lock Files

```bash
# Commit both files to git
git add pyproject.toml uv.lock
git commit -m "Update dependencies"
```

### Separate Dev Dependencies

```toml
[project]
dependencies = [
    "fastapi",  # Runtime dependency
]

[project.optional-dependencies]
dev = [
    "pytest",   # Dev-only
    "black",    # Dev-only
]
```

### Pin Python Version

```
# .python-version
3.11
```

### Use Scripts for Common Tasks

```toml
[project.scripts]
dev = "uvicorn my_app:app --reload"
test = "pytest tests/"
lint = "ruff check ."
```

### Keep Dependencies Updated

```bash
# Regular dependency updates
uv lock --upgrade
uv sync
uv run pytest  # Ensure tests pass
```

## Troubleshooting

### Command Not Found After Install

**Issue:** `uv: command not found`

**Solution:** Add uv to PATH:

```bash
# macOS/Linux
export PATH="$HOME/.cargo/bin:$PATH"

# Windows (PowerShell)
$env:PATH += ";$HOME\.cargo\bin"
```

### Lock File Out of Sync

**Issue:** `uv.lock is out of sync with pyproject.toml`

**Solution:**

```bash
uv lock
uv sync
```

### Python Version Not Found

**Issue:** `Python 3.11 not found`

**Solution:**

```bash
uv python install 3.11
```

### Dependency Conflicts

**Issue:** `Unable to resolve dependencies`

**Solution:**

```bash
# Try upgrading all dependencies
uv lock --upgrade

# Or remove conflicting package and re-add
uv remove problematic-package
uv add problematic-package
```

## Summary

`uv` modernizes Python project management with:

- **Speed**: 10-100x faster than traditional tools
- **Simplicity**: One tool for packages, environments, and Python versions
- **Reliability**: Lock files for reproducible builds
- **Standards**: Built on modern Python standards (PEP 517/621)

It replaces pip, pip-tools, virtualenv, and pyenv with a single, fast, unified interface.

## Next Steps

Ready to practice? Head to the [uv Hands-On Lab](../../module-02/advanced-python/02-uv/README.md) to work through practical exercises.

## Additional Resources

- [Official uv documentation](https://github.com/astral-sh/uv)
- [PEP 621 - Storing project metadata in pyproject.toml](https://peps.python.org/pep-0621/)
- [Python Packaging User Guide](https://packaging.python.org/)
