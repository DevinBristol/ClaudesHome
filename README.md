# ClaudesHome

Universal command center for managing tasks, Salesforce development, and procedures across multiple PCs.

## Quick Start

```powershell
home    # Navigate to ClaudesHome
sync    # Pull, commit, push in one command
```

## Structure

```
ClaudesHome/
├── tasks/              # Task management
│   ├── urgent.md       # Do today
│   ├── development.md  # Coding, SF dev
│   ├── administration.md # Admin, IT, Five9
│   ├── ideas.md        # Someday/maybe
│   ├── waiting.md      # Blocked tasks
│   └── done.md         # Completed
├── inbox/
│   └── capture.md      # Quick dump
├── sops/               # Standard Operating Procedures
│   ├── salesforce/
│   ├── five9/
│   └── it/
├── projects/
│   └── projects.md     # Map of repos
├── context/            # Reference info
│   ├── orgs.md         # Salesforce orgs
│   ├── tools.md        # Available tools
│   └── ...
├── scripts/            # Automation
│   ├── data/           # SOQL, exports
│   ├── debug/          # Logs, limits
│   ├── deploy/         # Deployments
│   └── setup/          # Auth, setup
├── meta/               # Self-improvement
│   ├── usage-patterns.md
│   └── improvement-ideas.md
├── notes/              # Meeting notes, etc.
└── CLAUDE.md           # Claude instructions
```

## Task Commands (to Claude)

```
"urgent: [task]"        # Add urgent task
"dev task: [task]"      # Add dev task
"admin task: [task]"    # Add admin task
"idea: [thought]"       # Add to ideas bin
"what's urgent"         # Show urgent tasks
"what's on my plate"    # Summary of all
"done with [task]"      # Mark complete
```

## Salesforce Orgs

| Alias | Type | Notes |
|-------|------|-------|
| prod | Production | JWT auth, BE CAREFUL |
| devin1 | Dev Sandbox | Primary dev |
| Devin2/3 | Dev Sandbox | Secondary |
| uat-jwt | Partial Copy | Testing |

## Mobile Access

SSH via Tailscale, then:
```bash
wsl    # Auto-attaches tmux session
```

## Second PC Setup

```powershell
cd ~\IdeaProjects
git clone https://github.com/DevinBristol/ClaudesHome.git
# Add to PowerShell profile:
# function home { Set-Location "C:\Users\<User>\IdeaProjects\ClaudesHome" }
# function sync { & "C:\Users\<User>\IdeaProjects\ClaudesHome\scripts\sync.ps1" }
```

Then authenticate Salesforce orgs: `sf org login web -a <alias>`
