# Claude & Happy Session Management Guide

## Overview
This guide covers how to start, stop, resume, and reset sessions in both Claude Code and Happy CLI. Both tools now default to **Opus 4.5** for optimal performance.

---

## Default Model Configuration ✓ CONFIGURED

Both Claude and Happy are now configured to use **Opus 4.5** by default.

### How It's Configured:
1. **User Settings** (`~/.claude/settings.json`):
   ```json
   {
     "model": "opus"
   }
   ```

2. **Environment Variable** (`~/.bashrc`):
   ```bash
   export ANTHROPIC_MODEL=opus
   ```

### Verification:
After your next login or running `source ~/.bashrc`, both tools will use Opus 4.5 automatically.

---

## Starting Fresh Sessions (New Chat / Reset Context)

### Claude Code

#### Option 1: Just Start Claude (New Session)
```bash
claude
```
- Starts a brand new session with fresh context
- No history from previous conversations
- Uses Opus 4.5 by default

#### Option 2: Start with Specific Options
```bash
# Start in specific directory
cd /path/to/project && claude

# Start with custom model (override default)
claude --model sonnet

# Start with custom system prompt
claude --system-prompt "You are a security expert"

# Start bypassing permissions (YOLO mode)
claude --dangerously-skip-permissions
```

#### Option 3: Start with Specific Session ID (Advanced)
```bash
# Create new session with specific UUID
claude --session-id $(uuidgen)
```

### Happy

#### Option 1: Just Start Happy (New Session)
```bash
happy
```
- Starts new session in ClaudesHome (via custom function)
- Fresh context, no history
- Uses Opus 4.5 by default

#### Option 2: Start with Options
```bash
# YOLO mode (bypass permissions)
happy --yolo

# With custom model
happy --model sonnet

# Start in specific directory
cd /path/to/project && command happy

# Print mode (non-interactive)
happy -p "query here"
```

---

## Resuming Existing Sessions

### Claude Code

#### Resume Most Recent Session
```bash
claude --continue
# or shorthand:
claude -c
```

#### Resume Specific Session (Interactive Selection)
```bash
claude --resume
# or shorthand:
claude -r
```
This will show you a list of recent sessions to choose from.

#### Resume Specific Session by ID
```bash
claude --resume <session-id>
```

#### Continue with Query (Non-Interactive)
```bash
claude -c -p "follow up question"
```

### Happy

Happy supports all Claude options:
```bash
# Resume most recent
happy --continue
happy -c

# Resume specific session
happy --resume
happy -r
```

---

## Switching Models Mid-Session

### During an Active Session:
```
/model opus       # Switch to Opus 4.5
/model sonnet     # Switch to Sonnet 4.5
/model haiku      # Switch to Haiku
```

### Model Aliases:
- `opus` → Latest Opus (currently 4.5)
- `sonnet` → Latest Sonnet (currently 4.5)
- `haiku` → Latest Haiku
- `opusplan` → Opus during planning, Sonnet during execution

You can also use full model names:
```
/model claude-opus-4-5-20250929
```

---

## Session Storage & Management

### Where Sessions Are Stored:
- User home: `~/.claude/projects/`
- Per-directory: `~/.claude/projects/-mnt-c-Users-devin-IdeaProjects-ClaudesHome/`

### Session Files:
Each session is stored as `<session-id>.jsonl` containing the full conversation history.

### Viewing Active Sessions:
```bash
# List all sessions for current directory
ls -lt ~/.claude/projects/$(pwd | tr '/' '-' | sed 's/^-//')/

# Count sessions
ls ~/.claude/projects/$(pwd | tr '/' '-' | sed 's/^-//')/ | wc -l
```

### Cleaning Up Old Sessions:
```bash
# Remove sessions older than 30 days
find ~/.claude/projects/ -name "*.jsonl" -mtime +30 -delete

# Remove all sessions (nuclear option)
rm -rf ~/.claude/projects/
```

---

## Exiting Sessions

### Exit Cleanly:
- Type `Ctrl+D` (EOF)
- Type `exit` or `quit`

### Force Exit:
- `Ctrl+C` (cancels current input, press again to exit)

### Background Session (Advanced):
Run Claude in tmux:
```bash
tmux new-session -s claude
claude
# Detach: Ctrl+b d
# Re-attach: tmux attach -t claude
```

---

## Quick Reference: Common Commands

### Start Fresh (New Chat)
```bash
claude              # Fresh session with Opus 4.5
happy               # Fresh session in ClaudesHome with Opus 4.5
```

### Resume Last Session
```bash
claude -c           # Continue most recent
happy -c            # Continue most recent
```

### Resume Specific Session
```bash
claude -r           # Interactive selection
happy -r            # Interactive selection
```

### Change Model (During Session)
```
/model opus         # Switch to Opus 4.5
/model sonnet       # Switch to Sonnet 4.5
```

### Override Model at Startup
```bash
claude --model sonnet       # Start with Sonnet instead of Opus
happy --model haiku         # Start with Haiku instead of Opus
```

---

## Seamless Integration Between Claude & Happy

Since Happy wraps Claude Code, they share:
- ✓ Same credentials (`~/.claude/.credentials.json`)
- ✓ Same session storage (`~/.claude/projects/`)
- ✓ Same settings (`~/.claude/settings.json`)
- ✓ Same model defaults (Opus 4.5)

**Key Difference:**
- `happy` command auto-navigates to ClaudesHome before starting
- `claude` command starts in current directory

### To Use Happy Without ClaudesHome Navigation:
```bash
command happy       # Bypasses the custom function, runs raw happy
```

---

## Interactive Session Commands

### While in a Claude/Happy session:

| Command | Action |
|---------|--------|
| `/model <name>` | Switch to different model |
| `/config` | Configure session settings |
| `/new` | Pseudo-fresh start (forget all context) |
| `/fresh` | Instructions to exit for true fresh session |
| `/reset` | Soft reset (clear confusion, keep awareness) |
| `/session` | Show session information |
| `/vim` | Enable Vim mode |
| `/help` | Show help |
| `Ctrl+C` | Cancel current input |
| `Ctrl+D` | Exit session |
| `Ctrl+L` | Clear screen |
| `Esc Esc` | Rewind conversation |
| `Tab` | Toggle extended thinking |
| `Shift+Tab` | Toggle permission mode |

---

## Advanced: Custom Session Workflows

### Create Alias for Specific Project Session
Add to `~/.bashrc`:
```bash
alias sf-claude='cd ~/IdeaProjects/bristol-sf-project && claude --model opus'
alias admin-claude='cd ~/IdeaProjects/ClaudesHome && claude --model opus'
```

### Auto-Resume Last Session on Startup
Add to `~/.bashrc`:
```bash
alias c='claude -c'
alias h='happy -c'
```

### Create Named Session Presets
```bash
# Development session with extended permissions
alias dev-claude='claude --dangerously-skip-permissions --model opus'

# Quick query without session
alias ask='claude -p'
```

---

## Troubleshooting

### Session Not Resuming
```bash
# Check if sessions exist
ls ~/.claude/projects/$(pwd | tr '/' '-' | sed 's/^-//')/

# Verify credentials
cat ~/.claude/.credentials.json | jq .
```

### Model Not Defaulting to Opus
```bash
# Check environment variable
echo $ANTHROPIC_MODEL

# Re-source bashrc
source ~/.bashrc

# Check user settings
cat ~/.claude/settings.json
```

### Happy Not Starting
```bash
# Check Happy status
happy doctor

# Check authentication
happy auth status

# Check if daemon is running
ps aux | grep happy
```

### Sessions Taking Too Much Disk Space
```bash
# Check session storage size
du -sh ~/.claude/projects/

# Clean old sessions
find ~/.claude/projects/ -name "*.jsonl" -mtime +30 -delete
```

---

## Best Practices

1. **Start Fresh for New Topics**
   - Don't resume sessions when switching to unrelated work
   - Fresh context = better responses

2. **Resume for Continuity**
   - Use `--continue` when following up on previous work
   - Saves time re-explaining context

3. **Name Your Projects**
   - Work in named directories (e.g., `bristol-sf-project`)
   - Sessions are organized by directory

4. **Clean Up Regularly**
   - Old sessions consume disk space
   - Delete sessions older than 30-60 days

5. **Use the Right Model**
   - Opus 4.5 (default): Complex tasks, deep reasoning
   - Sonnet 4.5: Faster, good for most tasks
   - Haiku: Simple queries, speed critical

---

## Configuration Files Reference

### User Settings
**Location:** `~/.claude/settings.json`
```json
{
  "model": "opus"
}
```

### Project Settings (ClaudesHome)
**Location:** `/mnt/c/Users/devin/IdeaProjects/ClaudesHome/.claude/settings.local.json`
```json
{
  "permissions": {
    "allow": [
      "Bash(git:*)",
      "Bash(doppler:*)",
      "Bash(sf org:*)",
      "Read",
      "Glob",
      "Grep"
    ],
    "defaultMode": "bypassPermissions"
  }
}
```

### Environment Variables
**Location:** `~/.bashrc`
```bash
export ANTHROPIC_MODEL=opus
```

---

## Summary

### ✅ Configured:
- Opus 4.5 set as default model (both settings file + environment variable)
- Happy function configured to start in ClaudesHome
- Session management ready

### Quick Commands:
```bash
# New session (fresh context)
claude               # or: happy

# Resume last session
claude -c            # or: happy -c

# Resume specific session
claude -r            # or: happy -r

# Override model
claude --model sonnet

# Change model mid-session
/model opus
```

### Files Modified:
- ✓ `~/.claude/settings.json` (created)
- ✓ `~/.bashrc` (added ANTHROPIC_MODEL export)

**Next steps:**
- Restart your shell or run `source ~/.bashrc`
- Start a new session to verify Opus 4.5 is default
- Check with `/config` or by observing the model in use

---

*Generated by Claude Opus 4.5 on 2025-11-26*
