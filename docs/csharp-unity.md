# C# and Unity

> **Read this when** you write C# for a Unity 6 VR or XR teleoperation app (for example, on Meta Quest) or for a plain .NET tool, and want Rider, Visual Studio, VS Code and CI to apply the same rules.

We follow Microsoft's C# coding conventions and pick, from the options Unity's C# style guide offers, the naming that matches Microsoft's. One `.editorconfig` carries the formatting rules, the naming rules and the analyzer severities, including the Unity-specific analyzers. The one thing to remember: your editor enforces these rules while you type; Unity's own compiler does not run the .NET code-style rules, so CI checks them with `dotnet format`.

## Contents

- [The style we follow](#the-style-we-follow)
- [Naming and file layout](#naming-and-file-layout)
- [What the config does](#what-the-config-does)
- [How Unity 6 uses analyzers and .editorconfig](#how-unity-6-uses-analyzers-and-editorconfig)
- [Install and editor setup](#install-and-editor-setup)
- [Adopt the config in a repo](#adopt-the-config-in-a-repo)
- [Check in CI](#check-in-ci)
- [Common mistakes](#common-mistakes)
- [Related](#related)

## The style we follow

- **Microsoft's [common C# code conventions](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions)** and [identifier naming rules](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/identifier-names): Allman braces (each brace on its own line), four-space indentation, PascalCase for types and members.
- **Unity's C# style guide** ([Unity 6 edition](https://unity.com/resources/c-sharp-style-guide-unity-6)) for Unity-specific advice: serialized fields, MonoBehaviour messages, organizing scripts. Its [naming tips](https://unity.com/how-to/naming-and-code-style-tips-c-scripting-unity) say Unity's own guides prefix private fields with `m_`, constants with `k_` and statics with `s_`, and that others use an underscore instead. We use the underscore, because it is what Microsoft's conventions and the .NET libraries use, and the Inspector hides it (`_maxSpeed` shows as "Max Speed").

Unity 6 compiles **C# 9.0**, and its default API compatibility level is .NET Standard 2.1 ([C# compiler](https://docs.unity3d.com/6000.0/Documentation/Manual/csharp-compiler.html), [.NET profile support](https://docs.unity3d.com/6000.0/Documentation/Manual/dotnet-profile-support.html)). So no file-scoped namespaces, `record` types in serialized data or `init` setters in Unity code.

## Naming and file layout

| Thing | Style | Example |
|---|---|---|
| Namespaces | `PascalCase`, by feature | `Atr.Teleoperation` |
| Classes, structs, enums, delegates | `PascalCase` | `HandTargetFollower`, `TeleopCommand` |
| Interfaces | `I` + `PascalCase` | `IRobotLink` |
| Methods, properties, events | `PascalCase` | `Engage()`, `LastCommand` |
| Public fields | `PascalCase` (prefer a property or a `[SerializeField] private` field) | `MaxSpeed` |
| Private and internal fields, including `[SerializeField]` | `_camelCase` | `_maxSpeed` |
| Private static fields | `s_camelCase` | `s_instanceCount` |
| Constants | `PascalCase` | `DefaultSpeed` |
| Parameters and locals | `camelCase` | `angleStep` |
| Type parameters | `T` + `PascalCase` | `TMessage` |
| Files | One class per file, named after it (Unity requires this for MonoBehaviours) | `HandTargetFollower.cs` |

Keep your scripts under `Assets/Scripts/<Feature>/` with an assembly definition (`.asmdef`) per feature, so a change recompiles less and analyzers can be scoped to your code.

## What the config does

`configs/csharp-unity/.editorconfig` has four parts:

1. **Formatting** (`IDE0055`): Allman braces, four spaces, `using System` first. Unity's serialized files (`.unity`, `.prefab`, `.asset`, `.meta` and others) are left exactly as Unity writes them.
2. **Code style**: braces always (`IDE0011`), explicit access modifiers (`IDE0040`), no `this.`, `using` outside the namespace, block-scoped namespaces (C# 9).
3. **Naming** (`IDE1006`): the table above, as `dotnet_naming_rule` entries ([naming rules reference](https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/style-rules/naming-rules)).
4. **Analyzer severities**: the rules above as warnings, plus these [Microsoft.Unity.Analyzers](https://github.com/microsoft/Microsoft.Unity.Analyzers) rules raised from their default "info" level, which is easy to miss:

| Rule | Catches |
|---|---|
| `UNT0001` | Empty Unity message, such as an empty `Update()` that still costs a call every frame |
| `UNT0002` | Tag comparison with `==`; use `CompareTag` |
| `UNT0006` | A Unity message with the wrong signature, which Unity will never call |
| `UNT0007`, `UNT0008`, `UNT0029` | `??`, `?.` and `is null` on Unity objects, which skip Unity's destroyed-object check |
| `UNT0026` | `GetComponent` that allocates; use `TryGetComponent` |

## How Unity 6 uses analyzers and .editorconfig

This part confuses most people, so here is what the [Unity 6 manual](https://docs.unity3d.com/6000.0/Documentation/Manual/roslyn-analyzers.html) documents:

- **Your editor is where you see the rules.** Visual Studio, Rider and VS Code (with the Unity extension) read `.editorconfig` for formatting, naming and severities. Microsoft.Unity.Analyzers ships with Visual Studio's Unity workload and the VS Code Unity extension.
- **Analyzers inside the Unity Editor** are DLLs that you add to the project. Put the DLL under `Assets/`, turn off every platform in its import settings and give it the asset label `RoslynAnalyzer` (case-sensitive). It applies to the assembly definition it sits in and to assemblies that reference it ([install an analyzer](https://docs.unity3d.com/6000.0/Documentation/Manual/install-existing-analyzer.html)). Diagnostics then show in the Unity Console.
- **Severities for those analyzers** can come from `Assets/Default.ruleset` or, as the manual says, from `dotnet_diagnostic.<ID>.severity` lines in a root `.editorconfig` ([analyzer scope and rule sets](https://docs.unity3d.com/6000.0/Documentation/Manual/analyzer-scope-and-diagnostics.html)). A Unity issue reported on 2022.3 says the Editor ignored `.editorconfig` there, so check the Console after you change a severity; if nothing changes, use the rule set file.
- **The .NET code-style rules (IDE0055, IDE1006 and friends)** come with the .NET SDK and your editor, not with Unity. That is why CI runs `dotnet format`.

If you want Microsoft.Unity.Analyzers in the Unity Console too, its maintainers describe the rule-set route in [issue 242](https://github.com/microsoft/Microsoft.Unity.Analyzers/issues/242); their stated target is Visual Studio, so treat the Console as a bonus.

## Install and editor setup

Install Unity 6 through Unity Hub, and the .NET 10 SDK (the current long-term support release, supported until Nov. 14, 2028, per the [.NET support policy](https://dotnet.microsoft.com/en-us/platform/support/policy/dotnet-core)) for `dotnet format`:

```bash
# macOS
brew install --cask dotnet-sdk
# Ubuntu 24.04 (in the built-in Ubuntu feed)
sudo apt-get update && sudo apt-get install -y dotnet-sdk-10.0
```

Editors (pick one, and set it under Unity's **Preferences > External Tools**):

- **Rider** reads `.editorconfig` for naming styles and inspection severities ([Rider docs](https://www.jetbrains.com/help/rider/Using_EditorConfig.html)).
- **Visual Studio** with the "Game development with Unity" workload: reads `.editorconfig` and includes Microsoft.Unity.Analyzers.
- **VS Code** with the **Unity** extension (`visualstudiotoolsforunity.vstuc`), which installs C# Dev Kit and needs the Visual Studio Editor package 2.0.20 or later in Unity ([VS Code Unity guide](https://code.visualstudio.com/docs/other/unity)).

For a Meta Quest project, start with Meta's [Unity setup guide](https://developers.meta.com/vr/documentation/unity/unity-project-setup/).

## Adopt the config in a repo

Run from the repo root (the folder that holds `Assets/`):

```bash
curl -fsSLO https://raw.githubusercontent.com/ATR-Lab/dev-guidelines/master/configs/csharp-unity/.editorconfig
# Fix whitespace in your scripts once, in its own commit (works without project files)
dotnet format whitespace Assets --folder
```

Then open a script in your editor and fix the naming warnings it shows, one feature at a time. For a plain .NET project, add these to the `.csproj` so the build enforces the style too:

```xml
<PropertyGroup>
  <EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>
  <GenerateDocumentationFile>true</GenerateDocumentationFile>
</PropertyGroup>
```

`EnforceCodeStyleInBuild` runs the `IDE` rules during `dotnet build`, which is off by default ([MSBuild reference](https://learn.microsoft.com/en-us/dotnet/core/project-sdk/msbuild-props)); `GenerateDocumentationFile` lets `IDE0005` (unused usings) run on build.

## Check in CI

Unity projects: CI cannot build without a Unity license, but it can check formatting from the source files alone.

```yaml
name: csharp
on: [push, pull_request]
jobs:
  format:
    runs-on: ubuntu-latest
    container: mcr.microsoft.com/dotnet/sdk:10.0
    steps:
      - uses: actions/checkout@v7
      - run: dotnet format whitespace Assets --folder --verify-no-changes
```

Plain .NET projects: check everything, including naming and analyzers.

```yaml
      - run: dotnet format --verify-no-changes --severity warn
      - run: dotnet build -warnaserror
```

## Common mistakes

- **`?.`, `??` or `is null` on a `GameObject` or component.** Unity objects override `==` to report destroyed objects as null; the C# operators skip that check. Use `if (_hand == null)`.
- **Public fields just to see them in the Inspector.** Use `[SerializeField] private` so other scripts cannot change them.
- **`GetComponent` in `Update()`.** Cache the reference in `Awake()`, or use `TryGetComponent`.
- **Unity's `.meta` files missing from Git.** Commit every `.meta` file; Unity uses them to keep references. Use the Unity template from [github/gitignore](https://github.com/github/gitignore) so `Library/`, `Temp/` and `Logs/` stay out.
- **Coordinate frames.** Unity is left-handed with Y up; ROS 2 is right-handed with Z up ([REP 103](https://www.ros.org/reps/rep-0103.html)). Convert in one place (the bridge) and say so in a comment.
- **Large assets in plain Git.** Track textures, models and audio with Git LFS (see [Git and GitHub](git-and-github.md#large-files-git-lfs)).

## Related

- Config file: [`configs/csharp-unity/.editorconfig`](../configs/csharp-unity/.editorconfig); example scripts and the check harness in [`examples/csharp-unity/`](../examples/csharp-unity/)
- [TeleBot-4R-XR](https://github.com/ATR-Lab/TeleBot-4R-XR): the lab's public XR interface for TeleBot-4R
- [ROS 2 packages](ros2-packages.md): the robot side of a Unity teleoperation setup
- `dotnet format` [reference](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-format), analyzer [configuration options](https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/configuration-options), Microsoft.Unity.Analyzers [rule list](https://github.com/microsoft/Microsoft.Unity.Analyzers/blob/main/doc/index.md)

<sub>Last reviewed: Sept. 30, 2026 · Sources checked on that date · [Suggest a change](https://github.com/ATR-Lab/dev-guidelines/issues/new)</sub>
