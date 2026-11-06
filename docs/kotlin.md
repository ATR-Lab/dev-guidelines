# Kotlin

> **Read this when** you build an Android app, such as an app for the Pepper robot or a Wear OS app, and want Android Studio, ktlint and detekt to agree.

We follow the Kotlin coding conventions and the Android Kotlin style guide. ktlint, in its `android_studio` code style, checks and fixes layout; detekt finds code smells. The one thing to remember: ktlint reads its settings from `.editorconfig`, and so does Android Studio, which is why the `android_studio` style keeps the two in agreement.

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

- **[Kotlin coding conventions](https://kotlinlang.org/docs/coding-conventions.html)** (JetBrains): four-space indentation, naming, trailing commas at the declaration site, idiomatic use of the language.
- **[Android Kotlin style guide](https://developer.android.com/kotlin/style-guide)** (Google): the same basics plus a 100-character column limit and no wildcard imports of any kind.

The two guides agree on almost everything. Where they differ, we take the Android guide, because most of our Kotlin runs on Android.

**Why ktlint's `android_studio` code style.** ktlint has three [code styles](https://ktlint.github.io/ktlint/1.8.0/rules/code-styles/): `ktlint_official` (the default, stricter than either guide), `intellij_idea` (based on the Kotlin coding conventions) and `android_studio` (based on the Android Kotlin style guide). We use `android_studio` because it matches both our guide and Android Studio's own formatter, so **Code > Reformat Code** and ktlint do not undo each other. Its default line limit is 100, as in the Android guide.

## Naming and file layout

| Thing | Style | Example |
|---|---|---|
| Packages | lowercase, the lab's web domain reversed | `edu.kent.cs.atr.pepper` (from `atr.cs.kent.edu`) |
| Classes, interfaces, objects | `PascalCase` | `SpeechQueue` |
| Functions, properties, variables | `camelCase` | `enqueue()`, `isSpeaking` |
| Constants (`const val`, top-level `val` of immutable data) | `UPPER_SNAKE_CASE` | `DEFAULT_CAPACITY` |
| Compose functions | `PascalCase` nouns, like types | `HeartRateCard()` |
| Backing properties | leading underscore | `_state` behind `state` |
| Files | Named after the single top-level class, or `PascalCase` for a group of top-level functions | `SpeechQueue.kt` |

Android projects follow the Gradle layout (`app/src/main/kotlin/...`, `app/src/test/`, `app/src/androidTest/`). Put the package path in the folder path; detekt checks that they match.

## What the configs do

**`configs/kotlin/.editorconfig`** (read by ktlint and Android Studio):

- `ktlint_code_style = android_studio`, `indent_size = 4`, `max_line_length = 100`.
- `ktlint_function_naming_ignore_when_annotated_with = Composable`, so Compose functions may start with a capital letter.
- The three `ij_kotlin_*import*` settings that stop Android Studio from writing wildcard imports, from ktlint's [IntelliJ IDEA guide](https://ktlint.github.io/ktlint/1.8.0/rules/configuration-intellij-idea/).
- `ij_kotlin_allow_trailing_comma = true`: trailing commas on declarations, as the Kotlin conventions encourage.

**`configs/kotlin/detekt.yml`** lists only the changes from detekt's defaults, so run it with `--build-upon-default-config`:

- `MaxLineLength` at 100, to match ktlint.
- `WildcardImport` with no exceptions (the default allows `java.util.*`; the Android guide does not).
- Compose-friendly settings: `FunctionNaming`, `LongParameterList` and `MagicNumber` ignore `@Composable` functions; `UnusedPrivateMember` ignores `@Preview` functions.
- `ForbiddenComment` allows `TODO` and `FIXME` and blocks only `STOPSHIP`.

We do not use the `detekt-formatting` plugin: it wraps ktlint 0.50.0, an old release whose rules differ from ktlint 1.8. Run ktlint itself instead.

> [!NOTE]
> detekt 1.23.8 is the current stable release (Feb. 21, 2025). Its [compatibility table](https://detekt.dev/docs/1.23.8/introduction/compatibility/) lists Kotlin 2.0.21, so code that uses newer language features may not parse. detekt 2.0 is in alpha; check its release notes before you switch.

## Install the tools

macOS:

```bash
brew install ktlint detekt
```

Ubuntu 24.04 (both tools need Java; we tested with Java 21):

```bash
sudo apt install openjdk-21-jre-headless
# ktlint: a self-contained launcher from the official GitHub release
curl -fsSLO https://github.com/ktlint/ktlint/releases/download/1.8.0/ktlint
chmod +x ktlint && sudo mv ktlint /usr/local/bin/
# detekt: the command-line jar from the official GitHub release
curl -fsSLO https://github.com/detekt/detekt/releases/download/v1.23.8/detekt-cli-1.23.8-all.jar
java -jar detekt-cli-1.23.8-all.jar --version
```

## Editor setup

**Android Studio.**

1. Put `.editorconfig` at the repo root. Android Studio, like IntelliJ IDEA, reads it when it formats code, including the `ij_kotlin_*` settings.
2. Add `kotlin.code.style=official` to `gradle.properties` so every machine starts from the Kotlin conventions ([migration guide](https://kotlinlang.org/docs/code-style-migration-guide.html)).
3. If a project was created long ago, delete `.idea/codeStyles/`, as ktlint's IntelliJ IDEA guide advises, so old XML code-style settings cannot compete with `.editorconfig`.
4. Optional: the community [ktlint plugin](https://plugins.jetbrains.com/plugin/15057-ktlint) shows ktlint results while you type.

**VS Code** is not a good fit for Android work; use Android Studio and run ktlint and detekt in the terminal.

## Adopt the config in a repo

Run from the repo root:

```bash
BASE=https://raw.githubusercontent.com/ATR-Lab/dev-guidelines/master/configs/kotlin
# No .editorconfig yet? Download ours. Already have one? Copy our [*.{kt,kts}] section into it instead.
curl -fsSLO "$BASE/.editorconfig"
mkdir -p config/detekt && curl -fsSL -o config/detekt/detekt.yml "$BASE/detekt.yml"
ktlint --format "**/src/**/*.kt" "**/*.kts"            # reformat once, in its own commit
detekt --input . --config config/detekt/detekt.yml --build-upon-default-config
```

To run detekt from Gradle instead, add its plugin to the app module ([detekt Gradle docs](https://detekt.dev/docs/1.23.8/gettingstarted/gradle/)):

```kotlin
plugins {
    id("io.gitlab.arturbosch.detekt") version "1.23.8"
}

detekt {
    config.setFrom("$rootDir/config/detekt/detekt.yml")
    buildUponDefaultConfig = true
}
```

Then run `./gradlew detekt`. ktlint has only third-party Gradle plugins; the command line is enough for CI.

## Check in CI

```yaml
name: kotlin
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: actions/setup-java@v6
        with:
          distribution: temurin
          java-version: 21
      - name: ktlint
        run: |
          curl -fsSLO https://github.com/ktlint/ktlint/releases/download/1.8.0/ktlint
          chmod +x ktlint
          ./ktlint "**/src/**/*.kt" "**/*.kts"
      - name: detekt
        run: |
          curl -fsSLO https://github.com/detekt/detekt/releases/download/v1.23.8/detekt-cli-1.23.8-all.jar
          java -jar detekt-cli-1.23.8-all.jar --input . --config config/detekt/detekt.yml --build-upon-default-config
```

## Common mistakes

- **Running `ktlint --format` with a different code style than Android Studio.** Keep `ktlint_code_style = android_studio` in `.editorconfig`, or the two formatters take turns rewriting your files.
- **Wildcard imports from Android Studio's auto-import.** The `.editorconfig` settings above stop them; ktlint and detekt both flag any that slip through.
- **Catching `Exception` and doing nothing.** detekt flags `TooGenericExceptionCaught` and `SwallowedException`; on a robot, a swallowed error hides why the robot stopped.
- **Blocking the main thread** with robot SDK calls that wait for the robot. Run them in a coroutine on a background dispatcher.
- **Committing `local.properties`, `build/` or `.gradle/`.** Use the Android template from [github/gitignore](https://github.com/github/gitignore).

## Related

- Config files: [`configs/kotlin/`](../configs/kotlin/) and the example in [`examples/kotlin/`](../examples/kotlin/)
- [PepperLLMDemo](https://github.com/ATR-Lab/PepperLLMDemo): a public lab Android app written in Kotlin
- [Documentation](documentation.md#docstrings-per-language): KDoc comments
- ktlint [rules](https://ktlint.github.io/ktlint/1.8.0/rules/standard/), detekt [rule sets](https://detekt.dev/docs/1.23.8/rules/complexity/)

<sub>Last reviewed: Sept. 30, 2026 · Sources checked on that date · [Suggest a change](https://github.com/ATR-Lab/dev-guidelines/issues/new)</sub>
