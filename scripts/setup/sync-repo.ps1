param(
    [Parameter(Mandatory=$false)][string]$Message = "Update from $env:COMPUTERNAME"
)

$claudesHome = $PSScriptRoot | Split-Path | Split-Path

Push-Location $claudesHome

Write-Host "=== ClaudesHome Sync ===" -ForegroundColor Yellow
Write-Host "Location: $claudesHome" -ForegroundColor Gray
Write-Host ""

Write-Host "Pulling latest changes..." -ForegroundColor Cyan
git pull

$status = git status --porcelain
if ($status) {
    Write-Host ""
    Write-Host "Local changes detected:" -ForegroundColor Yellow
    git status --short
    Write-Host ""

    $commit = Read-Host "Commit and push these changes? (y/n)"
    if ($commit -eq 'y') {
        $customMsg = Read-Host "Commit message (Enter for default: '$Message')"
        if ($customMsg) { $Message = $customMsg }

        git add -A
        git commit -m $Message
        Write-Host "Pushing..." -ForegroundColor Cyan
        git push
        Write-Host "Sync complete!" -ForegroundColor Green
    } else {
        Write-Host "Changes not committed." -ForegroundColor Yellow
    }
} else {
    Write-Host "No local changes to push." -ForegroundColor Green
}

Pop-Location
