# Data Procedures

## Export Data for Analysis
```powershell
.\scripts\data\export-records.ps1 -Query "SELECT Id, Name, CreatedDate FROM Account WHERE CreatedDate = THIS_MONTH" -Org devin1
```

## Bulk Update Records
1. Prepare CSV file with Id column and fields to update
2. **Always test in sandbox first**:
   ```powershell
   .\scripts\data\bulk-update.ps1 -SObject Account -CsvFile updates.csv -Org devin1
   ```
3. Verify results before running in production

## Compare Data Between Orgs
```powershell
.\scripts\data\compare-orgs.ps1 -Query "SELECT COUNT() FROM Account" -Org1 devin1 -Org2 PartialCopy
```

## Authentication

### Re-authenticate Single Org
```powershell
.\scripts\setup\refresh-auth.ps1 -Org FullCopy
```

### Check All Org Connections
```powershell
.\scripts\setup\refresh-auth.ps1 -All
```

### Add New Org
```powershell
sf org login web -a NewOrgAlias
```
Then update `context/orgs.md` with the new org details.
