---
name: "zhixing"
description: "Execute an existing SWCC implementation plan through 国务院 decomposition, 部委 execution, and 纪委 inspection. Use when Codex already has a plan and should only carry out execution plus verification."
---

# 执行 / Zhixing

Skip consultation and run only the execution and inspection stages.

## Before Starting

- Read `../swcc/references/runtime.md`.
- Create `.tmp/swcc/` if it does not exist.

## Inputs

- If the invoking prompt contains a plan, use it as `PLAN`.
- Otherwise load `.tmp/swcc/dangwei-decision.md`.
- If neither exists, ask the user to provide a plan or run `$xieshang` first.

## Workflow

1. **国务院拆分**
   - Read `../swcc/agents/guowuyuan.md`.
   - Spawn `guowuyuan` as an `explorer` sub-agent with `PLAN`.
   - Save the result to `.tmp/swcc/guowuyuan-tasks.md`.

2. **部委执行**
   - Read `../swcc/agents/buwei.md`.
   - Parse batches from `.tmp/swcc/guowuyuan-tasks.md`.
   - Spawn one `worker` sub-agent per ministry task for the current batch.
   - After each batch completes, integrate the accepted code changes locally.
   - Save each report as `.tmp/swcc/buwei-<n>-result.md`.

3. **纪委监察**
   - Read `../swcc/agents/jiwei.md`.
   - Spawn `jiwei` with `PLAN` and all ministry reports.
   - Save the verdict to `.tmp/swcc/jiwei-verdict.md`.

4. **驳回重试**
   - If `jiwei` rejects the result, retry ministry execution up to **2** times.
   - Pass the rejection report into the retried tasks.
   - Stop after the second failed retry and report that manual intervention is needed.

## Final Response

Summarize the changed files, inspection outcome, and relevant `.tmp/swcc/` artifacts.
