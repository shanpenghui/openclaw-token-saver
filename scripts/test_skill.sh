#!/bin/bash
# test_skill.sh - Test token-optimizer skill functionality

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Testing Token Optimizer Skill..."
echo "Skill directory: $SKILL_DIR"
echo ""

# Test 1: Validate SKILL.md structure
echo "📝 Test 1: SKILL.md validation"
if [[ -f "$SKILL_DIR/SKILL.md" ]]; then
    # Check frontmatter
    if head -n 5 "$SKILL_DIR/SKILL.md" | grep -q "^name: token-optimizer"; then
        echo -e "${GREEN}✓${NC} Frontmatter contains name"
    else
        echo -e "${RED}✗${NC} Missing name in frontmatter"
        exit 1
    fi
    
    if head -n 5 "$SKILL_DIR/SKILL.md" | grep -q "^description:"; then
        echo -e "${GREEN}✓${NC} Frontmatter contains description"
    else
        echo -e "${RED}✗${NC} Missing description in frontmatter"
        exit 1
    fi
    
    # Check for key sections
    if grep -q "## Quick Start" "$SKILL_DIR/SKILL.md"; then
        echo -e "${GREEN}✓${NC} Quick Start section found"
    else
        echo -e "${YELLOW}⚠${NC} No Quick Start section"
    fi
else
    echo -e "${RED}✗${NC} SKILL.md not found"
    exit 1
fi
echo ""

# Test 2: Check scripts exist and are executable
echo "🔧 Test 2: Scripts"
if [[ -x "$SKILL_DIR/scripts/optimize_workspace.sh" ]]; then
    echo -e "${GREEN}✓${NC} optimize_workspace.sh is executable"
else
    echo -e "${RED}✗${NC} optimize_workspace.sh not executable"
    exit 1
fi

if [[ -x "$SKILL_DIR/scripts/analyze_costs.py" ]]; then
    echo -e "${GREEN}✓${NC} analyze_costs.py is executable"
else
    echo -e "${RED}✗${NC} analyze_costs.py not executable"
    exit 1
fi

# Test help flags
if "$SKILL_DIR/scripts/optimize_workspace.sh" --help &>/dev/null; then
    echo -e "${GREEN}✓${NC} optimize_workspace.sh --help works"
else
    echo -e "${YELLOW}⚠${NC} optimize_workspace.sh --help failed"
fi

if "$SKILL_DIR/scripts/analyze_costs.py" --help &>/dev/null; then
    echo -e "${GREEN}✓${NC} analyze_costs.py --help works"
else
    echo -e "${YELLOW}⚠${NC} analyze_costs.py --help failed"
fi
echo ""

# Test 3: Check reference files
echo "📚 Test 3: Reference files"
refs=(
    "references/pricing_guide.md"
    "references/best_practices.md"
)

for ref in "${refs[@]}"; do
    if [[ -f "$SKILL_DIR/$ref" ]]; then
        size=$(wc -c < "$SKILL_DIR/$ref")
        if [[ $size -gt 1000 ]]; then
            echo -e "${GREEN}✓${NC} $ref exists ($size bytes)"
        else
            echo -e "${YELLOW}⚠${NC} $ref is small ($size bytes)"
        fi
    else
        echo -e "${RED}✗${NC} $ref not found"
        exit 1
    fi
done
echo ""

# Test 4: Run optimize_workspace.sh in dry-run mode
echo "🧹 Test 4: optimize_workspace.sh dry-run"
if "$SKILL_DIR/scripts/optimize_workspace.sh" --dry-run --workspace /tmp/test-workspace 2>&1 | grep -q "Workspace not found"; then
    echo -e "${GREEN}✓${NC} Script handles missing workspace gracefully"
else
    echo -e "${YELLOW}⚠${NC} Unexpected dry-run behavior"
fi
echo ""

# Test 5: Test analyze_costs.py with sample data
echo "📊 Test 5: analyze_costs.py with sample data"

# Create sample JSONL
SAMPLE_LOG="/tmp/test_usage.jsonl"
cat > "$SAMPLE_LOG" << 'EOF'
{"timestamp": "2026-03-11T15:00:00", "prompt_tokens": 5, "completion_tokens": 89, "cache_read_tokens": 0, "cache_create_tokens": 112819, "cost": 1.02, "model": "claude-sonnet-3.5"}
{"timestamp": "2026-03-11T15:05:00", "prompt_tokens": 5, "completion_tokens": 2315, "cache_read_tokens": 47105, "cache_create_tokens": 93, "cost": 0.12, "model": "claude-sonnet-3.5"}
EOF

if "$SKILL_DIR/scripts/analyze_costs.py" "$SAMPLE_LOG" 2>&1 | grep -q "Token Usage & Cost Analysis"; then
    echo -e "${GREEN}✓${NC} analyze_costs.py processes sample data"
else
    echo -e "${RED}✗${NC} analyze_costs.py failed"
    exit 1
fi

rm "$SAMPLE_LOG"
echo ""

# Test 6: Check file sizes
echo "📏 Test 6: File sizes"
SKILL_SIZE=$(wc -c < "$SKILL_DIR/SKILL.md")
if [[ $SKILL_SIZE -lt 30000 ]]; then
    echo -e "${GREEN}✓${NC} SKILL.md size is reasonable ($SKILL_SIZE bytes)"
else
    echo -e "${YELLOW}⚠${NC} SKILL.md is large ($SKILL_SIZE bytes)"
fi

TOTAL_REFS=$(find "$SKILL_DIR/references" -type f -exec wc -c {} + | tail -1 | awk '{print $1}')
echo -e "${GREEN}✓${NC} Total reference size: $TOTAL_REFS bytes"
echo ""

# Test 7: Check for symlinks (security)
echo "🔒 Test 7: Security checks"
if find "$SKILL_DIR" -type l | grep -q .; then
    echo -e "${RED}✗${NC} Symlinks found (packaging will fail)"
    exit 1
else
    echo -e "${GREEN}✓${NC} No symlinks found"
fi
echo ""

# Summary
echo "========================================="
echo -e "${GREEN}All tests passed!${NC}"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Package the skill:"
echo "   cd ~/.openclaw/workspace"
echo "   python3 ~/.npm-global/lib/node_modules/openclaw/skills/skill-creator/scripts/package_skill.py skills/token-optimizer"
echo ""
echo "2. Test installation:"
echo "   openclaw skills install token-optimizer.skill"
echo ""
echo "3. Test in OpenClaw:"
echo "   Ask: 'Why are my API costs so high?'"
echo "   Verify the token-optimizer skill loads"
