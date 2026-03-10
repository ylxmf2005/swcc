---
name: zhengyanshi
description: "Pre-task brainstorming: explore problem space, identify ambiguities, propose approaches, get user confirmation before formal consultation. Use when you want to think through a task before committing to a plan."
argument-hint: "task description"
---

# 政研（/zhengyanshi）— 前期调研与方案预研

在正式进入民主集中制流程之前，先深入调研问题空间，与用户确认方向。

## 重要原则

1. 你是调度器，不是参与者。
2. 这个命令**不执行代码变更**，只产出调研报告和设计方向。
3. **必须与用户互动**：政研室产出报告后，暂停让用户确认方向，再保存最终设计文档。
4. 每个 agent 自己负责将报告保存到指定文件路径。

## 工作流程

### Step 1: 解析参数与创建会话目录

接受 $ARGUMENTS 作为 `TASK_DESC`。如果为空，从对话上下文提取。如仍不明确，请用户提供。

**创建会话目录：**

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

等待完成。

### Step 3: 调用政研室 — 前期调研

```
Agent tool parameters:
  subagent_type: "swcc:zhengyanshi"
  prompt: "请对以下任务进行前期调研与方案预研：

任务描述：{TASK_DESC}

中办分拣报告请从此文件读取：`{SESSION_DIR}/zhongban-report.md`

请按照你的工作流程，深入调查项目上下文、识别关键问题和模糊点、提出 2-3 种可选方向。

请将报告保存到 `{SESSION_DIR}/zhengyanshi-report.md`"
  description: "政研室前期调研"
```

等待完成。

### Step 4: 向用户展示报告并确认方向

读取 `{SESSION_DIR}/zhengyanshi-report.md` 的完整内容并展示给用户。

向用户提出确认请求：

```
政研室调研完成。请确认：
1. 以上关键问题和模糊点是否需要补充？
2. 你倾向哪个方向？（或提出你自己的方向）

确认后可继续：
- /xieshang 进入政协协商（让左右派在确认的方向上展开辩论）
- /zhili 进入全流程（自动衔接后续所有步骤）
```

**等待用户回复。** 如果用户提供了反馈，将反馈记录到 `{SESSION_DIR}/user-direction.md` 中。

### Step 5: 报告结果

```
政研调研完成。所有中间产物保存在 {SESSION_DIR}/
如需进入协商：/xieshang
如需全流程执行：/zhili
```

---

$ARGUMENTS
