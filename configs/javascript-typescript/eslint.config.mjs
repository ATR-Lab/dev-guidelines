// @ts-check
// ESLint flat config for JavaScript and TypeScript in ATR Lab repos.
//
// Tested with eslint 10.11.0, typescript-eslint 8.71.0, typescript 6.0.3 and
// eslint-config-prettier 10.1.8 (Sept. 30, 2026).
//
// - ESLint's recommended rules plus typescript-eslint's "strict" and "stylistic"
//   sets with type information, which catch floating promises, unsafe `any`
//   and unnecessary conditions that plain lint rules miss.
// - Prettier owns formatting; eslint-config-prettier turns off every ESLint rule
//   that would fight it, so it must stay last.
// Docs: https://typescript-eslint.io/getting-started/typed-linting
import js from '@eslint/js';
import prettier from 'eslint-config-prettier/flat';
import { defineConfig, globalIgnores } from 'eslint/config';
import globals from 'globals';
import tseslint from 'typescript-eslint';

export default defineConfig(
  globalIgnores(['dist/', 'build/', 'coverage/', '**/*.min.js']),
  {
    files: ['**/*.{js,mjs,cjs,ts,mts,cts,tsx}'],
    extends: [
      js.configs.recommended,
      tseslint.configs.strictTypeChecked,
      tseslint.configs.stylisticTypeChecked,
    ],
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
      // Dashboards run in the browser, servers in Node.js. Remove the one you
      // do not use.
      globals: { ...globals.browser, ...globals.node },
    },
    rules: {
      eqeqeq: ['error', 'always'],
      'no-console': ['warn', { allow: ['warn', 'error'] }],
      '@typescript-eslint/consistent-type-imports': 'error',
      // Numbers in template strings (`${speed} m/s`) are fine.
      '@typescript-eslint/restrict-template-expressions': ['error', { allowNumber: true }],
    },
  },
  {
    // Plain JavaScript files (like this config) have no type information.
    files: ['**/*.{js,mjs,cjs}'],
    extends: [tseslint.configs.disableTypeChecked],
  },
  prettier,
);
