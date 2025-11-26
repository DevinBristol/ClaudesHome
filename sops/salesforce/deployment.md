# Deployment Procedures

## Deploy to Sandbox (Standard)
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

## Deploy to Production
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
