# Copy-ready configs

> **Read this when** you want to add formatter and linter settings to a lab repo, or you are updating a tool version here.

Each folder holds the config files for one language, ready to copy to the root of your repo. Every file is tested: `scripts/check-configs.sh` runs each tool against the samples in [`examples/`](../examples/), which must pass, and against a deliberately bad sample, which must fail. The one thing to remember: copy the files as they are, and change a rule only in a pull request that says why.

## Contents

- [What's here](#whats-here)
- [How to copy a config](#how-to-copy-a-config)
- [Tested versions](#tested-versions)
- [How the configs are checked](#how-the-configs-are-checked)
- [Updating a tool version](#updating-a-tool-version)
- [Related](#related)

## What's here

| Folder | Files | Language page |
|---|---|---|
| [`editorconfig/`](editorconfig/) | `.editorconfig`: indentation, line endings and line length for every language | [Documentation](../docs/documentation.md) |
| [`c-cpp/`](c-cpp/) | `.clang-format` (ROS 2 style, identical to `ament_clang_format`), `.clang-tidy` | [C and C++](../docs/c-cpp.md) |
| [`python/`](python/) | `ruff.toml`, `pyproject-snippet.toml` (mypy, pyright, pytest, dev dependencies) | [Python](../docs/python.md) |
| [`javascript-typescript/`](javascript-typescript/) | `eslint.config.mjs`, `.prettierrc.json`, `tsconfig.base.json`, `package-snippet.json` | [JavaScript and TypeScript](../docs/javascript-typescript.md) |
| [`swift/`](swift/) | `.swift-format`, `.swiftlint.yml` | [Swift](../docs/swift.md) |
| [`kotlin/`](kotlin/) | `.editorconfig` (ktlint settings), `detekt.yml` | [Kotlin](../docs/kotlin.md) |
| [`csharp-unity/`](csharp-unity/) | `.editorconfig` (formatting, naming rules, analyzer severities, Unity notes) | [C# and Unity](../docs/csharp-unity.md) |
| [`markdown/`](markdown/) | `.markdownlint.jsonc` (the same rules the lab's docs repos use) | [Documentation](../docs/documentation.md#writing-well) |

A repo that mixes languages has one `.editorconfig` at its root: start from `editorconfig/.editorconfig` and paste in the `[*.{kt,kts}]` section from `kotlin/` or the `[*.cs]` section from `csharp-unity/` when you need them.

## How to copy a config

Each language page has the exact commands. The pattern is the same everywhere:

```bash
# From the root of your repo; replace <folder> and <file>
BASE=https://raw.githubusercontent.com/ATR-Lab/dev-guidelines/master/configs
curl -fsSLO "$BASE/<folder>/<file>"
```

Then run the formatter over the whole repo once, commit that on its own ("Apply lab formatter config") and add the CI snippet from the language page.

## Tested versions

Tested with these versions on Sept. 30, 2026. Newer patch releases should behave the same; re-run the checks before you move to a new minor or major version.

| Language | Tool | Version | Where it ran |
|---|---|---|---|
| All | editorconfig-checker | 4.0.2 | `mstruebing/editorconfig-checker:4.0.2` |
| C, C++ | clang-format, clang-tidy | 18.1.3 | Ubuntu 24.04 packages in `ros:jazzy-ros-base` |
| C, C++ | clang-format (same output on our examples) | 14.0.0, 21.1.8, 23.1.2 | Ubuntu 22.04, Ubuntu 26.04, apt.llvm.org |
| C, C++, Python | ament_lint (`ament_clang_format`, `ament_cpplint`, `ament_flake8`, `ament_pep257` and others) | 0.17.5 | ROS 2 Jazzy |
| Python | Ruff | 0.16.9 | Python 3.12.14, uv 0.12.21 |
| Python | mypy, pyright, pytest | 2.3.1, 1.1.414, 9.1.1 | same |
| JavaScript, TypeScript | ESLint, `@eslint/js` | 10.11.0, 10.0.1 | Node.js 24.21.0 |
| JavaScript, TypeScript | typescript-eslint, TypeScript | 8.71.0, 6.0.3 | same |
| JavaScript, TypeScript | Prettier, eslint-config-prettier, globals | 3.9.9, 10.1.8, 17.12.0 | same |
| Swift | swift-format (bundled with the toolchain) | Swift 6.4 | `swift:6.4-noble`; Xcode 27.1 on macOS |
| Swift | SwiftLint | 0.65.1 (also 0.63.2) | `ghcr.io/realm/swiftlint:0.65.1`; Homebrew |
| Kotlin | ktlint | 1.8.0 | Eclipse Temurin Java 21 |
| Kotlin | detekt | 1.23.8 | same |
| C# | .NET SDK (`dotnet build`, `dotnet format`) | 10.0.401 | `mcr.microsoft.com/dotnet/sdk:10.0` |
| C# | Microsoft.Unity.Analyzers | 1.28.0 | same |
| Markdown | markdownlint-cli2 | 0.23.3 | `davidanson/markdownlint-cli2:v0.23.3` |

The Unity scripts were checked with the .NET SDK against small stand-ins for the UnityEngine types (`examples/csharp-unity/check/`), not inside the Unity Editor. See [C# and Unity](../docs/csharp-unity.md#how-unity-6-uses-analyzers-and-editorconfig) for what Unity itself reads.

## How the configs are checked

```bash
scripts/check-configs.sh                    # every language (needs Docker)
scripts/check-configs.sh python kotlin      # only some
scripts/check-configs.sh --local swift      # use tools installed on this machine
```

For each language, the script copies the samples and the configs into a throwaway container, so nothing changes in your checkout. The good samples must pass every tool; each file in `examples/<language>/bad/` must be rejected, which proves the rules are switched on. The bad samples for EditorConfig and Markdown are generated by the script, because editors and the docs workflow would "fix" or reject committed ones. The same script runs in CI ([`.github/workflows/configs.yml`](../.github/workflows/configs.yml)) on every pull request that touches `configs/`, `examples/` or the script.

## Updating a tool version

1. Change the version in the config file's header comment, in `scripts/check-configs.sh` and in the table above.
2. For JavaScript and TypeScript, also update `package-snippet.json`; for Python, `pyproject-snippet.toml`.
3. Run `scripts/check-configs.sh` for that language and fix the samples or the config until it passes.
4. Mention the new version and anything that changed in the pull request, so repos that copied the config know to update.

## Related

- [All guides](../docs/README.md)
- [Examples](../examples/README.md): what each sample shows
- [Check script](../scripts/check-configs.sh)

<sub>Last reviewed: Sept. 30, 2026 · Sources checked on that date · [Suggest a change](https://github.com/ATR-Lab/dev-guidelines/issues/new)</sub>
