# Standard Procedures

## Deployment Procedures

### Deploy to Sandbox (Standard)
1. Ensure changes are saved and committed locally
2. Run validation:
   ```powershell
   .\scripts\deploy\quick-deploy.ps1 -Path force-app -Org devin1 -NoTests
   ```
3. Test in sandbox
4. If successful, deploy with tests:
   ```powershell
   .\scripts\deploy\quick-deploy.ps1 -Path force-app -Org devin1
   ```

### Deploy to Production
1. **Pre-deployment checklist**:
   - [ ] All unit tests passing in sandbox
   - [ ] Code reviewed
   - [ ] Test cases documented
   - [ ] Rollback plan identified

2. **Validate against production**:
   ```powershell
   .\scripts\deploy\validate-prod.ps1 -Path force-app
   ```

3. **Review validation results**:
   - Check test pass rate
   - Review code coverage
   - Verify components to be deployed

4. **Deploy to production** (only after successful validation):
   ```powershell
   .\scripts\deploy\deploy-prod.ps1 -Path force-app
   ```
   - Type `CONFIRM PROD DEPLOY` when prompted

5. **Post-deployment verification**:
   - Test functionality in production
   - Monitor logs for errors
   - Verify no performance degradation

## Debugging Procedures

### Debug Apex Code
1. Start log tailing:
   ```powershell
   .\scripts\debug\tail-logs.ps1 -Org devin1
   ```

2. In a separate terminal, trigger the code to debug

3. Review logs for:
   - SOQL queries and counts
   - DML operations
   - Governor limit usage
   - Exception details

### Check Governor Limits
```powershell
.\scripts\debug\check-limits.ps1 -Org devin1
```

Review limits above 75% and plan accordingly.

## Data Procedures

### Export Data for Analysis
```powershell
.\scripts\data\export-records.ps1 -Query "SELECT Id, Name, CreatedDate FROM Account WHERE CreatedDate = THIS_MONTH" -Org devin1
```

### Bulk Update Records
1. Prepare CSV file with Id column and fields to update
2. **Always test in sandbox first**:
   ```powershell
   .\scripts\data\bulk-update.ps1 -SObject Account -CsvFile updates.csv -Org devin1
   ```
3. Verify results before running in production

### Compare Data Between Orgs
```powershell
.\scripts\data\compare-orgs.ps1 -Query "SELECT COUNT() FROM Account" -Org1 devin1 -Org2 PartialCopy
```

## Authentication Procedures

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

## Sync Procedures

### Start of Session
```powershell
cd C:\Users\Devin\IdeaProjects\ClaudesHome
git pull
```

### End of Session
```powershell
.\scripts\setup\sync-repo.ps1
```
Or manually:
```powershell
git add -A
git commit -m "Description of changes"
git push
```

### Resolve Sync Conflicts
1. Pull latest changes: `git pull`
2. If conflicts, resolve manually in affected files
3. Stage resolved files: `git add <file>`
4. Commit: `git commit -m "Resolved merge conflict"`
5. Push: `git push`

## Troubleshooting

### "Unable to refresh session" Error
The org authentication has expired. Re-authenticate:
```powershell
sf org login web -a <alias>
```

### "INVALID_SESSION_ID" Error
Same as above - re-authenticate the org.

### Deployment Fails with Test Errors
1. Run tests locally to identify failures:
   ```powershell
   sf apex run test -o devin1 --code-coverage --result-format human
   ```
2. Fix failing tests
3. Re-deploy

### "Insufficient access rights" Error
Check user permissions in the target org. May need:
- API Enabled permission
- Modify All Data (for some operations)
- Author Apex permission (for code deployment)
