param(
    [string]$Message = "Sync from $(hostname) at $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
)

$claudesHome = $PSScriptRoot | Split-Path

Push-Location $claudesHome

Write-Host "Pulling latest..." -ForegroundColor Cyan
git pull

$status = git status --porcelain
if ($status) {
    Write-Host "Changes detected. Committing..." -ForegroundColor Yellow
    git add -A
    git commit -m $Message
    Write-Host "Pushing..." -ForegroundColor Cyan
    git push
    Write-Host "Synced!" -ForegroundColor Green
} else {
    Write-Host "No local changes. Already in sync." -ForegroundColor Green
}

Pop-Location
