<p align="center">
  <h1 align="center">🇨🇳 SWCC</h1>
  <p align="center"><b>Socialism With Chinese Characteristics — SW Claude Code</b></p>
  <p align="center">民主集中制多智能体编排 Claude Code 插件</p>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/agents-8_specialized-red" alt="Agents">
  <img src="https://img.shields.io/badge/skills-5_workflows-yellow" alt="Skills">
  <img src="https://img.shields.io/badge/python-not_needed-green" alt="No Python">
  <img src="https://img.shields.io/badge/dependencies-zero-brightgreen" alt="Zero deps">
  <img src="https://img.shields.io/badge/Claude_Code-plugin-blue" alt="Claude Code Plugin">
  <img src="https://img.shields.io/badge/license-MIT-lightgrey" alt="MIT">
</p>

---

> **美国人用三权分立编排 AI，中国古人用三省六部编排 AI，我们用什么？**
>
> 1949 年之后的答案：**民主集中制**。
>
> 先让左派和右派吵，吵完党委拍板，国务院拆活儿，部委干活儿，纪委验收。
>
> 一个编码任务，走完一整套中国特色社会主义政治流程。

## 为什么是民主集中制？

大多数 Multi-Agent 框架的思路是：让 Agent 自由协作，出了问题再修。

这就像没有制度的团队——要么一团和气（所有 Agent 都同意，没人提反对意见），要么各说各的（Agent 之间矛盾无人裁决）。

民主集中制的解法：**先强制对立，再集中拍板**。左派和右派必须提出不同方案，暴露盲区；党委综合裁决，一锤定音；部委坚决执行，纪委铁面验收。

| | SWCC 🇨🇳 | directive 🇺🇸 | edict 🏯 |
|---|:---:|:---:|:---:|
| **灵感来源** | 中国特色社会主义 | 美国宪政 | 三省六部 |
| **运行方式** | ✅ Claude Code 插件，装上即用 | 独立应用，需 Docker | 独立应用，需 Docker + OpenClaw |
| **决策机制** | 民主集中制 | 三权制衡 | 层级审批 |
| **强制对立** | ✅ 左右必须提出不同方案 | ❌ | ❌ |
| **动态流程** | ✅ 按规模自动调节协商深度 | ❌ 固定流程 | ❌ 固定流程 |
| **冲突裁决** | 党委综合裁决 | 最高法院仲裁 | 门下省封驳 |
| **代码执行** | ✅ 部委执行 | ✅ DoD 执行 | ✅ 兵部执行 |
| **代码验收** | ✅ 纪委 Review + 测试 | ✅ Senate + DoJ 审查 | ⚠️ 门下省审计划 |
| **紧急通道** | ✅ 举国体制 | ❌ | ❌ |

## 30 秒体验

```bash
# 安装
claude plugins marketplace add ylxmf2005/swcc
claude plugins install swcc

# 在任意项目中
/zhili 给这个项目加 JWT 认证
```

坐好，看戏。中办会先分拣任务，然后左右派开始辩论，党委拍板，部委干活，纪委验收。

## 🏛️ 架构：谁是谁

```
                          ┌─────────┐
                    ┌─────│  用户    │─────┐
                    │     └─────────┘     │
                    ▼                     │
              ┌──────────┐                │
              │ 📋 中办   │ 收文分拣        │ 交付
              │ zhongban │ 判定：小/中/大   │
              └────┬─────┘                │
         ┌─────────┼─────────┐            │
         ▼         ▼         ▼            │
    ┌─────────┐┌─────────┐┌─────────┐     │
    │ 🔴 左派  ││ 🔵 右派  ││ 🟡 中间  │     │
    │ zuopai  ││ youpai  ││zhongjian│     │
    │ 大破大立 ││ 稳中求进 ││ 实事求是 │     │
    └────┬────┘└────┬────┘└────┬────┘     │
         └──────────┼──────────┘          │
                    ▼                     │
              ┌──────────┐                │
              │ ⭐ 党委   │ 集中决策        │
              │ dangwei  │ 最终裁决        │
              └────┬─────┘                │
                   ▼                      │
              ┌──────────┐                │
              │ 🏢 国务院 │ 拆分子任务      │
              │guowuyuan │ 分析依赖        │
              └────┬─────┘                │
          ┌────────┼────────┐             │
          ▼        ▼        ▼             │
       ┌──────┐┌──────┐┌──────┐           │
       │ 部委1 ││ 部委2 ││ 部委3 │ 并行执行  │
       │buwei ││buwei ││buwei │           │
       └──┬───┘└──┬───┘└──┬───┘           │
          └────────┼────────┘             │
                   ▼                      │
              ┌──────────┐                │
              │ 🔍 纪委   │ 代码审查        │
              │  jiwei   │ + 跑测试        │
              └────┬─────┘                │
                   │ 通过? ─── 否 → 驳回重做
                   │
                   ▼────────────────────→─┘
```

## 🎭 八大员：每个 Agent 都有灵魂

| Agent | 角色 | 信条 | 模型 |
|-------|------|------|------|
| 📋 zhongban (中办) | 收文分拣 | "宁大勿小，多协商总比少协商好" | opus |
| 🔴 zuopai (左派) | 激进革新 | "推倒重来！旧代码就该删掉重写！" | opus |
| 🔵 youpai (右派) | 保守稳健 | "能修补绝不重写，能复用绝不新建" | opus |
| 🟡 zhongjian (中间路线) | 折中调和 | "实践是检验真理的唯一标准" | opus |
| ⭐ dangwei (党委) | 最终裁决 | "批评左倾冒险主义，纠正右倾保守主义" | opus |
| 🏢 guowuyuan (国务院) | 拆分调度 | "党委决策不可更改，我只负责拆分" | opus |
| 🔧 buwei (部委) | 代码执行 | "令行禁止——不多做，不少做" | opus |
| 🔍 jiwei (纪委) | 监察验收 | "铁面无私，信任但验证" | opus |

## 📊 动态协商深度

中办会根据任务复杂度自动决定协商深度。你也可以用 `--scale` 覆盖：

```
/zhili --scale 小 fix typo in README        → 跳过协商，直接执行
/zhili add input validation                  → 中办自动判定
/zhili --scale 大 redesign the auth system   → 强制三方协商
```

| 规模 | 协商深度 | 判定标准 |
|------|---------|---------|
| 小 | 跳过协商 | <3 文件，简单改动 |
| 中 | 🔴左派 vs 🔵右派 | 3-8 文件，中等复杂度 |
| 大 | 🔴左派 vs 🔵右派 → 🟡中间路线折中 | >8 文件或架构级变更 |

## ⚡ 举国体制 (`/juguo`)

当任务紧急到没时间开会：

```
/juguo 紧急修复认证漏洞
```

> 跳过中办。跳过政协。跳过党委。国务院直接拆活，全部委同时开干，纪委只跑自动化。
>
> 集中力量办大事。

## 🛠️ 五大技能

| 技能 | 说明 | 用法 |
|------|------|------|
| `/zhili` | **全流程一条龙** — 从协商到交付 | `/zhili [--scale 小\|中\|大] 任务描述` |
| `/xieshang` | **只看方案** — 产出计划不动代码 | `/xieshang 任务描述` |
| `/zhixing` | **直接执行** — 跳过讨论 | `/zhixing [方案]` |
| `/jicha` | **纪委审查** — review 当前变更 | `/jicha [关注点]` |
| `/juguo` | **举国体制** — 全力冲刺 | `/juguo 任务描述` |

## 📦 安装

```bash
# 方式一：从 GitHub 安装
claude plugins marketplace add ylxmf2005/swcc
claude plugins install swcc

# 方式二：本地安装
git clone https://github.com/ylxmf2005/swcc.git
claude plugins install --path ./swcc
```

零依赖。不需要 Python，不需要 Docker，不需要 OpenClaw。装上就用。

## 📁 产物

所有中间结果保存在 `.tmp/swcc/`，完整可追溯：

```
.tmp/swcc/
├── zhongban-report.md        # 📋 中办分拣报告
├── zuopai-proposal.md        # 🔴 左派方案（含 diff 草案）
├── youpai-proposal.md        # 🔵 右派方案（含 diff 草案）
├── zhongjian-proposal.md     # 🟡 中间路线方案（大任务时）
├── dangwei-decision.md       # ⭐ 党委最终决策
├── guowuyuan-tasks.md        # 🏢 国务院子任务清单
├── buwei-{N}-result.md       # 🔧 各部委执行报告
└── jiwei-verdict.md          # 🔍 纪委审查报告
```

## 🤔 FAQ

**Q: 这是认真的吗？**

A: 是的。民主集中制在多智能体编排中是一个合理的范式——协商阶段收集多元信息避免盲区，集中阶段快速决策避免僵局，执行阶段统一调度保证效率。我们只是用了一个有趣的隐喻来包装它。

**Q: 和其他多 Agent 框架有什么区别？**

A: 大多数多 Agent 框架只做规划（产出方案/计划），SWCC 是全流程的——从协商到写代码到审查，一条龙交付。

**Q: 如果党委做了错误的决策怎么办？**

A: 纪委会驳回。纪委不看面子，只看代码和测试结果。驳回后自动重试（最多 2 次），之后交给人工介入。

**Q: 举国体制真的有用吗？**

A: 对于紧急且明确的任务（比如修 bug），跳过 30 分钟的左右辩论直接开干是合理的。牺牲审议质量换速度，和现实中一样。

## Contributing

PRs welcome. 无论你是左派还是右派，我们都欢迎。

## License

MIT — 比任何政治制度都自由。
