# Documentation

> **Read this when** you start a repo, finish a feature someone else will use or set up a repo so coding agents can work in it.

Good code still needs a README that gets a new person from clone to running robot, docstrings that say what a function promises and an `AGENTS.md` that gives coding agents the same map. This page sets the standard for all three, plus diagrams and changelogs. The one thing to remember: if you had to explain something to a lab mate out loud, write it down in the repo.

## Contents

- [README standard](#readme-standard)
- [Docstrings per language](#docstrings-per-language)
- [AGENTS.md and CLAUDE.md](#agentsmd-and-claudemd)
- [Diagrams](#diagrams)
- [Changelogs](#changelogs)
- [Writing well](#writing-well)
- [Related](#related)

## README standard

Every repo has a `README.md` at its root. Start from [`templates/README.template.md`](../templates/README.template.md), which has these sections in this order:

| Section | What it answers |
|---|---|
| Title and one sentence | What is this, and who is it for? |
| Status | Active, maintained or archived; which robot and software versions it was last tested with |
| Quick start | The fewest commands from a clean machine to something running |
| Requirements | Hardware (which robot, which sensors), OS and ROS 2 distribution, accounts or licenses |
| Usage | Common tasks, launch files, parameters |
| Safety | What can go wrong with the hardware and how to stop it (a `> [!WARNING]` block) |
| Troubleshooting | The errors people actually hit, with fixes |
| Repo map | Folders and what they hold |
| Contributing | Branches, style and checks (link to this repo) |
| License and citation | License, how to cite the paper if there is one, funding acknowledgment |

Rules:

- **Commands are copyable.** One command per line in a fenced block tagged with its language, no `$` prompts and a comment when a step is not obvious. Say which OS and version they are for.
- **Everything the lab must supply stays a `[bracketed placeholder]`** until someone confirms it: robot names and locations, people, accounts, grant numbers. Never guess them.
- **Images have alt text.** Describe what the image shows; decorative images get `alt=""`.
- **Keep it current.** A README that describes last year's setup is worse than none; update it in the same PR as the change.

## Docstrings per language

Document every public class, function and message field: what it does, its units and what it returns or throws. Put examples in tests, not in long comments.

| Language | Format | Minimal example |
|---|---|---|
| C, C++ | Doxygen, as the ROS 2 style asks: `///` or `/** */` for docs, `//` for notes ([Doxygen docs](https://www.doxygen.nl/manual/docblocks.html)) | `/// Returns the command to send, in m/s and rad/s.` |
| Python | Google style: summary line, then `Args:`, `Returns:`, `Raises:` ([Google guide 3.8](https://google.github.io/styleguide/pyguide.html#s3.8-comments-and-docstrings)) | `"""Load frames from a JSON file."""` |
| Swift | `///` with a one-line summary, then `- Parameters:`, `- Returns:`, `- Throws:` ([Apple docs](https://developer.apple.com/documentation/xcode/writing-symbol-documentation-in-your-source-files)) | `/// Stops the robot.` |
| Kotlin | KDoc: `/** */` with `@param`, `@return`, `@throws` ([KDoc](https://kotlinlang.org/docs/kotlin-doc.html)) | `/** Adds a phrase to the queue. */` |
| C# | XML comments: `/// <summary>`, `<param>`, `<returns>` ([XML documentation](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/)) | `/// <summary>Stops following the hand.</summary>` |
| TypeScript, JavaScript | TSDoc or JSDoc: `/** */` with `@param`, `@returns`, `@throws` ([TSDoc](https://tsdoc.org/)) | `/** Formats a speed for display. */` |

Every file in [`examples/`](../examples/) shows the format for its language and passes the linters.

## AGENTS.md and CLAUDE.md

Coding agents read a file at the repo root before they work. We keep one canonical file and point the others at it:

- **`AGENTS.md` is the source of truth.** [AGENTS.md](https://agents.md/) is an open format, "a README for agents"; OpenAI's Codex reads it before doing any work ([Codex docs](https://learn.chatgpt.com/docs/agent-configuration/agents-md)).
- **`CLAUDE.md` holds exactly one line: `@AGENTS.md`.** Claude Code reads `CLAUDE.md` and imports files written as `@path` ([Claude Code memory docs](https://code.claude.com/docs/en/memory)), so both tools read the same instructions and nothing drifts apart.

Start from [`templates/AGENTS.template.md`](../templates/AGENTS.template.md). It has the same sections as the `AGENTS.md` files in the lab's docs repos, plus safety rules:

1. What the repo is, who uses it and what it is not.
2. **Repo map**: every folder and important file, one line each.
3. **Sources of truth**: where facts come from (datasheets, lockfiles, papers) and the rule that agents never invent names, results, versions or dates.
4. **Writing rules**: which configs from this repo apply, the commit message style, units and frames.
5. **How to check your work**: the exact format, lint, build and test commands.
6. **Safety rules**: what an agent must never do, such as run code that moves the robot or change speed limits without review.
7. **Open items**: every `[placeholder]` and who can fill it.
8. **Related repos**.

Update `AGENTS.md` in the same PR as any change to commands, layout or rules. An outdated map misleads agents faster than no map. [AI-assisted development](ai-assisted-development.md) has the rules for using agents in lab repos.

## Diagrams

- **Mermaid in Markdown** for architecture, ROS 2 graphs and flows. GitHub renders `mermaid` code blocks ([creating diagrams](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-diagrams)), and the source stays diffable. Start each diagram with the lab theme line from [`AGENTS.md`](../AGENTS.md#writing-rules) so it reads in light and dark mode.
- **GitHub also renders ASCII STL files** in the browser (same page), which is handy for printed parts; see [Hardware and firmware](hardware.md).
- **Other drawings**: commit the editable source next to the exported image (`robot-wiring.drawio` and `robot-wiring.svg`), so the next person can edit it.
- Every diagram gets a sentence of text that says what it shows, for readers who cannot see it.

## Changelogs

Repos that publish releases keep a `CHANGELOG.md` in the [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/) format:

```markdown
## [Unreleased]

## [1.4.0] - 2026-09-30

### Added

- Dead-man switch timeout parameter (`deadman_timeout_s`).

### Fixed

- The follower no longer coasts after the operator releases the switch.
```

- Group entries under Added, Changed, Deprecated, Removed, Fixed and Security.
- Write for users of the software, not for its developers; link the PR for details.
- The dates follow the format's `YYYY-MM-DD`, an exception to the lab's "Sept. 30, 2026" style for prose.

## Writing well

- Lead with what the reader can do, then how. Short paragraphs, active voice, "you" for the reader.
- Define jargon the first time: "teleoperation (controlling a robot from a distance)".
- For bigger docs, separate tutorials, how-to guides, reference and explanation, as [Diátaxis](https://diataxis.fr/) describes.
- Good starting points: Write the Docs' [beginner's guide to docs](https://www.writethedocs.org/guide/writing/beginners-guide-to-docs/) and [RTFM? How to write a manual worth reading](https://opensource.com/business/15/5/write-better-docs).
- Lint Markdown with [`configs/markdown/.markdownlint.jsonc`](../configs/markdown/.markdownlint.jsonc); the VS Code extension is **markdownlint** (`DavidAnson.vscode-markdownlint`).

## Related

- [README template](../templates/README.template.md) and [AGENTS template](../templates/AGENTS.template.md)
- [AI-assisted development](ai-assisted-development.md)
- [Git and GitHub](git-and-github.md#releases-and-tags): releases and tags
- [Research standards](https://github.com/ATR-Lab/getting-started-atr-lab/blob/master/research/standards.md) in Getting started: papers, citations and data

<sub>Last reviewed: Sept. 30, 2026 · Sources checked on that date · [Suggest a change](https://github.com/ATR-Lab/dev-guidelines/issues/new)</sub>
