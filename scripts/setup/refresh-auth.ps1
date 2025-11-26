param(
    [Parameter(Mandatory=$false)][string]$Org,
    [Parameter(Mandatory=$false)][switch]$All
)

Write-Host "=== Refresh Org Authentication ===" -ForegroundColor Yellow

if ($All) {
    Write-Host "Refreshing all org connections..." -ForegroundColor Cyan

    $orgs = sf org list --json | ConvertFrom-Json

    foreach ($nonScratch in $orgs.result.nonScratchOrgs) {
        Write-Host "Checking $($nonScratch.alias)..." -NoNewline

        # Try to run a simple command to check connection
        $result = sf org display -o $nonScratch.alias --json 2>&1 | ConvertFrom-Json

        if ($result.status -eq 0) {
            Write-Host " Connected" -ForegroundColor Green
        } else {
            Write-Host " Needs re-auth" -ForegroundColor Yellow
            $reauth = Read-Host "Re-authenticate $($nonScratch.alias)? (y/n)"
            if ($reauth -eq 'y') {
                sf org login web -a $nonScratch.alias
            }
        }
    }
} elseif ($Org) {
    Write-Host "Re-authenticating $Org..." -ForegroundColor Cyan
    sf org login web -a $Org
} else {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\refresh-auth.ps1 -Org <alias>    # Re-auth specific org" -ForegroundColor Gray
    Write-Host "  .\refresh-auth.ps1 -All            # Check all orgs" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Current orgs:" -ForegroundColor Cyan
    sf org list
}
