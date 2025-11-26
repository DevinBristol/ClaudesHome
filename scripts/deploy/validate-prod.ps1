param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$false)][string]$ProdOrg = "prod"
)

Write-Host "=== PRODUCTION VALIDATION ===" -ForegroundColor Yellow
Write-Host "Path: $Path" -ForegroundColor White
Write-Host "Org: $ProdOrg" -ForegroundColor White
Write-Host ""
Write-Host "This is a CHECK-ONLY deployment (no changes will be made)" -ForegroundColor Cyan
Write-Host ""

$confirm = Read-Host "Proceed with validation? (y/n)"
if ($confirm -eq 'y') {
    sf project deploy start -d $Path -o $ProdOrg --dry-run --test-level RunLocalTests

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "Validation PASSED - Ready to deploy to production" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Validation FAILED - Review errors before deploying" -ForegroundColor Red
    }
} else {
    Write-Host "Validation cancelled." -ForegroundColor Red
}
