---
name: zhili
description: "Full pipeline democratic centralism orchestration: task triage → CPPCC consultation → Party Committee decision → execution → inspection. Use when you have a coding task that needs multi-agent planning and execution."
argument-hint: "[--scale 小|中|大] task description"
---

# 治理（/zhili）— 全流程民主集中制编排

从任务输入到代码交付的一条龙编排。主 agent 是**纯调度器**：只传数据，不做判断。

## 重要原则

1. 你是调度器，不是参与者。不要自己分析代码、提方案、写代码。
2. 每个阶段都交给对应的 agent 完成，你只传递输入和收集输出。
3. 所有中间产物保存到 `.tmp/swcc/` 目录。
4. 这是一个**直接任务→代码的管道**。

## 工作流程

### Step 1: 解析参数

接受 $ARGUMENTS。

**提取 `--scale` 参数（可选）：**
- `--scale 小` / `--scale 中` / `--scale 大`
- 如果有，记住 `USER_SCALE` 并从参数中移除
- 剩余部分为 `TASK_DESC`（任务描述）

**如果参数为空：** 从最近的对话上下文提取任务描述。如果仍然无法确定，请用户提供。

```bash
mkdir -p .tmp/swcc
```

### Step 2: 调用中办 — 收文分拣

**REQUIRED AGENT CALL:**

```
Agent tool parameters:
  subagent_type: "swcc:zhongban"
  prompt: "请对以下任务进行分拣评估：

任务描述：{TASK_DESC}

请按照你的工作流程，调查代码库并判定任务规模（小/中/大）。"
  description: "中办收文分拣"
```

等待 agent 完成。提取输出，保存到 `.tmp/swcc/zhongban-report.md`。

**确定最终规模：**
- 如果用户指定了 `USER_SCALE`，使用用户指定的
- 否则使用中办的判定
- 记为 `SCALE`

向用户报告：`中办分拣完成：规模判定为「{SCALE}」`

### Step 3: 政协协商（按规模分流）

**如果 SCALE = 小：**
跳过协商，直接进入 Step 5。向用户报告：`小任务，跳过政协协商，直接进入执行阶段。`

**如果 SCALE = 中：**
并行调用左派 + 右派（**1 条消息，2 个 Agent 调用**）：

```
Agent call #1:
  subagent_type: "swcc:zuopai"
  prompt: "请对以下任务提出你的左派革新方案：

任务描述：{TASK_DESC}

中办代码库摘要：
{ZHONGBAN_REPORT}

请按照你的工作流程，研究 SOTA 方案并提出大胆革新的实施建议。"
  description: "左派委员提案"

Agent call #2:
  subagent_type: "swcc:youpai"
  prompt: "请对以下任务提出你的右派稳健方案：

任务描述：{TASK_DESC}

中办代码库摘要：
{ZHONGBAN_REPORT}

请按照你的工作流程，分析现有代码并提出最小改动的稳健方案。"
  description: "右派委员提案"
```

等待两者完成。保存到 `.tmp/swcc/zuopai-proposal.md` 和 `.tmp/swcc/youpai-proposal.md`。然后进入 Step 4。

**如果 SCALE = 大：**
先并行调用左派 + 右派（同上），等待完成。然后调用中间路线：

```
Agent tool parameters:
  subagent_type: "swcc:zhongjian"
  prompt: "请在以下左右两派方案基础上，提出你的中间路线折中方案：

任务描述：{TASK_DESC}

中办代码库摘要：
{ZHONGBAN_REPORT}

左派方案：
{ZUOPAI_PROPOSAL}

右派方案：
{YOUPAI_PROPOSAL}

请按照你的工作流程，交叉验证两派主张并提出实事求是的折中方案。"
  description: "中间路线折中"
```

等待完成。保存到 `.tmp/swcc/zhongjian-proposal.md`。然后进入 Step 4。

### Step 4: 党委集中决策

```
Agent tool parameters:
  subagent_type: "swcc:dangwei"
  prompt: "请综合以下政协各派意见，做出最终的实施决策：

任务描述：{TASK_DESC}

中办分拣报告：
{ZHONGBAN_REPORT}

[根据 SCALE 包含对应的报告]
左派方案：{ZUOPAI_PROPOSAL}
右派方案：{YOUPAI_PROPOSAL}
[如果 SCALE = 大] 中间路线方案：{ZHONGJIAN_PROPOSAL}

请做出最终裁决。对左倾冒险主义要批评，对右倾保守主义要纠正。"
  description: "党委集中决策"
```

等待完成。保存到 `.tmp/swcc/dangwei-decision.md`。

### Step 5: 国务院执行规划

```
Agent tool parameters:
  subagent_type: "swcc:guowuyuan"
  prompt: "请将以下实施方案拆解为可并行执行的子任务：

{DANGWEI_DECISION 或 ZHONGBAN_REPORT+TASK_DESC（小任务时）}

请分析文件依赖关系，拆分为子任务并分组。"
  description: "国务院拆分子任务"
```

等待完成。保存到 `.tmp/swcc/guowuyuan-tasks.md`。提取子任务清单和分批信息。

### Step 6: 部委执行

按国务院的分批计划，逐批派发 buwei agent。**每一批在一条消息中并行派发：**

```
Agent call #N:
  subagent_type: "swcc:buwei"
  prompt: "请执行以下子任务：
{TASK_N_DESCRIPTION}
相关文件：{TASK_N_FILES}
请阅读相关代码并完成变更。"
  description: "部委执行任务N"
```

等待该批全部完成，保存报告到 `.tmp/swcc/buwei-{N}-result.md`。继续下一批。

### Step 7: 纪委监察

```
Agent tool parameters:
  subagent_type: "swcc:jiwei"
  prompt: "请对本次所有代码变更进行监察验收：

党委方案：
{DANGWEI_DECISION}

各部委执行报告：
{ALL_BUWEI_REPORTS}

请进行代码审查和自动化验证，对照党委方案检查完整性。"
  description: "纪委监察验收"
```

等待完成。保存到 `.tmp/swcc/jiwei-verdict.md`。

### Step 8: 处理审查结果

**通过：** 向用户报告完成。列出变更摘要和纪委意见。

**驳回且重试 < 2：** 根据驳回报告重新构建子任务，将纪委意见传给新的 buwei agent，回到 Step 6。

**驳回且重试 >= 2：** 报告失败，建议人工介入。所有产物保存在 `.tmp/swcc/`。

---

$ARGUMENTS
