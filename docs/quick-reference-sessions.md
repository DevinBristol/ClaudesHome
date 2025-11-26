# Session Management Quick Reference

## TL;DR - What You Need to Know

### Fresh Session (New Chat)
```bash
claude    # Start fresh in current directory
happy     # Start fresh in ClaudesHome
```

### Resume Last Session
```bash
claude -c    # Continue where you left off
happy -c     # Continue where you left off
```

### Switch Model During Session
```
/model opus      # Opus 4.5 (default, most capable)
/model sonnet    # Sonnet 4.5 (faster)
/model haiku     # Haiku (quick tasks)
```

### Exit Session
```
Ctrl+D    # Clean exit
exit      # Also works
```

---

## Common Scenarios

| I want to... | Command |
|--------------|---------|
| **Start a new conversation** | `claude` or `happy` |
| **Continue my last session** | `claude -c` or `happy -c` |
| **Pick from recent sessions** | `claude -r` or `happy -r` |
| **Fresh context (in session)** | `/new` |
| **Instructions for true fresh** | `/fresh` |
| **Soft reset context** | `/reset` |
| **Check session info** | `/session` |
| **Use a different model** | `claude --model sonnet` |
| **Switch model mid-chat** | `/model sonnet` |
| **Work without interruptions** | `claude --yolo` or `happy --yolo` |
| **Exit the session** | `Ctrl+D` |
| **Cancel current response** | `Ctrl+C` |
| **Clear the screen** | `Ctrl+L` |

---

## Model Selection

| Model | Best For | Speed | Command |
|-------|----------|-------|---------|
| **Opus 4.5** (default) | Complex tasks, deep reasoning | Slower | `/model opus` |
| **Sonnet 4.5** | Most general tasks | Fast | `/model sonnet` |
| **Haiku** | Simple queries, speed critical | Fastest | `/model haiku` |

---

## Configuration Applied ✓

**Default Model:** Opus 4.5
**Location:** Both `~/.claude/settings.json` and `~/.bashrc`

**To apply changes:**
```bash
source ~/.bashrc
```

**To verify:**
```bash
echo $ANTHROPIC_MODEL    # Should show: opus
cat ~/.claude/settings.json    # Should show: {"model":"opus"}
```

---

## Help Commands

```bash
claude --help     # Full CLI reference
happy --help      # Happy options
happy doctor      # Diagnose issues
```

**In-session:**
```
/help             # Show available commands
/config           # Configure session
/new              # Pseudo-fresh start (forget context)
/fresh            # Instructions to exit for true fresh
/reset            # Soft context reset
/session          # Show session information
```

---

## File Locations

| What | Where |
|------|-------|
| Sessions | `~/.claude/projects/` |
| Settings | `~/.claude/settings.json` |
| Credentials | `~/.claude/.credentials.json` |
| Happy config | `~/.happy/` |

---

**For full details, see:** `docs/session-management.md`
