# Git and GitHub

> **Read this when** you start a branch, write a commit message, open or review a pull request, cut a release or wonder whether a file belongs in Git at all.

We use [Git](https://git-scm.com/) for version control and [GitHub](https://github.com/ATR-Lab) to host the lab's code. This page is the workflow every lab repo follows: short-lived branches, clear commits, reviewed pull requests and tagged releases. The one thing to remember: nothing reaches the default branch without a pull request that someone else has read.

## Contents

- [Four habits](#four-habits)
- [Branches](#branches)
- [Commit messages](#commit-messages)
- [Pull requests and reviews](#pull-requests-and-reviews)
- [Issues](#issues)
- [Releases and tags](#releases-and-tags)
- [.gitignore](#gitignore)
- [Large files: Git LFS](#large-files-git-lfs)
- [Protected default branches](#protected-default-branches)
- [Never commit secrets](#never-commit-secrets)
- [Related](#related)

## Four habits

1. **Make sure the build passes before you commit.**
   *Why:* broken code should not be committed; the next person to pull inherits it.
2. **Work on a feature branch.**
   *Why:* changes on your branch don't affect anyone else, and a feature under development can be unstable.
3. **Pull the latest changes before you start.**
   *Why:* your branch stays close to the default branch, so merging stays easy.
4. **Write meaningful, short commit messages.**
   *Why:* a project's long-term success depends on its maintainability, and clear history makes every commit and pull request easier to review.

## Branches

We use the simple flow GitHub describes as [GitHub flow](https://docs.github.com/en/get-started/using-github/github-flow): branch from the default branch, commit, open a pull request, review, merge, delete the branch.

- The **default branch** (`main` in newer repos, `master` in older ones) always builds and passes its tests.
- Name branches `<type>/<short-description>` in lowercase with hyphens: `feature/deadman-switch`, `fix/imu-frame-id`, `docs/setup-guide`, `refactor/driver-timeouts`.
- Keep branches short-lived (days, not months). Merge the default branch into yours, or rebase onto it, when it moves.
- Delete the branch after the merge. Long-lived `develop` branches go stale; if a repo still has one, merge anything useful and delete it.

> [!NOTE]
> The well-known ["A successful Git branching model"](https://nvie.com/posts/a-successful-git-branching-model/) (git-flow, 2010) now opens with a note from its author recommending simpler workflows, like GitHub flow, for software that ships continuously. Use git-flow only if a project really maintains several released versions at once.

## Commit messages

A good commit message tells other developers why a change happened. We follow the seven rules from Chris Beams' post [How to Write a Git Commit Message](https://cbea.ms/git-commit/):

1. Separate subject from body with a blank line
2. Limit the subject line to 50 characters
3. Capitalize the subject line
4. Do not end the subject line with a period
5. Use the imperative mood in the subject line
6. Wrap the body at 72 characters
7. Use the body to explain what and why vs. how

For example:

```text
Limit teleop speed when the dead-man switch is released

The follower kept the last velocity command for up to 0.5 s after the
operator let go, because the timeout started only after the next
message. Stop immediately on release and reset the limiter, so the
robot never coasts.

Fixes #42
```

**Conventional Commits (optional).** Repos that generate changelogs and version numbers automatically can use [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/): `fix:` for a bug fix (a PATCH release), `feat:` for a new feature (a MINOR release) and `!` after the type or a `BREAKING CHANGE:` footer for incompatible changes (a MAJOR release). The type prefix replaces rule 3 in those repos:

```text
feat(teleop): add dead-man switch timeout parameter
```

Pick one style per repo and write it in the repo's `AGENTS.md`, so people and coding agents follow it.

## Pull requests and reviews

Open a pull request (PR) for every change to the default branch, even small ones. Open it as a draft early if you want feedback.

**Author checklist:**

- [ ] The PR does one thing. Split refactors and reformatting into their own PRs.
- [ ] The description says what changed, why and how you tested it (in simulation, on the robot or both).
- [ ] Formatters and linters pass locally; CI is green.
- [ ] Docs and `AGENTS.md` are updated if behavior, setup or commands changed.
- [ ] Changes to speed, force or workspace limits are called out as safety changes.
- [ ] Linked issues use a closing keyword (see [Issues](#issues)).

**Review etiquette:**

- Review within [agreed review time, for example two working days: lab to confirm]. If you can't, say so and suggest another reviewer.
- Comment on the code, not the person. Ask questions ("What happens if the robot loses Wi-Fi here?") rather than give orders.
- Mark optional suggestions as optional ("nit:"), so the author knows what blocks the merge.
- Approve when the change is correct and safe, even if you would have written it differently.
- Authors: reply to every comment, push fixes as new commits during review and let the reviewer resolve their own threads.

A `.github/pull_request_template.md` file pre-fills the description for every PR ([GitHub docs](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository)); a `CODEOWNERS` file requests reviews from the right people automatically ([about code owners](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)).

## Issues

Track bugs, tasks and ideas as GitHub issues, one problem per issue, with steps to reproduce for bugs (robot, distribution, commit, what you expected, what happened).

A PR closes an issue when its description or a commit message uses one of GitHub's [closing keywords](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue): `close`, `closes`, `closed`, `fix`, `fixes`, `fixed`, `resolve`, `resolves` or `resolved`, followed by the issue number (`Fixes #42`). It works only when the PR targets the default branch.

## Releases and tags

Version anything other people install or depend on (a driver, a library, an app build) with [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html): `MAJOR.MINOR.PATCH`. Increase MAJOR for incompatible API changes, MINOR for new features that keep compatibility and PATCH for bug fixes. Use a pre-release suffix for candidates: `1.4.0-rc.1`.

```bash
git switch master   # or main: the repo's default branch
git pull
git tag -a v1.4.0 -m "Release 1.4.0"
git push origin v1.4.0
```

Then create a GitHub release from the tag ([about releases](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases)). Use the version as the release title, and let GitHub [draft the release notes](https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes) from merged PRs; edit them for humans. Keep a `CHANGELOG.md` in the [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/) format if people upgrade between versions (see [Documentation](documentation.md#changelogs)).

In ROS 2 packages, the version in `package.xml` must match the tag.

## .gitignore

Every repo has a `.gitignore` that keeps build output, editor files and secrets out. Start from GitHub's [templates](https://github.com/github/gitignore) for your language (`ROS.gitignore`, `Python.gitignore`, `Unity.gitignore`, `Swift.gitignore`, `Android.gitignore`, `Node.gitignore`) and add what your project generates:

```gitignore
# colcon workspaces
build/
install/
log/
# Python
.venv/
__pycache__/
# Editors and OS
.vscode/*
!.vscode/settings.json
!.vscode/extensions.json
.idea/
.DS_Store
# Secrets and local settings
.env
*.pem
```

More: the [Ignoring files](https://git-scm.com/book/en/v2/Git-Basics-Recording-Changes-to-the-Repository#_ignoring) section of the Pro Git book, GitHub's [ignoring files](https://docs.github.com/en/get-started/git-basics/ignoring-files) guide and the [gitignore(5)](https://git-scm.com/docs/gitignore) manual page.

## Large files: Git LFS

GitHub warns about files larger than 50 MiB and blocks files larger than 100 MiB ([about large files](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github)). Robot projects hit that quickly. Track these with [Git LFS](https://git-lfs.com/) from the first commit:

- meshes and CAD exports (`*.stl`, `*.dae`, `*.obj`, `*.glb`, `*.step`)
- Unity assets (`*.fbx`, `*.psd`, `*.png` textures, `*.wav`)
- short sample recordings used by tests (`*.mcap`, `*.db3`)
- model weights (`*.pt`, `*.onnx`, `*.safetensors`)

```bash
# Once per machine: macOS `brew install git-lfs`, Ubuntu `sudo apt install git-lfs`
git lfs install
# Once per repo, then commit .gitattributes
git lfs track "*.stl" "*.dae" "*.mcap"
git add .gitattributes
```

Full ROS bag recordings and training datasets are usually too large even for LFS. Keep them in [lab data storage location: lab manager to confirm] and put a README next to your code that says where they are and how to get them.

## Protected default branches

Repo admins protect the default branch of every active repo with [branch protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches) or a [ruleset](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets):

- require a pull request with at least one approving review;
- require CI status checks to pass;
- block force-pushes and branch deletion.

Ask [repo admin: lab manager to confirm] to set this up for a new repo.

## Never commit secrets

API keys, access tokens, passwords, Wi-Fi credentials, robot account logins and private keys never go into Git, not even in a private repo or a commit you plan to undo.

- Keep them in environment variables or an ignored `.env` file, and commit a `.env.example` with placeholder values.
- GitHub's [push protection](https://docs.github.com/en/code-security/concepts/secret-security/push-protection) blocks pushes that contain known secret formats, and [secret scanning](https://docs.github.com/en/code-security/concepts/secret-security/secret-scanning) finds them in history. Don't bypass a block without asking.
- **If a secret reaches GitHub, revoke or rotate it first**, then tell [lab contact for security incidents: lab manager to confirm]. Rewriting history comes second ([removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)), because clones and forks may already have it.
- On shared robot computers, don't leave your personal GitHub credentials behind; log out or use [the lab's shared-machine account policy: lab manager to confirm].

## Related

- [Documentation](documentation.md): READMEs, `AGENTS.md` and changelogs
- [AI-assisted development](ai-assisted-development.md): rules for coding agents working in these repos
- [ROS 2 packages](ros2-packages.md): what goes into a package and its PR checklist
- [Hardware and firmware](hardware.md): versioning CAD files and BOMs

<sub>Last reviewed: Sept. 30, 2026 · Sources checked on that date · [Suggest a change](https://github.com/ATR-Lab/dev-guidelines/issues/new)</sub>
