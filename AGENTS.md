# AGENTS.md: dev-guidelines

This repo is the Advanced Telerobotics Research Laboratory's development standard. It covers the Git and GitHub workflow, documentation and AI-agent rules, one style guide per language (C and C++, Python, JavaScript and TypeScript, Swift, Kotlin, C# and Unity) and conventions for ROS 2 packages and hardware. It also holds copy-ready formatter and linter configs that `scripts/check-configs.sh` tests against sample code. Lab members read it when they start or review code; coding agents read it before working in any lab repo. It is **not** a ROS 2 tutorial (that is `all-things-ros2`), not lab onboarding or safety rules (`getting-started-atr-lab`) and not a description of the lab (`about`).

## Repo map

| Path | What it is |
|---|---|
| `README.md` | Landing page: start-here cards, language matrix, quick start, repo map |
| `AGENTS.md` | This file: the agent's index and rules |
| `CLAUDE.md` | One line, `@AGENTS.md`, so Claude Code reads this file |
| `LICENSE` | MIT License, 2017-2026 |
| `.gitignore` | OS, editor, build and cache files kept out of Git |
| `.markdownlint.jsonc` | markdownlint rules for this repo's Markdown (shared across the lab's docs repos) |
| `.lycheeignore` | URL patterns the link checker skips: sites that block bots and template placeholders |
| `.github/workflows/docs.yml` | CI: markdownlint and lychee link check |
| `.github/workflows/configs.yml` | CI: runs `scripts/check-configs.sh`, one job per language |
| `.github/assets/header.png`, `social-preview.png` | README banner and GitHub social preview (do not regenerate) |
| `.github/assets/icons/*.png` | Navy icon badges used by the README card grid |
| `docs/README.md` | Index of all guides |
| `docs/git-and-github.md` | Branches, seven commit rules (credited to Chris Beams), Conventional Commits, PRs, reviews, issues, SemVer releases, `.gitignore`, Git LFS, protected branches, secrets |
| `docs/documentation.md` | README standard, docstrings per language, AGENTS.md and CLAUDE.md convention, diagrams, changelogs |
| `docs/ai-assisted-development.md` | Rules for Claude Code, Codex and other agents in lab repos |
| `docs/c-cpp.md` | ROS 2 C++ style, clang-format, clang-tidy, ament linters, CI |
| `docs/python.md` | PEP 8, Google docstrings, Ruff, mypy, pyright, uv, ROS 2 interplay |
| `docs/javascript-typescript.md` | ESLint flat config, typescript-eslint, Prettier, strict tsconfig |
| `docs/swift.md` | Swift API Design Guidelines, swift-format, SwiftLint |
| `docs/kotlin.md` | Kotlin conventions, Android style guide, ktlint (`android_studio`), detekt |
| `docs/csharp-unity.md` | Microsoft C# conventions, Unity style guide, `.editorconfig`, Unity 6 analyzers, `dotnet format` |
| `docs/ros2-packages.md` | REP 144 naming, package layouts, `ament_lint_auto`, REP 103, REP 105, launch, parameters |
| `docs/hardware.md` | CAD naming and versions, BOMs, PlatformIO firmware, wiring colors and labels, 3D prints |
| `docs/other-languages.md` | Official style guides for Arduino, Java, MATLAB, Solidity and Ada |
| `configs/README.md` | What each config folder holds, copy commands, tested versions table, how checks work |
| `configs/editorconfig/.editorconfig` | Shared EditorConfig for every language |
| `configs/c-cpp/.clang-format`, `.clang-tidy` | ROS 2 clang-format (identical to `ament_clang_format`) and a focused clang-tidy check set |
| `configs/python/ruff.toml`, `pyproject-snippet.toml` | Ruff lint and format; mypy, pyright, pytest and pinned dev dependencies |
| `configs/javascript-typescript/eslint.config.mjs`, `.prettierrc.json`, `tsconfig.base.json`, `package-snippet.json` | ESLint, Prettier, TypeScript and pinned devDependencies |
| `configs/swift/.swift-format`, `.swiftlint.yml` | swift-format and SwiftLint, set up not to conflict |
| `configs/kotlin/.editorconfig`, `detekt.yml` | ktlint settings and detekt overrides |
| `configs/csharp-unity/.editorconfig` | C# formatting, naming rules, analyzer severities, Unity notes |
| `configs/markdown/.markdownlint.jsonc` | markdownlint rules for project repos |
| `examples/README.md` | What each sample shows; the `bad/` convention |
| `examples/c-cpp/teleop_velocity_limiter/` | ROS 2 C++ component package (library, node, gtest, launch, config) |
| `examples/c-cpp/firmware/` | C ring buffer for microcontroller firmware |
| `examples/python/` | `src/teleop_episodes/` module and `tests/` |
| `examples/javascript-typescript/` | `src/` modules and `tsconfig.json` |
| `examples/swift/Sources/` | SwiftUI view, `@Observable` view model, watchOS model |
| `examples/kotlin/src/main/kotlin/edu/kent/cs/atr/` | Pepper speech queue and Wear OS Compose card |
| `examples/csharp-unity/Assets/Scripts/Teleoperation/` | Unity MonoBehaviour and command struct |
| `examples/csharp-unity/check/` | Check harness only: `.csproj` and UnityEngine stand-ins (never copy into Unity) |
| `examples/*/bad/` | Deliberately bad samples that every linter must reject; never copy |
| `scripts/check-configs.sh` | Runs every formatter and linter against `examples/` in Docker; `--local` uses installed tools |
| `templates/README.template.md` | README template for lab project repos |
| `templates/AGENTS.template.md` | AGENTS.md template for lab project repos |

## Sources of truth

- **Lab facts** (names, director, projects, platforms, contacts): only `references/brand-foundation.md` in the lab design skill (`atr-lab-design`). This repo needs very few: the lab's full name on first reference, then "the lab"; "Department of Computer Science, Kent State University".
- **Technical facts** (tool versions, rules, commands, dates): only official sources checked on the date in each page's footer: docs.ros.org, ros.org/reps, the ament_lint and ros2_documentation repos, clang.llvm.org, docs.astral.sh, mypy.readthedocs.io, typescript-eslint.io, eslint.org, prettier.io, swift.org, the swiftlang and realm/SwiftLint repos, kotlinlang.org, developer.android.com, ktlint.github.io, detekt.dev, learn.microsoft.com, docs.unity3d.com, unity.com, docs.github.com, git-scm.com, semver.org, conventionalcommits.org, docs.platformio.org, docs.arduino.cc and each tool's GitHub releases (plus npm and PyPI metadata for version numbers). Link the source next to the fact.
- **Tested versions** live in the table in `configs/README.md` and in `scripts/check-configs.sh`; the two must match.
- **Never invent names, rooms, results, versions or dates: use `[brackets]`** and list them under Open items. If a fact cannot be verified, say so in the text or leave it out.

## Writing rules

- Two readers: a new student who skims and a coding agent that opens one file cold. One topic per file, stable paths, relative links inside the repo, full `https://github.com/ATR-Lab/<repo>/blob/<branch>/<path>` links across repos (`master` here and in `about` and `getting-started-atr-lab`; `main` in `all-things-ros2` and `.github`).
- Voice: precise, curious, hands-on, welcoming, grounded. "We" for the lab, "you" for the reader, active voice, short paragraphs, outcome first. Define jargon on first use.
- Kent State style: sentence-case headings, no Oxford comma in a simple series, "and" not "&" in prose, one through nine spelled out (numerals with units and versions), dates like "Sept. 30, 2026", no emoji, no exclamation marks.
- Words: ROS 2 (never "ROS2" in prose), teleoperation, open-source (adjective), real-world (adjective), leader-follower. Cut hype words (see the grep in the next section).
- Never write "ATR" alone or "KSU" in running copy; never print the lab handles or rooms from the brand foundation's "never print" list.
- Every page except README.md, AGENTS.md and CLAUDE.md: `# Title`, a `> **Read this when** ...` line, two to four sentences with the one thing to remember, `## Contents` when there are five or more sections, sections in the order what, why, how, reference, `## Related`, then the footer line `<sub>Last reviewed: ... · Sources checked on that date · [Suggest a change](...)</sub>`.
- Language pages keep the same section order: style we follow, naming and layout, what the configs do, install, editor setup, adopt the config, CI, common mistakes, related.
- Commands: fenced blocks tagged with the language, one command per line, no `$` prompts, a comment when a step is not obvious and the OS or version they are for.
- GitHub alerts (`> [!NOTE]`, `> [!WARNING]`, `> [!CAUTION]`) sparingly; safety goes in WARNING or CAUTION.
- Mermaid diagrams start with the lab theme line:

  ```text
  %%{init: {'theme':'base','themeVariables':{'primaryColor':'#003976','primaryTextColor':'#FFFFFF','primaryBorderColor':'#00295F','secondaryColor':'#EFAB00','secondaryTextColor':'#1B2533','tertiaryColor':'#F3F6FA','tertiaryTextColor':'#1B2533','lineColor':'#2C8ECD','textColor':'#1B2533','edgeLabelBackground':'#F3F6FA','clusterBkg':'#F3F6FA','clusterBorder':'#D6DEE8','titleColor':'#003976'}}}%%
  ```

  When edges carry labels, add `linkStyle default color:#1B2533` at the end of the diagram so the labels stay readable. Don't set a font in the theme line: a custom `fontFamily` makes node text clip.

- Third-party tools are facts, not endorsements.
- **Repo-specific:** a config change is not done until `scripts/check-configs.sh <language>` passes, including the bad-sample checks. Keep each config's header comment, `configs/README.md` and the script's version variables in sync. Samples in `examples/` stay small and realistic; bad samples carry a comment naming the rule each line breaks.

## How to check your work

Run from the repo root:

```bash
# 1. Configs: every formatter and linter against examples/ (needs Docker)
scripts/check-configs.sh
# 2. Brand, facts and Kent State style (exit 0 = no errors); README files are named explicitly
PYTHONDONTWRITEBYTECODE=1 ~/.claude/skills/atr-lab-design/.venv/bin/python ~/.claude/skills/atr-lab-design/scripts/brand_check.py $(git ls-files --others --cached --exclude-standard '*.md')
# 3. Markdown structure
npx --yes markdownlint-cli2 "**/*.md"
# 4. Hype words and "ROS2" in prose (review each hit; slugs, URLs and code are fine)
grep -rnE -i "cutting-edge|state-of-the-art|revolutionary|groundbreaking|world-class|innovative|novel|leverag|utiliz|seamless|robust|holistic|transformative|pivotal|delve|furthermore|moreover|ROS2" --include='*.md' .
# 5. Links (what the docs workflow runs; --offline checks only links inside the repo)
docker run --rm -v "$PWD":/input -w /input lycheeverse/lychee --offline --no-progress "**/*.md"
```

Brand-check warnings for intentional `[placeholders]` are expected. Templates in `templates/` are full of placeholders by design.

## Open items

Placeholders only the lab can fill. Agents must not fill these by guessing.

| File | Placeholder | Who can fill it |
|---|---|---|
| `docs/git-and-github.md` | `[agreed review time, for example two working days: lab to confirm]` | Director or lab manager |
| `docs/git-and-github.md` | `[lab data storage location: lab manager to confirm]` | Lab manager |
| `docs/git-and-github.md` | `[repo admin: lab manager to confirm]` | Lab manager (GitHub org owners) |
| `docs/git-and-github.md` | `[lab contact for security incidents: lab manager to confirm]` | Lab manager |
| `docs/git-and-github.md` | `[the lab's shared-machine account policy: lab manager to confirm]` | Lab manager |
| `docs/hardware.md` | `[cloud CAD workspace: lab manager to confirm]` | Lab manager |
| `docs/hardware.md` | `[parts ordering process: lab manager to confirm]` | Lab manager |
| `docs/hardware.md` | `[printer booking process: lab manager to confirm]` | Lab manager |

The BOM example in `docs/hardware.md` and both files in `templates/` contain placeholders on purpose (`[supplier]`, `[Project name]` and so on); they stay.

Decisions the lab may want to revisit: the ktlint `android_studio` style, the `_camelCase` private-field convention for C#, Swift's four-space indentation and 120-column limit and Python's single quotes. Each page explains the choice.

## Related repos

- [ATR-Lab/.github](https://github.com/ATR-Lab/.github): the organization's GitHub profile page; which repo answers which question.
- [about](https://github.com/ATR-Lab/about): who the lab is, its research, achievements and press kit.
- [getting-started-atr-lab](https://github.com/ATR-Lab/getting-started-atr-lab): how a new member gets started, lab rules, safety, research standards and hardware.
- [dev-guidelines](https://github.com/ATR-Lab/dev-guidelines): this repo; how lab code is written, reviewed and checked.
- [all-things-ros2](https://github.com/ATR-Lab/all-things-ros2): how to learn, install and debug ROS 2 on lab robots.
