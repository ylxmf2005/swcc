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
3. 所有中间产物保存到 `.tmp/swcc/`。

## 工作流程

### Step 1: 解析参数

接受 $ARGUMENTS 作为 `TASK_DESC`。如果为空，从对话上下文提取。

```bash
mkdir -p .tmp/swcc
```

### Step 2: 调用中办 — 收文分拣

```
Agent tool parameters:
  subagent_type: "swcc:zhongban"
  prompt: "请对以下任务进行分拣评估：

任务描述：{TASK_DESC}

请调查代码库并判定任务规模（小/中/大）。"
  description: "中办收文分拣"
```

等待完成。保存到 `.tmp/swcc/zhongban-report.md`。提取 `SCALE`。

### Step 3: 政协协商

**无论规模大小，/xieshang 总是进行协商**（即使是小任务也跑，因为用户显式要求了协商）。

并行调用左派 + 右派（1 条消息，2 个 Agent 调用）：

```
Agent call #1:
  subagent_type: "swcc:zuopai"
  prompt: "请对以下任务提出你的左派革新方案：

任务描述：{TASK_DESC}
中办代码库摘要：{ZHONGBAN_REPORT}"
  description: "左派委员提案"

Agent call #2:
  subagent_type: "swcc:youpai"
  prompt: "请对以下任务提出你的右派稳健方案：

任务描述：{TASK_DESC}
中办代码库摘要：{ZHONGBAN_REPORT}"
  description: "右派委员提案"
```

等待完成。保存报告。

**如果 SCALE = 大：** 追加调用中间路线（传入左右两派报告）。

### Step 4: 党委集中决策

```
Agent tool parameters:
  subagent_type: "swcc:dangwei"
  prompt: "请综合政协各派意见，做出最终实施决策：

任务描述：{TASK_DESC}
中办分拣报告：{ZHONGBAN_REPORT}
左派方案：{ZUOPAI_PROPOSAL}
右派方案：{YOUPAI_PROPOSAL}
[如果有] 中间路线方案：{ZHONGJIAN_PROPOSAL}"
  description: "党委集中决策"
```

等待完成。保存到 `.tmp/swcc/dangwei-decision.md`。

### Step 5: 报告结果

向用户展示党委决策方案的完整内容。

```
政协协商 + 党委决策完成。方案已保存到 .tmp/swcc/dangwei-decision.md
如需执行此方案，运行：/zhixing
```

---

$ARGUMENTS
