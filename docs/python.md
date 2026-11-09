# Python

> **Read this when** you write Python for a ROS 2 node, a machine learning experiment (PyTorch, LeRobot) or a lab tool, and want one setup that passes both our checks and `colcon test`.

We follow PEP 8, write Google-style docstrings and let Ruff do both formatting and linting, with mypy for types and uv for environments. The one thing to remember: our Ruff settings match the ROS 2 linters (99-character lines, single quotes), so the same code passes in a ROS 2 package, as long as `ament_pep257` is told to use the Google docstring convention.

## Contents

- [The style we follow](#the-style-we-follow)
- [Naming and file layout](#naming-and-file-layout)
- [Ruff: which rules and why](#ruff-which-rules-and-why)
- [Types: mypy and pyright](#types-mypy-and-pyright)
- [Environments with uv](#environments-with-uv)
- [Inside ROS 2 packages](#inside-ros-2-packages)
- [Install and editor setup](#install-and-editor-setup)
- [Adopt the config in a repo](#adopt-the-config-in-a-repo)
- [Check in CI](#check-in-ci)
- [Common mistakes](#common-mistakes)
- [Related](#related)

## The style we follow

- **[PEP 8](https://peps.python.org/pep-0008/)** for layout and naming. PEP 8 allows lines up to 99 characters when a team agrees, and we do, because that is what `ament_flake8` checks in ROS 2 packages.
- **Single quotes** for strings unless the string contains one. The [ROS 2 code style](https://docs.ros.org/en/jazzy/The-ROS2-Project/Contributing/Code-Style-Language-Versions.html) picks single quotes, and PEP 8 makes no recommendation. Docstrings keep triple double quotes, as [PEP 257](https://peps.python.org/pep-0257/) says.
- **[Google Python Style Guide, section 3.8](https://google.github.io/styleguide/pyguide.html#s3.8-comments-and-docstrings)** for docstrings: a one-line summary, a blank line, then `Args:`, `Returns:` and `Raises:` sections.

```python
def summarize(frames: Sequence[Frame]) -> EpisodeSummary:
    """Summarize one recorded episode.

    Args:
        frames: Samples in time order. Every frame must have the same number of joints.

    Returns:
        The frame count, the duration, the range of each joint and the fastest joint speed.

    Raises:
        ValueError: If there are fewer than two frames or the joint counts differ.
    """
```

## Naming and file layout

| Thing | Style | Example |
|---|---|---|
| Modules and packages | `snake_case`, short | `teleop_episodes/stats.py` |
| Classes and exceptions | `CamelCase` | `EpisodeSummary`, `StatusParseError` |
| Functions, methods, variables | `snake_case` | `load_frames()`, `max_speed` |
| Constants | `UPPER_CASE` | `DEFAULT_RATE_HZ` |
| Private names | leading underscore | `_clamp()` |

Outside ROS 2, use the `src/` layout that `uv init --package` creates, with tests in `tests/`:

```text
my_tool/
├── pyproject.toml     # dependencies, mypy and pyright settings
├── ruff.toml          # from configs/python/
├── uv.lock            # commit it: it pins every dependency
├── src/my_tool/
└── tests/
```

ROS 2 Python packages use the `ament_python` layout instead; see [ROS 2 packages](ros2-packages.md#ament_python-layout).

## Ruff: which rules and why

[Ruff](https://docs.astral.sh/ruff/) replaces Black, isort, flake8 and pydocstyle with one fast tool. Ruff 0.16 changed its default rule set, so `configs/python/ruff.toml` lists every family it wants:

| Rules | What they catch | Why we want them |
|---|---|---|
| `E`, `W` | pycodestyle errors and warnings | The same checks flake8 runs in ROS 2 packages |
| `F` | Unused imports, undefined names | Real bugs |
| `I` | Import order | Sorted like the "google" order `ament_flake8` checks |
| `N` | PEP 8 naming | Consistent names |
| `D` | Docstrings, Google convention | Public classes and functions need one (module and package docstrings are optional, as in ROS 2) |
| `UP` | Old syntax for the target version | `list[int]`, not `List[int]` |
| `B` | flake8-bugbear | Mutable default arguments, loop variable capture |
| `A`, `C4` | Shadowed built-ins, clumsy comprehensions | Also run by `ament_flake8` |
| `SIM` | Code that can be simpler | Fewer nested `if`s |
| `NPY` | Deprecated NumPy calls | Common in ML code |
| `RUF` | Ruff's own checks | For example, `itertools.pairwise` over `zip(x, x[1:])` |

We leave out the quote (`Q`) and trailing-comma (`COM`) rules, because the formatter already handles them and the [Ruff docs](https://docs.astral.sh/ruff/formatter/#conflicting-lint-rules) list them as conflicting. For the same reason we cannot enforce the ROS 2 preference for one import per line: Ruff's `force-single-line` setting is incompatible with its formatter.

## Types: mypy and pyright

- **mypy** (`strict = true`) is the gate in CI. Add type hints to every function you write; `mypy --strict` rejects untyped definitions.
- **pyright** runs inside VS Code as Pylance. We set it to `standard` so the editor stays quiet enough to be useful; mypy catches the rest.
- For a library without type hints (common in robot SDKs), add it to the `[[tool.mypy.overrides]]` list in `pyproject.toml` rather than turning checks off for the whole project.

## Environments with uv

[uv](https://docs.astral.sh/uv/) creates the virtual environment, installs dependencies and writes `uv.lock`, so everyone in the project gets the same versions.

```bash
uv init --package my_tool         # new project with src/ layout
cd my_tool
uv add numpy                       # runtime dependency
uv add --dev ruff==0.16.9 mypy==2.3.1 pytest
uv run pytest                      # runs inside the project's environment
uvx ruff check .                   # runs a tool without adding it to the project
```

Commit `pyproject.toml` and `uv.lock`; never commit `.venv/`. For ML projects, follow the library's own install guide (PyTorch builds differ by CUDA version) and let uv record the result in the lockfile.

## Inside ROS 2 packages

ROS 2 packages are checked by `ament_flake8` and `ament_pep257` when you run `colcon test`. Our Ruff settings agree with `ament_flake8`'s configuration (99 columns, Google import order, single quotes), and we tested that the example code passes both. Two things need attention:

1. **Docstrings.** `ament_pep257`'s default "ament" convention rejects Google-style `Args:` sections. Tell it to use the Google convention in `test/test_pep257.py` (the paths must come before the options):

   ```python
   # test/test_pep257.py: the file ros2 pkg create generates, with the argv changed
   from ament_pep257.main import main
   import pytest

   # Docstrings stay optional, as in the default "ament" convention.
   OPTIONAL_DOCSTRINGS = ['D100', 'D101', 'D102', 'D103', 'D104', 'D105', 'D106', 'D107']


   @pytest.mark.linter
   @pytest.mark.pep257
   def test_pep257():
       rc = main(argv=['.', 'test', '--convention', 'google', '--add-ignore', *OPTIONAL_DOCSTRINGS])
       assert rc == 0, 'Found code style errors / warnings'
   ```

   Keeping docstrings optional means the test files that `ros2 pkg create` generates still pass. We ran this file through Ruff, `ament_flake8` and pytest on ROS 2 Jazzy.

2. **Slices.** Ruff's formatter writes `ham[lower + offset : upper]` with spaces around the colon, and `ament_flake8` reports that as `E203`. Put the bound in a variable (`end = lower + offset`) or add `# noqa: E203`.

**Virtual environments and ROS 2.** ROS 2 is built against the system Python, so do not point a ROS 2 workspace at a uv-managed interpreter. The ROS 2 guide on [using Python packages](https://docs.ros.org/en/jazzy/How-To-Guides/Using-Python-Packages.html) prefers rosdep keys; when a package is only on PyPI, it recommends a virtual environment made from the system interpreter, with a `COLCON_IGNORE` file inside so colcon skips it:

```bash
# Ubuntu 24.04 with ROS 2 Jazzy; run from the workspace root
uv venv --python /usr/bin/python3 --system-site-packages venv   # also sees packages rosdep installed with apt
touch venv/COLCON_IGNORE
source venv/bin/activate
uv pip install <package-from-pypi>
```

## Install and editor setup

macOS or Linux:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh   # or, on macOS: brew install uv
uv tool install ruff@0.16.9
uv tool install mypy@2.3.1
```

VS Code: install **Python** (`ms-python.python`), **Pylance** (`ms-python.vscode-pylance`), **Ruff** (`charliermarsh.ruff`) and **Mypy Type Checker** (`ms-python.mypy-type-checker`). Then format on save with Ruff, as its [README](https://github.com/astral-sh/ruff-vscode) shows:

```json
{
  "[python]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.codeActionsOnSave": { "source.fixAll": "explicit", "source.organizeImports": "explicit" }
  }
}
```

## Adopt the config in a repo

```bash
BASE=https://raw.githubusercontent.com/ATR-Lab/dev-guidelines/master/configs
curl -fsSLO "$BASE/python/ruff.toml"
curl -fsSL "$BASE/python/pyproject-snippet.toml"   # read it, then paste the tables into pyproject.toml
uvx ruff@0.16.9 format .                          # reformat once, in its own commit
uvx ruff@0.16.9 check --fix .
```

## Check in CI

```yaml
name: python
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: astral-sh/setup-uv@v10.3.3   # setup-uv publishes no major tag, so @v10 does not resolve
      - run: uv sync --dev
      - run: uv run ruff format --check .
      - run: uv run ruff check .
      - run: uv run mypy .
      - run: uv run pytest
```

## Common mistakes

- **Double quotes everywhere.** Ruff fixes them on format; `ament_flake8` fails on them (`Q000`) if you skip the formatter.
- **`pip install` into the system Python on Ubuntu 24.04.** Ubuntu marks its Python as externally managed ([PEP 668](https://peps.python.org/pep-0668/)), so pip refuses. Use uv for projects and rosdep for ROS 2 dependencies.
- **Mutable default arguments** (`def f(items=[])`). Ruff's `B006` catches them.
- **Notebooks as the only copy of the code.** Move code you reuse into a module with tests; keep notebooks for exploration.
- **Unpinned tools.** Pin Ruff and mypy in `pyproject.toml` so a new release does not fail CI overnight.

## Related

- [ROS 2 packages](ros2-packages.md): `ament_python` layout and linters
- [C and C++](c-cpp.md): the C++ side of a ROS 2 workspace
- [Documentation](documentation.md#docstrings-per-language): docstrings in every language
- Config files: [`configs/python/`](../configs/python/) and the example in [`examples/python/`](../examples/python/)
- Ruff [rules](https://docs.astral.sh/ruff/rules/), mypy [configuration](https://mypy.readthedocs.io/en/stable/config_file.html), uv [projects guide](https://docs.astral.sh/uv/guides/projects/)

<sub>Last reviewed: Nov. 9, 2026 · Sources checked on that date · [Suggest a change](https://github.com/ATR-Lab/dev-guidelines/issues/new)</sub>
