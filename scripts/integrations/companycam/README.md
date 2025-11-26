# CompanyCam Integration

Scripts for interacting with the CompanyCam API for photo/project management.

## Setup

1. Get your API key from CompanyCam dashboard
2. Add to `.env`:
   ```
   COMPANYCAM_API_KEY=your-api-key
   COMPANYCAM_COMPANY_ID=your-company-id
   ```

## Available Scripts

- `list-projects.ps1` - List recent projects
- `get-photos.ps1` - Get photos for a project
- `search-projects.ps1` - Search projects by name/address

## API Documentation

CompanyCam API: https://docs.companycam.com/

## Common Tasks

### List recent projects
```powershell
.\list-projects.ps1 -Limit 20
```

### Get photos for a project
```powershell
.\get-photos.ps1 -ProjectId "abc123"
```

### Search for a project
```powershell
.\search-projects.ps1 -Query "123 Main St"
```
