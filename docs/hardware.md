# Hardware and firmware

> **Read this when** you design a part, write microcontroller firmware, wire a robot or print something, and want the next person to find, understand and rebuild it.

Hardware work needs the same care as code: files someone else can open, versions you can tell apart and wiring you can trace without taking the robot apart. This page sets the conventions for CAD files, bills of materials, firmware projects, wiring and 3D prints. The one thing to remember: every physical thing the lab builds has its source files, a BOM and a photo in a repo.

> [!WARNING]
> Power off and disconnect batteries before you change wiring, and follow the [lab safety guide](https://github.com/ATR-Lab/getting-started-atr-lab/blob/master/lab-rules/safety.md) for batteries, power tools, printers and moving robots. The lab's equipment list is in [Getting started: hardware](https://github.com/ATR-Lab/getting-started-atr-lab/blob/master/hardware/README.md).

## Contents

- [Repo layout for a hardware project](#repo-layout-for-a-hardware-project)
- [CAD files: naming and versions](#cad-files-naming-and-versions)
- [Bills of materials](#bills-of-materials)
- [Firmware projects](#firmware-projects)
- [Wiring: colors and labels](#wiring-colors-and-labels)
- [3D print files](#3d-print-files)
- [Related](#related)

## Repo layout for a hardware project

```text
gripper-mount/
├── README.md          # what it is, photo, how to build it, which robot it fits
├── cad/               # native CAD source and STEP exports
├── print/             # STL or 3MF files and print settings
├── electronics/       # KiCad project, wiring diagram
├── firmware/          # PlatformIO project
├── bom.csv            # bill of materials
└── photos/            # finished build, wiring close-ups
```

Track binary files (STEP, STL, 3MF, images) with Git LFS from the first commit; see [Git and GitHub](git-and-github.md#large-files-git-lfs).

## CAD files: naming and versions

- **Names:** lowercase kebab-case, `<project>-<part>-rev-<letter>`, for example `gripper-mount-bracket-rev-b.step`. The same name, with a different extension, for every format of the same part.
- **Revisions:** a letter for each version that was built or printed (A, B, C). Record what changed and why in the README ("Rev B: widened the cable slot to 8 mm").
- **Formats:** commit the native file you edit (a Fusion `.f3d` archive, a SolidWorks part, a FreeCAD `.FCStd` file) *and* a STEP export, so someone without that CAD tool can still open the part.
- **Cloud CAD** (Fusion, Onshape) keeps its own history. Mark built versions there too (Fusion calls them [milestones](https://help.autodesk.com/view/fusion360/ENU/?guid=TPD-DESIGN-MILESTONES)), and put the share link in the README: [cloud CAD workspace: lab manager to confirm].
- **Units:** millimeters in CAD, meters in robot descriptions (URDF uses SI units, [REP 103](https://www.ros.org/reps/rep-0103.html)). Say which one in the file name or README when it is not obvious.

## Bills of materials

Keep the BOM as a CSV file in the repo, so changes show up in diffs:

```csv
item,qty,part,manufacturer,mpn,supplier,supplier_part,unit_cost_usd,price_checked,notes
1,4,M3x8 socket head cap screw,,,[supplier],[supplier part number],,,stainless steel
2,1,Dynamixel servo,ROBOTIS,[model],[supplier],[supplier part number],[cost],[date],[supply voltage]
3,1,LiPo battery 3S,[manufacturer],[model],[supplier],[supplier part number],[cost],[date],see safety guide
```

- One row per distinct part; quantities for one complete build.
- Manufacturer part numbers (MPN) identify a part better than supplier links, which change.
- Record the date you checked a price (`price_checked`); prices change.
- Link datasheets for anything electrical.
- Order through [parts ordering process: lab manager to confirm].

## Firmware projects

We use [PlatformIO](https://docs.platformio.org/en/latest/core/quickstart.html) for new firmware, because it pins the board platform and library versions in one file and builds from the command line and in CI. The Arduino IDE is fine for quick experiments.

```text
firmware/
├── platformio.ini     # board, framework, pinned platform and library versions
├── src/               # main.cpp and sources
├── include/           # headers
├── lib/               # project-private libraries
└── test/              # unit tests for `pio test`
```

- **Pin versions** in `platformio.ini` (`platform = <name>@<version>`, `lib_deps = <library>@<version>`) so a build from last year still builds today.
- **Style:** the same [`.clang-format`](../configs/c-cpp/.clang-format) as the rest of our C and C++, which also formats `.ino` sketches. Libraries published for the Arduino ecosystem follow Arduino's own [library style guide](https://docs.arduino.cc/learn/contributions/arduino-library-style-guide/) (camelCase functions), so they look like other Arduino libraries.
- **Checks:** `pio run` builds, `pio test` runs unit tests and `pio check` runs static analysis (cppcheck by default; clang-tidy is also supported, see the [static analysis docs](https://docs.platformio.org/en/latest/advanced/static-code-analysis/index.html)).
- **Secrets:** Wi-Fi passwords and tokens go in an ignored `include/secrets.h`; commit `include/secrets.example.h` with placeholders.
- **Arduino IDE projects:** [Arduino CLI](https://arduino.github.io/arduino-cli/latest/) builds them from the command line, and [Arduino Lint](https://arduino.github.io/arduino-lint/latest/) checks libraries and sketches.

Install PlatformIO with its VS Code extension (**PlatformIO IDE**, `platformio.platformio-ide`), or on the command line:

```bash
# macOS
brew install platformio
# Ubuntu 24.04: the installer script recommended by the PlatformIO docs
curl -fsSL -o get-platformio.py https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py
python3 get-platformio.py
```

## Wiring: colors and labels

These are the lab's conventions. When a robot vendor's harness uses other colors, keep the vendor's and write them in the README.

| Wire | Color |
|---|---|
| Positive supply (+V) | Red |
| Ground (0 V) | Black |
| Second supply voltage on the same robot | Another color, written on the label ("5 V", "12 V") |
| Signals and buses (UART, I2C, CAN, RS-485) | Any other colors, one color per signal, listed in the wiring diagram's legend |

- **Label both ends of every cable** with the same ID, matching the wiring diagram (`W07: battery to fuse box`). Heat-shrink labels survive longer than tape.
- **Label connectors with their voltage** where two connectors could be swapped.
- **Fuse the battery** close to its terminal, and write the fuse rating in the diagram.
- **Draw it**: a KiCad schematic or a diagram (commit the source and a PDF or SVG export), plus a photo of the finished wiring. KiCad files are plain text ([file formats](https://dev-docs.kicad.org/en/file-formats/sexpr-intro/)), so they diff well; start from GitHub's [KiCad `.gitignore`](https://github.com/github/gitignore/blob/main/KiCad.gitignore).

## 3D print files

- Commit the CAD source, the STEP export and the printable file (STL or 3MF) with the same name and revision.
- Write the print settings in the README or a `print/settings.md`: printer, material, layer height, infill, supports, orientation and any post-processing.
- Note which robot and which revision a part fits.
- 3MF can store settings with the model; still write them down, because slicers read them differently.
- Resin printers and their chemicals have their own safety rules; read the safety guide before you use one. Book printers through [printer booking process: lab manager to confirm].

## Related

- [Getting started: hardware](https://github.com/ATR-Lab/getting-started-atr-lab/blob/master/hardware/README.md): the lab's robots and equipment
- [Lab safety guide](https://github.com/ATR-Lab/getting-started-atr-lab/blob/master/lab-rules/safety.md)
- [C and C++](c-cpp.md): style and linters for firmware code
- [ROS 2 packages](ros2-packages.md): drivers and robot descriptions
- [multi-servo-dynamixel-library](https://github.com/ATR-Lab/multi-servo-dynamixel-library): a public lab library for Dynamixel servos

<sub>Last reviewed: Sept. 30, 2026 · Sources checked on that date · [Suggest a change](https://github.com/ATR-Lab/dev-guidelines/issues/new)</sub>
