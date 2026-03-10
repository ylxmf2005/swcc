# SWCC Codex Install

This repository keeps the Codex skill source under `.codex/`:

- `.codex/skills/*` — the five user-invocable Codex skills
- `.codex/skills/swcc/agents/*` — the eight shared SWCC role prompts
- `.codex/skills/swcc/scripts/*` — install and uninstall helpers

Codex discovers repository skills from `.agents/skills/`. This setup keeps the editable files under `.codex/` and installs one repo-local symlink.

## Install

Run from the repository root:

```bash
bash .codex/skills/swcc/scripts/install.sh
```

What it does:

- creates `./.agents/` if needed
- links `./.agents/skills` to `.codex/skills/`
- keeps the editable files in `.codex/` only

After installing, restart Codex or reopen the repository.

Only repo-local installation is supported.

## Verify

1. Restart Codex or reopen the project.
2. Open this repository in Codex.
3. Invoke one of the skills explicitly, for example:

```text
$zhili 给这个项目加 JWT 认证
$xieshang 只给我这个功能的实施方案
$jicha 重点关注安全问题和测试覆盖
```

Expected skill names:

- `zhili`
- `xieshang`
- `zhixing`
- `jicha`
- `juguo`

## Uninstall

Remove repo-local symlinks:

```bash
bash .codex/skills/swcc/scripts/uninstall.sh
```

## Dry Run

Preview the install or uninstall actions without changing anything:

```bash
bash .codex/skills/swcc/scripts/install.sh --dry-run
bash .codex/skills/swcc/scripts/uninstall.sh --dry-run
```

## Notes

- The runtime artifacts still live in `.tmp/swcc/`, just like the Claude version.
- The Codex adaptation preserves the same five workflow names and the same eight political role prompts.
- The orchestration backend is adapted to Codex sub-agents, so the coordinator skill dispatches `spawn_agent`-style role work instead of Claude's `swcc:agent-name` namespace.
