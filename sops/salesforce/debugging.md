# Debugging Procedures

## Debug Apex Code
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

## Check Governor Limits
```powershell
.\scripts\debug\check-limits.ps1 -Org devin1
```

Review limits above 75% and plan accordingly.

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
