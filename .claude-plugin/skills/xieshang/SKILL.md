---
name: xieshang
description: "Consultation only: run CPPCC left-right debate and Party Committee decision without code execution. Use when you want to see the plan before committing to execution."
argument-hint: "task description"
---

# 协商（/xieshang）— 仅政协协商 + 党委决策

运行中办分拣 → 政协协商 → 党委决策，产出实施方案但**不执行代码变更**。

## 重要原则

1. 你是调度器，不是参与者。
2. 这个命令**不执行代码变更**，只产出方案。
3. 每个 agent 自己负责将报告保存到指定文件路径。下游 agent 从文件中读取上游报告。

## 工作流程

### Step 1: 解析参数与创建会话目录

接受 $ARGUMENTS 作为 `TASK_DESC`。如果为空，从对话上下文提取。

**创建会话目录：**
从任务描述提取 2-4 个英文关键词作为 slug（kebab-case，不超过 30 字符），生成：

```bash
SESSION_DIR=".tmp/swcc/$(date +%Y-%m-%d)-{slug}"
mkdir -p "$SESSION_DIR"
```

### Step 2: 调用中办 — 收文分拣

```
Agent tool parameters:
  subagent_type: "swcc:zhongban"
  prompt: "请对以下任务进行分拣评估：

任务描述：{TASK_DESC}

请调查代码库并判定任务规模（小/中/大）。

请将报告保存到 `{SESSION_DIR}/zhongban-report.md`"
  description: "中办收文分拣"
```

等待完成。读取 `{SESSION_DIR}/zhongban-report.md` 提取 `SCALE`。

### Step 3: 政协协商

**无论规模大小，/xieshang 总是进行协商**（即使是小任务也跑，因为用户显式要求了协商）。

并行调用左派 + 右派（1 条消息，2 个 Agent 调用）：

```
Agent call #1:
  subagent_type: "swcc:zuopai"
  prompt: "请对以下任务提出你的左派革新方案：

任务描述：{TASK_DESC}
中办代码库摘要请从此文件读取：`{SESSION_DIR}/zhongban-report.md`

请将报告保存到 `{SESSION_DIR}/zuopai-proposal.md`"
  description: "左派委员提案"

Agent call #2:
  subagent_type: "swcc:youpai"
  prompt: "请对以下任务提出你的右派稳健方案：

任务描述：{TASK_DESC}
中办代码库摘要请从此文件读取：`{SESSION_DIR}/zhongban-report.md`

请将报告保存到 `{SESSION_DIR}/youpai-proposal.md`"
  description: "右派委员提案"
```

等待完成。

**如果 SCALE = 大：** 追加调用中间路线：

```
Agent tool parameters:
  subagent_type: "swcc:zhongjian"
  prompt: "请在左右两派方案基础上，提出你的中间路线折中方案：

任务描述：{TASK_DESC}

请从以下文件读取上游报告：
- 中办分拣报告：`{SESSION_DIR}/zhongban-report.md`
- 左派方案：`{SESSION_DIR}/zuopai-proposal.md`
- 右派方案：`{SESSION_DIR}/youpai-proposal.md`

请将报告保存到 `{SESSION_DIR}/zhongjian-proposal.md`"
  description: "中间路线折中"
```

等待完成。

### Step 4: 党委集中决策

```
Agent tool parameters:
  subagent_type: "swcc:dangwei"
  prompt: "请综合政协各派意见，做出最终实施决策：

任务描述：{TASK_DESC}

请从以下文件读取各方报告：
- 中办分拣报告：`{SESSION_DIR}/zhongban-report.md`
- 左派方案：`{SESSION_DIR}/zuopai-proposal.md`
- 右派方案：`{SESSION_DIR}/youpai-proposal.md`
{如果 SCALE = 大，加上：}
- 中间路线方案：`{SESSION_DIR}/zhongjian-proposal.md`

请将决策报告保存到 `{SESSION_DIR}/dangwei-decision.md`"
  description: "党委集中决策"
```

等待完成。

### Step 5: 报告结果

读取 `{SESSION_DIR}/dangwei-decision.md` 的完整内容并展示给用户。

```
政协协商 + 党委决策完成。所有中间产物保存在 {SESSION_DIR}/
如需执行此方案，运行：/zhixing
```

---

$ARGUMENTS
