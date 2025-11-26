# Five9 Integration

Scripts for interacting with the Five9 call center API.

## Setup

1. Add your Five9 credentials to `.env`:
   ```
   FIVE9_USERNAME=your-email@domain.com
   FIVE9_PASSWORD=your-password
   FIVE9_DOMAIN=your-domain
   ```

2. Five9 uses a SOAP API. You'll need your domain's API endpoint.

## Available Scripts

- `get-call-stats.ps1` - Get call statistics for a date range
- `list-agents.ps1` - List agents and their status
- `get-campaigns.ps1` - List active campaigns

## API Documentation

Five9 API docs: https://webapps.five9.com/assets/files/for_customers/documentation/apis/

## Common Tasks

### Get today's call stats
```powershell
.\get-call-stats.ps1 -Date (Get-Date)
```

### Check agent availability
```powershell
.\list-agents.ps1 -Status Available
```
