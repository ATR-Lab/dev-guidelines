<p align="center">
  <img src=".github/assets/header.png" alt="Dev guidelines: Style guides, lint configs and Git practices. Advanced Telerobotics Research Laboratory, Kent State University." width="100%">
</p>

<p align="center">
  <b>Style guides, copy-ready lint configs and Git practices for every code repo of the Advanced Telerobotics Research Laboratory, written for lab members and the coding agents that work with them.</b><br>
  <sub>Advanced Telerobotics Research Laboratory · Department of Computer Science · Kent State University</sub>
</p>

<p align="center">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-003976?style=flat-square"></a>
  <a href="https://www.atr.cs.kent.edu/"><img alt="Advanced Telerobotics Research Laboratory, Kent State University" src="https://img.shields.io/badge/ATR_Lab-Kent_State-003976?style=flat-square"></a>
  <img alt="Last reviewed Nov. 2026" src="https://img.shields.io/badge/last_reviewed-Nov._2026-4A5868?style=flat-square">
</p>

## Start here

<table>
  <tr>
    <td width="33%" valign="top">
      <img src=".github/assets/icons/code.png" width="44" alt=""><br>
      <b><a href="docs/README.md">Language guides</a></b><br>
      <sub>C and C++, Python, TypeScript, Swift, Kotlin, C# and Unity: style, tools and CI.</sub>
    </td>
    <td width="33%" valign="top">
      <img src=".github/assets/icons/mechanical-gear.png" width="44" alt=""><br>
      <b><a href="configs/README.md">Copy-ready configs</a></b><br>
      <sub>Formatter and linter files for each language, with the versions we tested.</sub>
    </td>
    <td width="33%" valign="top">
      <img src=".github/assets/icons/milestone-flag.png" width="44" alt=""><br>
      <b><a href="docs/git-and-github.md">Git and GitHub</a></b><br>
      <sub>Branches, commit messages, pull requests, releases, Git LFS and secrets.</sub>
    </td>
  </tr>
  <tr>
    <td width="33%" valign="top">
      <img src=".github/assets/icons/ros-graph.png" width="44" alt=""><br>
      <b><a href="docs/ros2-packages.md">ROS 2 packages</a></b><br>
      <sub>Naming, layout, ament linters, units, frames, launch files and parameters.</sub>
    </td>
    <td width="33%" valign="top">
      <img src=".github/assets/icons/embedded-chip.png" width="44" alt=""><br>
      <b><a href="docs/hardware.md">Hardware and firmware</a></b><br>
      <sub>CAD versions, BOMs, PlatformIO firmware, wiring colors and 3D prints.</sub>
    </td>
    <td width="33%" valign="top">
      <img src=".github/assets/icons/ai-neural-net.png" width="44" alt=""><br>
      <b><a href="docs/ai-assisted-development.md">AI-assisted development</a></b><br>
      <sub>Rules for Claude Code, Codex and other coding agents in lab repos.</sub>
    </td>
  </tr>
  <tr>
    <td width="33%" valign="top">
      <img src=".github/assets/icons/publication.png" width="44" alt=""><br>
      <b><a href="docs/documentation.md">Documentation</a></b><br>
      <sub>READMEs, docstrings, AGENTS.md, diagrams and changelogs.</sub>
    </td>
    <td width="33%" valign="top">
      <img src=".github/assets/icons/workshop-idea.png" width="44" alt=""><br>
      <b><a href="templates/README.template.md">Templates</a></b><br>
      <sub>README and AGENTS.md templates for new lab project repos.</sub>
    </td>
    <td width="33%" valign="top">
      <img src=".github/assets/icons/results-chart.png" width="44" alt=""><br>
      <b><a href="examples/README.md">Tested examples</a></b><br>
      <sub>Sample code that passes every config, and bad samples that must fail.</sub>
    </td>
  </tr>
</table>

## Language matrix

The six languages the lab uses most. Each row links to its guide, which has the exact check commands; the config folder holds files you can copy as they are.

| Language | Style guide we follow | Formatter | Linter | Config folder |
|---|---|---|---|---|
| [C and C++](docs/c-cpp.md) | [ROS 2 code style](https://docs.ros.org/en/jazzy/The-ROS2-Project/Contributing/Code-Style-Language-Versions.html) (Google C++ with ROS 2 changes) | clang-format | clang-tidy; `ament_cpplint` in ROS 2 packages | [`configs/c-cpp/`](configs/c-cpp/) |
| [Python](docs/python.md) | [PEP 8](https://peps.python.org/pep-0008/), [Google docstrings](https://google.github.io/styleguide/pyguide.html#s3.8-comments-and-docstrings) | Ruff | Ruff, mypy | [`configs/python/`](configs/python/) |
| [JavaScript and TypeScript](docs/javascript-typescript.md) | typescript-eslint strict rules, Prettier defaults | Prettier | ESLint with typescript-eslint, `tsc` | [`configs/javascript-typescript/`](configs/javascript-typescript/) |
| [Swift](docs/swift.md) | [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) | swift-format | SwiftLint | [`configs/swift/`](configs/swift/) |
| [Kotlin](docs/kotlin.md) | [Kotlin coding conventions](https://kotlinlang.org/docs/coding-conventions.html), [Android Kotlin style guide](https://developer.android.com/kotlin/style-guide) | ktlint (`--format`) | ktlint, detekt | [`configs/kotlin/`](configs/kotlin/) |
| [C# and Unity](docs/csharp-unity.md) | [Microsoft C# conventions](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions), [Unity C# style guide](https://unity.com/resources/c-sharp-style-guide-unity-6) | `dotnet format`, your IDE | Roslyn analyzers, Microsoft.Unity.Analyzers | [`configs/csharp-unity/`](configs/csharp-unity/) |

Every repo also gets the shared [`.editorconfig`](configs/editorconfig/.editorconfig) and, for Markdown, [`.markdownlint.jsonc`](configs/markdown/.markdownlint.jsonc). Arduino, Java, MATLAB, Solidity and Ada: see [Other languages](docs/other-languages.md).

## Quick start

1. **New to the lab's code?** Read [Git and GitHub](docs/git-and-github.md), then the guide for your language.
2. **Setting up a repo?** Copy the configs for its languages (each guide has a copy command), add the CI snippet from the guide and start the README and `AGENTS.md` from the [templates](templates/).
3. **Changing a config here?** Run the checks, which need only Docker:

   ```bash
   scripts/check-configs.sh            # all languages
   scripts/check-configs.sh python     # one language
   ```

## Repo map

| Path | What it holds | Read it when |
|---|---|---|
| [`docs/`](docs/README.md) | One guide per topic: Git, documentation, AI agents, six languages, ROS 2 packages, hardware, other languages | You want the rules and the reasons |
| [`configs/`](configs/README.md) | Copy-ready formatter and linter configs (one folder per language) and the tested versions | You set up or update a repo |
| [`examples/`](examples/README.md) | Samples that pass each config; `bad/` samples that must fail | You want to see the style in real code, or you change a config |
| [`templates/`](templates/) | `README.template.md` and `AGENTS.template.md` for lab project repos | You start a new repo |
| [`scripts/check-configs.sh`](scripts/check-configs.sh) | Runs every tool against `examples/` in Docker | You change a config or a tool version |
| [`.github/workflows/`](.github/workflows/) | `configs.yml` runs the checks; `docs.yml` lints Markdown and checks links | You wonder what CI does |
| [`AGENTS.md`](AGENTS.md) | Instructions and repo map for coding agents (`CLAUDE.md` points to it) | You are, or you are directing, a coding agent |

## Contributing

Suggest a change by [opening an issue](https://github.com/ATR-Lab/dev-guidelines/issues/new) or a pull request. Change one topic per pull request, and for a config change, say why and run `scripts/check-configs.sh` for that language. Writing rules, sources and checks for this repo are in [`AGENTS.md`](AGENTS.md); people and agents follow the same ones.

## License

Text and code in this repository are released under the [MIT License](LICENSE). The names and logos of the Advanced Telerobotics Research Laboratory and Kent State University are trademarks and are not covered by that license.

The seven commit message rules in [Git and GitHub](docs/git-and-github.md#commit-messages) are quoted from Chris Beams' post "[How to Write a Git Commit Message](https://cbea.ms/git-commit/)", with credit. The `.clang-format` rules come from the ROS 2 [ament_lint](https://github.com/ament/ament_lint) project (Apache License 2.0).

---

<p align="center">
  <sub><b>ATR Lab docs</b> ·
  <a href="https://github.com/ATR-Lab/about">About the lab</a> ·
  <a href="https://github.com/ATR-Lab/getting-started-atr-lab">Getting started</a> ·
  <a href="https://github.com/ATR-Lab/dev-guidelines">Dev guidelines</a> ·
  <a href="https://github.com/ATR-Lab/all-things-ros2">All things ROS 2</a> ·
  <a href="https://github.com/ATR-Lab">All repositories</a></sub><br>
  <sub>Advanced Telerobotics Research Laboratory · Department of Computer Science · Kent State University ·
  <a href="https://www.atr.cs.kent.edu/">www.atr.cs.kent.edu</a></sub>
</p>
