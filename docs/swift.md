# Swift

> **Read this when** you build a visionOS, watchOS or iOS app (for example, a teleoperation interface on Apple Vision Pro or a study app on Apple Watch) and want consistent code that Xcode, your reviewer and CI agree on.

We follow Apple's Swift API Design Guidelines, format with swift-format (it ships with the Swift toolchain) and lint with SwiftLint. The one thing to remember: swift-format owns layout and SwiftLint owns everything else; our SwiftLint config switches off the few rules that would fight swift-format.

## Contents

- [The style we follow](#the-style-we-follow)
- [Naming and file layout](#naming-and-file-layout)
- [What the configs do](#what-the-configs-do)
- [Install the tools](#install-the-tools)
- [Editor setup](#editor-setup)
- [Adopt the config in a repo](#adopt-the-config-in-a-repo)
- [Check in CI](#check-in-ci)
- [Common mistakes](#common-mistakes)
- [Related](#related)

## The style we follow

The [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) are the style guide for Swift. Their first rule, "Clarity at the point of use is your most important goal," decides most naming questions: read the call site out loud and check that it makes sense.

For layout we use swift-format with two changes from its defaults: four-space indentation (Xcode's default, so files look the same in every editor) and 120-character lines (SwiftUI modifier chains nest deeply).

## Naming and file layout

| Thing | Style | Example |
|---|---|---|
| Types and protocols | `UpperCamelCase` | `TeleopViewModel`, `RobotLink` |
| Everything else: properties, functions, cases, parameters | `lowerCamelCase` | `joystickMoved(x:y:)`, `.teleoperated` |
| Booleans | Read as an assertion | `isConnected`, `showsDetails` |
| Factory methods | Start with `make` | `makeRobotLink()` |
| Protocols that describe a capability | End in `-able`, `-ible` or `-ing` | `Sendable`, `Equatable` |
| Units | In the name or a doc comment | `maxLinearSpeed` with `/// meters per second` |
| Files | One main type per file, named after it | `TeleopViewModel.swift` |

Layout:

- Swift packages: `Sources/<Module>/` and `Tests/<Module>Tests/` (the Swift Package Manager default).
- Xcode app projects: group files by feature (`Teleoperation/`, `Status/`), not by kind (`Views/`, `Models/`), so a feature's view, view model and model sit together.
- SwiftUI: views end in `View`; UI state lives in an `@Observable` view model marked `@MainActor`; `@State` properties are `private`.

`examples/swift/Sources/` has a view model, a SwiftUI view and a small watchOS model that pass both tools.

## What the configs do

**`.swift-format`** (JSON) sets `indentation` to four spaces and `lineLength` to 120, and turns on a few lint rules that are off by default:

- `BeginDocumentationCommentWithOneLineSummary`: doc comments start with a one-sentence summary.
- `NeverUseForceTry`: no `try!`.

The full rule list is in the swift-format [rule documentation](https://github.com/swiftlang/swift-format/blob/main/Documentation/RuleDocumentation.md).

**`.swiftlint.yml`** keeps SwiftLint's default rules, with these changes:

| Change | Rules | Why |
|---|---|---|
| Off | `opening_brace`, `trailing_comma`, `vertical_parameter_alignment` | swift-format's output breaks them. We found these by formatting sample code with swift-format and then running every SwiftLint rule on it |
| Off | `todo` | TODO comments are fine; track the work in an issue |
| On (opt-in) | `accessibility_label_for_image` | VoiceOver users need a label for every meaningful image, on visionOS and watchOS too |
| On (opt-in) | `private_swiftui_state` | `@State` belongs to the view that owns it |
| On (opt-in) | `empty_count`, `first_where`, `contains_over_first_not_nil`, `toggle_bool` and others | Clearer, faster code; each has an automatic fix |
| Tuned | `line_length` warns at 120 (same as swift-format), errors at 160 | Long string literals that swift-format cannot break |
| Tuned | `identifier_name` allows `x`, `y`, `z`, `i`, `j`, `dt`, `id` | Short names that are clear in math and robotics code |

## Install the tools

macOS: install Xcode 16 or later. Its toolchain includes swift-format, which you run as `swift format` ([swift-format README](https://github.com/swiftlang/swift-format)). Then:

```bash
brew install swiftlint
swift format --version
swiftlint version
```

Ubuntu 24.04 (for CI or server-side Swift): install the toolchain with swiftly, as [swift.org](https://www.swift.org/install/linux/) describes, or use the official `swift:6.4-noble` Docker image. SwiftLint publishes a Docker image too:

```bash
docker run --rm -v "$PWD":/work -w /work swift:6.4-noble swift format lint --strict --recursive .
docker run --rm -v "$PWD":/work -w /work ghcr.io/realm/swiftlint:0.65.1 swiftlint lint --strict
```

## Editor setup

**Xcode.** Add SwiftLint as a build tool plugin so warnings appear inline after each build. In the project's Package Dependencies, add `https://github.com/SimplyDanny/SwiftLintPlugins` (the repo SwiftLint's README recommends for plugins), then add `SwiftLintBuildToolPlugin` under your target's Build Phases, in Run Build Tool Plug-ins. Format from Terminal before you commit:

```bash
swift format --in-place --recursive .
```

**VS Code.** Install the **Swift** extension (`swiftlang.swift-vscode`) for language support, and run the same `swift format` and `swiftlint` commands in the integrated terminal.

## Adopt the config in a repo

Run from the folder that holds your `.xcodeproj` or `Package.swift`:

```bash
BASE=https://raw.githubusercontent.com/ATR-Lab/dev-guidelines/master/configs/swift
curl -fsSLO "$BASE/.swift-format"
curl -fsSLO "$BASE/.swiftlint.yml"
swift format --in-place --recursive .   # reformat once, in its own commit
swiftlint lint --fix                    # apply SwiftLint's automatic fixes
swiftlint lint --strict                 # what is left needs a person
```

## Check in CI

Linux containers are enough for formatting and linting; you only need a macOS runner to build the app.

```yaml
name: swift
on: [push, pull_request]
jobs:
  swift-format:
    runs-on: ubuntu-latest
    container: swift:6.4-noble
    steps:
      - uses: actions/checkout@v7
      - run: swift format lint --strict --recursive --parallel .
  swiftlint:
    runs-on: ubuntu-latest
    container: ghcr.io/realm/swiftlint:0.65.1
    steps:
      - uses: actions/checkout@v7
      - run: swiftlint lint --strict
```

## Common mistakes

- **Letting Xcode's re-indent and swift-format disagree.** Our four-space setting matches Xcode's default; if you changed Xcode's indentation, set it back or run `swift format` before every commit.
- **`try!` and `as!`** in app code. A crash on a headset or a watch in the middle of a session is worse than an error message. Use `do`/`catch` and `as?`.
- **Public `@State`.** Keep it `private`; pass data in through `let` properties or bindings.
- **Images without labels.** Give meaningful images an `accessibilityLabel`, and mark decorative ones with `.accessibilityHidden(true)`.
- **Ignoring Swift 6 concurrency warnings.** Mark value types that cross tasks `Sendable` and UI types `@MainActor`, as the example does, instead of silencing the checker.
- **Committing `xcuserdata/`, `DerivedData/` or `.build/`.** Use the Swift template from [github/gitignore](https://github.com/github/gitignore).

## Related

- Config files: [`configs/swift/`](../configs/swift/) and the example in [`examples/swift/`](../examples/swift/)
- [Documentation](documentation.md#docstrings-per-language): Swift doc comments
- [Git and GitHub](git-and-github.md): branches, commits and pull requests
- swift-format [configuration](https://github.com/swiftlang/swift-format/blob/main/Documentation/Configuration.md), SwiftLint [rule directory](https://realm.github.io/SwiftLint/rule-directory.html)

<sub>Last reviewed: Sept. 30, 2026 · Sources checked on that date · [Suggest a change](https://github.com/ATR-Lab/dev-guidelines/issues/new)</sub>
