# ClaudesHome - Claude Instructions

## What Is This
ClaudesHome is Devin's universal command center. From here, you help him manage tasks, look up procedures, work on projects, and handle whatever comes up.

## Project Location
Resolved dynamically from `config/machines.json` based on hostname.

## Path Resolution (Multi-PC Support)

ClaudesHome syncs between multiple PCs with different paths.

### How to resolve paths:
1. Run `hostname` to get current machine name
2. Read `config/machines.json`, find entry for that hostname
3. If not found, check `config/local.json` (local override)
4. Use `projectsRoot` as base path for all projects
5. Use `claudesHome` for ClaudesHome path

### Adding a new PC:
1. Run `hostname` to get machine name
2. Add entry to `config/machines.json`:
```json
"YOUR-HOSTNAME": {
  "name": "Description",
  "projectsRoot": "path/to/IdeaProjects",
  "claudesHome": "path/to/ClaudesHome"
}
```
3. Commit and sync

## Navigation
When Devin says `/home`, `go home`, or `home`:
1. Resolve `claudesHome` path from config
2. `cd` to that path

When Devin says `sync`:
Run `scripts/sync.ps1` from ClaudesHome directory.

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

## Project Navigation

When Devin says "work on [project]" or references a project:
1. Check `projects/projects.md` to find the project name
2. Resolve path: `{projectsRoot from config}/{project name}`
3. Navigate to that path
4. Check if that project has a `CLAUDE.md` - if so, read it for project-specific instructions
5. If no local CLAUDE.md, use context from projects.md description

### Quick Project Shortcuts
- "work on salesforce" / "sf project" -> `bristol-sf-project`
- "check production" / "prod metadata" -> `Production` (read-only)
- "work on swarm" -> `DevinSwarm`
- "ai agent" -> `salesforce-ai-agent`
- "home" -> `ClaudesHome`

### When Working in Another Project
- You're still aware of ClaudesHome context
- Can still manage tasks, check SOPs
- Return with `home` command
- Sync ClaudesHome if you made changes there

---

## Task Management (GitHub Issues)

Tasks sync across PCs via GitHub Issues - no manual sync needed.

### Task Categories (Labels)
| Label | Color | Use for |
|-------|-------|---------|
| **urgent** | Red | Do today, time-sensitive |
| **development** | Blue | Coding, Salesforce dev, technical |
| **administration** | Purple | Admin work, IT, Five9 |
| **ideas** | Yellow | Someday/maybe, the bin |
| **waiting** | Light blue | Blocked on someone |

### Scripts (`scripts/tasks/`)
```powershell
# Add a task
.\scripts\tasks\Add-Task.ps1 "Fix login bug" development
.\scripts\tasks\Add-Task.ps1 "Call Cameron" urgent
.\scripts\tasks\Add-Task.ps1 "Explore AI tools" ideas
.\scripts\tasks\Add-Task.ps1 "Get API key" waiting -WaitingOn "Cameron"

# View tasks
.\scripts\tasks\Get-Tasks.ps1              # Summary of all categories
.\scripts\tasks\Get-Tasks.ps1 urgent       # Just urgent
.\scripts\tasks\Get-Tasks.ps1 -Brief       # Counts only

# Complete a task
.\scripts\tasks\Complete-Task.ps1 42
.\scripts\tasks\Complete-Task.ps1 42 -Comment "Deployed"

# Move between categories
.\scripts\tasks\Move-Task.ps1 42 urgent    # Make it urgent

# View details
.\scripts\tasks\Show-Task.ps1 42
```

### Quick gh Commands
```powershell
gh issue list --label urgent              # List urgent tasks
gh issue create --title "X" --label dev   # Quick add
gh issue close 42                         # Complete
gh issue view 42                          # Details
```

### Natural Language Mappings
When Devin says -> Do this:
- "add to my list" / "remind me to" -> `Add-Task.ps1`
- "what's on my plate" / "my tasks" -> `Get-Tasks.ps1`
- "what's urgent" -> `Get-Tasks.ps1 urgent`
- "dev tasks" -> `Get-Tasks.ps1 development`
- "done with #42" -> `Complete-Task.ps1 42`
- "make #42 urgent" -> `Move-Task.ps1 42 urgent`
- "waiting on X for Y" -> `Add-Task.ps1 "Y" waiting -WaitingOn "X"`

Category hints:
- "urgent", "asap", "today", "fire" -> urgent
- "build", "code", "fix bug", "deploy", "apex" -> development
- "password reset", "Five9", "admin", "IT" -> administration
- "idea", "maybe", "someday", "potential" -> ideas
- "waiting on", "blocked", "need X from Y" -> waiting

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
- `.\scripts\setup\refresh-auth.ps1 -Org devin1` - Re-authenticate org
- `.\scripts\setup\refresh-auth.ps1 -All` - Check all org connections
- `.\scripts\sync.ps1` - One-command git sync (pull, commit, push)

---

## Projects Map
See projects/projects.md for where Devin's repos and projects live.
When he references a project, check this file to find the path.

---

## Mobile Access (Terminus + tmux)
Devin connects remotely via Terminus app on his phone through Tailscale.

**WSL Ubuntu has tmux auto-attach configured.** SSH directly into WSL on port 2222 and tmux auto-attaches.

### SSH Commands for Terminus

| Target | Command |
|--------|---------|
| **Home PC WSL** | `ssh -p 2222 devin@100.125.164.128` |
| **Work PC Windows** | `ssh -p 22 devin@100.110.31.58` |
| **Work PC WSL** | `ssh -p 2222 devin@100.110.31.58` |

### If connection drops:
Just reconnect - tmux session is preserved. You'll auto-attach to your existing session.

### Useful tmux commands:
| Command | Action |
|---------|--------|
| `Ctrl+b d` | Detach (leave session running) |
| `tmux ls` | List sessions |
| `tmux kill-session -t main` | Kill session (start fresh) |

---

## Cross-PC Remote Repair

If one PC has issues (disk full, WSL broken, SSH down), Claude can SSH from the other PC to fix it.

### PC Connection Info (stored in Doppler)

| PC | Tailscale IP | Windows SSH | WSL SSH |
|----|--------------|-------------|---------|
| **Work PC** (desktop-jdd0eek) | `WORKPC_TAILSCALE_IP` | Port 22, user `devin`, pass `WORKPC_WIN_SSH_PASS` | Port 2222, user `devin`, pass `WORKPC_WSL_PASSWORD` |
| **Home PC** (Devin24) | `HOMEPC_TAILSCALE_IP` | N/A | Port 2222, user `devin`, pass `HOMEPC_WSL_SSH_PASS` |

### Remote Repair Commands

**From any PC with WSL, SSH to another PC:**
```bash
# To Work PC (Windows CMD)
sshpass -p "$(doppler secrets get WORKPC_WIN_SSH_PASS --plain)" ssh -p 22 devin@$(doppler secrets get WORKPC_TAILSCALE_IP --plain) "command"

# To Work PC (WSL)
sshpass -p "$(doppler secrets get WORKPC_WSL_PASSWORD --plain)" ssh -p 2222 devin@$(doppler secrets get WORKPC_TAILSCALE_IP --plain) "command"

# To Home PC (WSL)
sshpass -p "$(doppler secrets get HOMEPC_WSL_SSH_PASS --plain)" ssh -p 2222 devin@$(doppler secrets get HOMEPC_TAILSCALE_IP --plain) "command"
```

### Common Remote Fixes

**Disk full on remote PC:**
```bash
# Clean temp files (via Windows SSH)
ssh ... "del /q/f/s %TEMP%\*"
# Check free space
ssh ... "fsutil volume diskfree C:"
```

**WSL won't start:**
```bash
ssh ... "wsl --shutdown"
ssh ... "wsl --list -v"
ssh ... "wsl -d Ubuntu"
```

**SSH service down in WSL:**
```bash
ssh ... "wsl -d Ubuntu -u root -- service ssh start"
```

### Claude Authentication
Anthropic API key stored in Doppler as `ANTHROPIC_API_KEY` for re-authentication when needed.

### Claude Credentials Sync (Windows ↔ WSL)
Claude CLI stores credentials in `~/.claude/.credentials.json`. Windows and WSL have separate home directories, so credentials must be synced:

```bash
# Copy Windows Claude creds to WSL (run in WSL)
cp /mnt/c/Users/Devin/.claude/.credentials.json ~/.claude/
```

This is needed when:
- Happy coder or other tools in WSL need Claude access
- Claude was authenticated in Windows but not WSL

### Happy Coder Setup (Work PC WSL)
Happy coder is installed globally in WSL: `/usr/lib/node_modules/happy-coder`

**Config location:** `~/.happy/`
- `access.key` - Happy cloud authentication
- `settings.json` - Onboarding status, machine ID
- `daemon.state.json` - Daemon process info

**Commands:**
```bash
happy                    # Start interactive session
happy -p "prompt"        # Print mode (non-interactive)
happy auth status        # Check authentication
happy connect claude     # Connect Anthropic API key
happy daemon start/stop  # Manage background daemon
happy doctor             # Diagnostics
```

### Remote OAuth Authentication Workaround
Some tools (happy, claude setup-token) need OAuth which redirects to `localhost`. To authenticate remotely:

**From the PC with a browser (e.g., Home PC authenticating Work PC):**
```bash
# 1. Create SSH tunnel for OAuth callback
wsl -d Ubuntu-24.04 -- sshpass -p 'bristol2024' ssh -L 54545:localhost:54545 -p 2222 devin@100.110.31.58 -f -N

# 2. Add Windows port forward to WSL
netsh interface portproxy add v4tov4 listenport=54545 listenaddress=127.0.0.1 connectport=54545 connectaddress=<WSL_IP>

# 3. Run the OAuth command on remote PC (via SSH)
ssh ... "happy connect claude"

# 4. Open the OAuth URL in local browser - callback routes through tunnel

# 5. Clean up port forward after
netsh interface portproxy delete v4tov4 listenport=54545 listenaddress=127.0.0.1
```

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

### Mobile Sessions (Terminus)
When Devin is on mobile and a response is long/hard to read:
- He may say "email that", "send that to me", or "email me that"
- Use `Send-ClaudeResponse` to email the response to him
- Example: `Send-ClaudeResponse -Content $previousResponse -Subject "Query Results"`
- Requires MS365 connection and DEVIN_EMAIL in Doppler

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

## System Administration

ClaudesHome is configured for cross-platform system administration with unified access to Five9, Microsoft 365, Salesforce, Company Cam, and Google Workspace.

### Secrets Management
All API credentials are stored in **Doppler** (project: `claudeshome`, config: `prd`).
- Never ask for or display passwords from Doppler
- To view secrets: `doppler secrets` (from ClaudesHome directory)
- To set a secret: `doppler secrets set SECRET_NAME="value"`

### Loading the Admin Module
```powershell
Import-Module "C:\Users\Devin\IdeaProjects\ClaudesHome\scripts\admin\ClaudesHomeAdmin.psd1"
```

### Quick Commands

**Connect to platforms:**
```powershell
Connect-AllPlatforms                    # All platforms
Connect-AllPlatforms -Platforms @("Five9", "Salesforce")  # Specific ones
Get-ConnectionStatus                    # Check what's connected
```

**Unified User Management:**
```powershell
# Create user across platforms
New-UniversalUser -FirstName "John" -LastName "Doe" -Email "john@company.com" `
    -Platforms @("MS365", "Google", "Salesforce")

# Create user including Five9 agent
New-UniversalUser -FirstName "Jane" -LastName "Smith" -Email "jane@company.com" -IsFive9Agent

# Disable user everywhere (offboarding)
Disable-UniversalUser -Email "john@company.com"

# Reset passwords across platforms
Reset-UniversalPassword -Email "john@company.com" -Platforms @("MS365", "Google")
Reset-UniversalPassword -Email "john@company.com" -SamePassword  # Use same password everywhere
```

**Five9 Specific:**
```powershell
Get-Five9Users
New-Five9Agent -FirstName "Susan" -LastName "Smith" -Email "susan@company.com"
Reset-Five9UserPassword -Username "susan@company.com"
Disable-Five9User -Username "susan@company.com"

# Campaigns
Get-Five9Campaigns
Start-Five9Campaign -Name "Outbound Sales"
Stop-Five9Campaign -Name "Outbound Sales"

# ANI/DNIS Management
Get-Five9ANIs
Set-Five9ANIStatus -ANI "8005551234" -Campaign "Sales" -Status Active

# Skills
Get-Five9Skills
Add-Five9UserSkill -Username "susan@company.com" -SkillName "Sales"
```

**Microsoft 365:**
```powershell
Get-MS365Users
Get-MS365User -UserPrincipalName "john@company.com"
New-MS365User -DisplayName "John Doe" -UserPrincipalName "john@company.com" -MailNickname "johnd"
Reset-MS365UserPassword -UserPrincipalName "john@company.com"
Disable-MS365User -UserPrincipalName "john@company.com"

# Groups
Get-MS365Groups
Get-MS365GroupMembers -GroupId "group-id"
Add-MS365GroupMember -GroupId "group-id" -UserId "user-id"
```

**Salesforce:**
```powershell
Get-SalesforceUsers -ActiveOnly
Get-SalesforceUser -Email "john@company.com"
Invoke-SalesforceQuery -Query "SELECT Id, Name FROM Account LIMIT 10"
Get-SalesforceProfiles
Get-SalesforceOrgLimits  # Shows limits above 75% usage
```

**Company Cam (Hybrid - Reads direct, Writes via Salesforce):**
```powershell
# READ operations (direct API)
Get-CompanyCamProjects
Get-CompanyCamProject -ProjectId "abc123"
Search-CompanyCamProjects -Query "Main St"
Get-CompanyCamPhotos -ProjectId "abc123"
Get-CompanyCamComments -PhotoId "xyz789"
Get-CompanyCamUsers

# WRITE operations (via Salesforce proxy - requires CompanyCamProxy Apex class)
New-CompanyCamProject -Name "123 Main St Roof" -StreetAddress "123 Main St" -City "Lincoln" -State "NE"
Add-CompanyCamComment -PhotoId "abc123" -Content "Needs follow-up"
Update-CompanyCamProject -ProjectId "abc123" -Status "completed"

# Data reconciliation
Sync-CompanyCamData -SalesforceObjectName "CompanyCam_Project__c" -ExternalIdField "CC_Project_Id__c" -DryRun
```

**Google Workspace:**
```powershell
Get-GoogleUsers
Get-GoogleUser -User "john@company.com"
New-GoogleUser -PrimaryEmail "john@company.com" -GivenName "John" -FamilyName "Doe"
Reset-GoogleUserPassword -User "john@company.com"
Suspend-GoogleUser -User "john@company.com"
Resume-GoogleUser -User "john@company.com"

# Groups
Get-GoogleGroups
Get-GoogleGroupMembers -Group "sales@company.com"
Add-GoogleGroupMember -GroupEmail "sales@company.com" -MemberEmail "john@company.com" -Role "MEMBER"

# Org Units
Get-GoogleOrgUnits
Move-GoogleUserToOU -User "john@company.com" -OrgUnitPath "/Sales"
```

### Natural Language Mappings
When Devin says -> Do this:
- "reset [name]'s password" -> Reset-UniversalPassword for that user
- "disable [name]" or "offboard [name]" -> Disable-UniversalUser
- "new employee [name]" -> New-UniversalUser
- "Five9 password reset for [name]" -> Reset-Five9UserPassword
- "activate ANI [number]" -> Set-Five9ANIStatus -Status Active
- "start [campaign] campaign" -> Start-Five9Campaign
- "Company Cam project for [address]" -> New-CompanyCamProject
- "add comment to photo" -> Add-CompanyCamComment
- "show Company Cam projects" -> Get-CompanyCamProjects
- "sync Company Cam data" -> Sync-CompanyCamData

### Platform Setup Status
To verify all integrations are configured:
```powershell
.\scripts\setup\verify-setup.ps1
```

### Configuring Credentials
Each platform needs credentials in Doppler:

**Five9:**
- `FIVE9_USERNAME` - Admin email
- `FIVE9_PASSWORD` - Admin password
- `FIVE9_DATACENTER` - US, EU, etc.

**Microsoft 365:**
- `MS365_TENANT_ID` - Azure AD tenant ID
- `MS365_CLIENT_ID` - App registration client ID
- `MS365_CLIENT_SECRET` - Client secret (or use cert)
- `MS365_CERT_THUMBPRINT` - Certificate thumbprint (optional)

**Salesforce:**
- `SF_CLIENT_ID` - Connected App consumer key
- `SF_USERNAME` - Admin username
- `SF_INSTANCE_URL` - Instance URL
- `SF_PRIVATE_KEY_PATH` - Path to JWT private key

**Company Cam:**
- `COMPANYCAM_ACCESS_TOKEN` - Read-only API token
- `COMPANYCAM_MODE` - Set to "hybrid"

**Google Workspace:**
- `GOOGLE_SERVICE_ACCOUNT_EMAIL` - Service account email
- `GOOGLE_ADMIN_EMAIL` - Admin to impersonate
- `GOOGLE_CREDENTIALS_PATH` - Path to service account JSON
- `GOOGLE_CUSTOMER_ID` - Customer ID (or "my_customer")

---

## Reference Files
- `context/orgs.md` - Detailed org information and purposes
- `context/current-project.md` - Active work items
- `context/common-queries.md` - Frequently used SOQL
- `context/field-reference.md` - Important objects and fields
- `context/tools.md` - Tools and access available
- `projects/projects.md` - Map of all repos and projects
- `sops/` - Standard operating procedures (salesforce, five9, it)
- `scripts/admin/` - Admin module and platform-specific scripts
- `scripts/auth/` - Authentication/connection scripts
