# AGENTS.md: [repo-name]

<!--
AGENTS.md template for ATR Lab project repos, from https://github.com/ATR-Lab/dev-guidelines.
Save it as AGENTS.md at the repo root, and add a CLAUDE.md file that contains exactly one line: @AGENTS.md
Replace every [bracketed placeholder] you can fill from facts you know; list the rest under "Open items".
Keep it current: update it in the same pull request as any change to commands, layout or rules.
-->

[One paragraph: what this repo is (for example, "ROS 2 packages that drive the [robot model] and teleoperate it from a Meta Quest headset"), who uses it (lab members running [experiment or course]) and what it is not (for example, "not the robot's firmware, which lives in [repo]").]

## Repo map

Every folder and important file, one line each.

| Path | What it holds |
|---|---|
| `README.md` | Human quick start |
| `AGENTS.md` | This file |
| `[folder]/` | [description] |

## Sources of truth

- Robot and hardware facts (joint limits, voltages, ports): [datasheet or vendor docs URL] and `[path to config]`.
- Software versions: `package.xml`, `pyproject.toml`, `package.json` or `[other lockfile]`; do not assume newer versions.
- Lab facts (names, rooms, people, results): only what is written in this repo or given by a person. **Never invent names, rooms, results, versions or dates: use a `[bracketed placeholder]` and add it to Open items.**

## Writing rules

- Code style: the lab configs from [dev-guidelines](https://github.com/ATR-Lab/dev-guidelines/tree/master/configs), copied into this repo: [list the config files, for example `.clang-format`, `.clang-tidy`, `ruff.toml`].
- Commit messages: [the seven rules / Conventional Commits], subject line under 50 characters, imperative mood.
- Branches: `<type>/<short-description>`; never commit to the default branch; never force-push.
- Units: SI (meters, radians, seconds); frames follow REP 103 and REP 105.
- Docs: sentence-case headings; commands in fenced blocks, one per line, no `$` prompts.

## How to check your work

Run these before you say a task is done, and report their output.

```bash
[format check command]
[lint command]
[build command]
[test command]
```

## Safety rules

- Never run code that moves the robot ([launch files or scripts that command motion]) unless a person confirms they are watching it with the emergency stop in reach.
- Never change speed, force or workspace limits (`[path to limits file]`) without flagging it in the pull request as a safety change.
- Never flash firmware or change network settings on the robot.
- Never read or copy study data from `[path, if any]`; it may contain identifiable information.

## Open items

Placeholders that only a person can fill. Agents must not fill these by guessing.

| File | Placeholder | Who can fill it |
|---|---|---|
| `[file]` | `[placeholder]` | [maintainer / advisor / lab manager] |

## Related repos

- [dev-guidelines](https://github.com/ATR-Lab/dev-guidelines): code style, Git workflow and configs
- [getting-started-atr-lab](https://github.com/ATR-Lab/getting-started-atr-lab): lab onboarding, safety and hardware
- [all-things-ros2](https://github.com/ATR-Lab/all-things-ros2): ROS 2 basics and installation
- [other lab repos this one depends on]
