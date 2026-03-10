---
name: "zhili"
description: "Run the full SWCC democratic-centralism coding workflow: 中办 triage, 左右派 consultation, 党委 decision, 国务院 decomposition, 部委 execution, and 纪委 inspection. Use when Codex should both plan and implement a coding task under the full SWCC process."
---

# 治理 / Zhili

Run the complete SWCC task-to-code pipeline.

## Before Starting

- Read `../swcc/references/runtime.md`.
- Create `.tmp/swcc/` if it does not exist.
- Act as the **coordinator**. Delegate planning and implementation phases to the bundled SWCC role prompts instead of replacing them with your own opinionated shortcut.

## Inputs

- Parse an optional `--scale 小|中|大` override from the invoking prompt.
- Use the remaining text as `TASK_DESC`.
- If `TASK_DESC` is missing, infer it from the recent conversation. Only ask the user when the ambiguity would materially change the workflow.

## Workflow

1. **中办分拣**
   - Read `../swcc/agents/zhongban.md`.
   - Spawn `zhongban` as an `explorer` sub-agent.
   - Ask it to triage the repository, summarize the relevant code, and judge task scale.
   - Save the full report to `.tmp/swcc/zhongban-report.md`.
   - Determine `SCALE` by priority: user override first, then the `zhongban` report.

2. **政协协商（按规模分流）**
   - If `SCALE = 小`, skip consultation and move directly to execution planning.
   - If `SCALE = 中`, read `../swcc/agents/zuopai.md` and `../swcc/agents/youpai.md`, then spawn both in parallel.
   - Save their reports to `.tmp/swcc/zuopai-proposal.md` and `.tmp/swcc/youpai-proposal.md`.
   - If `SCALE = 大`, do the same left/right parallel run first, then read `../swcc/agents/zhongjian.md`, spawn `zhongjian`, and save its report to `.tmp/swcc/zhongjian-proposal.md`.

3. **党委决策**
   - Skip this step only for `SCALE = 小`.
   - Read `../swcc/agents/dangwei.md`.
   - Spawn `dangwei` with the task description, `zhongban` report, and whichever consultation reports exist.
   - Save the final decision to `.tmp/swcc/dangwei-decision.md`.

4. **国务院拆分**
   - Read `../swcc/agents/guowuyuan.md`.
   - Spawn `guowuyuan` as an `explorer` sub-agent.
   - For `SCALE = 小`, provide `TASK_DESC` plus `.tmp/swcc/zhongban-report.md`.
   - Otherwise provide `.tmp/swcc/dangwei-decision.md`.
   - Save the task breakdown to `.tmp/swcc/guowuyuan-tasks.md`.

5. **部委执行**
   - Read `../swcc/agents/buwei.md`.
   - Parse execution batches from `.tmp/swcc/guowuyuan-tasks.md`.
   - Spawn one `worker` sub-agent per ministry task in the current batch.
   - Wait for the whole batch, then integrate accepted code changes into the coordinator workspace.
   - Save each ministry report as `.tmp/swcc/buwei-<n>-result.md`.
   - Continue batch by batch.

6. **纪委监察**
   - Read `../swcc/agents/jiwei.md`.
   - Spawn `jiwei` after the ministry changes are integrated locally.
   - Provide the decision or small-task execution basis plus all `buwei` reports.
   - Save the verdict to `.tmp/swcc/jiwei-verdict.md`.

7. **驳回重试**
   - If `jiwei` rejects the result, retry ministry execution up to **2** times.
   - Feed the rejection report back into the retried `buwei` tasks.
   - Stop after the second failed retry and report that manual intervention is needed.

## Final Response

Report:

- final status
- chosen `SCALE`
- changed files
- whether `jiwei` passed
- the `.tmp/swcc/` artifact paths
