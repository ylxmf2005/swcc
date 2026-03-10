---
name: zhixing
description: "Execute only: run State Council task decomposition, Discipline Commission task review, Ministry execution, and multi-dimensional review. Use when you already have a plan (from /xieshang or your own) and want to execute it."
argument-hint: "[plan description] or empty to use existing dangwei-decision.md"
---

# 执行（/zhixing）— 仅执行阶段

跳过协商和决策，直接从国务院拆分任务开始：国务院 → 纪委任务审查 → 部委执行 → 纪委三维审查。

## 工作流程

### Step 1: 确定执行方案和会话目录

接受 $ARGUMENTS。

**如果参数不为空：** 使用 $ARGUMENTS 作为执行方案 `PLAN`。创建新会话目录：

```bash
SESSION_DIR=".tmp/swcc/$(date +%Y-%m-%d)-{slug}"
mkdir -p "$SESSION_DIR"
```

**如果参数为空：** 查找最近的会话目录中的 `dangwei-decision.md`：

```bash
# 找到最近的 session 目录
SESSION_DIR=$(ls -td .tmp/swcc/20*/ 2>/dev/null | head -1)
```

- 如果找到且包含 `dangwei-decision.md`：读取其内容作为 `PLAN`，复用该 `SESSION_DIR`
- 如果未找到：提示用户先运行 `/xieshang` 生成方案或直接提供计划

### Step 2: 国务院拆分任务

```
Agent tool parameters:
  subagent_type: "swcc:guowuyuan"
  prompt: "请将以下实施方案拆解为可并行执行的子任务：

{如果 PLAN 来自文件：}
党委决策请从此文件读取：`{SESSION_DIR}/dangwei-decision.md`
{如果 PLAN 来自参数：}
执行方案：{PLAN}

请分析文件依赖关系，拆分为子任务并分组。

请将执行规划保存到 `{SESSION_DIR}/guowuyuan-tasks.md`"
  description: "国务院拆分子任务"
```

等待完成。读取 `{SESSION_DIR}/guowuyuan-tasks.md` 提取子任务清单。

### Step 3: 纪委任务审查

对国务院的任务拆分进行完整性审查：

```
Agent tool parameters:
  subagent_type: "swcc:jiwei"
  prompt: "【任务审查】请对国务院的任务拆分进行完整性审查。

{如果有 dangwei-decision.md：}
党委决策请从此文件读取：`{SESSION_DIR}/dangwei-decision.md`
{否则：}
执行方案：{PLAN}

国务院执行规划请从此文件读取：`{SESSION_DIR}/guowuyuan-tasks.md`

检查要点：
1. 任务清单是否完整覆盖了方案的所有要求
2. 有没有遗漏或超范围的任务
3. 子任务的文件边界是否清晰
4. 依赖关系是否合理
5. 每个子任务的描述是否具体

请将审查报告保存到 `{SESSION_DIR}/jiwei-xunshi-2.md`"
  description: "纪委任务审查"
```

等待完成。如果纪委发现遗漏，将遗漏项反馈给国务院重新拆分（最多重试 1 次）。

### Step 4: 部委执行

按国务院的分批计划，逐批并行派发 buwei agent。

**每一批在一条消息中并行派发所有子任务的 agent：**

```
Agent call #N:
  subagent_type: "swcc:buwei"
  prompt: "请执行以下子任务：
{TASK_N_DESCRIPTION}
相关文件：{TASK_N_FILES}

请将执行报告保存到 `{SESSION_DIR}/buwei-{N}-result.md`"
  description: "部委执行任务N"
```

等待该批全部完成。继续下一批。

### Step 5: 纪委三维审查

并行派发 3 个纪委专项：

```
Agent call #1:
  subagent_type: "swcc:jiwei"
  prompt: "【执行审查 — 正确性专项】

你是正确性审查专项纪委。你的发现编号使用 C1, C2, C3... 前缀。

{如果有 dangwei-decision.md：}
党委决策请从此文件读取：`{SESSION_DIR}/dangwei-decision.md`
{否则：}
执行方案：{PLAN}

各部委执行报告请从以下文件读取：
{列出所有 SESSION_DIR/buwei-*-result.md 文件}

审查重点：逻辑正确性、安全性、执行一致性、竞态问题。
运行自动化验证（测试、linter、type checker）。

请将审查报告保存到 `{SESSION_DIR}/jiwei-verdict-correctness.md`"
  description: "纪委正确性审查"

Agent call #2:
  subagent_type: "swcc:jiwei"
  prompt: "【执行审查 — 设计专项】

你是设计审查专项纪委。你的发现编号使用 D1, D2, D3... 前缀。

{如果有 dangwei-decision.md：}
党委决策请从此文件读取：`{SESSION_DIR}/dangwei-decision.md`
{否则：}
执行方案：{PLAN}

各部委执行报告请从以下文件读取：
{列出所有 SESSION_DIR/buwei-*-result.md 文件}

审查重点：代码重复、本地/外部复用、抽象合理性、模块职责。
不要运行自动化验证。

请将审查报告保存到 `{SESSION_DIR}/jiwei-verdict-design.md`"
  description: "纪委设计审查"

Agent call #3:
  subagent_type: "swcc:jiwei"
  prompt: "【执行审查 — 规范专项】

你是规范审查专项纪委。你的发现编号使用 S1, S2, S3... 前缀。

{如果有 dangwei-decision.md：}
党委决策请从此文件读取：`{SESSION_DIR}/dangwei-decision.md`
{否则：}
执行方案：{PLAN}

各部委执行报告请从以下文件读取：
{列出所有 SESSION_DIR/buwei-*-result.md 文件}

审查重点：命名规范、类型安全、魔数、commit 卫生、项目约定。
不要运行自动化验证。

请将审查报告保存到 `{SESSION_DIR}/jiwei-verdict-standards.md`"
  description: "纪委规范审查"
```

等待全部完成。

### Step 6: 交叉质疑

3 个纪委专项互相质疑（**1 条消息，3 个 Agent 调用**）：

```
Agent call #1:
  subagent_type: "swcc:jiwei"
  prompt: "【交叉质疑 — 正确性专项】

请阅读其他两个专项的审查报告：
- 设计审查：`{SESSION_DIR}/jiwei-verdict-design.md`
- 规范审查：`{SESSION_DIR}/jiwei-verdict-standards.md`
你自己的报告：`{SESSION_DIR}/jiwei-verdict-correctness.md`

必须质疑至少一条其他专项的发现。给出最终判定（通过/驳回）。

请将最终报告保存到 `{SESSION_DIR}/jiwei-final-correctness.md`"
  description: "纪委正确性交叉质疑"

Agent call #2:
  subagent_type: "swcc:jiwei"
  prompt: "【交叉质疑 — 设计专项】

请阅读其他两个专项的审查报告：
- 正确性审查：`{SESSION_DIR}/jiwei-verdict-correctness.md`
- 规范审查：`{SESSION_DIR}/jiwei-verdict-standards.md`
你自己的报告：`{SESSION_DIR}/jiwei-verdict-design.md`

必须质疑至少一条其他专项的发现。给出最终判定（通过/驳回）。

请将最终报告保存到 `{SESSION_DIR}/jiwei-final-design.md`"
  description: "纪委设计交叉质疑"

Agent call #3:
  subagent_type: "swcc:jiwei"
  prompt: "【交叉质疑 — 规范专项】

请阅读其他两个专项的审查报告：
- 正确性审查：`{SESSION_DIR}/jiwei-verdict-correctness.md`
- 设计审查：`{SESSION_DIR}/jiwei-verdict-design.md`
你自己的报告：`{SESSION_DIR}/jiwei-verdict-standards.md`

必须质疑至少一条其他专项的发现。给出最终判定（通过/驳回）。

请将最终报告保存到 `{SESSION_DIR}/jiwei-final-standards.md`"
  description: "纪委规范交叉质疑"
```

等待全部完成。

### Step 7: 处理结果

读取三份最终报告。

**全部通过：** 报告完成，列出变更摘要。提示：`所有中间产物保存在 {SESSION_DIR}/`
**任一驳回（重试 < 2）：** 汇总"必须修复"项，重新派发 buwei 修复，回到 Step 4。
**驳回（重试 >= 2）：** 报告失败，建议人工介入。

---

$ARGUMENTS
