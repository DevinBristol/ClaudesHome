# ClaudesHome - Claude Instructions

## What Is This
ClaudesHome is Devin's universal command center. From here, you help him manage tasks, look up procedures, work on projects, and handle whatever comes up.

## Project Location
`C:\Users\Devin\IdeaProjects\ClaudesHome`

## Navigation
When Devin says `/home`, `go home`, or `home`, interpret that as:
```
cd C:\Users\Devin\IdeaProjects\ClaudesHome
```

When Devin says `sync`:
```powershell
.\scripts\sync.ps1
```

## Session Start Protocol
ALWAYS do this when Devin starts a session:
1. cd to ClaudesHome (if not already there)
2. Run `git pull` to get latest changes
3. Briefly mention if there were updates

## Session End Protocol
Before Devin disconnects, ask:
"Want me to sync your changes before you go?"
If yes: `.\scripts\sync.ps1`

---

## Task Management

### Task Categories
- **urgent.md** - Do today, time-sensitive, fires to put out
- **development.md** - Coding, Salesforce dev, technical projects
- **administration.md** - Admin work, IT tasks, Five9, routine stuff
- **ideas.md** - The bin: potential projects, someday/maybe, things to explore
- **waiting.md** - Blocked on someone/something else
- **done.md** - Completed tasks (for reference)

### Adding Tasks
When Devin says "add to my list" or "remind me to" or "I need to":
1. Determine the right category (ask if unclear)
2. Add to appropriate file with today's date
3. Format: `- [ ] [DATE] Task description`

Category hints:
- "urgent", "asap", "today", "fire" -> urgent.md
- "build", "code", "fix bug", "deploy", "apex" -> development.md
- "password reset", "Five9", "admin", "IT" -> administration.md
- "idea", "maybe", "someday", "thinking about", "potential" -> ideas.md
- "waiting on", "blocked", "need X from Y" -> waiting.md

### Checking Tasks
When Devin asks "what's on my plate" or "my tasks":
- Start with urgent.md (anything here?)
- Then summarize development.md and administration.md counts
- Don't mention ideas.md unless asked

Specific views:
- "what's urgent" -> just urgent.md
- "dev tasks" -> just development.md
- "admin tasks" -> just administration.md
- "my ideas" or "the bin" -> ideas.md

### Completing Tasks
When Devin says "done with X" or "finished X":
- Find the task in any category
- Move to done.md with completion date
- Format: `- [x] [COMPLETED] Task (from [CATEGORY], added [ORIGINAL DATE])`

### Promoting/Moving Tasks
- "make X urgent" -> move to urgent.md
- "this is a dev task" -> move to development.md
- Note the move: `- [ ] [DATE] Task (moved from [CATEGORY])`

### Waiting/Blocked
When Devin says "waiting on X for Y":
- Add to waiting.md with who/what we're waiting on
- Format: `- [ ] [DATE] Task - waiting on [PERSON/THING]`

---

## Quick Capture (Inbox)
When Devin dumps a request quickly ("got a text about X", "Cameron needs Y"):
- Add to inbox/capture.md with timestamp
- Ask if he wants to act on it now or just capture it

---

## SOPs (Standard Operating Procedures)
When Devin does a task that could be repeated:
- Offer to document it: "Want me to save this as an SOP?"
- If yes, create in appropriate folder (sops/salesforce/, sops/five9/, sops/it/)
- Keep it simple: numbered steps, no fluff

When Devin asks how to do something:
- Check sops/ folder first for existing procedure
- If found, walk through it
- If not found, help him do it and offer to create SOP

---

## Salesforce Work

### Org Aliases
| Alias | Type | Status | Notes |
|-------|------|--------|-------|
| **prod** | Production (DevHub) | Connected via JWT | CAREFUL - always confirm before any changes |
| **uat-jwt** | Partial Copy Sandbox | Connected | Safe for testing with production-like data |
| **devin1** | Dev Sandbox | Connected | Primary dev sandbox, safe for experimentation |
| **Devin2** | Dev Sandbox | Connected | Secondary dev sandbox |
| **Devin3** | Dev Sandbox | Connected | Tertiary dev sandbox |
| **Developing** | Sandbox | Connected | Additional sandbox |
| **myDevOrg** | Scratch Org | Connected | Ephemeral dev environment |
| **FullCopy** | Full Copy Sandbox | **Inactive** | Needs re-authentication |

### JWT Authentication
Production uses JWT auth via Connected App "bristol-sf-project".
- Consumer Key and private key stored in ClaudesHome (certs/ folder, gitignored)
- To re-authenticate on a new PC, run: `.\scripts\setup\sf-jwt-auth.ps1`

### Common Commands
```powershell
# Authentication
sf org list                              # See all orgs
sf org login web -a <alias>              # Auth new org
sf org display -o <alias>                # Show org details

# Data
sf data query -q "SELECT..." -o <org>
sf data export tree -q "SELECT..." -p temp/ -o <org>
sf data query -q "SELECT COUNT() FROM Account" -o devin1

# Deployment
sf project deploy start -d force-app -o <org>
sf project deploy start -d force-app -o <org> --dry-run  # Validate only
sf project deploy start -m "ApexClass:MyClass" -o <org>  # Single class

# Debugging
sf apex tail log -o <org>
sf apex run -f temp/anon.apex -o <org>
sf org list limits -o <org>
```

### Production Safety
NEVER deploy to production without:
1. Running validation first (--dry-run)
2. Devin explicitly typing "CONFIRM PROD DEPLOY"

---

## Scripts Available
Run from ClaudesHome directory:

### Data Scripts
- `.\scripts\data\query.ps1 -Query "SELECT..." -Org devin1` - Run SOQL query
- `.\scripts\data\export-records.ps1 -Query "SELECT..." -Org devin1` - Export to CSV
- `.\scripts\data\count-records.ps1 -SObject Account -Org devin1` - Quick count
- `.\scripts\data\compare-orgs.ps1 -Query "SELECT..." -Org1 devin1 -Org2 PartialCopy` - Compare data
- `.\scripts\data\bulk-update.ps1 -SObject Account -CsvFile data.csv -Org devin1` - Bulk update

### Debug Scripts
- `.\scripts\debug\tail-logs.ps1 -Org devin1` - Stream debug logs
- `.\scripts\debug\run-apex.ps1 -Code "System.debug('test');" -Org devin1` - Run anonymous Apex
- `.\scripts\debug\check-limits.ps1 -Org devin1` - Check org limits

### Deploy Scripts
- `.\scripts\deploy\quick-deploy.ps1 -Path force-app -Org devin1` - Quick sandbox deploy
- `.\scripts\deploy\deploy-class.ps1 -ClassName MyClass -Org devin1` - Deploy single class
- `.\scripts\deploy\validate-prod.ps1 -Path force-app` - Validate against production
- `.\scripts\deploy\deploy-prod.ps1 -Path force-app` - Deploy to production (requires confirmation)

### Setup Scripts
- `.\scripts\setup\sync-repo.ps1` - Git pull/push helper
- `.\scripts\setup\refresh-auth.ps1 -Org devin1` - Re-authenticate org
- `.\scripts\setup\refresh-auth.ps1 -All` - Check all org connections

### Sync Script
- `.\scripts\sync.ps1` - One-command git sync (pull, commit, push)

---

## Projects Map
See projects/projects.md for where Devin's repos and projects live.
When he references a project, check this file to find the path.

---

## Mobile Access (Terminus + tmux)
Devin connects remotely via Terminus app on his phone through Tailscale.

**WSL Ubuntu has tmux auto-attach configured.** When Devin types `wsl`, he automatically enters a tmux session called "main".

### If Devin connects from mobile:
1. He'll SSH into this PC via Tailscale
2. Type `wsl` to enter Ubuntu + tmux
3. If connection drops, just reconnect and type `wsl` - session is preserved

### Useful tmux commands:
| Command | Action |
|---------|--------|
| `wsl` | Enter Ubuntu + auto-attach tmux |
| `tm` | Same as wsl (shortcut) |
| `Ctrl+b d` | Detach (leave session running) |
| `tmux ls` | List sessions |
| `tmux kill-session -t main` | Kill session (start fresh) |

---

## My Priorities
Devin spends most of his time on:
1. Salesforce Admin & Development
2. Five9 Admin (campaigns, users, ANI management)
3. IT tasks (password resets, general support)
4. Random business tasks

---

## Communication Style
- Keep it brief - Devin's often on his phone
- Don't over-explain
- Just do things when the intent is clear
- Ask for clarification only when genuinely needed

---

## Safety Rules
1. **NEVER deploy to Production without explicit confirmation**
   - Always validate-only first using `validate-prod.ps1`
   - Require Devin to type "CONFIRM PROD DEPLOY" before actual deployment
   - Double-check the org alias before any production operation

2. **Always show what will change before making changes**
   - Preview queries before bulk updates
   - Show deployment components before deploying

3. **Git commit after significant changes**
   - After modifying scripts or context files
   - Before ending a session with changes

4. **Default org for testing is devin1**
   - Unless specified otherwise, use devin1 for queries and tests
   - Always confirm org for destructive operations

---

## Self-Improvement: Expanding ClaudesHome

### Usage Tracking
After each session, briefly note in meta/usage-patterns.md:
- What Devin asked for help with
- Any friction points or missing features
- New tools or workflows used

Keep it minimal - just one line per session:
`[DATE] Session focus: [brief description]`

### Suggesting Improvements
When Claude notices patterns, add ideas to meta/improvement-ideas.md:
- Repeated manual tasks that could be scripted
- Missing SOPs for things Devin does often
- New integrations or tools that would help
- Workflow optimizations

Format:
```
## [DATE] Idea: [Title]
**Observed pattern:** What triggered this idea
**Suggestion:** What to add/change
**Effort:** Low/Medium/High
**Impact:** Low/Medium/High
```

### Weekly Review (Optional)
If Devin asks "how can we improve ClaudesHome" or "any suggestions":
1. Read meta/usage-patterns.md and meta/improvement-ideas.md
2. Summarize top 2-3 high-impact, low-effort improvements
3. Offer to implement any he approves

### Auto-Prompting
After every 5th session (or ~weekly), proactively mention:
"I've noticed some patterns - want to hear a quick idea for improving ClaudesHome?"

Only suggest things that are:
- Simple to implement
- Based on actual observed usage
- Genuinely useful, not feature creep

---

## Common Task Workflows

### "Check the logs"
1. Ask which org (default: devin1)
2. Run: `sf apex tail log -o <org>`
3. Summarize any errors or warnings found

### "Deploy this class"
1. Ask which class and which org
2. If prod:
   - Run validate-only first
   - Show results
   - Require "CONFIRM PROD DEPLOY"
3. If sandbox: deploy directly with tests

### "Run this query"
1. Execute against specified org (default devin1)
2. Display results in readable format
3. Offer to export to CSV if large result set (>50 records)

### "Compare orgs"
1. Ask what to compare (specific object, metadata, data)
2. Run comparison using compare-orgs.ps1
3. Summarize differences clearly

### "Check my limits"
1. Run check-limits.ps1 against specified org
2. Highlight any limits above 75% usage
3. Warn about any limits above 90%

### "Help me debug"
1. Start tailing logs in the appropriate org
2. Ask Devin to reproduce the issue
3. Analyze log output for errors, governor limits, or unexpected behavior

---

## Reference Files
- `context/orgs.md` - Detailed org information and purposes
- `context/current-project.md` - Active work items
- `context/common-queries.md` - Frequently used SOQL
- `context/field-reference.md` - Important objects and fields
- `context/procedures.md` - Step-by-step guides for common tasks
- `context/tools.md` - Tools and access available
- `projects/projects.md` - Map of all repos and projects
