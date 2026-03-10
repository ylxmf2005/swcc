---
name: "xieshang"
description: "Run SWCC consultation only: 中办 triage, 左派/右派 debate, optional 中间路线 synthesis, and 党委 final decision, without executing code changes. Use when Codex should generate a plan before implementation."
---

# 协商 / Xieshang

Run the SWCC consultation and decision phases without modifying code.

## Before Starting

- Read `../swcc/references/runtime.md`.
- Create `.tmp/swcc/` if it does not exist.
- Stay in coordinator mode. Produce plans and reports only.

## Inputs

- Use the invoking prompt as `TASK_DESC`.
- If the prompt is empty, infer the task from recent conversation. Ask only if the request is still ambiguous.

## Workflow

1. **中办分拣**
   - Read `../swcc/agents/zhongban.md`.
   - Spawn `zhongban` as an `explorer` sub-agent.
   - Save the result to `.tmp/swcc/zhongban-report.md` and extract `SCALE`.

2. **政协协商**
   - Always run consultation, even if `SCALE = 小`.
   - Read `../swcc/agents/zuopai.md` and `../swcc/agents/youpai.md`.
   - Spawn left and right in parallel and save to `.tmp/swcc/zuopai-proposal.md` and `.tmp/swcc/youpai-proposal.md`.
   - If `SCALE = 大`, read `../swcc/agents/zhongjian.md`, spawn `zhongjian`, and save to `.tmp/swcc/zhongjian-proposal.md`.

3. **党委决策**
   - Read `../swcc/agents/dangwei.md`.
   - Spawn `dangwei` with the task, the `zhongban` report, and the consultation reports.
   - Save the final decision to `.tmp/swcc/dangwei-decision.md`.

## Hard Rule

- Do **not** implement code changes in this skill.
- Do **not** spawn `guowuyuan`, `buwei`, or `jiwei`.

## Final Response

Show the decision summary and point the user to `.tmp/swcc/dangwei-decision.md`.
If they want to execute it next, recommend `$zhixing`.
