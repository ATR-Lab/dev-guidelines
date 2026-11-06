#!/usr/bin/env bash
# Runs every formatter and linter in configs/ against the samples in examples/.
#
# For each language, the good samples must pass and every file in examples/<lang>/bad/ must be
# rejected, which proves the config is both correct and actually switched on.
#
# Usage:
#   scripts/check-configs.sh                  # all languages
#   scripts/check-configs.sh python swift     # only these
#   scripts/check-configs.sh --local swift    # use tools installed on this machine, not Docker
#
# Languages: editorconfig markdown c-cpp python javascript-typescript swift kotlin csharp-unity
#
# Needs only Docker. Each check copies the samples and configs into a throwaway container, so
# nothing is written to your checkout. Without Docker (or with --local), the script uses local
# tools where it finds them (swift format, swiftlint, uvx, npm) and skips the rest.
# Exit status: 0 when every check that ran passed, 1 otherwise.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ALL_LANGUAGES=(editorconfig markdown c-cpp python javascript-typescript swift kotlin csharp-unity)

# Tool versions tested on Sept. 30, 2026. Change them together with configs/README.md.
ROS_IMAGE="ros:jazzy-ros-base"                       # Ubuntu 24.04: clang-format and clang-tidy 18
UV_IMAGE="ghcr.io/astral-sh/uv:0.12.21-python3.12-trixie-slim"
RUFF_VERSION="0.16.9"
MYPY_VERSION="2.3.1"
PYRIGHT_VERSION="1.1.414"
NODE_IMAGE="node:24-bookworm-slim"
SWIFT_IMAGE="swift:6.4-noble"                        # swift-format ships in the toolchain
SWIFTLINT_IMAGE="ghcr.io/realm/swiftlint:0.65.1"
JAVA_IMAGE="eclipse-temurin:21-jre"
KTLINT_VERSION="1.8.0"
KTLINT_SHA256="a3fd620207d5c40da6ca789b95e7f823c54e854b7fade7f613e91096a3706d75"
DETEKT_VERSION="1.23.8"
DETEKT_SHA256="2ce2ff952e150baf28a29cda70a363b0340b3e81a55f43e51ec5edffc3d066c1"
DOTNET_IMAGE="mcr.microsoft.com/dotnet/sdk:10.0"
MARKDOWNLINT_IMAGE="davidanson/markdownlint-cli2:v0.23.3"
EDITORCONFIG_IMAGE="mstruebing/editorconfig-checker:4.0.2"
CPP_CHECK_IMAGE="atr-dev-guidelines-cpp:jazzy"       # built locally from ROS_IMAGE (see check_c_cpp)
CACHE_VOLUME="atr-dev-guidelines-cache"              # Docker volume for downloads (npm, NuGet, jars)

USE_DOCKER=1
declare -a RESULTS=()
FAILED=0

log() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }

record() {  # record <PASS|FAIL|SKIP> <name>
  RESULTS+=("$1  $2")
  if [[ "$1" == "FAIL" ]]; then
    FAILED=1
  fi
}

# expect_pass <name> <command...>: the command must exit 0.
expect_pass() {
  local name="$1"
  shift
  log "$name (must pass)"
  if "$@"; then record PASS "$name"; else record FAIL "$name"; fi
}

# expect_fail <name> <command...>: the command must exit non-zero (the linter caught the bad file).
expect_fail() {
  local name="$1"
  shift
  log "$name (must be rejected)"
  if "$@"; then
    echo "!! The linter accepted a deliberately bad file: its rules are not active."
    record FAIL "$name"
  else
    echo "-- Rejected, as expected."
    record PASS "$name"
  fi
}

# in_docker <image> <shell script>: runs the script in a container with the repo mounted read-only
# at /repo and a cache volume at /cache.
in_docker() {
  local image="$1" script="$2"
  docker run --rm -v "$REPO_ROOT:/repo:ro" -v "$CACHE_VOLUME:/cache" --entrypoint sh "$image" \
    -c "set -e; $script"
}

have() { command -v "$1" >/dev/null 2>&1; }

# --------------------------------------------------------------------------------------------
# EditorConfig: every sample must follow configs/editorconfig/.editorconfig.
# The bad sample (tabs and trailing spaces) is generated here, because editors would "fix" a
# committed one.
check_editorconfig() {
  local setup='mkdir -p /tmp/w && cp -r /repo/examples /tmp/w/ && rm -rf /tmp/w/examples/*/bad
    cp /repo/configs/editorconfig/.editorconfig /tmp/w/ && cd /tmp/w'
  if [[ $USE_DOCKER == 1 ]]; then
    expect_pass "editorconfig: examples" in_docker "$EDITORCONFIG_IMAGE" \
      "$setup && /usr/bin/editorconfig-checker"
    expect_fail "editorconfig: generated bad file" in_docker "$EDITORCONFIG_IMAGE" \
      "$setup && printf 'def f():\n\treturn 1   \n' > examples/bad.py && /usr/bin/editorconfig-checker"
  else
    record SKIP "editorconfig (needs Docker)"
  fi
}

# --------------------------------------------------------------------------------------------
# Markdown: the README and AGENTS templates must pass configs/markdown/.markdownlint.jsonc.
check_markdown() {
  local setup='mkdir -p /tmp/w && cp /repo/templates/*.md /tmp/w/
    cp /repo/configs/markdown/.markdownlint.jsonc /tmp/w/ && cd /tmp/w'
  if [[ $USE_DOCKER == 1 ]]; then
    expect_pass "markdown: templates" in_docker "$MARKDOWNLINT_IMAGE" \
      "$setup && markdownlint-cli2 '*.md'"
    expect_fail "markdown: generated bad file" in_docker "$MARKDOWNLINT_IMAGE" \
      "$setup && rm ./*.md && printf '# Title\n## Skipped a blank line\nText with trailing spaces   \n* mixed\n- markers\n' > bad.md && markdownlint-cli2 bad.md"
  elif have npx; then
    local work
    work="$(mktemp -d)"
    cp "$REPO_ROOT"/templates/*.md "$REPO_ROOT/configs/markdown/.markdownlint.jsonc" "$work/"
    expect_pass "markdown: templates (local)" bash -c "cd '$work' && npx --yes markdownlint-cli2 '*.md'"
    rm -rf "$work"
  else
    record SKIP "markdown (needs Docker or npx)"
  fi
}

# --------------------------------------------------------------------------------------------
# C and C++: a ROS 2 package (teleop_velocity_limiter) and a C firmware module.
# clang-format and clang-tidy come from Ubuntu 24.04; the package is built and tested with
# colcon, so ament_clang_format, ament_cpplint, ament_lint_cmake, ament_xmllint, ament_flake8
# and ament_pep257 all run against the same code.
check_c_cpp() {
  if [[ $USE_DOCKER == 0 ]]; then
    record SKIP "c-cpp (needs Docker: ROS 2 Jazzy image)"
    return
  fi
  log "Building $CPP_CHECK_IMAGE from $ROS_IMAGE (cached after the first run)"
  if ! docker build -q -t "$CPP_CHECK_IMAGE" - <<EOF
FROM $ROS_IMAGE
RUN apt-get update && apt-get install -y --no-install-recommends \\
      clang-format clang-tidy ros-jazzy-ament-cmake-clang-format ros-jazzy-ament-lint-auto \\
      ros-jazzy-ament-lint-common ros-jazzy-ament-cmake-gtest ros-jazzy-rclcpp-components \\
    && rm -rf /var/lib/apt/lists/*
EOF
  then
    record FAIL "c-cpp: build check image"
    return
  fi
  local setup='. /opt/ros/jazzy/setup.sh
    mkdir -p /tmp/w && cp -r /repo/examples/c-cpp/. /tmp/w/
    cp /repo/configs/c-cpp/.clang-format /repo/configs/c-cpp/.clang-tidy /tmp/w/ && cd /tmp/w
    clang-format --version && clang-tidy --version | head -n 2'
  local sources='find teleop_velocity_limiter firmware -name "*.[ch]" -o -name "*.[ch]pp"'
  expect_pass "c-cpp: clang-format" in_docker "$CPP_CHECK_IMAGE" \
    "$setup && $sources | xargs clang-format --dry-run --Werror && echo 'clang-format: clean'"
  expect_pass "c-cpp: ament_clang_format agrees" in_docker "$CPP_CHECK_IMAGE" \
    "$setup && ament_clang_format teleop_velocity_limiter firmware"
  expect_pass "c-cpp: colcon build, clang-tidy, colcon test" in_docker "$CPP_CHECK_IMAGE" \
    "$setup && colcon build --base-paths teleop_velocity_limiter --event-handlers console_direct- \
       --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
     && clang-tidy -p build/teleop_velocity_limiter --quiet teleop_velocity_limiter/src/*.cpp \
       teleop_velocity_limiter/test/*.cpp \
     && clang-tidy --quiet firmware/ring_buffer.c -- -std=c99 \
     && colcon test --base-paths teleop_velocity_limiter --event-handlers console_direct- >/dev/null \
     && colcon test-result --verbose"
  expect_fail "c-cpp: clang-format rejects bad/" in_docker "$CPP_CHECK_IMAGE" \
    "$setup && clang-format --dry-run --Werror bad/*.cpp"
  expect_fail "c-cpp: clang-tidy rejects bad/" in_docker "$CPP_CHECK_IMAGE" \
    "$setup && clang-tidy --quiet bad/*.cpp -- -std=c++17"
}

# --------------------------------------------------------------------------------------------
# Python: ruff (lint and format), mypy --strict, pyright and pytest; then the ROS 2 linters
# (ament_flake8, ament_pep257 with the Google convention) on the same files.
check_python() {
  local copy='mkdir -p /tmp/w && cp -r /repo/examples/python/. /tmp/w/
    cp /repo/configs/python/ruff.toml /tmp/w/ && cp /repo/configs/python/pyproject-snippet.toml /tmp/w/pyproject.toml
    cd /tmp/w'
  # pyright's PyPI wrapper downloads Node.js, which needs libatomic on slim Debian images.
  local prep="$copy && export UV_CACHE_DIR=/cache/uv MYPYPATH=src PYTHONPATH=src"
  local ruff="uvx ruff@$RUFF_VERSION" mypy="uvx --with pytest mypy@$MYPY_VERSION"
  local pyright="uvx --with pytest pyright@$PYRIGHT_VERSION" pytest="uvx pytest"
  local libatomic="apt-get update -qq && apt-get install -y -qq libatomic1 >/dev/null"
  if [[ $USE_DOCKER == 1 ]]; then
    expect_pass "python: ruff check, ruff format, mypy, pyright, pytest" in_docker "$UV_IMAGE" \
      "$libatomic && $prep && $ruff --version && $ruff check --exclude bad . \
       && $ruff format --check --exclude bad . && $mypy src tests && $pyright src tests && $pytest -q"
    expect_fail "python: ruff check rejects bad/" in_docker "$UV_IMAGE" "$prep && $ruff check bad"
    expect_fail "python: ruff format rejects bad/" in_docker "$UV_IMAGE" "$prep && $ruff format --check bad"
    expect_fail "python: mypy rejects bad/" in_docker "$UV_IMAGE" "$prep && $mypy bad"
    if docker image inspect "$CPP_CHECK_IMAGE" >/dev/null 2>&1; then
      expect_pass "python: ament_flake8 and ament_pep257 (ROS 2) accept the same code" \
        in_docker "$CPP_CHECK_IMAGE" ". /opt/ros/jazzy/setup.sh && $copy && ament_flake8 src tests \
         && ament_pep257 src tests --convention google \
            --add-ignore D100 D101 D102 D103 D104 D105 D106 D107"
    else
      record SKIP "python: ROS 2 linters (run the c-cpp check first to build its image)"
    fi
  elif have uvx; then
    local work
    work="$(mktemp -d)"
    cp -r "$REPO_ROOT/examples/python/." "$work/"
    cp "$REPO_ROOT/configs/python/ruff.toml" "$work/"
    cp "$REPO_ROOT/configs/python/pyproject-snippet.toml" "$work/pyproject.toml"
    local env="cd '$work' && export MYPYPATH=src PYTHONPATH=src"
    expect_pass "python: ruff, mypy, pyright, pytest (local)" bash -c "$env \
      && $ruff check --exclude bad . && $ruff format --check --exclude bad . && $mypy src tests \
      && $pyright src tests && $pytest -q"
    expect_fail "python: ruff check rejects bad/ (local)" bash -c "$env && $ruff check bad"
    expect_fail "python: mypy rejects bad/ (local)" bash -c "$env && $mypy bad"
    rm -rf "$work"
  else
    record SKIP "python (needs Docker or uv)"
  fi
}

# --------------------------------------------------------------------------------------------
# JavaScript and TypeScript: Prettier, ESLint (typed rules) and tsc with the versions pinned in
# configs/javascript-typescript/package-snippet.json.
check_javascript_typescript() {
  local prep='mkdir -p /tmp/w && cp -r /repo/examples/javascript-typescript/. /tmp/w/
    cd /repo/configs/javascript-typescript && cp eslint.config.mjs .prettierrc.json tsconfig.base.json /tmp/w/
    cd /tmp/w && node -e "
      const s = require(\"/repo/configs/javascript-typescript/package-snippet.json\");
      delete s[\"//\"]; s.name = \"config-check\"; s.private = true;
      require(\"fs\").writeFileSync(\"package.json\", JSON.stringify(s, null, 2));"
    npm install --no-audit --no-fund --loglevel=error --cache /cache/npm
    npx eslint --version && npx prettier --version && npx tsc --version'
  if [[ $USE_DOCKER == 1 ]]; then
    expect_pass "javascript-typescript: prettier, eslint, tsc" in_docker "$NODE_IMAGE" \
      "$prep && npx prettier --check src eslint.config.mjs tsconfig.json tsconfig.base.json \
       && npx eslint src eslint.config.mjs && npx tsc --noEmit -p tsconfig.json"
    expect_fail "javascript-typescript: prettier rejects bad/" in_docker "$NODE_IMAGE" \
      "$prep >/dev/null && npx prettier --check bad/*.ts"
    expect_fail "javascript-typescript: eslint rejects bad/" in_docker "$NODE_IMAGE" \
      "$prep >/dev/null && npx eslint bad"
    expect_fail "javascript-typescript: tsc rejects bad/" in_docker "$NODE_IMAGE" \
      "$prep >/dev/null && npx tsc --noEmit -p bad/tsconfig.json"
  elif have npm && have node; then
    local work
    work="$(mktemp -d)"
    cp -r "$REPO_ROOT/examples/javascript-typescript/." "$work/"
    cp "$REPO_ROOT"/configs/javascript-typescript/{eslint.config.mjs,.prettierrc.json,tsconfig.base.json} "$work/"
    node -e "
      const s = require('$REPO_ROOT/configs/javascript-typescript/package-snippet.json');
      delete s['//']; s.name = 'config-check'; s.private = true;
      require('fs').writeFileSync('$work/package.json', JSON.stringify(s, null, 2));"
    local env="cd '$work' && npm install --no-audit --no-fund --loglevel=error"
    expect_pass "javascript-typescript: prettier, eslint, tsc (local)" bash -c "$env \
      && npx prettier --check src eslint.config.mjs tsconfig.json tsconfig.base.json \
      && npx eslint src eslint.config.mjs && npx tsc --noEmit -p tsconfig.json"
    expect_fail "javascript-typescript: eslint rejects bad/ (local)" bash -c "cd '$work' && npx eslint bad"
    expect_fail "javascript-typescript: tsc rejects bad/ (local)" bash -c \
      "cd '$work' && npx tsc --noEmit -p bad/tsconfig.json"
    rm -rf "$work"
  else
    record SKIP "javascript-typescript (needs Docker or Node.js)"
  fi
}

# --------------------------------------------------------------------------------------------
# Swift: swift-format (bundled with the Swift 6 toolchain) and SwiftLint.
check_swift() {
  local prep='mkdir -p /tmp/w && cp -r /repo/examples/swift/. /tmp/w/
    cp /repo/configs/swift/.swift-format /repo/configs/swift/.swiftlint.yml /tmp/w/ && cd /tmp/w'
  if [[ $USE_DOCKER == 1 ]]; then
    expect_pass "swift: swift format lint" in_docker "$SWIFT_IMAGE" \
      "$prep && swift --version && swift format lint --strict --recursive Sources"
    expect_pass "swift: swiftlint" in_docker "$SWIFTLINT_IMAGE" \
      "$prep && swiftlint version && swiftlint lint --strict --quiet Sources"
    expect_fail "swift: swift format rejects bad/" in_docker "$SWIFT_IMAGE" \
      "$prep && swift format lint --strict --recursive bad"
    expect_fail "swift: swiftlint rejects bad/" in_docker "$SWIFTLINT_IMAGE" \
      "$prep && swiftlint lint --strict --quiet bad"
  elif have swift && have swiftlint; then
    local work
    work="$(mktemp -d)"
    cp -r "$REPO_ROOT/examples/swift/." "$work/"
    cp "$REPO_ROOT/configs/swift/.swift-format" "$REPO_ROOT/configs/swift/.swiftlint.yml" "$work/"
    expect_pass "swift: swift format lint (local)" bash -c \
      "cd '$work' && swift format lint --strict --recursive Sources"
    expect_pass "swift: swiftlint $(swiftlint version) (local)" bash -c \
      "cd '$work' && swiftlint lint --strict --quiet Sources"
    expect_fail "swift: swift format rejects bad/ (local)" bash -c \
      "cd '$work' && swift format lint --strict --recursive bad"
    expect_fail "swift: swiftlint rejects bad/ (local)" bash -c \
      "cd '$work' && swiftlint lint --strict --quiet bad"
    rm -rf "$work"
  else
    record SKIP "swift (needs Docker, or swift and swiftlint)"
  fi
}

# --------------------------------------------------------------------------------------------
# Kotlin: ktlint (reads .editorconfig) and detekt, from their official GitHub releases,
# checked against pinned SHA-256 sums.
check_kotlin() {
  if [[ $USE_DOCKER == 0 ]]; then
    record SKIP "kotlin (needs Docker)"
    return
  fi
  local prep="set -eu
    mkdir -p /cache/kotlin && cd /cache/kotlin
    if [ ! -f ktlint-$KTLINT_VERSION ]; then
      curl -fsSL -o ktlint-$KTLINT_VERSION \
        https://github.com/ktlint/ktlint/releases/download/$KTLINT_VERSION/ktlint
    fi
    if [ ! -f detekt-cli-$DETEKT_VERSION-all.jar ]; then
      curl -fsSL -o detekt-cli-$DETEKT_VERSION-all.jar \
        https://github.com/detekt/detekt/releases/download/v$DETEKT_VERSION/detekt-cli-$DETEKT_VERSION-all.jar
    fi
    echo '$KTLINT_SHA256  ktlint-$KTLINT_VERSION' | sha256sum -c -
    echo '$DETEKT_SHA256  detekt-cli-$DETEKT_VERSION-all.jar' | sha256sum -c -
    chmod +x ktlint-$KTLINT_VERSION
    mkdir -p /tmp/w && cp -r /repo/examples/kotlin/. /tmp/w/
    cp /repo/configs/kotlin/.editorconfig /repo/configs/kotlin/detekt.yml /tmp/w/ && cd /tmp/w"
  local ktlint="/cache/kotlin/ktlint-$KTLINT_VERSION"
  local detekt="java -jar /cache/kotlin/detekt-cli-$DETEKT_VERSION-all.jar --config detekt.yml --build-upon-default-config"
  expect_pass "kotlin: ktlint, detekt" in_docker "$JAVA_IMAGE" \
    "$prep && $ktlint --version && $ktlint 'src/**/*.kt' && $detekt --input src"
  expect_fail "kotlin: ktlint rejects bad/" in_docker "$JAVA_IMAGE" "$prep && $ktlint 'bad/**/*.kt'"
  expect_fail "kotlin: detekt rejects bad/" in_docker "$JAVA_IMAGE" "$prep && $detekt --input bad"
}

# --------------------------------------------------------------------------------------------
# C# and Unity: the check/ harness compiles the Unity scripts against small UnityEngine stubs
# with the lab .editorconfig and Microsoft.Unity.Analyzers, then runs dotnet format.
check_csharp_unity() {
  if [[ $USE_DOCKER == 0 ]]; then
    record SKIP "csharp-unity (needs Docker)"
    return
  fi
  local prep='export DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 NUGET_PACKAGES=/cache/nuget
    mkdir -p /tmp/w && cp -r /repo/examples/csharp-unity/. /tmp/w/
    cp /repo/configs/csharp-unity/.editorconfig /tmp/w/ && cd /tmp/w && dotnet --version'
  expect_pass "csharp-unity: dotnet build (analyzers), dotnet format" in_docker "$DOTNET_IMAGE" \
    "$prep && dotnet build check/CheckHarness.csproj -nologo -warnaserror \
     && dotnet format check/CheckHarness.csproj --verify-no-changes --severity warn \
     && dotnet format whitespace Assets --folder --verify-no-changes && echo 'dotnet format: clean'"
  expect_fail "csharp-unity: dotnet build rejects bad/" in_docker "$DOTNET_IMAGE" \
    "$prep && dotnet build check/CheckHarness.csproj -nologo -p:CheckBad=true"
  expect_fail "csharp-unity: dotnet format rejects bad/" in_docker "$DOTNET_IMAGE" \
    "$prep && dotnet format whitespace bad --folder --verify-no-changes"
}

# --------------------------------------------------------------------------------------------
main() {
  local languages=()
  for arg in "$@"; do
    case "$arg" in
      --local) USE_DOCKER=0 ;;
      -h | --help) sed -n '2,19p' "${BASH_SOURCE[0]}"; exit 0 ;;
      *) languages+=("$arg") ;;
    esac
  done
  if [[ ${#languages[@]} -eq 0 ]]; then
    languages=("${ALL_LANGUAGES[@]}")
  fi
  if [[ $USE_DOCKER == 1 ]] && ! docker info >/dev/null 2>&1; then
    echo "Docker is not running; falling back to local tools (--local)."
    USE_DOCKER=0
  fi

  for language in "${languages[@]}"; do
    case "$language" in
      editorconfig) check_editorconfig ;;
      markdown) check_markdown ;;
      c-cpp) check_c_cpp ;;
      python) check_python ;;
      javascript-typescript) check_javascript_typescript ;;
      swift) check_swift ;;
      kotlin) check_kotlin ;;
      csharp-unity) check_csharp_unity ;;
      *) echo "Unknown language: $language (choose from: ${ALL_LANGUAGES[*]})"; exit 2 ;;
    esac
  done

  log "Summary"
  printf '%s\n' "${RESULTS[@]}"
  if [[ $FAILED == 1 ]]; then
    echo "Some checks failed."
    exit 1
  fi
  echo "All checks that ran passed."
}

main "$@"
