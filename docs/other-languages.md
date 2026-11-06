# Other languages

> **Read this when** you write code in a language the lab uses only now and then (Arduino sketches, Java, MATLAB, Solidity or Ada) and need the style guide to follow.

We don't keep configs for these languages. Follow the official guide below, and fall back on the general rules in this repo: [Git and GitHub](git-and-github.md), [Documentation](documentation.md) and the shared [`.editorconfig`](../configs/editorconfig/.editorconfig). If a language becomes common in lab projects, open an issue so we can add a page and a tested config.

## Style guides

| Language | Guide to follow | Notes |
|---|---|---|
| Arduino | [Arduino Style Guide for Creating Libraries](https://docs.arduino.cc/learn/contributions/arduino-library-style-guide/) (APIs) and [Arduino Style Guide for Writing Content](https://docs.arduino.cc/learn/contributions/arduino-writing-style-guide/) (examples and sketches) | Check libraries and sketches with [Arduino Lint](https://arduino.github.io/arduino-lint/latest/). For firmware that is not an Arduino library, use our [C and C++](c-cpp.md) setup and [PlatformIO](hardware.md#firmware-projects) |
| Java | [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html) | Oracle's [Code Conventions for the Java Programming Language](https://www.oracle.com/java/technologies/javase/codeconventions-contents.html) are archived (last revised in 1999). For Android, write new code in [Kotlin](kotlin.md) |
| MATLAB | MathWorks' [MATLAB Coding Guidelines](https://github.com/mathworks/MATLAB-Coding-Guidelines) (version 1.0, 2025) | For MATLAB R2025a and later. The repo's `codeAnalyzerConfiguration.json` lets the MATLAB Code Analyzer flag rule violations in the Editor and in its report; the guidelines link MathWorks' instructions for setting it up |
| Solidity | [Solidity style guide](https://docs.soliditylang.org/en/latest/style-guide.html) in the official Solidity docs | |
| Ada | The [Ada 95 Quality and Style Guide](https://www.adaic.org/resources/add_content/docs/95style/html/cover.html) (Ada Information Clearinghouse) | Format with `gnatpp`, the GNAT pretty printer ([GNAT user's guide](https://docs.adacore.com/gnat_ugn-docs/html/gnat_ugn/gnat_ugn/gnat_utility_programs.html)); the language reference is the [Ada 2022 Reference Manual](http://www.ada-auth.org/standards/ada22.html) |

## What changed from the old list

The old version of this repo linked guides that have moved or no longer apply:

- **C:** the Indian Hill C style guide is replaced by the ROS 2 C style (PEP 7 based), which our [C and C++](c-cpp.md) page and `.clang-format` cover.
- **C++:** the Google C++ Style Guide is still the base, with the ROS 2 changes described in [C and C++](c-cpp.md).
- **JavaScript:** JavaScript Standard Style is replaced by our [JavaScript and TypeScript](javascript-typescript.md) setup (ESLint, typescript-eslint and Prettier).
- **Python:** the Google Python Style Guide now applies to docstrings, with PEP 8 and Ruff for everything else; see [Python](python.md).
- **Arduino:** the old `arduino.cc/en/Reference/StyleGuide` link now opens the Arduino home page; the guides above replaced it.

## Related

- [Language matrix](../README.md#language-matrix): the six languages with tested configs
- [Hardware and firmware](hardware.md): microcontroller projects
- [Google style guides](https://google.github.io/styleguide/): the index of Google's guides for other languages

<sub>Last reviewed: Sept. 30, 2026 · Sources checked on that date · [Suggest a change](https://github.com/ATR-Lab/dev-guidelines/issues/new)</sub>
