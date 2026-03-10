---
name: jicha
description: "Inspection only: run Discipline Commission code review and automated tests on current working tree changes. Use after writing code to check quality before committing."
argument-hint: "[optional focus areas]"
---

# 监察（/jicha）— 纪委单独审查

对当前工作区的代码变更进行 code review + 自动化验证。

## 工作流程

### Step 1: 收集变更信息和确定会话目录

```bash
git diff --name-only
git diff --stat
```

如果没有变更，报告：`当前工作区没有代码变更。无需监察。`

**确定会话目录：**

```bash
# 复用最近的 session 目录，或新建
SESSION_DIR=$(ls -td .tmp/swcc/20*/ 2>/dev/null | head -1)
if [ -z "$SESSION_DIR" ]; then
  SESSION_DIR=".tmp/swcc/$(date +%Y-%m-%d)-jicha"
  mkdir -p "$SESSION_DIR"
fi
```

### Step 2: 调用纪委

```
Agent tool parameters:
  subagent_type: "swcc:jiwei"
  prompt: "请对当前工作区的代码变更进行监察验收。

[如果用户提供了 $ARGUMENTS]
重点关注：{$ARGUMENTS}

[如果 SESSION_DIR 中有 dangwei-decision.md]
党委决策请从此文件读取：`{SESSION_DIR}/dangwei-decision.md`

请按照你的工作流程：
1. 使用 git diff 查看所有变更
2. 对变更文件进行代码审查（质量、安全、风格）
3. 运行项目的测试套件、linter、type checker
4. 给出通过或驳回的结论

请将审查报告保存到 `{SESSION_DIR}/jiwei-verdict.md`"
  description: "纪委监察验收"
```

等待完成。

### Step 3: 报告结果

读取 `{SESSION_DIR}/jiwei-verdict.md` 的完整内容并展示给用户。提示：`审查报告保存在 {SESSION_DIR}/jiwei-verdict.md`

---

$ARGUMENTS
