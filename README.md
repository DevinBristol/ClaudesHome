# ClaudesHome

A synchronized Salesforce development environment designed to work across multiple PCs with Claude CLI assistance.

## Quick Start

```powershell
# Navigate to ClaudesHome
home  # (PowerShell alias)

# Or directly
cd C:\Users\Devin\IdeaProjects\ClaudesHome

# Sync before starting
.\scripts\setup\sync-repo.ps1
```

## Structure

```
ClaudesHome/
├── scripts/
│   ├── data/           # Data export, query, bulk operations
│   ├── debug/          # Log tailing, anonymous Apex, limits
│   ├── deploy/         # Sandbox and production deployments
│   └── setup/          # Auth refresh, repo sync
├── context/
│   ├── orgs.md         # Org aliases and details
│   ├── current-project.md
│   ├── common-queries.md
│   ├── field-reference.md
│   └── procedures.md
├── logs/               # Deployment logs (gitignored)
├── temp/               # Temporary files (gitignored)
├── CLAUDE.md           # Instructions for Claude
└── README.md
```

## Common Commands

### Data
```powershell
.\scripts\data\query.ps1 -Query "SELECT Id, Name FROM Account LIMIT 10" -Org devin1
.\scripts\data\count-records.ps1 -SObject Account -Org devin1
.\scripts\data\export-records.ps1 -Query "SELECT..." -Org devin1
```

### Debugging
```powershell
.\scripts\debug\tail-logs.ps1 -Org devin1
.\scripts\debug\run-apex.ps1 -Code "System.debug('test');" -Org devin1
.\scripts\debug\check-limits.ps1 -Org devin1
```

### Deployment
```powershell
.\scripts\deploy\quick-deploy.ps1 -Path force-app -Org devin1
.\scripts\deploy\validate-prod.ps1 -Path force-app
.\scripts\deploy\deploy-prod.ps1 -Path force-app  # Requires confirmation
```

### Setup
```powershell
.\scripts\setup\refresh-auth.ps1 -Org devin1
.\scripts\setup\sync-repo.ps1
```

## Org Aliases

| Alias | Type | Use For |
|-------|------|---------|
| BristolProd | Production | Final deployments only |
| PartialCopy | Partial Copy | Testing with prod-like data |
| devin1 | Dev Sandbox | Primary development |
| Devin2/3 | Dev Sandbox | Secondary development |

## Setting Up on New PC

1. Clone the repo:
   ```powershell
   cd C:\Users\<YourUser>\IdeaProjects
   git clone https://github.com/DevinBristol/ClaudesHome.git
   ```

2. Add `home` alias to PowerShell profile:
   ```powershell
   notepad $PROFILE
   # Add: function home { cd "C:\Users\<YourUser>\IdeaProjects\ClaudesHome" }
   ```

3. Authenticate Salesforce orgs:
   ```powershell
   sf org login web -a BristolProd
   sf org login web -a devin1
   # etc.
   ```

## License

Private repository - personal use only.
