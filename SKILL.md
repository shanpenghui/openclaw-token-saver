---
name: token-saver
description: "Reduce OpenClaw API costs through workspace optimization, caching strategies, and workflow improvements. Use when: (1) user asks about high API costs or token usage, (2) setting up OpenClaw for cost-sensitive scenarios (high-frequency coding, CI/CD, production bots), (3) analyzing billing logs or unexpected charges, (4) optimizing workspace for minimal context loading. Triggers on phrases like 'save money', 'reduce costs', 'optimize tokens', 'why so expensive', 'billing analysis'."
---

# Token Saver

Reduce OpenClaw API costs by 60-90% through workspace optimization and smart usage patterns.

## Quick Start

### 1. Analyze Current Costs

```bash
scripts/analyze_costs.py ~/.openclaw/logs/usage.jsonl
```

Shows breakdown of cache creation, prompt, and completion costs.

### 2. Run Automated Optimization

```bash
scripts/optimize_workspace.sh --dry-run  # Preview changes
scripts/optimize_workspace.sh --apply    # Apply optimizations
```

Expected savings: 70-85% reduction in cache creation tokens.

## Cost Breakdown

### Understanding the Bill

Claude API pricing has 4 components (typical proxy multipliers shown):

| Component | Base Price | Multiplier | Your Cost |
|-----------|------------|------------|-----------|
| Prompt tokens | $3/1M | 1.0× | $3/1M |
| Completion tokens | $15/1M | 5.0× | $15/1M |
| Cache read | $0.30/1M | 0.1× | $0.30/1M |
| Cache write (5min) | $3.75/1M | 1.25× | $3.75/1M |

**Cache creation is 12.5× more expensive than cache reads.**

### Why First Message Costs More

Example billing log breakdown:

```
First message (¥1.02):
  Cache creation: 112,819 tokens × ¥3.75/1M = ¥0.42 (99% of cost)
  Completion: 89 tokens × ¥15/1M × 2.4 = ¥0.003

Second message (¥0.12):
  Cache read: 47,105 tokens × ¥0.30/1M = ¥0.014 (12%)
  Completion: 2,315 tokens × ¥15/1M × 2.4 = ¥0.083 (70%)
```

**Key insight**: First message loads entire workspace into cache. Subsequent messages reuse cache at 1/12 the cost.

## Optimization Strategies

### 1. Workspace Cleanup (Highest Impact)

**Problem**: OpenClaw loads ALL workspace files at session start:
- `AGENTS.md`, `SOUL.md`, `USER.md`, `TOOLS.md`, `IDENTITY.md`
- `HEARTBEAT.md`, `BOOTSTRAP.md`
- Today's `memory/YYYY-MM-DD.md`
- Yesterday's memory file

**Solution**: The `optimize_workspace.sh` script:
- Archives completed daily logs to `~/archive/memory/`
- Removes bootstrap files after initial setup
- Moves large documentation to `references/` subdirectories
- Trims verbose logs to essential summaries

**Manual cleanup**:
```bash
# Delete one-time setup files
rm ~/.openclaw/workspace/BOOTSTRAP.md

# Archive old memory files
mkdir -p ~/archive/memory
mv ~/.openclaw/workspace/memory/2026-*.md ~/archive/memory/

# Move large skill docs to references/
mv skills/*/docs/*.md skills/*/references/ 2>/dev/null
```

**Expected savings**: 60-80% reduction in cache creation (112K → 25K tokens).

### 2. Progressive Context Loading

**Default behavior** (expensive):
```
Session start → Load all workspace files → 112K cache creation
```

**Optimized workflow**:
```
Session start → Load only core files (20K) → Read specific docs as needed
```

**Implementation**:
- Keep `SOUL.md` and `USER.md` minimal (<500 words each)
- Store project details in `references/` subdirectories
- Use `/new` instead of `/reset` for clean sessions (reuses cache)

### 3. Memory Management

**Anti-pattern**: Verbose daily logs
```markdown
# memory/2026-03-11.md (14KB)
## Nav2无图导航一键启动脚本开发
[100+ lines of detailed implementation notes, full config dumps, etc.]
```

**Best practice**: Summary with archive links
```markdown
# memory/2026-03-11.md (1KB)
## Nav2无图导航完成
- ✅ 一键启动脚本（tmux 7窗口）
- ✅ 安全停止脚本
- 详见: ~/archive/memory/2026-03-11-full.md
```

**Rule**: Daily logs <2KB. Archive detailed notes externally.

### 4. Batch Operations

**Inefficient** (5 API calls):
```
User: Create file A
Agent: [creates A]
User: Write content X to A
Agent: [writes X]
User: Create file B
...
```

**Efficient** (1 API call):
```
User: Create A with content X, create B with content Y, configure Z
Agent: [completes all in one turn]
```

**Savings**: 80% fewer API calls, 80% fewer completion tokens.

### 5. Isolated Sessions for Heavy Tasks

Use `sessions_spawn` for:
- Large refactoring projects
- Multi-file code reviews
- Batch data processing

**Why**: Isolated sessions have separate token budgets and don't pollute main workspace cache.

```bash
# Instead of loading 50 files into main session:
sessions_spawn task="Review all FastLIO configs and suggest optimizations" mode=run
```

**Savings**: Main session cache stays lean, expensive work happens in throwaway context.

## Cost Analysis Tool

### Usage

```bash
# Analyze last 24 hours
scripts/analyze_costs.py ~/.openclaw/logs/usage.jsonl --since 24h

# Compare before/after optimization
scripts/analyze_costs.py ~/.openclaw/logs/usage.jsonl --date 2026-03-10 > before.txt
scripts/optimize_workspace.sh --apply
scripts/analyze_costs.py ~/.openclaw/logs/usage.jsonl --date 2026-03-11 > after.txt
diff before.txt after.txt
```

### Output Example

```
=== Token Usage Analysis ===
Period: 2026-03-11 00:00 - 23:59
Total sessions: 15

Cache creation: 112,819 tokens (avg) → ¥0.42/session
Cache reads:     47,105 tokens (avg) → ¥0.014/session
Completions:      2,315 tokens (avg) → ¥0.083/session

Total cost: ¥7.85/day
Projected monthly: ¥235.50

Optimization potential:
- Reduce cache creation to 25K: Save ¥5.50/day (70%)
- Archive old memories: Save ¥1.20/day (15%)
```

## Best Practices Checklist

See [best_practices.md](references/best_practices.md) for complete checklist.

**Quick wins**:
- [ ] Delete `BOOTSTRAP.md` after initial setup
- [ ] Archive memory files older than 2 days
- [ ] Move skill documentation >5KB to `references/`
- [ ] Keep `SOUL.md` under 500 words
- [ ] Use `/new` instead of `/reset` for coding sessions
- [ ] Batch multiple edits into one request
- [ ] Use `sessions_spawn` for isolated heavy tasks

## Understanding Proxy Pricing

Most OpenClaw users access Claude via Chinese proxy services, not official Anthropic API.

**Typical pricing structure**:
- Recharge: ¥1 CNY = ¥2 platform credits (50% bonus)
- Model multiplier: 1.5× (Sonnet 3.5)
- Output multiplier: 5× (completion vs prompt)
- Cache multipliers: 0.1× (read), 1.25× (write)
- Group multiplier: 2.4× (varies by provider)

**Effective cost** (after all multipliers):
- Prompt: ¥7.2/1M = ¥3.6 real CNY/1M
- Completion: ¥36/1M = ¥18 real CNY/1M

**Comparison to official pricing**:
- Official prompt: $3/1M ≈ ¥21.6/1M (at 7.2 exchange rate)
- Official completion: $15/1M ≈ ¥108/1M

**Proxies are 6× cheaper** than official API, but group multipliers (2.4×) bring it close to parity.

See [pricing_guide.md](references/pricing_guide.md) for detailed breakdown.

## Troubleshooting

### "Why did this session cost ¥2?"

Check if you used `/reset` instead of `/new`:
- `/reset` forces full cache rebuild
- `/new` reuses existing cache

### "Usage went up after adding a skill"

Skills with large `references/` files bloat cache if loaded unnecessarily.

**Fix**: Audit skill descriptions to ensure they only trigger when truly needed.

### "Costs spiked on a specific day"

Run analysis:
```bash
scripts/analyze_costs.py ~/.openclaw/logs/usage.jsonl --date 2026-03-11 --verbose
```

Look for:
- Multiple `/reset` commands
- Large file operations (reading multi-MB logs)
- Repeated context loading from failed operations

## Advanced: Custom Workspace Profiles

For users with multiple use cases (coding vs casual chat vs automation):

```bash
# Minimal coding profile (15KB cache)
~/.openclaw/workspace-coding/
├── SOUL.md          # Terse, code-focused
├── USER.md          # Empty
└── TOOLS.md         # IDE shortcuts only

# Full-featured profile (80KB cache)
~/.openclaw/workspace-personal/
├── SOUL.md          # Rich personality
├── USER.md          # Detailed preferences
├── MEMORY.md        # Long-term context
└── memory/          # Daily logs
```

**Usage**:
```bash
# Switch workspace via config
openclaw config set workspace ~/.openclaw/workspace-coding
```

**Savings**: Coding sessions use 80% less cache, personal sessions get full context.

## Resources

- [pricing_guide.md](references/pricing_guide.md) - Detailed pricing breakdown
- [best_practices.md](references/best_practices.md) - Complete optimization checklist
- [optimize_workspace.sh](scripts/optimize_workspace.sh) - Automated cleanup script
- [analyze_costs.py](scripts/analyze_costs.py) - Usage analysis tool

## Contributing

Found more optimization tricks? Submit a PR to add them to this skill.

Common contributions:
- Provider-specific pricing multipliers
- New optimization scripts
- Case studies with before/after metrics
