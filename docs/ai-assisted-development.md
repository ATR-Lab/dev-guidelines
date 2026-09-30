# AI-assisted development

> **Read this when** you use a coding agent such as Claude Code or Codex in a lab repo, or review a pull request that one helped write.

Coding agents can read a repo, run commands and write code. Used well, they speed up the boring parts; used carelessly, they commit code nobody understood, leak data or move a robot nobody was watching. These rules apply to every lab repo. The one thing to remember: you are the author of every line you commit, whoever typed it.

> [!NOTE]
> We name Claude Code and Codex because lab members use them. The rules apply to any AI coding tool, and naming a tool is not an endorsement by the lab or by Kent State University.

## Contents

- [The rules](#the-rules)
- [Set up a repo for agents](#set-up-a-repo-for-agents)
- [Working with an agent, step by step](#working-with-an-agent-step-by-step)
- [Data you must never share](#data-you-must-never-share)
- [Robots and hardware](#robots-and-hardware)
- [Licenses and third-party code](#licenses-and-third-party-code)
- [Papers and disclosure](#papers-and-disclosure)
- [Related](#related)

## The rules

1. **Review every diff before you commit it.** Read it as if a new lab mate wrote it. If you can't explain a line, don't commit it.
2. **Run the tests and linters yourself.** An agent saying "tests pass" is not evidence; the CI log is.
3. **Never paste secrets or restricted research data** into a prompt, a file the agent can read or a tool's settings (details below).
4. **Keep `AGENTS.md` current.** Agents follow it; an outdated one sends them the wrong way.
5. **Agents never push to the default branch and never force-push.** They work on a branch; a person opens or reviews the pull request and merges it.
6. **Agents never run code that moves hardware** unless a person is watching the robot with the emergency stop in reach.
7. **Check licenses** of code and dependencies an agent adds.
8. **Disclose AI assistance in papers** the way the venue requires.

## Set up a repo for agents

- Add `AGENTS.md` at the root (start from the [template](../templates/AGENTS.template.md)) and a `CLAUDE.md` containing only `@AGENTS.md`. Both Claude Code and Codex then read the same instructions ([Documentation](documentation.md#agentsmd-and-claudemd) explains why).
- In `AGENTS.md`, list the exact build, test and lint commands, the safety rules for the robot and what is off limits (for example, `config/limits.yaml` changes need a human reviewer).
- Use the tool's permission settings so it asks before running commands that change files outside the repo, install software or use the network. Don't give an agent credentials it doesn't need.
- Protect the default branch ([Git and GitHub](git-and-github.md#protected-default-branches)), so even a mistaken push cannot land there.

## Working with an agent, step by step

1. Create a branch: `git switch -c feature/short-description`.
2. Give the agent a small, clear task with the files and the goal ("add a unit test for `VelocityLimiter::limit` when `dt` is zero").
3. Let it run the formatter, linter and tests from `AGENTS.md`.
4. Read the diff (`git diff`), run the tests yourself and fix what you don't like.
5. Commit with a message you wrote or checked (see [commit messages](git-and-github.md#commit-messages)). Keep any `Co-authored-by` line the tool adds, so the history shows how the code was made.
6. Open a pull request and say in the description that an agent helped, and with what.

Good tasks: explaining unfamiliar code, writing tests, repetitive refactors, first drafts of docs, reviewing your own diff. Poor tasks: safety-critical control code without careful review, anything that produces research data or results.

## Data you must never share

Do not paste these into a prompt or leave them where an agent can read them:

- passwords, API keys, tokens, private keys, Wi-Fi credentials, robot account logins;
- **identifiable research data**: anything from human-subjects studies (video, audio, photos, names, questionnaire responses) and any data your IRB protocol or data agreement restricts;
- unpublished data or text from collaborators without their permission.

Check the tool's data-use terms before you use it for lab work, and follow Kent State's [AI Hub](https://www.kent.edu/ai): it lists the AI tools approved for university use and says tools outside that list (it names Claude and ChatGPT) "may be used for personal/non-sensitive work only, do not input university data." Until the director confirms with Kent State Information Security which lab work those tools may touch, use them only on public or non-sensitive code, such as the lab's open-source repositories. When in doubt, ask your advisor first. The lab's rules for research data are in the [research standards](https://github.com/ATR-Lab/getting-started-atr-lab/blob/master/research/standards.md).

## Robots and hardware

> [!CAUTION]
> Code an agent writes can move a robot in ways you did not expect. Test new motion code in simulation first. On hardware, a person watches the robot with the emergency stop in reach, and the speed limits in the parameter files stay in place. Never let an agent run a launch file, a driver or a firmware upload unattended.

Follow the lab's [safety guide](https://github.com/ATR-Lab/getting-started-atr-lab/blob/master/lab-rules/safety.md) for every robot, whoever wrote the code.

## Licenses and third-party code

- Agents can reproduce code from their training data. If a block looks copied from a known project, find the source and check that its license allows our use, or rewrite it.
- Check the license of every dependency an agent adds (`package.xml`, `pyproject.toml`, `package.json`, Gradle files). Ask before adding GPL-licensed code to a repo under the MIT or Apache license.
- Keep vendor code in its own folder with its license file, and say where it came from in the README.

## Papers and disclosure

Publishers set their own rules for AI assistance. IEEE, for example, requires authors to disclose AI-generated content in the acknowledgments section and to name the system used ([IEEE author guidelines](https://journals.ieeeauthorcenter.ieee.org/become-an-ieee-journal-author/publishing-ethics/guidelines-and-policies/submission-and-peer-review-policies/)). Check the policy of each venue before you submit; the lab's [research standards](https://github.com/ATR-Lab/getting-started-atr-lab/blob/master/research/standards.md) list the common ones and how the lab handles authorship.

Agents must never invent results, data or citations. Check that every reference an agent suggests exists and says what the text claims.

## Related

- [Documentation](documentation.md#agentsmd-and-claudemd): the `AGENTS.md` and `CLAUDE.md` convention
- [Git and GitHub](git-and-github.md): branches, reviews and protected branches
- [AGENTS template](../templates/AGENTS.template.md)
- [Research standards](https://github.com/ATR-Lab/getting-started-atr-lab/blob/master/research/standards.md) and [lab safety guide](https://github.com/ATR-Lab/getting-started-atr-lab/blob/master/lab-rules/safety.md) in Getting started
- Tool docs: [Claude Code memory and CLAUDE.md](https://code.claude.com/docs/en/memory), [Codex and AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)

<sub>Last reviewed: Sept. 30, 2026 · Sources checked on that date · [Suggest a change](https://github.com/ATR-Lab/dev-guidelines/issues/new)</sub>
