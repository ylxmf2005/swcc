---
name: zhiku
description: "Think tank research: directly invoke the 智库 agent for on-demand research. Supports 4 modes — 社科院 (SOTA research), 发改委 (feasibility analysis), 工程院 (implementation reference), 审计署 (compliance standards). Use when you need to research a technology, compare solutions, check docs, or investigate best practices."
argument-hint: "<research question or topic>"
---

# 智库调研（/zhiku）— 直接对话智库

按需调研：技术选型、方案对比、文档查阅、最佳实践、安全规范……有问题，问智库。

## 工作流程

### Step 1: 确定会话目录

```bash
SESSION_DIR=".tmp/swcc/$(date +%Y-%m-%d)-zhiku"
mkdir -p "$SESSION_DIR"
```

### Step 2: 调用智库

```
Agent tool parameters:
  subagent_type: "swcc:zhiku"
  prompt: "用户直接向你提问，请根据问题内容自动判断应切换为哪个机构身份（社科院/发改委/工程院/审计署）。

用户的调研问题：
{$ARGUMENTS}

请按照你的工作流程：
1. 识别身份——根据问题性质选择机构模式
2. 综合使用 WebSearch、WebFetch、Grep、Glob、Read 进行调研
3. 输出结构化的智库调研报告

请将调研报告保存到 `{SESSION_DIR}/zhiku-report.md`"
  description: "智库按需调研"
```

等待完成。

### Step 3: 报告结果

读取 `{SESSION_DIR}/zhiku-report.md` 的完整内容并展示给用户。提示：`调研报告保存在 {SESSION_DIR}/zhiku-report.md`

---

$ARGUMENTS
