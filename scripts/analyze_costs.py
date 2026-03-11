#!/usr/bin/env python3
"""
analyze_costs.py - Analyze OpenClaw token usage and costs from billing logs

Parses usage logs to show:
- Token breakdown (prompt, completion, cache)
- Cost per session
- Daily/monthly projections
- Optimization recommendations
"""

import json
import sys
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional
from dataclasses import dataclass
from collections import defaultdict

@dataclass
class TokenUsage:
    """Token usage for a single API call"""
    timestamp: datetime
    prompt_tokens: int
    completion_tokens: int
    cache_read_tokens: int
    cache_create_tokens: int
    cost: float
    model: str

class CostAnalyzer:
    """Analyze token usage and costs"""
    
    # Pricing (¥ per 1M tokens, after 2× recharge bonus)
    PROMPT_PRICE = 3.6 / 1_000_000       # ¥7.2 platform credits = ¥3.6 real
    COMPLETION_PRICE = 18.0 / 1_000_000  # ¥36 platform credits = ¥18 real
    CACHE_READ_PRICE = 0.15 / 1_000_000  # ¥0.3 platform credits = ¥0.15 real
    CACHE_CREATE_PRICE = 1.875 / 1_000_000  # ¥3.75 platform credits = ¥1.875 real
    
    def __init__(self, log_path: Path):
        self.log_path = log_path
        self.usage_records: List[TokenUsage] = []
        
    def parse_log(self, since: Optional[datetime] = None) -> None:
        """Parse usage log file (JSONL format)"""
        if not self.log_path.exists():
            print(f"Error: Log file not found: {self.log_path}")
            sys.exit(1)
            
        with open(self.log_path) as f:
            for line in f:
                if not line.strip():
                    continue
                    
                try:
                    record = json.loads(line)
                    timestamp = datetime.fromisoformat(record.get('timestamp', ''))
                    
                    if since and timestamp < since:
                        continue
                    
                    usage = TokenUsage(
                        timestamp=timestamp,
                        prompt_tokens=record.get('prompt_tokens', 0),
                        completion_tokens=record.get('completion_tokens', 0),
                        cache_read_tokens=record.get('cache_read_tokens', 0),
                        cache_create_tokens=record.get('cache_create_tokens', 0),
                        cost=record.get('cost', 0),
                        model=record.get('model', 'unknown')
                    )
                    self.usage_records.append(usage)
                    
                except (json.JSONDecodeError, KeyError, ValueError) as e:
                    print(f"Warning: Failed to parse line: {e}", file=sys.stderr)
                    continue
    
    def calculate_costs(self, usage: TokenUsage) -> Dict[str, float]:
        """Calculate cost breakdown for a usage record"""
        return {
            'prompt': usage.prompt_tokens * self.PROMPT_PRICE,
            'completion': usage.completion_tokens * self.COMPLETION_PRICE,
            'cache_read': usage.cache_read_tokens * self.CACHE_READ_PRICE,
            'cache_create': usage.cache_create_tokens * self.CACHE_CREATE_PRICE,
        }
    
    def aggregate_stats(self) -> Dict:
        """Aggregate statistics across all records"""
        if not self.usage_records:
            return {}
        
        total_prompt = sum(u.prompt_tokens for u in self.usage_records)
        total_completion = sum(u.completion_tokens for u in self.usage_records)
        total_cache_read = sum(u.cache_read_tokens for u in self.usage_records)
        total_cache_create = sum(u.cache_create_tokens for u in self.usage_records)
        
        total_cost = (
            total_prompt * self.PROMPT_PRICE +
            total_completion * self.COMPLETION_PRICE +
            total_cache_read * self.CACHE_READ_PRICE +
            total_cache_create * self.CACHE_CREATE_PRICE
        )
        
        # Daily aggregation
        daily_costs = defaultdict(float)
        for usage in self.usage_records:
            date = usage.timestamp.date()
            costs = self.calculate_costs(usage)
            daily_costs[date] += sum(costs.values())
        
        return {
            'total_requests': len(self.usage_records),
            'total_prompt': total_prompt,
            'total_completion': total_completion,
            'total_cache_read': total_cache_read,
            'total_cache_create': total_cache_create,
            'total_cost': total_cost,
            'avg_cache_create': total_cache_create / len(self.usage_records) if self.usage_records else 0,
            'avg_cost_per_request': total_cost / len(self.usage_records) if self.usage_records else 0,
            'daily_costs': dict(daily_costs),
        }
    
    def generate_report(self, stats: Dict, verbose: bool = False) -> None:
        """Generate human-readable cost report"""
        if not stats:
            print("No usage data found")
            return
        
        print("\n" + "="*60)
        print(" Token Usage & Cost Analysis")
        print("="*60 + "\n")
        
        # Overview
        print(f"Total API calls: {stats['total_requests']}")
        
        if self.usage_records:
            start = min(u.timestamp for u in self.usage_records)
            end = max(u.timestamp for u in self.usage_records)
            print(f"Period: {start.date()} to {end.date()}")
        
        print()
        
        # Token breakdown
        print("Token Usage:")
        print(f"  Prompt tokens:        {stats['total_prompt']:>12,}")
        print(f"  Completion tokens:    {stats['total_completion']:>12,}")
        print(f"  Cache read:           {stats['total_cache_read']:>12,}")
        print(f"  Cache creation:       {stats['total_cache_create']:>12,}")
        print()
        
        # Cost breakdown
        prompt_cost = stats['total_prompt'] * self.PROMPT_PRICE
        completion_cost = stats['total_completion'] * self.COMPLETION_PRICE
        cache_read_cost = stats['total_cache_read'] * self.CACHE_READ_PRICE
        cache_create_cost = stats['total_cache_create'] * self.CACHE_CREATE_PRICE
        
        print("Cost Breakdown:")
        print(f"  Prompt:               ¥{prompt_cost:>10.4f}  ({prompt_cost/stats['total_cost']*100:>5.1f}%)")
        print(f"  Completion:           ¥{completion_cost:>10.4f}  ({completion_cost/stats['total_cost']*100:>5.1f}%)")
        print(f"  Cache read:           ¥{cache_read_cost:>10.4f}  ({cache_read_cost/stats['total_cost']*100:>5.1f}%)")
        print(f"  Cache creation:       ¥{cache_create_cost:>10.4f}  ({cache_create_cost/stats['total_cost']*100:>5.1f}%)")
        print(f"  {'─'*40}")
        print(f"  Total:                ¥{stats['total_cost']:>10.4f}")
        print()
        
        # Averages
        print("Per-Request Averages:")
        print(f"  Cache creation:       {stats['avg_cache_create']:>12,.0f} tokens")
        print(f"  Cost per request:     ¥{stats['avg_cost_per_request']:>10.4f}")
        print()
        
        # Projections
        if stats['daily_costs']:
            avg_daily = sum(stats['daily_costs'].values()) / len(stats['daily_costs'])
            print("Projections:")
            print(f"  Daily average:        ¥{avg_daily:>10.2f}")
            print(f"  Monthly (30 days):    ¥{avg_daily * 30:>10.2f}")
            print()
        
        # Optimization recommendations
        self.show_recommendations(stats)
        
        # Verbose mode: daily breakdown
        if verbose and stats['daily_costs']:
            print("\n" + "─"*60)
            print("Daily Breakdown:")
            print("─"*60 + "\n")
            for date in sorted(stats['daily_costs'].keys()):
                cost = stats['daily_costs'][date]
                print(f"  {date}:  ¥{cost:>8.4f}")
            print()
    
    def show_recommendations(self, stats: Dict) -> None:
        """Show optimization recommendations based on usage patterns"""
        print("Optimization Recommendations:")
        print()
        
        # High cache creation
        if stats['avg_cache_create'] > 50_000:
            potential_savings = (stats['avg_cache_create'] - 25_000) * self.CACHE_CREATE_PRICE
            print(f"  🔴 HIGH CACHE CREATION ({stats['avg_cache_create']:,.0f} tokens/request)")
            print(f"     Potential savings: ¥{potential_savings:.4f} per /reset")
            print(f"     → Run: optimize_workspace.sh --apply")
            print(f"     → Archive old memory files")
            print(f"     → Move large docs to references/")
            print()
        
        # Cache creation vs reads
        cache_ratio = stats['total_cache_create'] / (stats['total_cache_read'] + 1)
        if cache_ratio > 0.5:
            print(f"  🟡 HIGH CACHE CREATION RATIO ({cache_ratio:.1%})")
            print(f"     Too many /reset commands or new sessions")
            print(f"     → Use /new instead of /reset for coding sessions")
            print(f"     → Reuse sessions when possible")
            print()
        
        # High completion tokens
        avg_completion = stats['total_completion'] / stats['total_requests']
        if avg_completion > 5000:
            print(f"  🟡 HIGH COMPLETION TOKENS ({avg_completion:,.0f}/request)")
            print(f"     Long responses increase costs")
            print(f"     → Batch multiple edits into one request")
            print(f"     → Use sessions_spawn for heavy tasks")
            print()
        
        # Good optimization
        if stats['avg_cache_create'] < 30_000 and cache_ratio < 0.3:
            print(f"  ✅ WELL OPTIMIZED")
            print(f"     Cache creation: {stats['avg_cache_create']:,.0f} tokens (good)")
            print(f"     Cache reuse: {(1-cache_ratio)*100:.0f}% (excellent)")
            print()

def main():
    import argparse
    
    parser = argparse.ArgumentParser(
        description='Analyze OpenClaw token usage and costs',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s usage.jsonl                    # Analyze all records
  %(prog)s usage.jsonl --since 24h        # Last 24 hours
  %(prog)s usage.jsonl --since 7d         # Last 7 days
  %(prog)s usage.jsonl --date 2026-03-11  # Specific date
  %(prog)s usage.jsonl --verbose          # Show daily breakdown
        """
    )
    
    parser.add_argument('log_file', type=Path, help='Path to usage log (JSONL)')
    parser.add_argument('--since', help='Analyze records since (e.g., 24h, 7d)')
    parser.add_argument('--date', help='Analyze specific date (YYYY-MM-DD)')
    parser.add_argument('--verbose', '-v', action='store_true', help='Show detailed breakdown')
    
    args = parser.parse_args()
    
    # Parse time filters
    since = None
    if args.since:
        if args.since.endswith('h'):
            hours = int(args.since[:-1])
            since = datetime.now() - timedelta(hours=hours)
        elif args.since.endswith('d'):
            days = int(args.since[:-1])
            since = datetime.now() - timedelta(days=days)
        else:
            print(f"Error: Invalid --since format: {args.since}")
            sys.exit(1)
    
    if args.date:
        try:
            date = datetime.strptime(args.date, '%Y-%m-%d')
            since = date
        except ValueError:
            print(f"Error: Invalid date format: {args.date}")
            sys.exit(1)
    
    # Analyze
    analyzer = CostAnalyzer(args.log_file)
    analyzer.parse_log(since=since)
    
    stats = analyzer.aggregate_stats()
    analyzer.generate_report(stats, verbose=args.verbose)

if __name__ == '__main__':
    main()
