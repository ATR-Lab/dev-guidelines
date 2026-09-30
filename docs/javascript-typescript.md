# JavaScript and TypeScript

> **Read this when** you build a web dashboard or a Node.js server (for example, a bridge between a robot and a browser) and want type safety, one formatter and a linter that catches async bugs.

New code is TypeScript with a strict `tsconfig`, formatted by Prettier and linted by ESLint with typescript-eslint's type-aware rules. The one thing to remember: install the exact versions in `package-snippet.json`, because `npm install typescript` now gets TypeScript 7, which typescript-eslint does not support yet.

## Contents

- [The style we follow](#the-style-we-follow)
- [Naming and file layout](#naming-and-file-layout)
- [What the configs do](#what-the-configs-do)
- [Install and editor setup](#install-and-editor-setup)
- [Adopt the config in a repo](#adopt-the-config-in-a-repo)
- [Check in CI](#check-in-ci)
- [Common mistakes](#common-mistakes)
- [Related](#related)

## The style we follow

There is no single official JavaScript style guide, so we let the tools define it:

- **Prettier** decides layout. We change two defaults: 100-character lines (to match our other languages) and single quotes.
- **ESLint** with [typescript-eslint](https://typescript-eslint.io/)'s `strict-type-checked` and `stylistic-type-checked` sets decides everything else. These rules use the TypeScript compiler, so they catch problems plain linting cannot: a promise nobody awaits, a value typed `any` leaking into your code, a condition that is always true.
- **TypeScript** in strict mode, plus the extra checks in `tsconfig.base.json`.

Write plain JavaScript only where TypeScript is not an option (a quick script, a config file). The same ESLint config lints it, without the type-aware rules.

## Naming and file layout

| Thing | Style | Example |
|---|---|---|
| Variables, functions, methods | `camelCase` | `parseStatus()`, `batteryPercent` |
| Classes, interfaces, types, enums | `PascalCase` | `RobotStatus`, `StatusParseError` |
| Module-level constants | `UPPER_CASE` | `STALE_AFTER_MS` |
| Files | `kebab-case.ts` (follow your framework where it differs, for example React components) | `robot-status.ts` |
| Units in names or comments | Always | `linearSpeed: number; // m/s` |

Keep source in `src/`, build output in `dist/` (ignored by Git and ESLint) and tests next to the code (`robot-status.test.ts`) or in `test/`.

## What the configs do

| File | What it sets |
|---|---|
| `eslint.config.mjs` | ESLint's flat config: recommended rules, typescript-eslint strict and stylistic sets with type information (`projectService`), `eqeqeq`, `consistent-type-imports`, then `eslint-config-prettier` last so no ESLint rule fights Prettier |
| `.prettierrc.json` | `printWidth: 100`, `singleQuote: true`; everything else is Prettier's default |
| `tsconfig.base.json` | `strict`, `noUncheckedIndexedAccess` (array lookups may be `undefined`), `exactOptionalPropertyTypes`, `noImplicitOverride`, `verbatimModuleSyntax`, ES2022 target, NodeNext modules |
| `package-snippet.json` | The `devDependencies` we tested together and `lint`, `format` and `typecheck` scripts |

TypeScript 6 changed a default you will notice: it no longer loads every installed `@types` package ([TypeScript 6.0 announcement](https://devblogs.microsoft.com/typescript/announcing-typescript-6-0/)). A Node.js server needs `"types": ["node"]` in its `tsconfig.json`.

## Install and editor setup

Install Node.js 24 (the active LTS release until Oct. 20, 2026; see the [Node.js release schedule](https://github.com/nodejs/Release#release-schedule)). ESLint 10 needs Node.js 20.19, 22.13 or 24 and later.

macOS:

```bash
brew install node@24
# Versioned formulas are not linked by default; put this one on PATH
echo 'export PATH="$(brew --prefix node@24)/bin:$PATH"' >> ~/.zshrc
```

Ubuntu 24.04, with nvm (one of the options on the [Node.js download page](https://nodejs.org/en/download)):

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | bash
. "$HOME/.nvm/nvm.sh"   # or open a new terminal
nvm install 24
```

VS Code: install **ESLint** (`dbaeumer.vscode-eslint`) and **Prettier** (`esbenp.prettier-vscode`), then add to `.vscode/settings.json`:

```json
{
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": { "source.fixAll.eslint": "explicit" }
}
```

## Adopt the config in a repo

```bash
BASE=https://raw.githubusercontent.com/ATR-Lab/dev-guidelines/master/configs/javascript-typescript
curl -fsSLO "$BASE/eslint.config.mjs"
curl -fsSLO "$BASE/.prettierrc.json"
curl -fsSLO "$BASE/tsconfig.base.json"
# Add the tested versions as devDependencies
npm install --save-dev --save-exact @eslint/js@10.0.1 eslint@10.11.0 eslint-config-prettier@10.1.8 \
  globals@17.12.0 prettier@3.9.9 typescript@6.0.3 typescript-eslint@8.71.0
```

Then point your `tsconfig.json` at the base file and copy the `scripts` block from [`package-snippet.json`](../configs/javascript-typescript/package-snippet.json):

```json
{
  "extends": "./tsconfig.base.json",
  "compilerOptions": { "outDir": "dist", "lib": ["ES2022", "DOM"] },
  "include": ["src"]
}
```

Run `npm run format` once and commit the result on its own before you turn on the CI check.

## Check in CI

```yaml
name: web
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: actions/setup-node@v7
        with:
          node-version: 24
          cache: npm
      - run: npm ci
      - run: npm run check   # format:check, lint and typecheck
```

## Common mistakes

- **Upgrading to TypeScript 7 before typescript-eslint supports it.** typescript-eslint 8.71 declares support for TypeScript below 6.1. Keep `typescript` pinned until its release notes say otherwise.
- **Floating promises.** `fetchStatus(url);` without `await`, `.catch()` or `void` loses errors silently. `no-floating-promises` flags it.
- **`any` from `JSON.parse`.** Type the result as `unknown` and check its fields, as `parseStatus()` in the example does.
- **`==` instead of `===`.** Blocked by `eqeqeq`.
- **Formatting rules in ESLint.** Leave layout to Prettier; `eslint-config-prettier` must stay the last entry.
- **Committing `node_modules/` or skipping the lockfile.** Ignore the first, commit `package-lock.json` (or `pnpm-lock.yaml`) and use `npm ci` in CI.

## Related

- Config files: [`configs/javascript-typescript/`](../configs/javascript-typescript/) and the example in [`examples/javascript-typescript/`](../examples/javascript-typescript/)
- [Documentation](documentation.md#docstrings-per-language): TSDoc comments
- [atr-dashboard](https://github.com/ATR-Lab/atr-dashboard): one of the lab's public web projects
- typescript-eslint [shared configs](https://typescript-eslint.io/users/configs/), ESLint [configuration files](https://eslint.org/docs/latest/use/configure/configuration-files), Prettier [options](https://prettier.io/docs/options), TypeScript [tsconfig reference](https://www.typescriptlang.org/tsconfig/)

<sub>Last reviewed: Sept. 30, 2026 · Sources checked on that date · [Suggest a change](https://github.com/ATR-Lab/dev-guidelines/issues/new)</sub>
