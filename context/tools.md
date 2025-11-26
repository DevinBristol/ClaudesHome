# Tools & Access

## CLI Tools
- Salesforce CLI (sf): v2.112.6 installed
- Git: Installed
- Node.js: v20.12.2
- PowerShell: Default shell on Windows
- Doppler CLI: Secrets management

## Authenticated Services
- Salesforce orgs: prod, devin1, Devin2, Devin3, Developing, myDevOrg, uat-jwt
- GitHub: DevinBristol (ClaudesHome repo)

## API Integrations (via Admin Module)
Load with: `Import-Module "C:\Users\Devin\IdeaProjects\ClaudesHome\scripts\admin\ClaudesHomeAdmin.psd1"`

| Platform | Auth Method | Capabilities |
|----------|-------------|--------------|
| **Salesforce** | JWT Bearer | Full admin (users, data, deploy) |
| **Microsoft 365** | App Registration | User/group management, licenses |
| **Google Workspace** | Service Account | User/group management |
| **Five9** | Username/Password | User/campaign/ANI management |
| **Company Cam** | Hybrid (API reads, SF writes) | Projects, photos, comments |

## Secrets
All API credentials stored in **Doppler** (project: `claudeshome`, config: `prd`)

## Quick Admin Commands
```powershell
Connect-AllPlatforms                    # Connect all platforms
Get-ConnectionStatus                    # Check connections
New-UniversalUser -FirstName "X" -LastName "Y" -Email "x@co.com" -Platforms @("MS365","Google")
Disable-UniversalUser -Email "x@co.com"  # Offboarding
Reset-UniversalPassword -Email "x@co.com" -Platforms @("MS365")
```
