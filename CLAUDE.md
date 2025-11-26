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
