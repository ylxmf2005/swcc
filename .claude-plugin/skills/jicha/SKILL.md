---
name: jicha
description: "Inspection only: run Discipline Commission code review and automated tests on current working tree changes. Use after writing code to check quality before committing."
argument-hint: "[optional focus areas]"
---

# 监察（/jicha）— 纪委单独审查

对当前工作区的代码变更进行 code review + 自动化验证。

## 工作流程

### Step 1: 收集变更信息

```bash
mkdir -p .tmp/swcc
git diff --name-only
git diff --stat
```

如果没有变更，报告：`当前工作区没有代码变更。无需监察。`

### Step 2: 调用纪委

```
Agent tool parameters:
  subagent_type: "swcc:jiwei"
  prompt: "请对当前工作区的代码变更进行监察验收。

[如果用户提供了 $ARGUMENTS]
重点关注：{$ARGUMENTS}

请按照你的工作流程：
1. 使用 git diff 查看所有变更
2. 对变更文件进行代码审查（质量、安全、风格）
3. 运行项目的测试套件、linter、type checker
4. 给出通过或驳回的结论"
  description: "纪委监察验收"
```

等待完成。保存到 `.tmp/swcc/jiwei-verdict.md`。

### Step 3: 报告结果

向用户展示纪委审查报告的完整内容。

---

$ARGUMENTS
