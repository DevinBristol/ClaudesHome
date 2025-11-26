param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$false)][string]$Org = "devin1",
    [Parameter(Mandatory=$false)][switch]$NoTests
)

Write-Host "=== Quick Deploy ===" -ForegroundColor Yellow
Write-Host "Path: $Path" -ForegroundColor White
Write-Host "Org: $Org" -ForegroundColor White
Write-Host ""

$testLevel = if ($NoTests) { "NoTestRun" } else { "RunLocalTests" }

if ($NoTests) {
    Write-Host "Warning: Running without tests" -ForegroundColor Yellow
}

sf project deploy start -d $Path -o $Org --test-level $testLevel

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Deployment successful!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Deployment failed." -ForegroundColor Red
}
