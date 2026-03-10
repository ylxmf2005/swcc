---
name: "jicha"
description: "Run SWCC inspection only: have 纪委 review the current working-tree changes and run automated verification. Use after code changes when Codex should perform review, tests, linting, and type-checking without planning or implementation."
---

# 监察 / Jicha

Run the Discipline Commission review flow on the current working tree.

## Before Starting

- Read `../swcc/references/runtime.md`.
- Create `.tmp/swcc/` if it does not exist.
- Collect `git diff --name-only` and `git diff --stat` before spawning the inspector.

## Workflow

1. **检查是否有变更**
   - If the working tree has no code changes, stop immediately and report that inspection is unnecessary.

2. **纪委审查**
   - Read `../swcc/agents/jiwei.md`.
   - Spawn `jiwei` with the current diff summary.
   - If the user supplied focus areas, include them explicitly.
   - Ask for both code review and automated verification.
   - Save the result to `.tmp/swcc/jiwei-verdict.md`.

## Hard Rule

- Do **not** spawn `zhongban`, `zuopai`, `youpai`, `zhongjian`, `dangwei`, `guowuyuan`, or `buwei`.
- This skill is inspection-only.

## Final Response

Present the verdict summary and point the user to `.tmp/swcc/jiwei-verdict.md`.
