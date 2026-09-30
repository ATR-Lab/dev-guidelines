# C and C++

> **Read this when** you write C++ for a ROS 2 package or a robot SDK (Unitree Go2, Dynamixel), or C for firmware, and want your editor, your reviewer and CI to agree on style.

We follow the ROS 2 code style everywhere, including code that never touches ROS, so one `.clang-format` and one `.clang-tidy` serve every lab repo. The one thing to remember: format with clang-format, and in ROS 2 packages run `ament_clang_format` instead of `ament_uncrustify`, because the two formatters cannot both be satisfied.

## Contents

- [The style we follow](#the-style-we-follow)
- [Language versions](#language-versions)
- [Naming and file layout](#naming-and-file-layout)
- [Install the tools](#install-the-tools)
- [Editor setup](#editor-setup)
- [Adopt the config in a repo](#adopt-the-config-in-a-repo)
- [Check in CI](#check-in-ci)
- [Common mistakes](#common-mistakes)
- [Related](#related)

## The style we follow

The [ROS 2 code style](https://docs.ros.org/en/jazzy/The-ROS2-Project/Contributing/Code-Style-Language-Versions.html) builds on the [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html) with a few changes. We use it because most of our C++ lives in ROS 2 packages, and matching the ecosystem means code moves between lab repos and upstream projects without a reformat.

The changes from Google style that you will notice:

| Rule | ROS 2 style |
|---|---|
| Line length | 100 characters |
| Braces | Open brace on its own line for function, class, struct and enum definitions; on the same line for `if`, `else`, `for`, `while` |
| Always braces | Even for one-line `if` and loop bodies |
| Pointers and references | `char * c;` and `const Limits & limits` (space on both sides) |
| Access specifiers | `public:` in the same column as `class` |
| Function names | `snake_case` is allowed and is what ROS 2 core packages use; we use it |
| Exceptions | Allowed; avoid them in APIs you plan to wrap in C |
| Boost | Avoid unless there is no alternative |

For C, ROS 2 follows [PEP 7](https://peps.python.org/pep-0007/) (Python's C style) with `//` comments allowed. Our `.clang-format` formats C files with the same settings.

`configs/c-cpp/.clang-format` is the configuration that ROS 2 ships in [ament_clang_format](https://github.com/ament/ament_lint/blob/jazzy/ament_clang_format/ament_clang_format/configuration/.clang-format), unchanged. We checked that clang-format 14 (Ubuntu 22.04), 18 (Ubuntu 24.04), 21 (Ubuntu 26.04) and 23 (the version Homebrew installs) all format our examples the same way; CI pins version 18.

`configs/c-cpp/.clang-tidy` turns on four check families and then removes the checks that are mostly noise in robot code:

| Family | What it catches | Turned off, and why |
|---|---|---|
| `bugprone-*` | Likely bugs: dangling handles, bad `memset`, suspicious string compares | `easily-swappable-parameters` (fires on every function with two `double`s), `narrowing-conversions` (every float/int mix in sensor code), `reserved-identifier` (ROS 2 header guards contain `__`) |
| `clang-analyzer-*` | Null dereferences, memory leaks, uses of uninitialized values (it follows each path through the code) | None |
| `performance-*` | Needless copies, `std::move` misuse | `avoid-endl` |
| `modernize-*` | `nullptr`, `using`, range `for`, `override` | `avoid-bind` (the ROS 2 style allows `std::bind`), `avoid-c-arrays` (vendor SDKs), `use-nodiscard`, `use-trailing-return-type` |
| `readability-*` (16 picked checks) | Missing braces, `size() == 0`, naming, redundant code | Everything else in the family |

`readability-identifier-naming` enforces the naming table below. Every enabled check is an error (`WarningsAsErrors: '*'`), so keep the list short enough that this stays true.

## Language versions

The C and C++ standards depend on the ROS 2 distribution. Set them in `CMakeLists.txt` so every compiler agrees.

| ROS 2 distribution | C++ | C | Source |
|---|---|---|---|
| Humble, Jazzy, Kilted | C++17 | C99 | [Jazzy code style page](https://docs.ros.org/en/jazzy/The-ROS2-Project/Contributing/Code-Style-Language-Versions.html) |
| Lyrical, Rolling | C++20 | C17 | [Rolling code style page](https://docs.ros.org/en/rolling/The-ROS2-Project/Contributing/Code-Style-Language-Versions.html) |

Code that must build on more than one distribution targets the oldest one, so C++17 for anything that still runs on Humble or Jazzy. Firmware uses the standard its board's toolchain supports; check the platform's docs.

## Naming and file layout

| Thing | Style | Example |
|---|---|---|
| Namespaces, packages | `snake_case` | `teleop_velocity_limiter` |
| Classes, structs, enums, type aliases | `CamelCase` | `VelocityLimiter` |
| Functions and methods | `snake_case` | `limit()`, `on_command()` |
| Variables and parameters | `snake_case` | `dt_seconds` |
| Private and protected members | `snake_case_` with a trailing underscore | `last_command_` |
| Global variables | `g_` prefix | `g_shutdown_requested` |
| Macros | `UPPER_CASE` | `RING_BUFFER_CAPACITY` |
| Constants and enum values | Any consistent style in the package (ROS 2 mixes `kName`, `NAME` and `name`) | `kMaxSpeed` |
| Header guards | `PACKAGE__PATH__FILE_HPP_` (what `ament_cpplint` expects) | `TELEOP_VELOCITY_LIMITER__VELOCITY_LIMITER_HPP_` |
| Files | `snake_case.hpp` and `snake_case.cpp`; C uses `.h` and `.c` | `velocity_limiter_node.cpp` |

A ROS 2 C++ package keeps public headers in `include/<package>/`, sources in `src/` and tests in `test/`; launch and parameter files go in `launch/` and `config/`. [ROS 2 packages](ros2-packages.md) has the full layout; `examples/c-cpp/teleop_velocity_limiter/` is a working example.

## Install the tools

macOS (Homebrew):

```bash
brew install clang-format
brew install llvm   # provides clang-tidy; Homebrew does not put it on PATH
echo 'export PATH="$(brew --prefix llvm)/bin:$PATH"' >> ~/.zshrc
```

Ubuntu 24.04 (clang-format and clang-tidy 18) or 22.04 (version 14):

```bash
sudo apt update
sudo apt install clang-format clang-tidy
```

For ROS 2 packages, also install the ament wrapper (replace `jazzy` with your distribution):

```bash
sudo apt install ros-jazzy-ament-cmake-clang-format
```

## Editor setup

VS Code has two good options. Pick one; running both gives duplicate diagnostics.

- **C/C++ extension** (`ms-vscode.cpptools`, Microsoft): formats with clang-format and reads `.clang-format` by default (`C_Cpp.clang_format_style` is `file`). Turn on clang-tidy with `"C_Cpp.codeAnalysis.clangTidy.enabled": true`.
- **clangd extension** (`llvm-vs-code-extensions.vscode-clangd`): reads `.clang-format` and [merges your `.clang-tidy`](https://clangd.llvm.org/config) into its live diagnostics. It looks for `compile_commands.json` in parent folders and in `build/`; in a colcon workspace, point it at the package's database with a `.clangd` file:

  ```yaml
  CompileFlags:
    CompilationDatabase: build/teleop_velocity_limiter
  ```

Both need a compilation database for accurate results. In a colcon workspace:

```bash
colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

Turn on format on save in `.vscode/settings.json`:

```json
{
  "[cpp]": { "editor.formatOnSave": true },
  "[c]": { "editor.formatOnSave": true }
}
```

## Adopt the config in a repo

Run this from the repo root (a single package, a colcon workspace repo or a firmware project):

```bash
BASE=https://raw.githubusercontent.com/ATR-Lab/dev-guidelines/master/configs
curl -fsSLO "$BASE/c-cpp/.clang-format"
curl -fsSLO "$BASE/c-cpp/.clang-tidy"
# Reformat everything once, in its own commit, so later diffs stay small
find . -path ./build -prune -o \( -name '*.[ch]pp' -o -name '*.[ch]' \) -print0 | xargs -0 clang-format -i
git add .clang-format .clang-tidy
git commit -am "Format C++ with the lab clang-format config"
```

In each ROS 2 package that uses `ament_lint_auto`, swap uncrustify for clang-format. Add the test dependency to `package.xml`:

```xml
<test_depend>ament_cmake_clang_format</test_depend>
```

Then exclude uncrustify in `CMakeLists.txt`, before `ament_lint_auto_find_test_dependencies()`:

```cmake
if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  # We format with clang-format; uncrustify disagrees with it on lambdas and one-line functions.
  list(APPEND AMENT_LINT_AUTO_EXCLUDE ament_cmake_uncrustify)
  ament_lint_auto_find_test_dependencies()
endif()
```

`ament_clang_format` uses the same rules as our file, so it needs no extra settings.

## Check in CI

This GitHub Actions job builds and tests a ROS 2 repo on Jazzy and runs clang-format and clang-tidy. We ran these steps in a `ros:jazzy-ros-base` container against `examples/c-cpp/` before publishing them; `rosdep` installs `ament_cmake_clang_format` from your `package.xml`.

```yaml
name: cpp
on: [push, pull_request]
jobs:
  lint-build-test:
    runs-on: ubuntu-latest
    container: ros:jazzy-ros-base
    steps:
      - uses: actions/checkout@v7
      - name: Install tools and dependencies
        run: |
          apt-get update
          apt-get install -y clang-format clang-tidy jq
          rosdep update
          rosdep install --from-paths . --ignore-src -y
      - name: clang-format
        run: find . \( -name '*.[ch]pp' -o -name '*.[ch]' \) -print0 | xargs -0 clang-format --dry-run --Werror
      - name: Build, clang-tidy and test
        shell: bash
        run: |
          source /opt/ros/jazzy/setup.bash
          colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
          # clang-tidy on our own sources only (not generated files or system libraries)
          for db in build/*/compile_commands.json; do
            files=$(jq -r '.[].file' "$db" | grep "^$PWD/" | grep -v "^$PWD/build/" | sort -u || true)
            if [ -n "$files" ]; then clang-tidy -p "$(dirname "$db")" --quiet $files; fi
          done
          colcon test
          colcon test-result --verbose
```

## Common mistakes

- **Running two formatters.** `ament_uncrustify --reformat` and clang-format undo each other's changes. Pick clang-format and exclude uncrustify, as above.
- **clang-tidy without a compilation database.** It then guesses include paths and reports missing headers. Build with `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` and pass `-p build/<package>`.
- **`#pragma once` in ROS 2 packages.** `ament_cpplint` expects `#ifndef` guards named after the path.
- **Formatting vendor code.** Keep vendor SDKs (Unitree, Dynamixel) in their own folder and exclude it from `find`, so updates stay easy to diff. `HeaderFilterRegex` already keeps clang-tidy out of headers outside `include/` and `src/`.
- **A reformat mixed into a feature commit.** Reformat in a separate commit so reviewers can see the real change.
- **Committing `build/`, `install/` or `log/`.** Add them to `.gitignore` (see [Git and GitHub](git-and-github.md#gitignore)).

## Related

- [ROS 2 packages](ros2-packages.md): layout, naming and `ament_lint_auto`
- [Hardware and firmware](hardware.md): PlatformIO and Arduino projects
- [Python](python.md): the other half of most ROS 2 workspaces
- Config files: [`configs/c-cpp/`](../configs/c-cpp/) and the example package in [`examples/c-cpp/`](../examples/c-cpp/)
- [All things ROS 2](https://github.com/ATR-Lab/all-things-ros2): ROS 2 basics, distributions and installation
- clang-format [style options](https://clang.llvm.org/docs/ClangFormatStyleOptions.html) and clang-tidy [check list](https://clang.llvm.org/extra/clang-tidy/checks/list.html)

<sub>Last reviewed: Sept. 30, 2026 · Sources checked on that date · [Suggest a change](https://github.com/ATR-Lab/dev-guidelines/issues/new)</sub>
