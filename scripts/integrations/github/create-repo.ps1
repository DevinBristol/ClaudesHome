<#
.SYNOPSIS
    Create a new GitHub repository
.EXAMPLE
    .\create-repo.ps1 -Name "my-new-project" -Description "A cool project" -Private
#>

param(
    [Parameter(Mandatory=$true)][string]$Name,
    [Parameter(Mandatory=$false)][string]$Description = "",
    [Parameter(Mandatory=$false)][switch]$Private,
    [Parameter(Mandatory=$false)][switch]$Init
)

# Load environment
. "$PSScriptRoot\..\..\helpers\Load-Env.ps1"

$token = $env:GITHUB_PAT
if (-not $token) {
    Write-Host "Error: GITHUB_PAT not set in .env" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "token $token"
    "Accept" = "application/vnd.github.v3+json"
}

$body = @{
    name = $Name
    description = $Description
    private = $Private.IsPresent
    auto_init = $Init.IsPresent
} | ConvertTo-Json

Write-Host "Creating repository: $Name" -ForegroundColor Cyan

try {
    $repo = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Headers $headers -Method Post -Body $body -ContentType "application/json"

    Write-Host "Repository created!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Name: $($repo.name)" -ForegroundColor White
    Write-Host "  URL: $($repo.html_url)" -ForegroundColor Gray
    Write-Host "  Clone: $($repo.clone_url)" -ForegroundColor Gray
    Write-Host "  Visibility: $(if ($repo.private) { 'Private' } else { 'Public' })" -ForegroundColor Gray
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
