param(
    [Parameter(Mandatory=$false)][string]$Org = "devin1",
    [Parameter(Mandatory=$false)][string]$DebugLevel = "SFDC_DevConsole"
)

Write-Host "Tailing logs for $Org (Ctrl+C to stop)..." -ForegroundColor Cyan
Write-Host "Debug Level: $DebugLevel" -ForegroundColor Gray
Write-Host ""

sf apex tail log -o $Org --color
