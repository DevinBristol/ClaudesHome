#!/bin/bash
# Session Manager - Quick commands for Claude & Happy sessions

show_help() {
    cat << EOF
Session Manager - Manage Claude Code and Happy sessions

Usage: session-manager.sh <command>

Commands:
  new            Start a fresh session with Opus 4.5
  resume         Resume the most recent session
  pick           Interactively pick a session to resume
  list           List all sessions for current directory
  clean          Remove sessions older than 30 days
  clean-all      Remove ALL sessions (caution!)
  verify         Verify Opus 4.5 is configured as default
  help           Show this help message

Examples:
  ./session-manager.sh new          # Start fresh with Opus
  ./session-manager.sh resume       # Continue last session
  ./session-manager.sh list         # Show all sessions
  ./session-manager.sh verify       # Check model configuration

Model Commands (during a session):
  /model opus      Switch to Opus 4.5
  /model sonnet    Switch to Sonnet 4.5
  /model haiku     Switch to Haiku

Exit Commands:
  Ctrl+D           Exit cleanly
  exit             Also exits
  Ctrl+C           Cancel current / force exit

EOF
}

# Get the session directory for current path
get_session_dir() {
    local pwd_encoded=$(pwd | tr '/' '-' | sed 's/^-//')
    echo "$HOME/.claude/projects/$pwd_encoded"
}

# Start new session
start_new() {
    echo "Starting fresh Claude session with Opus 4.5..."
    claude
}

# Resume last session
resume_last() {
    echo "Resuming most recent Claude session..."
    claude -c
}

# Pick session interactively
pick_session() {
    echo "Opening interactive session picker..."
    claude -r
}

# List sessions
list_sessions() {
    local session_dir=$(get_session_dir)

    if [ ! -d "$session_dir" ]; then
        echo "No sessions found for current directory"
        echo "Directory: $session_dir"
        return
    fi

    local count=$(ls "$session_dir"/*.jsonl 2>/dev/null | wc -l)

    if [ "$count" -eq 0 ]; then
        echo "No sessions found for current directory"
        return
    fi

    echo "Found $count session(s) in: $session_dir"
    echo ""
    echo "Recent sessions:"
    ls -lth "$session_dir"/*.jsonl | head -10 | awk '{print $6, $7, $8, $9}'
}

# Clean old sessions
clean_old() {
    echo "Removing sessions older than 30 days..."
    local count=$(find ~/.claude/projects/ -name "*.jsonl" -mtime +30 2>/dev/null | wc -l)

    if [ "$count" -eq 0 ]; then
        echo "No old sessions to remove"
        return
    fi

    echo "Found $count old session(s)"
    read -p "Remove these sessions? (y/N): " confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        find ~/.claude/projects/ -name "*.jsonl" -mtime +30 -delete
        echo "Removed $count session(s)"
    else
        echo "Cancelled"
    fi
}

# Clean ALL sessions
clean_all() {
    echo "WARNING: This will remove ALL Claude sessions!"
    read -p "Are you absolutely sure? Type 'DELETE ALL' to confirm: " confirm

    if [ "$confirm" == "DELETE ALL" ]; then
        rm -rf ~/.claude/projects/
        echo "All sessions removed"
    else
        echo "Cancelled"
    fi
}

# Verify Opus configuration
verify_config() {
    echo "Verifying Opus 4.5 default configuration..."
    echo ""

    echo "1. Environment Variable:"
    if [ -n "$ANTHROPIC_MODEL" ]; then
        echo "   ✓ ANTHROPIC_MODEL=$ANTHROPIC_MODEL"
    else
        echo "   ✗ ANTHROPIC_MODEL not set"
        echo "   Run: export ANTHROPIC_MODEL=opus"
        echo "   Or: source ~/.bashrc"
    fi

    echo ""
    echo "2. User Settings (~/.claude/settings.json):"
    if [ -f "$HOME/.claude/settings.json" ]; then
        cat "$HOME/.claude/settings.json"
    else
        echo "   ✗ Settings file not found"
        echo "   Expected: ~/.claude/settings.json"
    fi

    echo ""
    echo "3. Session Storage:"
    local total_size=$(du -sh ~/.claude/projects/ 2>/dev/null | awk '{print $1}')
    local session_count=$(find ~/.claude/projects/ -name "*.jsonl" 2>/dev/null | wc -l)

    if [ -d "$HOME/.claude/projects" ]; then
        echo "   ✓ Sessions directory exists"
        echo "   Total sessions: $session_count"
        echo "   Storage used: $total_size"
    else
        echo "   - No sessions yet"
    fi

    echo ""
    echo "4. Happy Status:"
    if command -v happy &> /dev/null; then
        echo "   ✓ Happy CLI installed"
        happy auth status 2>&1 | grep -E "(Authenticated|Machine registered)" || echo "   ! Not authenticated"
    else
        echo "   ✗ Happy CLI not installed"
    fi
}

# Main command dispatcher
case "${1:-help}" in
    new)
        start_new
        ;;
    resume)
        resume_last
        ;;
    pick)
        pick_session
        ;;
    list)
        list_sessions
        ;;
    clean)
        clean_old
        ;;
    clean-all)
        clean_all
        ;;
    verify)
        verify_config
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo "Run './session-manager.sh help' for usage"
        exit 1
        ;;
esac
