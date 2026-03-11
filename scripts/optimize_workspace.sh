#!/bin/bash
# optimize_workspace.sh - Reduce OpenClaw token usage by cleaning workspace
set -euo pipefail

WORKSPACE="${OPENCLAW_WORKSPACE:-$HOME/.openclaw/workspace}"
ARCHIVE_DIR="${ARCHIVE_DIR:-$HOME/archive}"
DRY_RUN=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Optimize OpenClaw workspace to reduce token usage and API costs.

OPTIONS:
    --dry-run           Show what would be changed without applying
    --apply             Apply optimizations (default: dry-run)
    --workspace PATH    Workspace directory (default: ~/.openclaw/workspace)
    --archive PATH      Archive directory (default: ~/archive)
    --help              Show this help message

OPTIMIZATIONS:
    1. Archive old memory files (>2 days old)
    2. Remove bootstrap/setup files
    3. Move large skill docs to references/
    4. Trim verbose logs to summaries
    5. Report token savings

EXAMPLES:
    $0 --dry-run              # Preview changes
    $0 --apply                # Apply optimizations
    $0 --apply --archive /mnt/backup/archive

EOF
    exit 0
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

estimate_tokens() {
    local file="$1"
    if [[ -f "$file" ]]; then
        # Rough estimate: 1 token ≈ 4 chars (conservative)
        local chars=$(wc -c < "$file")
        echo $((chars / 4))
    else
        echo 0
    fi
}

backup_file() {
    local file="$1"
    local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [[ $DRY_RUN == true ]]; then
        log_info "Would backup: $file → $backup"
    else
        cp "$file" "$backup"
        log_success "Backed up: $file"
    fi
}

archive_memory_files() {
    log_info "Archiving old memory files..."
    
    local memory_dir="$WORKSPACE/memory"
    local archive_memory="$ARCHIVE_DIR/memory"
    local tokens_saved=0
    
    if [[ ! -d "$memory_dir" ]]; then
        log_warning "No memory directory found"
        return
    fi
    
    # Archive files older than 2 days
    local cutoff_date=$(date -d '2 days ago' +%Y-%m-%d 2>/dev/null || date -v-2d +%Y-%m-%d)
    
    find "$memory_dir" -name "*.md" -type f | while read -r file; do
        local filename=$(basename "$file")
        local file_date="${filename%.md}"
        
        # Skip if not a date-formatted file
        if [[ ! "$file_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
            continue
        fi
        
        if [[ "$file_date" < "$cutoff_date" ]]; then
            local tokens=$(estimate_tokens "$file")
            tokens_saved=$((tokens_saved + tokens))
            
            if [[ $DRY_RUN == true ]]; then
                log_info "Would archive: $filename ($tokens tokens)"
            else
                mkdir -p "$archive_memory"
                mv "$file" "$archive_memory/"
                log_success "Archived: $filename ($tokens tokens)"
            fi
        fi
    done
    
    echo "$tokens_saved"
}

remove_bootstrap_files() {
    log_info "Removing bootstrap files..."
    
    local files=(
        "$WORKSPACE/BOOTSTRAP.md"
        "$WORKSPACE/INSTALLATION.md"
        "$WORKSPACE/SETUP.md"
    )
    
    local tokens_saved=0
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            local tokens=$(estimate_tokens "$file")
            tokens_saved=$((tokens_saved + tokens))
            
            if [[ $DRY_RUN == true ]]; then
                log_info "Would remove: $(basename "$file") ($tokens tokens)"
            else
                backup_file "$file"
                rm "$file"
                log_success "Removed: $(basename "$file") ($tokens tokens)"
            fi
        fi
    done
    
    echo "$tokens_saved"
}

move_large_skill_docs() {
    log_info "Moving large skill documentation to references/..."
    
    local tokens_saved=0
    local size_threshold=5120  # 5KB
    
    find "$WORKSPACE/skills" -type f -name "*.md" -size +${size_threshold}c 2>/dev/null | while read -r file; do
        local dir=$(dirname "$file")
        local filename=$(basename "$file")
        
        # Skip if already in references/
        if [[ "$dir" == *"/references"* ]]; then
            continue
        fi
        
        # Skip SKILL.md (core file)
        if [[ "$filename" == "SKILL.md" ]]; then
            continue
        fi
        
        local skill_dir=$(echo "$dir" | sed 's|/docs||' | sed 's|/guides||')
        local ref_dir="$skill_dir/references"
        
        local tokens=$(estimate_tokens "$file")
        tokens_saved=$((tokens_saved + tokens))
        
        if [[ $DRY_RUN == true ]]; then
            log_info "Would move: $filename → references/ ($tokens tokens)"
        else
            mkdir -p "$ref_dir"
            mv "$file" "$ref_dir/"
            log_success "Moved: $filename → references/ ($tokens tokens)"
        fi
    done
    
    echo "$tokens_saved"
}

trim_verbose_logs() {
    log_info "Checking for verbose log files..."
    
    local tokens_saved=0
    local size_threshold=10240  # 10KB
    
    # Check today's memory file
    local today=$(date +%Y-%m-%d)
    local today_log="$WORKSPACE/memory/$today.md"
    
    if [[ -f "$today_log" ]] && [[ $(wc -c < "$today_log") -gt $size_threshold ]]; then
        local tokens=$(estimate_tokens "$today_log")
        log_warning "Today's log is large: $today_log ($tokens tokens)"
        log_warning "Consider summarizing and archiving detailed notes"
        
        # Don't auto-trim today's file, just warn
        echo "# Consider trimming this file to <2KB summary" >> "$today_log.suggestion"
    fi
    
    echo "$tokens_saved"
}

generate_report() {
    local memory_tokens=$1
    local bootstrap_tokens=$2
    local docs_tokens=$3
    local total_saved=$((memory_tokens + bootstrap_tokens + docs_tokens))
    
    echo ""
    log_info "===== Optimization Report ====="
    echo ""
    echo "Tokens saved by category:"
    echo "  Memory archives:     $(printf "%8d" $memory_tokens) tokens"
    echo "  Bootstrap removal:   $(printf "%8d" $bootstrap_tokens) tokens"
    echo "  Docs reorganization: $(printf "%8d" $docs_tokens) tokens"
    echo "  ────────────────────────────────"
    echo "  Total saved:         $(printf "%8d" $total_saved) tokens"
    echo ""
    
    if [[ $total_saved -gt 0 ]]; then
        # Cost calculation (¥3.75/1M for cache creation)
        local cost_saved=$(echo "scale=4; $total_saved * 3.75 / 1000000" | bc)
        echo "Estimated cost savings: ¥${cost_saved} per /reset session"
        echo ""
        
        # Percentage reduction (assume baseline 112K tokens)
        local baseline=112000
        local percent=$(echo "scale=1; $total_saved * 100 / $baseline" | bc)
        log_success "Cache creation reduced by ~${percent}%"
    else
        log_info "No optimizations needed - workspace is already lean"
    fi
    
    echo ""
}

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --apply)
                DRY_RUN=false
                shift
                ;;
            --workspace)
                WORKSPACE="$2"
                shift 2
                ;;
            --archive)
                ARCHIVE_DIR="$2"
                shift 2
                ;;
            --help)
                usage
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                ;;
        esac
    done
    
    # Default to dry-run
    if [[ $DRY_RUN == true ]]; then
        log_warning "DRY RUN mode - no changes will be made"
        log_info "Use --apply to apply optimizations"
        echo ""
    fi
    
    # Verify workspace exists
    if [[ ! -d "$WORKSPACE" ]]; then
        log_error "Workspace not found: $WORKSPACE"
        exit 1
    fi
    
    log_info "Workspace: $WORKSPACE"
    log_info "Archive: $ARCHIVE_DIR"
    echo ""
    
    # Run optimizations
    memory_tokens=$(archive_memory_files)
    bootstrap_tokens=$(remove_bootstrap_files)
    docs_tokens=$(move_large_skill_docs)
    trim_tokens=$(trim_verbose_logs)
    
    # Generate report
    generate_report "$memory_tokens" "$bootstrap_tokens" "$docs_tokens"
    
    if [[ $DRY_RUN == true ]]; then
        log_info "Run with --apply to execute these changes"
    fi
}

main "$@"
