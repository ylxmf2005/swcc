---
name: juguo
description: "Emergency mode: skip all consultation, execute all agents in maximum parallelism, fast verification only. Use for urgent bug fixes or tasks where the solution is already clear."
argument-hint: "task description"
---

# 举国体制（/juguo）— 紧急快速通道

跳过中办分拣、政协协商、党委决策。直接执行。牺牲审议质量换最快交付。

## 重要原则

1. **跳过一切协商**：不调中办、不调政协、不调党委
2. **直接拆分执行**：国务院直接根据用户描述拆任务
3. **全部并行**：所有子任务尽量一批并行
4. **快速验证**：纪委只跑自动化测试，跳过深度 code review

## 工作流程

### Step 1: 解析参数

接受 $ARGUMENTS 作为 `TASK_DESC`。如果为空，请用户提供。

```bash
mkdir -p .tmp/swcc
```

向用户报告：`举国体制启动。跳过协商，直接执行。`

### Step 2: 国务院直接拆分

```
Agent tool parameters:
  subagent_type: "swcc:guowuyuan"
  prompt: "【举国体制】请将以下任务直接拆解为可并行执行的子任务：

任务描述：{TASK_DESC}

注意：举国体制模式，无需等待上级方案。直接根据任务描述和代码库现状拆分。尽量让所有子任务都在一批内并行执行。"
  description: "国务院紧急拆分"
```

等待完成。保存到 `.tmp/swcc/guowuyuan-tasks.md`。

### Step 3: 全部委并行执行

将所有子任务放在**一条消息中全部并行派发**（不分批次）：

```
Agent call #N:
  subagent_type: "swcc:buwei"
  prompt: "【举国体制】请执行以下子任务：
{TASK_N_DESCRIPTION}
相关文件：{TASK_N_FILES}"
  description: "部委执行任务N"
```

等待全部完成。保存报告。

### Step 4: 纪委快速验证

```
Agent tool parameters:
  subagent_type: "swcc:jiwei"
  prompt: "【举国体制 — 快速验证模式】

请对本次代码变更进行快速验证。仅执行自动化检查：
1. 运行测试套件
2. 运行 linter
3. 运行 type checker

**跳过深度代码审查**。自动化检查全部通过即判定为通过。

各部委执行报告：{ALL_BUWEI_REPORTS}"
  description: "纪委快速验证"
```

等待完成。保存到 `.tmp/swcc/jiwei-verdict.md`。

### Step 5: 报告结果

**通过：** 报告完成。提示：`本次跳过了深度代码审查。如需完整审查，运行 /jicha`
**失败（重试 < 1）：** 重新派 buwei 修复，回到 Step 3。
**失败（重试 >= 1）：** 报告失败（举国体制只给 1 次重试机会）。

---

$ARGUMENTS
