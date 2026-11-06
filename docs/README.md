# Dev guidelines: all pages

> **Read this when** you want the full list of guides in this repo, or you are not sure which page answers your question.

Each page covers one topic and can be read on its own in about 10 minutes. Language pages all follow the same order: the style guide we follow, naming and layout, the tools and their config, editor setup, how to adopt the config, a CI snippet and common mistakes.

## Working together

| Page | What's inside | Read it when |
|---|---|---|
| [Git and GitHub](git-and-github.md) | Branches, the seven commit message rules, pull requests and reviews, issues, releases, `.gitignore`, Git LFS, secrets | You start a branch, write a commit or cut a release |
| [Documentation](documentation.md) | README standard, docstrings per language, `AGENTS.md` and `CLAUDE.md`, diagrams, changelogs | You start a repo or finish something others will use |
| [AI-assisted development](ai-assisted-development.md) | Rules for Claude Code, Codex and other coding agents in lab repos | You use an agent or review code one helped write |

## Languages

| Page | Formatter and linter | Read it when |
|---|---|---|
| [C and C++](c-cpp.md) | clang-format, clang-tidy, `ament_clang_format` | You write ROS 2 nodes, robot SDK code or C firmware |
| [Python](python.md) | Ruff, mypy, uv | You write ROS 2 nodes, ML code or tools |
| [JavaScript and TypeScript](javascript-typescript.md) | Prettier, ESLint with typescript-eslint, `tsc` | You build a dashboard or a Node.js server |
| [Swift](swift.md) | swift-format, SwiftLint | You build a visionOS, watchOS or iOS app |
| [Kotlin](kotlin.md) | ktlint, detekt | You build an Android or Wear OS app |
| [C# and Unity](csharp-unity.md) | `.editorconfig`, Roslyn analyzers, Microsoft.Unity.Analyzers, `dotnet format` | You build a Unity VR or XR app or a .NET tool |
| [Other languages](other-languages.md) | Official guides only | You write Arduino, Java, MATLAB, Solidity or Ada code |

## Robots and hardware

| Page | What's inside | Read it when |
|---|---|---|
| [ROS 2 packages](ros2-packages.md) | Package naming (REP 144), layout, `ament_lint_auto`, units (REP 103), frames (REP 105), launch files, parameters | You create or review a ROS 2 package |
| [Hardware and firmware](hardware.md) | CAD naming and versions, BOMs, PlatformIO firmware, wiring colors and labels, 3D print files | You design, wire, print or flash something |

## Related

- [Repo README](../README.md): the language matrix and quick start
- [Configs](../configs/README.md): the copy-ready config files and the versions we tested
- [Templates](../templates/): README and AGENTS templates for lab project repos
- [Getting started](https://github.com/ATR-Lab/getting-started-atr-lab): the lab's onboarding repo

<sub>Last reviewed: Sept. 30, 2026 · Sources checked on that date · [Suggest a change](https://github.com/ATR-Lab/dev-guidelines/issues/new)</sub>
