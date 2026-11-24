---
title: "A Short Guide to uv for Data Science"
subtitle: "Managing Python, packages, and Jupyter with one tool"
author: "Dustin Michels"
date: |
  | November 2026
  | For: Urban Analytics (Shan Jiang, Tufts University)
---

[uv](https://docs.astral.sh/uv/) is a single, fast tool that handles Python versions, virtual environments, packages, and command-line tools. Part 1 walks through setting up a project. Part 2 explains where uv fits alongside pip and conda. Part 3 lists more commands and where to learn more.

# Part 1: How to use uv

## Install uv

```bash
# macOS / Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows (PowerShell)
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

Or use Homebrew (`brew install uv`) or WinGet (`winget install --id=astral-sh.uv -e`). You don't need Python installed first. Open a new terminal, then check that it worked:

```bash
uv --version
```

## Create a project and add packages

```bash
uv init --no-package my-project
cd my-project
uv add pandas geopandas matplotlib
```

uv downloads Python if needed, creates a virtual environment in `.venv/`, installs the packages, and records exact versions in `uv.lock`.

GeoPandas and its geospatial libraries (shapely, pyproj, pyogrio) come as prebuilt wheels on PyPI, with GDAL and PROJ included. You don't need conda or a system install.

## Project files

`uv init --no-package my-project` creates:

```text
my-project/
├── .gitignore
├── .python-version         # Python version for this project
├── README.md
├── main.py                 # a starter script
└── pyproject.toml          # project metadata and dependencies
```

After the first `uv add`, you'll also have `.venv/` (the environment) and `uv.lock` (exact versions of every package).

`--no-package` keeps the layout flat, which suits an analysis project. Two other options:

1. `uv init my-project` (no flag) creates a `src/my_project/` package instead of `main.py`. This is useful if you're building a library to install or publish.
1. `uv init --bare` creates only a `pyproject.toml`. It's handy for adding uv to a folder that already has your code.

Commit `pyproject.toml`, `uv.lock`, and `.python-version` to git. Don't commit `.venv/`; `uv init` already adds it to `.gitignore`.

> **A note on virtual environments.** uv mostly hides virtual environments, so this guide doesn't spend much time on them. The model is: **one project = one folder = one `.venv/`**. The project folder takes the place of the environment name. `uv add`, `uv sync`, and `uv run` create and update `.venv/` for you, so you never run `uv venv` yourself. To "switch environments," you `cd` into another project.

## Run a script

`uv run` runs a command inside the project environment. You don't have to activate anything.

```bash
uv run main.py
uv run python            # interactive Python shell
```

If you prefer activating the environment the usual way:

```bash
source .venv/bin/activate      # macOS / Linux
.venv\Scripts\activate         # Windows
```

## Open a notebook

Pick **one** of these.

**Option A: JupyterLab in the browser**

```bash
uv add --dev jupyterlab
uv run jupyter lab
```

In JupyterLab, create a new notebook with the default **Python 3** kernel. If you add a package while JupyterLab is running, restart the kernel to pick it up.

**Option B: VS Code**

```bash
uv add --dev ipykernel
code .
```

Install the **Python** and **Jupyter** extensions if you haven't already. Create `analysis.ipynb`, click **Select Kernel** (top right), and choose the `.venv` environment.

`--dev` marks packages you use only while working, like JupyterLab or ipykernel. Your code doesn't import them, and they're kept separate in `pyproject.toml`.

## Share and reproduce

When a collaborator clones your repo, they run:

```bash
uv sync
```

`uv sync` installs the exact package versions recorded in `uv.lock`, on any operating system. Everyone gets the same environment.

# Part 2: Why use uv

## What it is

uv is an open-source tool from [Astral](https://astral.sh), the company that also makes the Ruff linter. It first came out in 2024. It's written in Rust and ships as one binary with no dependencies, so it doesn't need Python in order to install Python.

## The problem it solves

A typical Python setup used to involve several separate tools:

- **pyenv** or the python.org installer for Python itself
- **venv** / **virtualenv** for isolated environments
- **pip** to install packages
- **pip-tools** to pin exact versions in a lockfile
- **pipx** for command-line tools
- **conda** for anything with hard-to-build compiled dependencies

uv covers almost all of these jobs with one consistent interface. It's also much faster: usually 10 to 100 times faster than pip, and far faster than conda's solver. Much of that speed comes from a global cache, so a package you've downloaded once is reused by every project.

## Comparison

| Tool          | Python versions | Environments | Lockfile   | Non-Python libraries | Speed     |
| ------------- | --------------- | ------------ | ---------- | -------------------- | --------- |
| **uv**        | Yes             | Yes          | Yes        | Wheels only          | Very fast |
| pip + venv    | No              | Yes          | No         | Wheels only          | Slow      |
| conda / mamba | Yes             | Yes          | Via add-on | Yes                  | Moderate  |
| pixi          | Yes             | Yes          | Yes        | Yes                  | Fast      |
| Poetry        | No              | Yes          | Yes        | Wheels only          | Moderate  |
| pyenv         | Yes             | Plugin       | No         | No                   | n/a       |

## uv vs. conda

For years, conda was the default for data science because packages like GDAL were hard to install with pip. That's mostly no longer true. Today, the common scientific stack ships as prebuilt wheels on PyPI, including NumPy, pandas, scikit-learn, GeoPandas, rasterio, and PyTorch.

Stick with **conda** or **[pixi](https://pixi.sh)** when you need things that aren't Python packages on PyPI. Examples include R, specific CUDA toolkits, or unusual geospatial or HPC libraries. pixi is a fast, project-based conda tool, and it uses uv internally for PyPI packages.

## Standards

uv follows the standard Python packaging specifications. Dependencies are declared in a regular `pyproject.toml` (PEP 621), and inline script metadata follows PEP 723. If you stop using uv, your project metadata still works with other tools. The `uv.lock` file is specific to uv, but you can export it with `uv export --format requirements-txt`.

# Part 3: More commands

## Packages

```bash
uv add "pandas>=2.2"               # with a version constraint
uv remove matplotlib               # remove a package
uv tree                            # show the dependency tree
uv lock --upgrade                  # upgrade everything
uv lock --upgrade-package pandas   # upgrade one package
```

More: [Working on projects](https://docs.astral.sh/uv/guides/projects/), [Managing dependencies](https://docs.astral.sh/uv/concepts/projects/dependencies/)

## Python versions

```bash
uv python list             # versions available and installed
uv python install 3.13     # install a version
uv python pin 3.12         # set this project's version (.python-version)
```

More: [Installing Python](https://docs.astral.sh/uv/guides/install-python/)

## Single-file scripts

uv can record dependencies inside a script itself, so anyone with uv can run it without setting up a project:

```bash
uv add --script clean_data.py pandas
uv run clean_data.py
```

More: [Running scripts](https://docs.astral.sh/uv/guides/scripts/)

## Command-line tools

For tools you use across projects, like the `ruff` linter:

```bash
uvx ruff check .           # run once, in a temporary environment
uv tool install ruff       # install permanently and put it on your PATH
uvx --with pandas jupyter lab   # throwaway notebook, no project needed
```

`uvx` is short for `uv tool run`. More: [Using tools](https://docs.astral.sh/uv/guides/tools/)

## Coming from pip or conda

```bash
uv add -r requirements.txt     # import an existing requirements file
uv pip install pandas          # pip-compatible interface
```

uv can't read a conda `environment.yml` directly. Copy the package names into `uv add`; most data science packages are on PyPI under the same names. More: [The pip interface](https://docs.astral.sh/uv/pip/)

## Updating uv

```bash
uv self update
```

Use `brew upgrade uv` or `winget upgrade astral-sh.uv` instead if you installed it that way.

## Learn more

- uv documentation: <https://docs.astral.sh/uv/>
- Using uv with Jupyter: <https://docs.astral.sh/uv/guides/integration/jupyter/>
- Command reference: <https://docs.astral.sh/uv/reference/cli/>
