# Pricing Guide

Complete breakdown of OpenClaw API pricing through Chinese proxy services.

## Proxy vs Official Pricing

### Typical Proxy Structure (2026)

Most Chinese users access Claude via proxy services with this pricing:

**Recharge bonus**: ¥1 CNY → ¥2 platform credits (100% bonus)

**Multipliers**:
- Model multiplier: 1.5× (Claude Sonnet 3.5)
- Output multiplier: 5× (completion vs prompt, industry standard)
- Cache read multiplier: 0.1× (cache hit discount)
- Cache write multiplier: 1.25× (5-minute cache creation)
- Group multiplier: 2.4× (varies by provider/plan)

**Effective rates** (platform credits):
- Prompt: ¥3/1M × 1.0 = ¥3/1M
- Completion: ¥3/1M × 5.0 = ¥15/1M
- Cache read: ¥3/1M × 0.1 = ¥0.30/1M
- Cache write (5min): ¥3/1M × 1.25 = ¥3.75/1M

**After group multiplier (2.4×)**:
- Prompt: ¥7.2/1M platform credits
- Completion: ¥36/1M platform credits
- Cache read: ¥0.72/1M platform credits
- Cache write: ¥9/1M platform credits

**Real CNY cost** (after 2× recharge bonus):
- Prompt: ¥3.6/1M (real money)
- Completion: ¥18/1M (real money)
- Cache read: ¥0.36/1M (real money)
- Cache write: ¥4.5/1M (real money)

### Official Anthropic Pricing

Direct API access (USD, as of 2026):
- Prompt: $3/1M tokens
- Completion: $15/1M tokens
- Cache read: $0.30/1M tokens
- Cache write: $3.75/1M tokens

**Converted to CNY** (at 7.2 exchange rate):
- Prompt: ¥21.6/1M
- Completion: ¥108/1M
- Cache read: ¥2.16/1M
- Cache write: ¥27/1M

### Comparison

| Component | Proxy (CNY) | Official (CNY) | Savings |
|-----------|-------------|----------------|---------|
| Prompt | ¥3.6/1M | ¥21.6/1M | **83%** |
| Completion | ¥18/1M | ¥108/1M | **83%** |
| Cache read | ¥0.36/1M | ¥2.16/1M | **83%** |
| Cache write | ¥4.5/1M | ¥27/1M | **83%** |

**Proxies are 6× cheaper** than official API (before group multipliers).

After 2.4× group multiplier, proxies are still ~2.5× cheaper than official.

## Understanding Your Bill

### Example Billing Log

```
First message (¥1.02):
  提示: 5 tokens
  5m缓存创建: 112,819 tokens
  补全: 89 tokens
  
Calculation:
  提示: 5/1M × ¥3 = ¥0.000015
  缓存创建: 112,819/1M × ¥3.75 = ¥0.423071
  补全: 89/1M × ¥15 × 2.4 = ¥0.003204
  Total: ¥0.42629 × 2.4 (group) = ¥1.02311
```

### Why Cache Creation Costs More

Cache creation is charged at **1.25× base rate** instead of prompt rate (1.0×):
- Cache creation stores context for 5 minutes
- Server must process and index the content
- Additional infrastructure overhead

**Cost per 100K tokens**:
- Prompt: ¥0.36
- Cache write: ¥0.45 (25% premium)
- Cache read: ¥0.036 (90% discount)

**Key insight**: Cache hits are 12.5× cheaper than cache creation.

## Cost Scenarios

### Scenario 1: Heavy Workspace (112K cache)

**First message** (cache creation):
```
Cache creation: 112,000 tokens × ¥4.5/1M = ¥0.504
Completion: 500 tokens × ¥18/1M = ¥0.009
Total: ¥0.513
```

**Subsequent messages** (cache hits):
```
Cache read: 112,000 tokens × ¥0.36/1M = ¥0.040
Completion: 500 tokens × ¥18/1M = ¥0.009
Total: ¥0.049
```

**Daily cost** (1 reset + 20 messages):
```
1 × ¥0.513 + 20 × ¥0.049 = ¥1.49/day
Monthly: ¥44.70
```

### Scenario 2: Optimized Workspace (25K cache)

**First message** (cache creation):
```
Cache creation: 25,000 tokens × ¥4.5/1M = ¥0.1125
Completion: 500 tokens × ¥18/1M = ¥0.009
Total: ¥0.1215
```

**Subsequent messages** (cache hits):
```
Cache read: 25,000 tokens × ¥0.36/1M = ¥0.009
Completion: 500 tokens × ¥18/1M = ¥0.009
Total: ¥0.018
```

**Daily cost** (1 reset + 20 messages):
```
1 × ¥0.1215 + 20 × ¥0.018 = ¥0.48/day
Monthly: ¥14.40
```

**Savings**: ¥30.30/month (68% reduction)

### Scenario 3: High-Frequency Coding (50 messages/day)

**Unoptimized** (112K cache, 5 resets/day):
```
5 × ¥0.513 + 45 × ¥0.049 = ¥4.77/day
Monthly: ¥143.10
```

**Optimized** (25K cache, 2 resets/day, use /new):
```
2 × ¥0.1215 + 48 × ¥0.018 = ¥1.11/day
Monthly: ¥33.30
```

**Savings**: ¥109.80/month (77% reduction)

## Provider Variations

Different proxy providers have different multipliers:

| Provider Type | Group Multiplier | Effective Prompt (CNY) | Effective Completion (CNY) |
|---------------|------------------|------------------------|---------------------------|
| Budget tier | 2.0× | ¥3.0/1M | ¥15.0/1M |
| Standard tier | 2.4× | ¥3.6/1M | ¥18.0/1M |
| Premium tier | 3.0× | ¥4.5/1M | ¥22.5/1M |

**Why group multipliers vary**:
- API key pooling overhead
- Payment processing fees
- Risk margins (account bans)
- Profit margins

## Optimization ROI

### Investment vs Returns

**One-time optimization**:
- Time: 30 minutes
- Cost: ¥0 (automated scripts)

**Monthly savings** (typical high-frequency user):
- Before: ¥143/month
- After: ¥33/month
- **Savings: ¥110/month** (77%)

**Annual ROI**: ¥1,320 saved for 30 minutes of work = **¥2,640/hour effective rate**

### Break-Even Analysis

Cache optimization pays for itself after:
- Light users (5 msgs/day): ~1 week
- Medium users (20 msgs/day): ~2 days
- Heavy users (50 msgs/day): **1 day**

## Cost Comparison by Use Case

### Use Case 1: Casual Chat
- Messages/day: 10
- Avg completion: 300 tokens
- Resets/day: 1

**Monthly cost**:
- Unoptimized (112K): ¥22.35
- Optimized (25K): ¥7.20
- **Savings: ¥15.15 (68%)**

### Use Case 2: Daily Coding
- Messages/day: 30
- Avg completion: 800 tokens
- Resets/day: 3

**Monthly cost**:
- Unoptimized (112K): ¥92.70
- Optimized (25K): ¥28.80
- **Savings: ¥63.90 (69%)**

### Use Case 3: Production Bot
- Messages/day: 200
- Avg completion: 500 tokens
- Resets/day: 10

**Monthly cost**:
- Unoptimized (112K): ¥573.00
- Optimized (25K): ¥168.00
- **Savings: ¥405.00 (71%)**

## Hidden Costs to Avoid

### 1. Repeated /reset Commands
Each `/reset` rebuilds the entire cache.

**Wasteful pattern**:
```
User: /reset  (¥0.50 cache creation)
User: Create file A
User: /reset  (¥0.50 again!)
User: Edit file A
```

**Better**:
```
User: /new    (reuses cache: ¥0.05)
User: Create file A
User: Edit file A
```

**Savings**: ¥0.45 per session

### 2. Loading Large Files Repeatedly
Reading a 50KB file costs ~12,500 tokens.

**Wasteful**:
```
User: Read config.yaml  (12,500 tokens)
User: What's the port?
User: Read config.yaml again  (12,500 more!)
User: What's the host?
```

**Better**:
```
User: Read config.yaml and tell me the port and host
```

**Savings**: 12,500 tokens = ¥0.045

### 3. Verbose Logging
Large daily logs bloat workspace cache.

**14KB log** = ~3,500 tokens = ¥0.016 per /reset
**Annual cost**: ¥5.84 just from one bloated log

**Solution**: Trim logs to <2KB summaries

## Advanced Pricing Strategies

### 1. Multi-Workspace Profiles

Create separate workspaces for different use cases:

```bash
# Minimal coding workspace
~/.openclaw/workspace-coding/
  Cache: 15K tokens
  Cost per reset: ¥0.07

# Full-featured personal workspace
~/.openclaw/workspace-personal/
  Cache: 80K tokens
  Cost per reset: ¥0.36
```

**Use coding workspace for 80% of work** → Save ¥0.29 per reset

### 2. Batch Operations

Bundle multiple requests:

**Inefficient** (5 API calls):
```
Create file1
Create file2
Create file3
Create file4
Create file5
```
Cost: 5 × ¥0.05 = ¥0.25

**Efficient** (1 API call):
```
Create file1, file2, file3, file4, file5
```
Cost: 1 × ¥0.05 = ¥0.05

**Savings**: ¥0.20 (80%)

### 3. Isolated Sessions for Heavy Tasks

Use `sessions_spawn` for large operations:

```bash
# Main session: 25K cache (¥0.12/reset)
# Isolated session: independent context

sessions_spawn task="Refactor entire codebase" mode=run
```

**Benefit**: Main session cache stays lean, expensive work happens in throwaway context

## FAQ

**Q: Why is completion 5× more expensive than prompt?**  
A: Generation requires full model inference (GPU compute), while prompts are mostly memory reads. This ratio is industry-standard across all LLM APIs.

**Q: Can I negotiate better rates with proxy providers?**  
A: Some providers offer volume discounts (e.g., 10% off for >¥1000/month usage). Ask in their support channels.

**Q: Is official API cheaper for high-volume?**  
A: Only if you qualify for Anthropic enterprise pricing (typically $50K+/year commitments). For individuals, proxies remain cheaper.

**Q: Do group multipliers change?**  
A: Yes, providers adjust based on their costs. Check their pricing page quarterly.

**Q: Are there free tiers?**  
A: Most proxies offer ¥5-10 free credits for new users (enough for ~200 messages). Official Anthropic API has no free tier.

## References

- Anthropic official pricing: https://www.anthropic.com/api
- OpenClaw docs: https://docs.openclaw.ai
- Token estimation: ~4 chars = 1 token (English), ~2 chars = 1 token (Chinese)
