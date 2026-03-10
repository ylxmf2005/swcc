# SWCC Codex Runtime

This folder provides the shared runtime rules for the five Codex skills in `.codex/skills/`.

## Core Rules

- Treat the invoking skill as the **coordinator**. Its job is to parse arguments, dispatch roles, persist artifacts, integrate accepted code changes, and report status.
- Treat `.codex/skills/swcc/agents/*.md` as the source-of-truth role prompts. Read the relevant file before spawning each role.
- Keep all intermediate artifacts under `.tmp/swcc/`. Create the directory if it does not exist.
- Save every completed role output to disk before moving to the next phase.
- Preserve the Chinese political-role voice from the bundled role prompts.

## Recommended Codex Agent Types

| Role | Recommended `agent_type` | Why |
|------|--------------------------|-----|
| `zhongban` | `explorer` | Fast repository scan and scale triage |
| `zuopai` | `default` | SOTA exploration and proposal writing |
| `youpai` | `default` | Conservative proposal writing |
| `zhongjian` | `default` | Synthesis and trade-off analysis |
| `dangwei` | `default` | Final decision writing |
| `guowuyuan` | `explorer` | Dependency-aware task decomposition |
| `buwei` | `worker` | Concrete code-change implementation |
| `jiwei` | `default` | Review plus verification reasoning |

## Spawning Pattern

1. Read the relevant role file from `../agents/<role>.md`.
2. Prepend that role prompt to the sub-agent task.
3. Append the phase-specific context: user task, previous reports, constraints, and expected output file.
4. Spawn all roles that can run in parallel before waiting.
5. After completion, persist the returned markdown report to the matching file in `.tmp/swcc/`.

## Buwei Integration Rule

Codex worker agents operate in their own delegated workspace context. When a `buwei` worker returns:

- Review the changed-file summary or patch guidance it produced.
- Integrate the accepted changes into the coordinator workspace before moving on.
- Prefer task batches with disjoint file sets so integration is mechanical.
- If a `buwei` report is too vague to apply, send it back for precise file-level edits or diff-quality instructions before continuing.

## Artifact Conventions

Write these filenames exactly when the corresponding phase runs:

- `.tmp/swcc/zhongban-report.md`
- `.tmp/swcc/zuopai-proposal.md`
- `.tmp/swcc/youpai-proposal.md`
- `.tmp/swcc/zhongjian-proposal.md`
- `.tmp/swcc/dangwei-decision.md`
- `.tmp/swcc/guowuyuan-tasks.md`
- `.tmp/swcc/buwei-<n>-result.md`
- `.tmp/swcc/jiwei-verdict.md`

Use a sequential integer for `buwei-<n>-result.md` across all ministry tasks in the current run.

## Parsing Guidance

- Prefer a user-specified `--scale 小|中|大` override when present.
- Otherwise, extract scale from the explicit `规模判定：[小/中|大]` heading in the `zhongban` report.
- When reading the `guowuyuan` report, derive execution batches from headings such as `### 第一批` and tasks from `#### 任务 N`.
- If the report format drifts, use the most explicit dependency statement available and keep file sets disjoint.

## Research Guidance

The `zuopai` role may benefit from live web search. Use it only when the current Codex session has web access. If web search is unavailable, still produce the strongest local-first proposal and explicitly note that the proposal is based on repository context plus existing model knowledge.

## Retry Rules

- `zhili` and `zhixing`: retry ministry execution up to **2** times after a `jiwei` rejection.
- `juguo`: retry ministry execution up to **1** time after a fast-verification rejection.
- Pass the latest `jiwei` rejection report back into the retried `buwei` tasks.

## Completion

In the final user-facing response, summarize:

- final status
- chosen scale or execution mode
- files changed
- whether verification passed
- where the `.tmp/swcc/` artifacts were written
