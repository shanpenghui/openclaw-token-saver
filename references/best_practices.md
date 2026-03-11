# Token Optimization Best Practices

Comprehensive checklist for reducing OpenClaw API costs.

## Quick Wins (Do These First)

### 1. Remove Bootstrap Files
After initial setup, delete one-time files:

```bash
cd ~/.openclaw/workspace
rm BOOTSTRAP.md INSTALLATION.md SETUP.md
```

**Savings**: 5-10K tokens (~¥0.02/reset)

### 2. Archive Old Memory Files
Move historical logs out of workspace:

```bash
mkdir -p ~/archive/memory
mv memory/2026-03-*.md ~/archive/memory/
```

**Savings**: 20-50K tokens (~¥0.09/reset) depending on log volume

### 3. Trim Today's Log
Keep daily logs under 2KB:

**Before** (14KB):
```markdown
# 2026-03-11 - Nav2开发日志
[3000 lines of detailed implementation notes]
```

**After** (1KB):
```markdown
# 2026-03-11
## Nav2一键启动完成
- ✅ tmux脚本
- ✅ 文档完善
详见: ~/archive/memory/2026-03-11-full.md
```

**Savings**: 3K tokens (~¥0.01/reset)

## Workspace Organization

### File Structure Best Practices

```
~/.openclaw/workspace/
├── SOUL.md              # <500 words (keep minimal)
├── USER.md              # <300 words (essentials only)
├── TOOLS.md             # <400 words (reference notes)
├── MEMORY.md            # <2000 words (main session only)
├── memory/
│   └── 2026-03-11.md    # <2KB (today + yesterday only)
└── skills/
    └── skill-name/
        ├── SKILL.md     # <5KB (core instructions)
        ├── scripts/     # Executable code
        ├── references/  # Loaded as needed
        └── assets/      # Templates, not loaded
```

**Total workspace**: Aim for <30KB → ~25K tokens → ¥0.11/reset

### What to Keep in Workspace

**Core files** (always loaded):
- `SOUL.md` - Personality (500 words max)
- `USER.md` - User preferences (300 words max)
- `TOOLS.md` - Quick reference (400 words max)

**Conditional files** (only in main session):
- `MEMORY.md` - Long-term memory (main session only)
- `memory/YYYY-MM-DD.md` - Today's log (2KB max)

**References** (loaded on demand):
- `skills/*/references/*.md` - Read when skill triggers
- `~/archive/` - Historical data (never auto-loaded)

### What to Move Out

**Large documentation** → `references/` subdirectories:
```bash
# Before
skills/robot-tour-guide/docs/NAV2_GUIDE.md  (14KB)

# After
skills/robot-tour-guide/references/NAV2_GUIDE.md  (not auto-loaded)
```

**Completed projects** → Archive:
```bash
mv memory/2026-02-*.md ~/archive/memory/
```

**Configuration examples** → External repos:
```bash
# Don't store in workspace
mv config-examples/ ~/repos/dotfiles/
```

## Session Management

### Use /new Instead of /reset

**Expensive** (rebuilds cache):
```
User: /reset  ← Cache creation: 25K tokens = ¥0.11
User: Help me code
```

**Cheap** (reuses cache):
```
User: /new    ← Cache read: 25K tokens = ¥0.009
User: Help me code
```

**Savings**: ¥0.10 per session × 30 sessions/day = **¥3/day**

### When to Use Each

| Command | Use When | Cost |
|---------|----------|------|
| `/new` | Clean slate, same context | ¥0.009 |
| `/reset` | Changed workspace files | ¥0.11 |
| Continue session | Ongoing conversation | ¥0.009 |

**Best practice**: Use `/new` for 90% of sessions, `/reset` only after workspace changes.

### Session Strategies by Use Case

**Coding sprints** (high message volume):
```
/new → 50 messages → /new → 50 messages
```
Avoid `/reset` unless workspace changed.

**Daily check-ins** (low volume):
```
/reset once/day → all messages in one session
```
Cache creation overhead amortized over many messages.

**Production bots** (automated):
```
Long-running session, never reset
```
Cache created once, reused for thousands of messages.

## Message Optimization

### Batch Operations

**❌ Inefficient** (5 API calls, 5× completion costs):
```
User: Create file A
Agent: [creates A]
User: Create file B
Agent: [creates B]
User: Create file C
...
```

**✅ Efficient** (1 API call):
```
User: Create files A, B, C, D, E with the following contents...
Agent: [creates all in one turn]
```

**Savings**: 80% fewer API calls, 80% fewer completion tokens.

### Reduce Verbosity

**❌ Verbose prompt**:
```
Hi! I was wondering if you could please help me create a new file called config.yaml.
I would really appreciate it if you could add the following configuration to it...
```
Tokens: ~50

**✅ Concise prompt**:
```
Create config.yaml with this content...
```
Tokens: ~10

**Savings**: 40 tokens/message × 30 messages/day = 1,200 tokens/day = ¥0.022/day

### Avoid Repetition

**❌ Re-reading files**:
```
User: Read config.yaml (12K tokens loaded)
User: What's the port?
Agent: [answers]
User: Read config.yaml again (12K more!)
User: What's the host?
```

**✅ Ask once**:
```
User: Read config.yaml and tell me the port, host, and database name
```

**Savings**: 12K tokens = ¥0.045

## Memory File Best Practices

### Daily Log Structure

**Minimal template** (<2KB):
```markdown
# YYYY-MM-DD

## Summary
[2-3 sentence overview]

## Key Tasks
- [ ] Task 1
- [x] Task 2 (completed)

## Decisions Made
- Choice A because reason B

## Notes
[Essential context only]

## Archive
Detailed notes: ~/archive/memory/YYYY-MM-DD-full.md
```

**What to exclude** from daily logs:
- Full code snippets (link to commits instead)
- Verbose configuration dumps (store in project repos)
- Detailed debugging logs (keep in tmux logs)
- Copied documentation (link to source)

### MEMORY.md Maintenance

**Keep it curated** (<2000 words):
- Review monthly
- Remove outdated context
- Consolidate related entries
- Focus on decisions, preferences, ongoing projects

**Structure example**:
```markdown
# MEMORY.md

## Current Projects
- Robot navigation system (ongoing, see memory/2026-03.md)

## Preferences
- Prefers bash over zsh
- Jetson Orin Nano platform

## Important Decisions
- 2026-03: Using Nav2 for autonomous navigation
- 2026-02: Switched from ROS 1 to ROS 2

## Context
[Essential long-term info only]
```

**Avoid**:
- Copy-pasting entire conversations
- Storing code (use git repos)
- Historical minutiae (archive it)

## Skill Optimization

### Skill Description Guidelines

Skill descriptions trigger when matched, so make them specific:

**❌ Too broad** (triggers unnecessarily):
```yaml
description: Help with documents
```

**✅ Specific**:
```yaml
description: Create, edit, and analyze .docx files with tracked changes. Use when working with Microsoft Word documents.
```

**Benefit**: Skill only loads when needed, not on every session.

### Skill File Organization

**Keep SKILL.md lean** (<5KB):
- Core workflow only
- Link to references/ for details
- Move examples to references/

**Use progressive disclosure**:
```markdown
# SKILL.md (2KB)
## Quick start
[Basic workflow]

## Advanced
See [ADVANCED.md](references/ADVANCED.md) for:
- Complex scenarios
- Edge cases
- Full API reference
```

**Benefit**: Basic usage doesn't load heavy docs.

### Audit Your Skills

```bash
# Find large SKILL.md files
find ~/.openclaw/workspace/skills -name "SKILL.md" -size +5k

# Move oversized content to references/
mv skills/skill-name/docs/*.md skills/skill-name/references/
```

## Advanced Strategies

### Multi-Workspace Profiles

Create specialized workspaces for different contexts:

```bash
# Minimal coding workspace
~/.openclaw/workspace-coding/
├── SOUL.md (100 words, terse)
├── USER.md (empty)
└── TOOLS.md (IDE shortcuts only)
Total: ~15K tokens → ¥0.07/reset

# Full personal workspace
~/.openclaw/workspace-personal/
├── SOUL.md (500 words, personality)
├── USER.md (300 words, preferences)
├── MEMORY.md (2000 words, context)
└── memory/ (recent logs)
Total: ~80K tokens → ¥0.36/reset
```

**Switch workspaces**:
```bash
openclaw config set workspace ~/.openclaw/workspace-coding
```

**Use cases**:
- `workspace-coding`: High-frequency development
- `workspace-personal`: Casual chat, memory-dependent tasks
- `workspace-automation`: Production bots (ultra-minimal)

**Savings**: 80% of work in coding workspace → Save ¥0.29/reset

### Isolated Sessions

Use `sessions_spawn` for heavy one-off tasks:

```bash
# Main session: 25K cache
sessions_spawn task="Review 50 files and suggest refactorings" mode=run

# Sub-agent creates independent context
# Main session cache stays lean
```

**When to use**:
- Multi-file code reviews
- Large refactoring projects
- Batch data processing
- One-time analysis tasks

**Benefit**: Expensive work doesn't bloat main workspace.

### Lazy Loading

Don't pre-load context you might not need.

**❌ Eager loading**:
```markdown
# SOUL.md
[Loads entire personality, preferences, history]
Total: 5000 words
```

**✅ Lazy loading**:
```markdown
# SOUL.md
Core personality: [500 words]
Detailed preferences: See USER.md
Project context: See memory/YYYY-MM-DD.md
```

**Benefit**: Only loads what's needed for the current task.

## Monitoring & Iteration

### Track Your Costs

```bash
# Weekly analysis
scripts/analyze_costs.py ~/.openclaw/logs/usage.jsonl --since 7d

# Before/after comparison
scripts/analyze_costs.py usage.jsonl --date 2026-03-10 > before.txt
scripts/optimize_workspace.sh --apply
scripts/analyze_costs.py usage.jsonl --date 2026-03-11 > after.txt
diff before.txt after.txt
```

### Set Cost Alerts

Add to your monitoring:
```bash
# Daily cost threshold
daily_limit=5.00  # ¥5/day

if (( $(analyze_costs.py --today) > $daily_limit )); then
    notify "High API costs today: ¥$(analyze_costs.py --today)"
fi
```

### Monthly Review

Once a month:
1. Run cost analysis for past 30 days
2. Identify highest-cost sessions
3. Check for optimization opportunities
4. Clean up workspace
5. Archive old memory files

**Template**:
```bash
# Last month's costs
scripts/analyze_costs.py usage.jsonl --since 30d

# Find large workspace files
du -sh ~/.openclaw/workspace/*

# Archive old memories
scripts/optimize_workspace.sh --apply
```

## ROI Calculation

### Time Investment

| Optimization | Time | Frequency | Savings/Month |
|-------------|------|-----------|---------------|
| Initial cleanup | 30 min | Once | ¥50-100 |
| Weekly archive | 5 min | Weekly | ¥10-20 |
| Skill audit | 20 min | Monthly | ¥5-15 |
| Profile setup | 15 min | Once | ¥20-40 |

**Total setup**: ~1 hour  
**Monthly savings**: ¥85-175  
**Annual savings**: ¥1,020-2,100

### Break-Even Analysis

**Light user** (10 messages/day):
- Before: ¥22/month
- After: ¥7/month
- Savings: ¥15/month
- **Break-even**: 4 days

**Heavy user** (50 messages/day):
- Before: ¥143/month
- After: ¥33/month
- Savings: ¥110/month
- **Break-even**: 1 day

## Checklist

### One-Time Setup
- [ ] Delete BOOTSTRAP.md
- [ ] Move large skill docs to references/
- [ ] Create ~/archive/ directory structure
- [ ] Set up cost monitoring
- [ ] Install optimize_workspace.sh

### Daily Habits
- [ ] Use /new instead of /reset
- [ ] Keep today's log under 2KB
- [ ] Batch multiple requests
- [ ] Archive completed logs

### Weekly Maintenance
- [ ] Run optimize_workspace.sh
- [ ] Review cost analysis
- [ ] Clean up completed projects
- [ ] Update MEMORY.md

### Monthly Review
- [ ] Audit skill descriptions
- [ ] Consolidate memory files
- [ ] Check workspace size (<30KB target)
- [ ] Review session patterns

## Common Pitfalls

### 1. Over-Optimization
Don't sacrifice usability for marginal savings:
- Keep SOUL.md rich enough to be useful
- Don't delete context you actually need
- Balance cost vs convenience

### 2. Under-Documentation
Don't remove context that prevents repeated questions:
- Keep essential project context in MEMORY.md
- Document important decisions
- Maintain skill references

### 3. Inconsistent Practices
Sporadic optimization wastes effort:
- Set up automation (scripts)
- Build habits (daily archiving)
- Monitor regularly (weekly reviews)

## Resources

- Cost analysis tool: `scripts/analyze_costs.py`
- Automated cleanup: `scripts/optimize_workspace.sh`
- Pricing details: `references/pricing_guide.md`
- OpenClaw docs: https://docs.openclaw.ai
