# [Project name]

<!--
README template for ATR Lab project repos, from https://github.com/ATR-Lab/dev-guidelines.
Replace every [bracketed placeholder], delete sections that do not apply, and delete this comment.
Keep headings in sentence case. Commands: one per line, no "$" prompts, say which OS they are for.
-->

[One sentence: what this is, and who it is for. Example: "ROS 2 driver and teleoperation launch files for the [robot model], for lab members running experiments on it."]

> [!NOTE]
> **Status:** [active / maintained / archived]. Last tested on [date] with [robot model and firmware version], [Ubuntu version] and [ROS 2 distribution].

## Quick start

The fewest steps from a clean machine to something running. For [Ubuntu version] with [ROS 2 distribution]:

```bash
# 1. Get the code
git clone [repo URL]
cd [repo folder]
# 2. Install dependencies
rosdep install --from-paths src --ignore-src -y
# 3. Build
colcon build
# 4. Run
source install/setup.bash
ros2 launch [package] [file].launch.py
```

## Requirements

| What | Version or detail |
|---|---|
| Robot or hardware | [robot model, sensors, cables] |
| Operating system | [Ubuntu version / macOS version] |
| ROS 2 distribution | [distribution] |
| Other software | [SDK, Unity version, Xcode version] |
| Accounts or licenses | [what is needed and who to ask] |

## Usage

[Common tasks, one short subsection each: how to start the robot, how to record data, how to change a parameter. Link launch files and parameter files by path.]

| Parameter | Default | Unit | What it does |
|---|---|---|---|
| `[name]` | `[value]` | [unit] | [description] |

## Safety

> [!WARNING]
> [What can go wrong with the hardware (unexpected motion, pinch points, battery hazards) and how to stop it (emergency stop location, software stop command). Follow the lab safety guide.]

## Troubleshooting

| Problem | Fix |
|---|---|
| [Error message or symptom] | [What to do] |

## Repo map

| Path | What it holds |
|---|---|
| `[folder]/` | [description] |

## Contributing

Branches, commits, code style and checks follow the lab's [dev guidelines](https://github.com/ATR-Lab/dev-guidelines). Before a pull request, run:

```bash
[format, lint and test commands]
```

Coding agents: read `AGENTS.md` first.

## License and citation

[License name]; see `LICENSE`.

If you use this work in a publication, please cite:

```bibtex
[BibTeX entry, or delete this block]
```

[Funding acknowledgment exactly as the award requires, or delete this line: "This material is based upon work supported by [Sponsor] under award No. [Grant No.]."]

---

Advanced Telerobotics Research Lab · Department of Computer Science · Kent State University
