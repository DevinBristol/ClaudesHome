# ClaudesHome - Claude Instructions

## Quick Start
When Devin connects, he may not be in this directory. If he asks for Salesforce help or references ClaudesHome, navigate here first:
```
cd C:\Users\Devin\IdeaProjects\ClaudesHome
```

## Project Location
`C:\Users\Devin\IdeaProjects\ClaudesHome`

## Org Aliases
| Alias | Type | Status | Notes |
|-------|------|--------|-------|
| **prod-jwt** | Production (DevHub) | Connected via JWT | CAREFUL - always confirm before any changes |
| **PartialCopy** | Partial Copy Sandbox | Connected | Safe for testing with production-like data |
| **devin1** | Dev Sandbox | Connected | Primary dev sandbox, safe for experimentation |
| **Devin2** | Dev Sandbox | Connected | Secondary dev sandbox |
| **Devin3** | Dev Sandbox | Connected | Tertiary dev sandbox |
| **Developing** | Sandbox | Connected | Additional sandbox |
| **myDevOrg** | Scratch Org | Connected | Ephemeral dev environment |
| **FullCopy** | Full Copy Sandbox | **Inactive** | Needs re-authentication |

## JWT Authentication
Production uses JWT auth via Connected App "bristol-sf-project".
- Consumer Key and private key stored in ClaudesHome (certs/ folder, gitignored)
- To re-authenticate on a new PC, run: `.\scripts\setup\sf-jwt-auth.ps1`

## Navigation
When Devin says `/home`, `go home`, or `home`, interpret that as:
```
cd C:\Users\Devin\IdeaProjects\ClaudesHome
```

## Mobile Access (Terminus + tmux)
Devin connects remotely via Terminus app on his phone through Tailscale. To maintain persistent sessions that survive connection drops:

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

## Key Commands Reference
```powershell
# Authentication
sf org list                          # See all orgs
sf org login web -a <alias>          # Auth new org
sf org display -o <alias>            # Show org details

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

## Sync Between PCs
Before starting work:
```powershell
cd C:\Users\Devin\IdeaProjects\ClaudesHome
git pull
```

After making changes:
```powershell
.\scripts\setup\sync-repo.ps1
# or manually:
git add -A && git commit -m "description" && git push
```

## Current Project
See `context/current-project.md` for what Devin is actively working on.

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

## Reference Files
- `context/orgs.md` - Detailed org information and purposes
- `context/current-project.md` - Active work items
- `context/common-queries.md` - Frequently used SOQL
- `context/field-reference.md` - Important objects and fields
- `context/procedures.md` - Step-by-step guides for common tasks
