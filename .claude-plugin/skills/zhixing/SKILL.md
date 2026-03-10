---
name: zhixing
description: "Execute only: run State Council task decomposition, Ministry execution, and Discipline Commission review. Use when you already have a plan (from /xieshang or your own) and want to execute it."
argument-hint: "[plan description] or empty to use existing dangwei-decision.md"
---

# 执行（/zhixing）— 仅执行阶段

跳过协商和决策，直接从国务院拆分任务开始：国务院 → 部委执行 → 纪委验收。

## 工作流程

### Step 1: 确定执行方案

接受 $ARGUMENTS。

**如果参数不为空：** 使用 $ARGUMENTS 作为执行方案 `PLAN`。

**如果参数为空：** 检查 `.tmp/swcc/dangwei-decision.md` 是否存在：
- 存在：读取其内容作为 `PLAN`
- 不存在：提示用户先运行 `/xieshang` 生成方案或直接提供计划

```bash
mkdir -p .tmp/swcc
```

### Step 2: 国务院拆分任务

```
Agent tool parameters:
  subagent_type: "swcc:guowuyuan"
  prompt: "请将以下实施方案拆解为可并行执行的子任务：

{PLAN}

请分析文件依赖关系，拆分为子任务并分组。"
  description: "国务院拆分子任务"
```

等待完成。保存到 `.tmp/swcc/guowuyuan-tasks.md`。

### Step 3: 部委执行

按国务院的分批计划，逐批并行派发 buwei agent。

**每一批在一条消息中并行派发所有子任务的 agent：**

```
Agent call #N:
  subagent_type: "swcc:buwei"
  prompt: "请执行以下子任务：
{TASK_N_DESCRIPTION}
相关文件：{TASK_N_FILES}"
  description: "部委执行任务N"
```

等待该批全部完成。保存报告到 `.tmp/swcc/buwei-{N}-result.md`。继续下一批。

### Step 4: 纪委监察

```
Agent tool parameters:
  subagent_type: "swcc:jiwei"
  prompt: "请对本次所有代码变更进行监察验收：

执行方案：{PLAN}
各部委执行报告：{ALL_BUWEI_REPORTS}

请进行代码审查和自动化验证。"
  description: "纪委监察验收"
```

等待完成。保存到 `.tmp/swcc/jiwei-verdict.md`。

### Step 5: 处理结果

**通过：** 报告完成，列出变更摘要。
**驳回（重试 < 2）：** 根据驳回意见重新派发 buwei 修复，回到 Step 3。
**驳回（重试 >= 2）：** 报告失败，建议人工介入。

---

$ARGUMENTS
