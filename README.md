# OpenClaw Token Saver | OpenClaw 省钱神器

[English](#english) | [中文](#中文)

---

## 中文

### 🚀 一句话介绍

**让你的 OpenClaw API 费用降低 60-90%** 的自动化工具包 + 最佳实践指南。

### 💰 真实省钱数据

基于 Jetson Orin Nano 高频机器人开发实测（每天 50+ 条消息）：

| 使用场景 | 消息数/天 | 优化前月费 | 优化后月费 | 节省 |
|---------|----------|-----------|-----------|------|
| 轻度用户（日常聊天） | 10 | ¥22 | ¥7 | **68%** ↓ |
| 中度用户（日常编程） | 30 | ¥93 | ¥29 | **69%** ↓ |
| 重度用户（高频开发） | 50 | ¥143 | ¥33 | **77%** ↓ |

**案例**：一位开发者通过 30 分钟优化，从 ¥143/月 → ¥33/月，省下 **¥110/月**。

### ✨ 核心功能

- 📊 **成本分析工具** - 解析计费日志，精确定位花钱的地方
- 🧹 **一键清理脚本** - 自动清理 workspace，减少 70-85% 缓存创建成本
- 📚 **定价完全指南** - 详解代理商/官方定价、缓存机制、计费公式
- 🎯 **最佳实践清单** - 从 workspace 组织到会话管理的完整优化策略

### 📦 安装

#### 方法 1：下载安装包（推荐）

```bash
# 1. 下载最新 release
wget https://github.com/shanpenghui/openclaw-token-saver/releases/latest/download/token-saver.skill

# 2. 安装到 OpenClaw
openclaw skills install token-saver.skill
```

#### 方法 2：从源码构建

```bash
git clone https://github.com/shanpenghui/openclaw-token-saver
cd openclaw-token-saver
python3 ~/.npm-global/lib/node_modules/openclaw/skills/skill-creator/scripts/package_skill.py skills/token-saver
openclaw skills install token-saver.skill
```

### 🚀 快速开始

#### 1. 分析当前成本

```bash
~/.openclaw/workspace/skills/token-saver/scripts/analyze_costs.py ~/.openclaw/logs/usage.jsonl
```

你会看到类似这样的输出：

```
=== Token 使用 & 成本分析 ===
总请求数: 150

Token 使用:
  提示 tokens:        45,230
  补全 tokens:        89,120
  缓存读取:           1,205,340
  缓存创建:           1,692,850

成本分解:
  提示:               ¥0.1628  (2.1%)
  补全:               ¥1.6042  (20.3%)
  缓存读取:           ¥0.4339  (5.5%)
  缓存创建:           ¥5.6982  (72.1%)  ← 主要开销！
  ──────────────────────────────
  总计:               ¥7.8991

🔴 高缓存创建 (112,819 tokens/请求)
   潜在节省: ¥0.33 每次 /reset
   → 运行: optimize_workspace.sh --apply
```

#### 2. 一键优化

```bash
# 预览会做什么（安全）
~/.openclaw/workspace/skills/token-saver/scripts/optimize_workspace.sh --dry-run

# 执行优化
~/.openclaw/workspace/skills/token-saver/scripts/optimize_workspace.sh --apply
```

优化结果示例：

```
✓ 归档旧记忆文件 (50K tokens)
✓ 删除引导文件 (8K tokens)
✓ 移动大文档到 references/ (30K tokens)

总节省: 88K tokens → ¥0.33/reset
新缓存大小: 25K tokens → ¥0.09/reset (便宜 78%)
```

#### 3. 验证效果

```bash
~/.openclaw/workspace/skills/token-saver/scripts/analyze_costs.py ~/.openclaw/logs/usage.jsonl --since 24h
```

### 📖 在 OpenClaw 中使用

技能会在你提到成本时自动激活：

```
你: 为什么这条消息收了 ¥1.02？

Agent: [加载 token-saver 技能]
这是缓存创建成本。你的 workspace 在会话启动时加载了 112,819 tokens:
- SOUL.md, USER.md, TOOLS.md
- memory/2026-03-11.md (14KB)
- 所有技能元数据

缓存创建: 112,819 tokens × ¥3.75/1M = ¥0.42 (占 99%)

运行 `optimize_workspace.sh --apply` 可减少 70-85%。
```

### 🎯 核心优化策略

#### 1. 清理 Workspace（最高效）

**问题**：OpenClaw 会话启动时加载所有 workspace 文件  
**方案**：归档旧日志、删除引导文件、移动大文档到 `references/`  
**效果**：缓存创建成本降低 70-85%

#### 2. 用 `/new` 替代 `/reset`

**问题**：`/reset` 重建整个缓存（贵）  
**方案**：用 `/new` 复用缓存（便宜 12.5 倍）  
**效果**：每次会话省 ¥0.10

#### 3. 批量操作

**问题**：多次小请求 = 多次补全费用  
**方案**：把多个编辑合并成一条消息  
**效果**：减少 80% API 调用

#### 4. 精简日志

**问题**：啰嗦的日志让 workspace 缓存膨胀  
**方案**：日志保持 <2KB，详细笔记归档到外部  
**效果**：每次 /reset 省 ¥0.016

### 📊 成本拆解原理

#### 为什么第一条消息更贵？

```
第一条消息 (¥1.02):
  缓存创建: 112,819 tokens × ¥3.75/1M = ¥0.42 (99%)
  补全: 89 tokens × ¥15/1M = ¥0.001 (1%)

第二条消息 (¥0.12):
  缓存读取: 47,105 tokens × ¥0.30/1M = ¥0.014 (12%)
  补全: 2,315 tokens × ¥15/1M = ¥0.083 (70%)
```

**关键洞察**：缓存创建比缓存读取贵 12.5 倍。优化 workspace → 更便宜的缓存创建 → 更低成本。

### 📁 包含内容

```
skills/token-saver/
├── SKILL.md                           # 主技能文档
├── scripts/
│   ├── optimize_workspace.sh          # 自动化清理脚本
│   ├── analyze_costs.py               # 成本分析工具
│   └── test_skill.sh                  # 测试套件
├── references/
│   ├── pricing_guide.md               # 定价完全指南
│   └── best_practices.md              # 最佳实践清单
├── RELEASE_GUIDE.md                   # 发布流程文档
└── CONTRIBUTING.md                    # 贡献指南
```

### 🛠️ 系统要求

- OpenClaw v1.0+
- Python 3.8+ (用于 analyze_costs.py)
- Bash (用于 optimize_workspace.sh)

### 🤝 贡献

欢迎 PR！发现新的省钱技巧？请查看 [CONTRIBUTING.md](CONTRIBUTING.md)。

**特别需要**：
- 真实使用数据（优化前后对比）
- 不同代理商的定价数据
- 跨平台测试（Windows/macOS）

### 💬 分享你的省钱成果

在 [Discussions](../../discussions) 分享你的数据：

**模板**：
- **场景**: 高频编程 / 日常聊天 / 生产机器人
- **优化前**: ¥XXX/月
- **优化后**: ¥XXX/月
- **节省**: XX%

### 📄 许可证

MIT License - 自由使用，分享改进

### 🙏 致谢

基于 Jetson Orin Nano 机器人开发的真实高频使用场景创建。

灵感来自帮助开发者优化：
- 高频编程会话
- 生产聊天机器人
- 自动化 CI/CD 工作流
- 成本敏感部署

### 📞 支持

- Issues: [GitHub Issues](../../issues)
- 讨论: [GitHub Discussions](../../discussions)
- OpenClaw 文档: https://docs.openclaw.ai
- 社区: https://discord.com/invite/clawd

---

## English

### 🚀 One-Line Pitch

**Reduce your OpenClaw API costs by 60-90%** through automated workspace optimization and best practices.

### 💰 Real Cost Savings

Based on real-world high-frequency robotics development on Jetson Orin Nano (50+ msgs/day):

| User Type | Messages/Day | Monthly Cost Before | After | Savings |
|-----------|--------------|---------------------|-------|---------|
| Light user (casual chat) | 10 | ¥22 | ¥7 | **68%** ↓ |
| Medium user (daily coding) | 30 | ¥93 | ¥29 | **69%** ↓ |
| Heavy user (high-frequency dev) | 50 | ¥143 | ¥33 | **77%** ↓ |

**Example**: A developer reduced costs from ¥143/month → ¥33/month with a 30-minute optimization, saving **¥110/month**.

### ✨ Features

- 📊 **Cost Analysis Tool** - Parse billing logs to identify where money goes
- 🧹 **One-Click Cleanup** - Automated workspace optimization (70-85% cache reduction)
- 📚 **Complete Pricing Guide** - Proxy vs official pricing, cache mechanics, billing formulas
- 🎯 **Best Practices Checklist** - Workspace organization to session management

### 📦 Installation

#### Method 1: Download Release (Recommended)

```bash
# 1. Download latest release
wget https://github.com/shanpenghui/openclaw-token-saver/releases/latest/download/token-saver.skill

# 2. Install to OpenClaw
openclaw skills install token-saver.skill
```

#### Method 2: Build from Source

```bash
git clone https://github.com/shanpenghui/openclaw-token-saver
cd openclaw-token-saver
python3 ~/.npm-global/lib/node_modules/openclaw/skills/skill-creator/scripts/package_skill.py skills/token-saver
openclaw skills install token-saver.skill
```

### 🚀 Quick Start

#### 1. Analyze Current Costs

```bash
~/.openclaw/workspace/skills/token-saver/scripts/analyze_costs.py ~/.openclaw/logs/usage.jsonl
```

Sample output:

```
=== Token Usage & Cost Analysis ===
Total requests: 150

Token Usage:
  Prompt tokens:        45,230
  Completion tokens:    89,120
  Cache read:           1,205,340
  Cache creation:       1,692,850

Cost Breakdown:
  Prompt:               ¥0.1628  (2.1%)
  Completion:           ¥1.6042  (20.3%)
  Cache read:           ¥0.4339  (5.5%)
  Cache creation:       ¥5.6982  (72.1%)  ← Main cost driver!
  ──────────────────────────────
  Total:                ¥7.8991

🔴 HIGH CACHE CREATION (112,819 tokens/request)
   Potential savings: ¥0.33 per /reset
   → Run: optimize_workspace.sh --apply
```

#### 2. Run Optimization

```bash
# Preview changes (safe)
~/.openclaw/workspace/skills/token-saver/scripts/optimize_workspace.sh --dry-run

# Apply optimizations
~/.openclaw/workspace/skills/token-saver/scripts/optimize_workspace.sh --apply
```

Sample output:

```
✓ Archived old memory files (50K tokens)
✓ Removed bootstrap files (8K tokens)
✓ Moved large docs to references/ (30K tokens)

Total saved: 88K tokens → ¥0.33/reset
New cache size: 25K tokens → ¥0.09/reset (78% cheaper)
```

#### 3. Verify Savings

```bash
~/.openclaw/workspace/skills/token-saver/scripts/analyze_costs.py ~/.openclaw/logs/usage.jsonl --since 24h
```

### 📖 Usage in OpenClaw

The skill activates automatically when you mention costs:

```
You: Why did this message cost ¥1.02?

Agent: [Loads token-saver skill]
That's cache creation cost. Your workspace loaded 112,819 tokens:
- SOUL.md, USER.md, TOOLS.md
- memory/2026-03-11.md (14KB)
- All skill metadata

Cache creation: 112,819 tokens × ¥3.75/1M = ¥0.42 (99% of cost)

Run `optimize_workspace.sh --apply` to reduce by 70-85%.
```

### 🎯 Key Optimization Strategies

#### 1. Clean Your Workspace (Highest Impact)

**Problem**: OpenClaw loads all workspace files at session start  
**Solution**: Archive old logs, remove bootstrap files, move large docs to `references/`  
**Impact**: 70-85% reduction in cache creation costs

#### 2. Use `/new` Instead of `/reset`

**Problem**: `/reset` rebuilds entire cache (expensive)  
**Solution**: Use `/new` to reuse cache (12.5× cheaper)  
**Impact**: Save ¥0.10 per session

#### 3. Batch Operations

**Problem**: Multiple small requests = multiple completion charges  
**Solution**: Bundle edits into one message  
**Impact**: 80% fewer API calls

#### 4. Trim Daily Logs

**Problem**: Verbose logs bloat workspace cache  
**Solution**: Keep logs <2KB, archive detailed notes externally  
**Impact**: Save ¥0.016 per /reset

### 📊 Cost Breakdown Explained

#### Why First Message Costs More

```
First message (¥1.02):
  Cache creation: 112,819 tokens × ¥3.75/1M = ¥0.42 (99%)
  Completion: 89 tokens × ¥15/1M = ¥0.001 (1%)

Second message (¥0.12):
  Cache read: 47,105 tokens × ¥0.30/1M = ¥0.014 (12%)
  Completion: 2,315 tokens × ¥15/1M = ¥0.083 (70%)
```

**Key insight**: Cache creation is 12.5× more expensive than reads. Optimize workspace → cheaper cache creation → lower costs.

### 🤝 Contributing

PRs welcome! Found new cost-saving tricks? See [CONTRIBUTING.md](CONTRIBUTING.md).

**Especially needed**:
- Real usage data (before/after comparisons)
- Pricing data from different providers
- Cross-platform testing (Windows/macOS)

### 💬 Share Your Savings

Share your results in [Discussions](../../discussions):

**Template**:
- **Scenario**: High-frequency coding / casual chat / production bot
- **Before**: ¥XXX/month
- **After**: ¥XXX/month
- **Savings**: XX%

### 📄 License

MIT License - Use freely, share improvements

### 📞 Support

- Issues: [GitHub Issues](../../issues)
- Discussions: [GitHub Discussions](../../discussions)
- OpenClaw Docs: https://docs.openclaw.ai
- Community: https://discord.com/invite/clawd

---

**⭐ Star this repo if it saved you money!**

**Share your savings**: Tweet your before/after stats with `#OpenClawSaver`
