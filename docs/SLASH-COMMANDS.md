# Custom Slash Commands for Session Management

## Overview

Custom slash commands have been added to ClaudesHome to help manage sessions more effectively while in an active Claude or Happy session.

---

## Commands Created

### `/new` - Pseudo-Fresh Start
**Purpose:** Reset context within the current session
**What it does:**
- Instructs Claude to forget ALL previous messages in the session
- Treats the next message as a brand new conversation
- Keeps the same session ID but acts like a fresh start
**Use when:** You want to change topics completely without exiting

### `/fresh` - True Fresh Session Instructions
**Purpose:** Get instructions for starting a truly fresh session
**What it does:**
- Provides step-by-step instructions to exit and restart
- Explains the difference between pseudo-fresh and true fresh
**Use when:** You need a new session ID and complete reset

### `/reset` - Soft Reset
**Purpose:** Clear confusion without losing all context
**What it does:**
- Clears working memory but keeps awareness of the session
- Like saying "let's start over on this topic" vs "let's pretend we just met"
**Use when:** The conversation got confusing but you want to keep the relationship

### `/session` - Session Information
**Purpose:** Check current session status
**What it does:**
- Shows current model (Opus/Sonnet/Haiku)
- Shows working directory
- Provides session summary
- Lists active todos/tasks
- Reminds of key commands
**Use when:** You want to know session details or available commands

---

## How Slash Commands Work

### Location
Commands are stored as Markdown files in:
```
.claude/commands/
├── fresh.md
├── new.md
├── reset.md
└── session.md
```

### Structure
Each `.md` file becomes a slash command:
- Filename = command name (e.g., `new.md` → `/new`)
- File contents = instructions to Claude

### Scope
- **Project-level:** `.claude/commands/` (in ClaudesHome)
- Available whenever working in ClaudesHome
- Shared if repository is cloned

---

## Usage Examples

### Scenario 1: Complete Topic Change
```
You: Let's work on Salesforce deployment
Claude: [helps with deployment]
You: /new
Claude: [forgets deployment context]
You: Help me with Five9 administration
Claude: [starts fresh on Five9 topic]
```

### Scenario 2: Got Confused, Need Reset
```
You: [complex multi-step task]
Claude: [gets confused with context]
You: /reset
Claude: [clears confusion but remembers we're working together]
You: Let me explain the task differently...
```

### Scenario 3: Need Actual New Session
```
You: /fresh
Claude: To start fresh: 1) Press Ctrl+D 2) Type 'claude'
You: Ctrl+D
[Terminal]: claude
[New session starts]
```

### Scenario 4: Check Status
```
You: /session
Claude: Running Opus 4.5 in /ClaudesHome, we've discussed X, Y, Z...
```

---

## Creating New Commands

To add your own slash command:

1. **Create the file:**
```bash
echo "Your command instructions" > .claude/commands/yourcommand.md
```

2. **Use it:**
```
/yourcommand
```

### Example Custom Commands You Could Add:

#### `/status` - Quick project status
```markdown
Provide a brief status update on:
1. Current git branch and changes
2. Any failing tests
3. Open todos
4. Last deployment status
```

#### `/standup` - Daily standup format
```markdown
Format the following as a standup update:
1. What was accomplished since last session
2. What's planned for this session
3. Any blockers or questions
```

#### `/commit` - Prepare commit message
```markdown
Review the current git diff and suggest a well-formatted commit message following conventional commits standard.
```

---

## Limitations

### What Commands CANNOT Do:
- ❌ Actually exit the current session
- ❌ Spawn a new Claude/Happy process
- ❌ Change system settings
- ❌ Execute shell commands directly
- ❌ Modify the session ID

### What Commands CAN Do:
- ✅ Change Claude's behavior/context
- ✅ Provide information or instructions
- ✅ Format outputs differently
- ✅ Set conversation tone/style
- ✅ Create workflow shortcuts

---

## Quick Reference

| Command | Purpose | Type |
|---------|---------|------|
| `/new` | Forget everything, pseudo-fresh | Context Reset |
| `/fresh` | Instructions for true fresh session | Instructions |
| `/reset` | Clear confusion, keep awareness | Soft Reset |
| `/session` | Show session information | Information |

---

## Files Modified

### Created:
- `.claude/commands/new.md`
- `.claude/commands/fresh.md`
- `.claude/commands/reset.md`
- `.claude/commands/session.md`

### Updated:
- `docs/quick-reference-sessions.md` - Added new commands
- `docs/session-management.md` - Added to commands table

---

## Testing the Commands

To verify commands are working:
1. Type `/help` in a Claude session - should list custom commands
2. Try `/session` - should show session info
3. Try `/new` then ask "what were we discussing?" - should not know

---

*Note: These commands are stored in the ClaudesHome repository and will sync across machines once committed and pushed.*