---
title: "A Short Guide to uv for Data Science"
subtitle: "Managing Python, packages, and Jupyter with one tool"
toc-title: "Contents"
---

[uv](https://docs.astral.sh/uv/) is a single, fast tool that handles Python versions, virtual environments, packages, and command-line tools. This guide starts with a quick, concrete example: a new mapping project with GeoPandas, seaborn, and matplotlib. Then it covers each step in more detail. It ends with [background](#background-why-uv) on where uv fits alongside pip, conda, and other tools.

# Quick start: a new data science project

## 1. Install uv

```bash
# macOS / Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows (PowerShell)
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

Open a new terminal afterwards. You don't need Python installed first. See [Installing uv](#installing-uv) for Homebrew, WinGet, and updates.

## 2. Create a project and add packages

```bash
uv init world-map
cd world-map
uv add geopandas seaborn matplotlib
```

uv downloads Python if needed, creates a virtual environment in `.venv/`, installs the packages, and records exact versions in `uv.lock`.

## 3. Open a notebook

Pick **one** of these.

**Option A: JupyterLab in the browser**

```bash
uv add --dev jupyterlab
uv run jupyter lab
```

In JupyterLab, create a new notebook with the default **Python 3** kernel.

**Option B: VS Code**

```bash
uv add --dev ipykernel
code .
```

Install the **Python** and **Jupyter** extensions if you haven't already. Create `analysis.ipynb`, click **Select Kernel** (top right), and choose the `.venv` environment.

## 4. Make a map and a chart

Paste this into a notebook cell and run it:

```python
import geopandas as gpd
import matplotlib.pyplot as plt
import seaborn as sns

url = "https://naciscdn.org/naturalearth/110m/cultural/ne_110m_admin_0_countries.zip"
world = gpd.read_file(url)
world = world[world["POP_EST"] > 1_000_000]  # drop Antarctica and tiny islands
world["gdp_per_capita"] = world["GDP_MD"] * 1e6 / world["POP_EST"]

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(9, 9))
world.plot(column="gdp_per_capita", cmap="viridis", legend=True, ax=ax1)
ax1.set_title("GDP per capita")
sns.boxplot(data=world, x="CONTINENT", y="gdp_per_capita", ax=ax2)
ax2.tick_params(axis="x", rotation=30)
plt.tight_layout()
```

That's a complete, reproducible project. Commit it to git, and a collaborator can recreate the same environment with `uv sync`. The rest of this guide explains each piece.

# The details

## Installing uv

**macOS / Linux**

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Or with Homebrew: `brew install uv`

**Windows** (PowerShell)

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

Or with WinGet: `winget install --id=astral-sh.uv -e`

Open a new terminal, then check that it worked:

```bash
uv --version
```

To update uv later, run `uv self update`, or use `brew upgrade uv` / `winget upgrade astral-sh.uv` if you installed it that way.

## Project files

`uv init world-map` creates:

```text
world-map/
├── .gitignore
├── .python-version         # Python version for this project
├── README.md
├── pyproject.toml          # project metadata and dependencies
└── src/world_map/__init__.py
```

After the first `uv add`, you'll also have `.venv/` (the environment) and `uv.lock` (exact versions of every package).

For an analysis project you may not need the `src/` package. `uv init --no-package world-map` creates a flat layout with a `main.py` instead. Older versions of uv use that layout by default.

## Adding and removing packages

```bash
uv add pandas geopandas matplotlib
uv add --dev jupyterlab
```

Packages you use only for development, like JupyterLab or ipykernel, go under `--dev`. Your code doesn't import them, and they're kept separate in `pyproject.toml`.

GeoPandas and its geospatial libraries (shapely, pyproj, pyogrio) come as prebuilt wheels on PyPI. These include GDAL and PROJ, so on macOS, Linux, and Windows you don't need conda or a system install.

Other useful commands:

```bash
uv add "pandas>=2.2"           # with a version constraint
uv remove matplotlib           # remove a package
uv tree                        # show the dependency tree
uv lock --upgrade              # upgrade everything
uv lock --upgrade-package pandas   # upgrade one package
```

Commit `pyproject.toml`, `uv.lock`, and `.python-version` to git. Don't commit `.venv/`; `uv init` already adds it to `.gitignore`.

## Jupyter

**JupyterLab.** `uv run jupyter lab` starts JupyterLab inside the project environment. Its notebooks can import everything you've added with `uv add`. If you add a package while JupyterLab is running, restart the kernel to pick it up.

**VS Code and other editors.** Editors start their own kernel, so the project needs `ipykernel` (`uv add --dev ipykernel`). Then choose `.venv` as the kernel or interpreter. If `.venv` doesn't appear in the list, reload the window or pick **Enter interpreter path** and point it at `.venv/bin/python` (`.venv\Scripts\python.exe` on Windows).

**Quick, throwaway notebook** (no project needed):

```bash
uvx --with pandas --with geopandas jupyter lab
```

## Running scripts

`uv run` runs a command inside the project environment. You don't have to activate anything.

```bash
uv run analysis.py
uv run python            # interactive Python shell
uv run pytest
```

If you prefer activating the environment the usual way:

```bash
source .venv/bin/activate      # macOS / Linux
.venv\Scripts\activate         # Windows
```

## Sharing and reproducing

When a collaborator clones your repo, they run:

```bash
uv sync
uv run jupyter lab
```

`uv sync` installs the exact package versions recorded in `uv.lock`, on any operating system. Everyone gets the same environment, so "works on my machine" problems are much less likely.

## Managing Python versions

```bash
uv python list             # versions available and installed
uv python install 3.13     # install a version
uv python pin 3.12         # set this project's version (.python-version)
```

You can also choose a version when creating a project: `uv init --python 3.12 world-map`.

## Single-file scripts

For a one-off analysis script, uv can record dependencies inside the file itself:

```bash
uv init --script clean_data.py
uv add --script clean_data.py pandas geopandas
uv run clean_data.py
```

uv writes a short metadata block at the top of the script. Anyone with uv can then run the script, and uv installs what it needs automatically.

## Command-line tools

For tools you use across projects, like the `ruff` linter or the `nbstripout` notebook-output cleaner:

```bash
uvx ruff check .           # run once, in a temporary environment
uv tool install ruff       # install permanently and put it on your PATH
uv tool upgrade --all
```

`uvx` is short for `uv tool run`.

## Coming from pip or conda

**From `requirements.txt`:**

```bash
uv init
uv add -r requirements.txt
```

**From a conda `environment.yml`:** uv can't read this file directly. Copy the package names into `uv add`. Most data science packages, including numpy, pandas, scikit-learn, GeoPandas, and JupyterLab, are on PyPI under the same names.

uv also has a pip-compatible interface. It's useful when you can't switch the whole workflow over yet:

```bash
uv venv
uv pip install -r requirements.txt
```

## Cheat sheet

| Task | Command |
|---|---|
| New project | `uv init name` |
| Add package | `uv add pkg` |
| Add dev package | `uv add --dev pkg` |
| Remove package | `uv remove pkg` |
| Start JupyterLab | `uv run jupyter lab` |
| Run a script | `uv run script.py` |
| Install from lockfile | `uv sync` |
| Upgrade all packages | `uv lock --upgrade` |
| Install Python | `uv python install 3.13` |
| Pin Python version | `uv python pin 3.13` |
| Run a tool once | `uvx tool` |

# Background: why uv?

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

uv covers almost all of these jobs with one consistent interface. It's also much faster: usually 10 to 100 times faster than pip, and far faster than conda's solver. Much of that speed comes from a global cache, so a package you've downloaded once is reused by every project. Creating a new environment with pandas and GeoPandas usually takes a few seconds.

## Comparison

| Tool | Python versions | Environments | Lockfile | Non-Python libraries | Speed |
|---|---|---|---|---|---|
| **uv** | Yes | Yes | Yes | Wheels only | Very fast |
| pip + venv | No | Yes | No | Wheels only | Slow |
| conda / mamba | Yes | Yes | Via add-on | Yes | Moderate |
| pixi | Yes | Yes | Yes | Yes | Fast |
| Poetry | No | Yes | Yes | Wheels only | Moderate |
| pyenv | Yes | Plugin | No | No | n/a |

## uv vs. conda

For years, conda was the default for data science because packages like GDAL were hard to install with pip. That's mostly no longer true. Today, the common scientific stack ships as prebuilt wheels on PyPI, including NumPy, pandas, scikit-learn, GeoPandas, rasterio, and PyTorch.

Stick with **conda** or **[pixi](https://pixi.sh)** when you need things that aren't Python packages on PyPI. Examples include R, specific CUDA toolkits, or unusual geospatial or HPC libraries. pixi is a fast, project-based conda tool, and it uses uv internally for PyPI packages.

## Standards

uv follows the standard Python packaging specifications. Dependencies are declared in a regular `pyproject.toml` (PEP 621), and inline script metadata follows PEP 723. If you stop using uv, your project metadata still works with other tools. The `uv.lock` file is specific to uv, but you can export it with `uv export --format requirements-txt`.

## Learn more

- uv documentation: <https://docs.astral.sh/uv/>
- Using uv with Jupyter: <https://docs.astral.sh/uv/guides/integration/jupyter/>
- Source code: <https://github.com/astral-sh/uv>
