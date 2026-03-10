# SWCC — Socialism With Chinese Characteristics (SW Claude Code)

民主集中制多智能体编排 Claude Code 插件

## Overview

SWCC orchestrates multiple Claude Code agents through a democratic centralism workflow:
consultation (政协协商) → decision (党委决策) → execution (部委执行) → inspection (纪委监察).

This is a direct task-to-code pipeline.

## Project Structure

```
.claude-plugin/
  marketplace.json       Plugin manifest
  agents/                8 agent definitions (zhongban, zuopai, youpai, zhongjian, dangwei, guowuyuan, buwei, jiwei)
  skills/                5 user-invocable skills (zhili, xieshang, zhixing, jicha, juguo)
  hooks/                 Lifecycle hooks (currently empty)
```

## Agent Roles

- **zhongban** (中办): Task triage, scale assessment (opus)
- **zuopai** (左派): Bold innovative proposals with SOTA research (opus)
- **youpai** (右派): Conservative stable proposals with minimal changes (opus)
- **zhongjian** (中间路线): Centrist synthesis of left and right (opus)
- **dangwei** (党委): Authoritative final decision (opus)
- **guowuyuan** (国务院): Task decomposition and scheduling (opus)
- **buwei** (部委): Concrete code execution (opus)
- **jiwei** (纪委): Code review + automated verification (opus)

## Key Conventions

- Agent names use pinyin (lowercase, no hyphens for single words)
- Skill names use pinyin (lowercase)
- All agent prompts written in Chinese for role immersion
- Intermediate artifacts stored in `.tmp/swcc/`
- Agents are invoked via `swcc:agent-name` namespace

## Adding New Agents

1. Create `agents/agent-name.md` with YAML frontmatter (name, description, tools, model)
2. Write system prompt in Chinese with role identity, workflow steps, and output format
3. Update marketplace.json description with new component count
4. Update README.md

## Adding New Skills

1. Create `skills/skill-name/SKILL.md` with YAML frontmatter
2. Include description explaining both what it does AND when to use it
3. Use `$ARGUMENTS` for input, document expected format
4. Update README.md
