---
name: "juguo"
description: "Run SWCC emergency mode: skip consultation, let 国务院 decompose the task immediately, execute all 部委 work with maximum parallelism, and perform fast 纪委 verification only. Use for urgent bug fixes or clear tasks where speed matters more than deliberation."
---

# 举国 / Juguo

Run the emergency fast path.

## Before Starting

- Read `../swcc/references/runtime.md`.
- Create `.tmp/swcc/` if it does not exist.
- Treat this as an explicit emergency mode. Skip consultation and final political deliberation.

## Inputs

- Use the invoking prompt as `TASK_DESC`.
- If it is missing, ask the user to provide the urgent task description.

## Workflow

1. **国务院紧急拆分**
   - Read `../swcc/agents/guowuyuan.md`.
   - Spawn `guowuyuan` as an `explorer` sub-agent.
   - Instruct it to decompose the task directly from `TASK_DESC`, maximize parallelism, and avoid waiting for upstream planning.
   - Save the result to `.tmp/swcc/guowuyuan-tasks.md`.

2. **全部委并行执行**
   - Read `../swcc/agents/buwei.md`.
   - Spawn all ministry tasks in a single parallel wave when possible.
   - Integrate the accepted code changes locally after the wave completes.
   - Save each report as `.tmp/swcc/buwei-<n>-result.md`.

3. **纪委快速验证**
   - Read `../swcc/agents/jiwei.md`.
   - Spawn `jiwei` in fast-verification mode.
   - Explicitly tell it to run tests, linting, and type-checking only, and to skip deep code review.
   - Save the verdict to `.tmp/swcc/jiwei-verdict.md`.

4. **快速重试**
   - If the fast verification fails, retry ministry execution at most **1** time.
   - Pass the rejection report into the retried tasks.
   - Stop after the first failed retry and report that the emergency path could not complete safely.

## Final Response

Report the urgent execution status, changed files, verification result, and `.tmp/swcc/` artifact paths.
