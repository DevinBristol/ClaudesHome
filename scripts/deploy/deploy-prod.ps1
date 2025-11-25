param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$false)][string]$ProdOrg = "BristolProd"
)

Write-Host "!!! PRODUCTION DEPLOYMENT !!!" -ForegroundColor Red
Write-Host "Path: $Path" -ForegroundColor White
Write-Host "Org: $ProdOrg" -ForegroundColor White
Write-Host ""
Write-Host "This will deploy changes to PRODUCTION." -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "Type 'CONFIRM PROD DEPLOY' to proceed"
if ($confirm -eq 'CONFIRM PROD DEPLOY') {
    Write-Host "Deploying to production..." -ForegroundColor Yellow
    sf project deploy start -d $Path -o $ProdOrg --test-level RunLocalTests

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "Production deployment SUCCESSFUL!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Production deployment FAILED!" -ForegroundColor Red
    }
} else {
    Write-Host "Deployment cancelled. Confirmation text did not match." -ForegroundColor Red
}
