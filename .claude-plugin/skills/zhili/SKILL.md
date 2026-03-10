---
name: zhili
description: "Full pipeline democratic centralism orchestration: task triage → brainstorming → CPPCC consultation → Party Committee decision → inspection → execution → multi-dimensional review. Use when you have a coding task that needs multi-agent planning and execution."
argument-hint: "[--scale 小|中|大] task description"
---

# 治理（/zhili）— 全流程民主集中制编排

从任务输入到代码交付的一条龙编排。主 agent 是**纯调度器**：只传数据，不做判断。

## 重要原则

1. 你是调度器，不是参与者。不要自己分析代码、提方案、写代码。
2. 每个阶段都交给对应的 agent 完成，你只传递输入和收集输出。
3. 每个 agent 自己负责将报告保存到指定文件路径。下游 agent 从文件中读取上游报告。
4. 这是一个**直接任务→代码的管道**。

## 工作流程

### Step 1: 解析参数与创建会话目录

接受 $ARGUMENTS。

**提取 `--scale` 参数（可选）：**
- `--scale 小` / `--scale 中` / `--scale 大`
- 如果有，记住 `USER_SCALE` 并从参数中移除
- 剩余部分为 `TASK_DESC`（任务描述）

**如果参数为空：** 从最近的对话上下文提取任务描述。如果仍然无法确定，请用户提供。

**创建会话目录（必须执行，不可跳过）：**
从任务描述提取 2-4 个英文关键词作为 slug（kebab-case，不超过 30 字符），生成：

```bash
SESSION_DIR=".tmp/swcc/$(date +%Y-%m-%d)-{slug}"
```

例如任务 "add user authentication" → `.tmp/swcc/2026-03-10-add-user-auth/`

**⚠️ 你必须立即用 Bash 工具执行 `mkdir -p "$SESSION_DIR"`，确认目录已创建后再进入下一步。** 不要把文件直接写到 `.tmp/swcc/` 根目录——所有产物必须写入子目录。

后续所有 agent 的输出路径都基于 `SESSION_DIR`。

### Step 2: 调用中办 — 收文分拣

```
Agent tool parameters:
  subagent_type: "swcc:zhongban"
  prompt: "请对以下任务进行分拣评估：

任务描述：{TASK_DESC}

请按照你的工作流程，调查代码库并判定任务规模（小/中/大）。

请将报告保存到 `{SESSION_DIR}/zhongban-report.md`"
  description: "中办收文分拣"
```

等待 agent 完成。读取 `{SESSION_DIR}/zhongban-report.md` 提取规模判定。

**确定最终规模：**
- 如果用户指定了 `USER_SCALE`，使用用户指定的
- 否则使用中办的判定
- 记为 `SCALE`

向用户报告：`中办分拣完成：规模判定为「{SCALE}」。会话目录：{SESSION_DIR}`

### Step 3: 政研室调研（按规模分流）

**如果 SCALE = 小：**
跳过政研室和协商，直接进入 Step 7。向用户报告：`小任务，跳过政研室调研和政协协商，直接进入执行阶段。`

**如果 SCALE = 中/大：**

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

等待完成。读取 `{SESSION_DIR}/zhengyanshi-report.md` 并展示给用户。

**向用户确认方向：**

```
政研室调研完成。请确认：
1. 以上关键问题和模糊点是否需要补充？
2. 你倾向哪个方向？

输入你的选择或反馈，我将继续进入政协协商阶段。
如无异议，直接回复"继续"。
```

**等待用户回复。** 将用户的反馈记为 `USER_DIRECTION`。

### Step 4: 政协协商

**如果 SCALE = 中：**
并行调用左派 + 右派（**1 条消息，2 个 Agent 调用**）：

```
Agent call #1:
  subagent_type: "swcc:zuopai"
  prompt: "请对以下任务提出你的左派革新方案：

任务描述：{TASK_DESC}

中办代码库摘要请从此文件读取：`{SESSION_DIR}/zhongban-report.md`
政研室调研报告请从此文件读取：`{SESSION_DIR}/zhengyanshi-report.md`
{如果有 USER_DIRECTION：}
用户确认的方向：{USER_DIRECTION}

请按照你的工作流程，研究 SOTA 方案并提出大胆革新的实施建议。

请将报告保存到 `{SESSION_DIR}/zuopai-proposal.md`"
  description: "政协左派提案"

Agent call #2:
  subagent_type: "swcc:youpai"
  prompt: "请对以下任务提出你的右派稳健方案：

任务描述：{TASK_DESC}

中办代码库摘要请从此文件读取：`{SESSION_DIR}/zhongban-report.md`
政研室调研报告请从此文件读取：`{SESSION_DIR}/zhengyanshi-report.md`
{如果有 USER_DIRECTION：}
用户确认的方向：{USER_DIRECTION}

请按照你的工作流程，分析现有代码并提出最小改动的稳健方案。

请将报告保存到 `{SESSION_DIR}/youpai-proposal.md`"
  description: "政协右派提案"
```

等待两者完成。然后进入 Step 5。

**如果 SCALE = 大：**
先并行调用左派 + 右派（同上），等待完成。然后调用中间路线：

```
Agent tool parameters:
  subagent_type: "swcc:zhongjian"
  prompt: "请在左右两派方案基础上，提出你的中间路线折中方案：

任务描述：{TASK_DESC}

请从以下文件读取上游报告：
- 中办分拣报告：`{SESSION_DIR}/zhongban-report.md`
- 政研室调研报告：`{SESSION_DIR}/zhengyanshi-report.md`
- 左派方案：`{SESSION_DIR}/zuopai-proposal.md`
- 右派方案：`{SESSION_DIR}/youpai-proposal.md`

请按照你的工作流程，交叉验证两派主张并提出实事求是的折中方案。

请将报告保存到 `{SESSION_DIR}/zhongjian-proposal.md`"
  description: "中间路线折中"
```

等待完成。然后进入 Step 5。

### Step 5: 党委集中决策

```
Agent tool parameters:
  subagent_type: "swcc:dangwei"
  prompt: "请综合政协各派意见，做出最终的实施决策：

任务描述：{TASK_DESC}

请从以下文件读取各方报告：
- 中办分拣报告：`{SESSION_DIR}/zhongban-report.md`
- 政研室调研报告：`{SESSION_DIR}/zhengyanshi-report.md`
- 左派方案：`{SESSION_DIR}/zuopai-proposal.md`
- 右派方案：`{SESSION_DIR}/youpai-proposal.md`
{如果 SCALE = 大，加上：}
- 中间路线方案：`{SESSION_DIR}/zhongjian-proposal.md`
{如果有 USER_DIRECTION：}
- 用户确认的方向：{USER_DIRECTION}

请做出最终裁决。对左倾冒险主义要批评，对右倾保守主义要纠正。

请将决策报告保存到 `{SESSION_DIR}/dangwei-decision.md`"
  description: "党委集中决策"
```

等待完成。

### Step 6: 纪委决策审查

对党委决策进行质量审查：

```
Agent tool parameters:
  subagent_type: "swcc:jiwei"
  prompt: "【决策审查】请对党委决策进行质量审查。

任务描述：{TASK_DESC}

请从以下文件读取：
- 党委决策：`{SESSION_DIR}/dangwei-decision.md`
- 左派方案：`{SESSION_DIR}/zuopai-proposal.md`
- 右派方案：`{SESSION_DIR}/youpai-proposal.md`

检查要点：
1. 党委是否引用并回应了各方的核心主张和风险分析
2. 裁决理由是否有据可依，而非武断拍板
3. 最终方案是否超出了原始任务描述的范围
4. 文件变更清单是否明确、可执行
5. 验收标准是否具体、可验证

请将审查报告保存到 `{SESSION_DIR}/jiwei-xunshi-1.md`"
  description: "纪委决策审查"
```

等待完成。向用户简要报告审查结论。如果存在问题，记录但继续流程。

### Step 7: 国务院执行规划

```
Agent tool parameters:
  subagent_type: "swcc:guowuyuan"
  prompt: "请将实施方案拆解为可并行执行的子任务。

{如果 SCALE = 小：}
任务描述：{TASK_DESC}
中办报告请从此文件读取：`{SESSION_DIR}/zhongban-report.md`

{如果 SCALE = 中/大：}
党委决策请从此文件读取：`{SESSION_DIR}/dangwei-decision.md`

请分析文件依赖关系，拆分为子任务并分组。

请将执行规划保存到 `{SESSION_DIR}/guowuyuan-tasks.md`"
  description: "国务院拆分子任务"
```

等待完成。读取 `{SESSION_DIR}/guowuyuan-tasks.md` 提取子任务清单和分批信息。

### Step 8: 纪委任务审查

**如果 SCALE = 小：跳过此步骤。**

对国务院的任务拆分进行完整性审查：

```
Agent tool parameters:
  subagent_type: "swcc:jiwei"
  prompt: "【任务审查】请对国务院的任务拆分进行完整性审查。

任务描述：{TASK_DESC}

请从以下文件读取：
- 党委决策：`{SESSION_DIR}/dangwei-decision.md`
- 国务院执行规划：`{SESSION_DIR}/guowuyuan-tasks.md`

检查要点：
1. 任务清单是否完整覆盖了党委决策的所有文件变更和要求
2. 有没有遗漏的变更项（决策要求了但任务没覆盖）
3. 有没有超范围的任务（决策没要求但任务里出现了）
4. 子任务的文件边界是否清晰、有没有重叠
5. 依赖关系是否合理
6. 每个子任务的描述是否具体到部委可以直接执行

请将审查报告保存到 `{SESSION_DIR}/jiwei-xunshi-2.md`"
  description: "纪委任务审查"
```

等待完成。向用户简要报告审查结论。

**如果纪委发现遗漏**（审查结论为"存在问题"且有具体遗漏项），将遗漏项反馈给国务院重新拆分（最多重试 1 次），然后继续。

### Step 9: 部委执行

按国务院的分批计划，逐批派发 buwei agent。**每一批在一条消息中并行派发：**

```
Agent call #N:
  subagent_type: "swcc:buwei"
  prompt: "请执行以下子任务：
{TASK_N_DESCRIPTION}
相关文件：{TASK_N_FILES}
请阅读相关代码并完成变更。

请将执行报告保存到 `{SESSION_DIR}/buwei-{N}-result.md`"
  description: "部委执行任务N"
```

等待该批全部完成。继续下一批。

### Step 10: 纪委三维审查

**同时**调用 3 个纪委专项（**1 条消息，3 个 Agent 调用**）：

```
Agent call #1:
  subagent_type: "swcc:jiwei"
  prompt: "【执行审查 — 正确性专项】

你是正确性审查专项纪委。你的发现编号使用 C1, C2, C3... 前缀。

{如果 SCALE = 小：}
中办报告请从此文件读取：`{SESSION_DIR}/zhongban-report.md`
{如果 SCALE = 中/大：}
党委决策请从此文件读取：`{SESSION_DIR}/dangwei-decision.md`

各部委执行报告请从以下文件读取：
{列出所有 SESSION_DIR/buwei-*-result.md 文件}

你的审查重点：
1. 代码逻辑是否正确、边界条件是否处理
2. 安全性（注入、硬编码密钥、输入验证）
3. 执行一致性（部委是否忠实执行了方案）
4. 竞态与并发问题
5. 运行自动化验证（测试、linter、type checker）

请将审查报告保存到 `{SESSION_DIR}/jiwei-verdict-correctness.md`"
  description: "纪委正确性审查"

Agent call #2:
  subagent_type: "swcc:jiwei"
  prompt: "【执行审查 — 设计专项】

你是设计审查专项纪委。你的发现编号使用 D1, D2, D3... 前缀。

{如果 SCALE = 小：}
中办报告请从此文件读取：`{SESSION_DIR}/zhongban-report.md`
{如果 SCALE = 中/大：}
党委决策请从此文件读取：`{SESSION_DIR}/dangwei-decision.md`

各部委执行报告请从以下文件读取：
{列出所有 SESSION_DIR/buwei-*-result.md 文件}

你的审查重点：
1. 代码重复（变更中有没有重复或相似的代码）
2. 本地复用（项目中有没有现成工具函数可以替代新代码）
3. 外部复用（标准库或已有依赖能否替代自定义实现）
4. 抽象合理性（有没有过度封装或应抽象而未抽象的地方）
5. 模块职责（变更文件是否保持了单一职责）

**不要运行自动化验证**，那是正确性专项的职责。

请将审查报告保存到 `{SESSION_DIR}/jiwei-verdict-design.md`"
  description: "纪委设计审查"

Agent call #3:
  subagent_type: "swcc:jiwei"
  prompt: "【执行审查 — 规范专项】

你是规范审查专项纪委。你的发现编号使用 S1, S2, S3... 前缀。

{如果 SCALE = 小：}
中办报告请从此文件读取：`{SESSION_DIR}/zhongban-report.md`
{如果 SCALE = 中/大：}
党委决策请从此文件读取：`{SESSION_DIR}/dangwei-decision.md`

各部委执行报告请从以下文件读取：
{列出所有 SESSION_DIR/buwei-*-result.md 文件}

你的审查重点：
1. 命名规范（变量/函数/类命名是否符合项目风格）
2. 类型安全（函数签名是否有类型标注）
3. 魔数（未命名的字面量是否应该用常量替代）
4. Commit 卫生（有没有调试代码、临时文件混入）
5. 项目约定（错误处理风格、日志格式、模块组织是否一致）

**不要运行自动化验证**，那是正确性专项的职责。

请将审查报告保存到 `{SESSION_DIR}/jiwei-verdict-standards.md`"
  description: "纪委规范审查"

```

等待全部完成。

### Step 11: 交叉质疑

3 个纪委专项互相质疑（**1 条消息，3 个 Agent 调用**）：

```
Agent call #1:
  subagent_type: "swcc:jiwei"
  prompt: "【交叉质疑 — 正确性专项】

你是正确性审查专项纪委，现在进入交叉质疑阶段。

请阅读其他两个专项的审查报告：
- 设计审查报告：`{SESSION_DIR}/jiwei-verdict-design.md`
- 规范审查报告：`{SESSION_DIR}/jiwei-verdict-standards.md`

你自己的审查报告：`{SESSION_DIR}/jiwei-verdict-correctness.md`

请执行交叉质疑：
1. **必须质疑至少一条**其他专项的发现（你认为不准确或过于严格的）
2. 可以附议你认为特别重要的发现
3. 如果其他专项的视角让你发现自己的某条发现有误，主动撤回
4. 给出你的最终判定（通过/驳回）

请将最终报告保存到 `{SESSION_DIR}/jiwei-final-correctness.md`"
  description: "纪委正确性交叉质疑"

Agent call #2:
  subagent_type: "swcc:jiwei"
  prompt: "【交叉质疑 — 设计专项】

你是设计审查专项纪委，现在进入交叉质疑阶段。

请阅读其他两个专项的审查报告：
- 正确性审查报告：`{SESSION_DIR}/jiwei-verdict-correctness.md`
- 规范审查报告：`{SESSION_DIR}/jiwei-verdict-standards.md`

你自己的审查报告：`{SESSION_DIR}/jiwei-verdict-design.md`

请执行交叉质疑：
1. **必须质疑至少一条**其他专项的发现
2. 可以附议你认为特别重要的发现
3. 如果其他专项的视角让你发现自己的某条发现有误，主动撤回
4. 给出你的最终判定（通过/驳回）

请将最终报告保存到 `{SESSION_DIR}/jiwei-final-design.md`"
  description: "纪委设计交叉质疑"

Agent call #3:
  subagent_type: "swcc:jiwei"
  prompt: "【交叉质疑 — 规范专项】

你是规范审查专项纪委，现在进入交叉质疑阶段。

请阅读其他两个专项的审查报告：
- 正确性审查报告：`{SESSION_DIR}/jiwei-verdict-correctness.md`
- 设计审查报告：`{SESSION_DIR}/jiwei-verdict-design.md`

你自己的审查报告：`{SESSION_DIR}/jiwei-verdict-standards.md`

请执行交叉质疑：
1. **必须质疑至少一条**其他专项的发现
2. 可以附议你认为特别重要的发现
3. 如果其他专项的视角让你发现自己的某条发现有误，主动撤回
4. 给出你的最终判定（通过/驳回）

请将最终报告保存到 `{SESSION_DIR}/jiwei-final-standards.md`"
  description: "纪委规范交叉质疑"
```

等待全部完成。

### Step 12: 处理审查结果

读取三份最终报告：
- `{SESSION_DIR}/jiwei-final-correctness.md`
- `{SESSION_DIR}/jiwei-final-design.md`
- `{SESSION_DIR}/jiwei-final-standards.md`

**全部通过：** 向用户报告完成。展示三个专项的审查结论。提示：`所有中间产物保存在 {SESSION_DIR}/`

**任一驳回且重试 < 2：** 汇总所有"必须修复"项，重新构建子任务，将纪委意见传给新的 buwei agent，回到 Step 9。

**驳回且重试 >= 2：** 报告失败，建议人工介入。提示：`所有中间产物保存在 {SESSION_DIR}/`

> 三个专项中**任何一个**判定驳回，整体即为驳回。

---

$ARGUMENTS
