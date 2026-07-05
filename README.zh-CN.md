# Fable-agents

[English](README.md) · **简体中文**

面向三层 Claude Code 模型路由设置的便携式安装器:**Fable 5** 作为只负责计划、派发、综合的编排者,搭配三个子代理(Opus 上的 **deep-reasoner**、Sonnet 上的 **fast-worker**、以及作为验收与发布闸门、同样跑在 Opus 上的 **gatekeeper**),外加作为独立同行工程师的 **Codex**。

## 为什么要分工

一份 Max (20x) 订阅,一天高强度多智能体工作(2026-07-05):**9.02 亿 tokens**、**4,911 个请求**、**96.1% 缓存命中率**——API 等值用量 **$731**。

![每日用量:902,494,882 个 tokens,4,911 个请求,96.1% 缓存命中率,API 等值 $731.38](docs/images/daily-usage-overview.png)

请求分布就是路由契约本身:Fable 只回答了 **492 个请求(10%)**——纯编排:计划、派发、判断、综合。Sonnet 扛下 **2,924 个执行请求**,Opus 承担 **705** 次判断与验收。

![各模型请求分布:claude-sonnet-5 2,924 个请求,claude-fable-5 492 个,claude-opus-4-8 705 个](docs/images/per-model-request-split.png)

Fable 计入独立的周配额池,与全模型共享池分开计量。Fable 只做编排时,两个池同步消耗——周中 **Fable 池 32%,全模型池 26%**。单个模型的周用量追平订阅内其余模型的总和,而不是 Fable 池先烧干、共享池闲置。

![Claude Max 周配额:Fable 池已用 32%,全模型池已用 26%](docs/images/weekly-limits-fable-vs-all-models.png)

## 安装

### 方式 A — 克隆并运行

```bash
git clone https://github.com/Ancienttwo/Fable-agents.git
cd Fable-agents
bash scripts/install.sh --project /path/to/your/project
```

不带 `--project` 运行时,默认作用于当前目录。脚本是幂等的——可以放心重复执行。

参数:
- `--project <dir>` — 目标项目根目录(默认:当前目录)
- `--skip-plugin` — 跳过安装/检查 Codex 插件
- `--skip-smoke` — 跳过无头 agent 冒烟测试(在没有 API 凭证的沙箱环境中使用)

### 方式 B — 发给你的 Claude

把下面这段话发给任何能在你机器上执行命令的 Claude(Claude Code CLI、桌面应用或 IDE 插件):

> 从 https://github.com/Ancienttwo/Fable-agents 安装这套模型路由设置——克隆仓库,运行 `bash scripts/install.sh --project <我的项目路径>`,然后报告每一层的结果(`[new]`/`[ok]`/`[conflict]`/`[warn]`)。遇到 `[conflict]` 时绝不覆盖任何文件。

## 它安装什么

1. 把 `.claude/agents/fast-worker.md`、`.claude/agents/deep-reasoner.md`、`.claude/agents/gatekeeper.md` 安装进目标项目
2. 把 `## Model Routing Hierarchy` 章节追加进你的全局 `CLAUDE.md`(`$CLAUDE_CONFIG_DIR/CLAUDE.md`,默认 `~/.claude/CLAUDE.md`)
3. 安装 `codex@openai-codex` 插件(市场来源 `openai/codex-plugin-cc`),并做就绪检查
4. 运行无头冒烟测试,确认三个 agent 都能响应

安装器遇到与内置版本不同的文件时绝不覆盖——会报告 `[conflict]` 并以退出码 `3` 结束,让你自己 diff 后决定。

## 路由模型

- **Fable 5(主循环)= 编排者。** 负责计划、派发、综合,绝不亲自做执行类工作。
- **子代理必须显式指定 model/type。** 任何派生——无论是 Agent tool 还是 Workflow——都不能静默继承 Fable。
- **`deep-reasoner`**(Opus,`effort: max`)——架构研究、高难度推理、高风险判断。只负责给建议,最终框架由编排者确认。
- **`fast-worker`**(Sonnet,`effort: max`)——实现、测试、重构、文档、机械性执行。
- **`gatekeeper`**(Opus,`effort: max`)——执行子代理交付后的最后一道闸门:对照目标审查 diff、跑项目真实验证,返回 `PASS`/`FAIL`/`BLOCKED` 的发布建议。只建议、不决定——发布动作只有在编排者下达明确执行单后才会执行;自己绝不改代码。
- **Codex**——独立的同行工程师,不是强制性的 reviewer。通过 `codex` 插件的 `/codex:*` 命令或 `codex exec` 调用。
- **高风险决策走双轨:** deep-reasoner 和 Codex 各自独立产出一版方案,编排者对比、综合,而不是简单二选一。

## 目录结构

```
SKILL.md                          Claude Code skill 清单(若本仓库被放置/软链接到
                                   ~/.claude/skills/ 下,可直接作为 skill 使用)
assets/deep-reasoner.md           安装进目标项目的 agent 定义
assets/fast-worker.md             安装进目标项目的 agent 定义
assets/gatekeeper.md              安装进目标项目的 agent 定义
assets/model-routing-hierarchy.md 安装器追加到 CLAUDE.md 的章节来源
scripts/install.sh                幂等安装器(参数见上文)
```

## 前置条件

- `claude`(Claude Code CLI)需在 PATH 中,供插件安装步骤与冒烟测试使用
- `node` 用于 Codex 就绪检查
- `codex` CLI + `codex login`,用于完整验证 Codex 层(可选——缺失时报告 `[warn]`,不是硬性失败)

已经在运行的交互式 Claude Code 会话在启动时加载 agent 类型,因此要等重启或执行 `/reload-plugins` 后才能看到新安装的 agent。
