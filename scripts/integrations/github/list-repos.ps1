<#
.SYNOPSIS
    List your GitHub repositories
.EXAMPLE
    .\list-repos.ps1
    .\list-repos.ps1 -Limit 10
#>

param(
    [Parameter(Mandatory=$false)][int]$Limit = 30,
    [Parameter(Mandatory=$false)][switch]$Private,
    [Parameter(Mandatory=$false)][switch]$Public
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

$url = "https://api.github.com/user/repos?per_page=$Limit&sort=updated"

if ($Private) { $url += "&type=private" }
elseif ($Public) { $url += "&type=public" }

try {
    $repos = Invoke-RestMethod -Uri $url -Headers $headers -Method Get

    Write-Host "Your GitHub Repositories:" -ForegroundColor Cyan
    Write-Host ""

    foreach ($repo in $repos) {
        $visibility = if ($repo.private) { "[Private]" } else { "[Public]" }
        $color = if ($repo.private) { "Yellow" } else { "Green" }

        Write-Host "  $($repo.name) " -NoNewline -ForegroundColor White
        Write-Host $visibility -ForegroundColor $color
        Write-Host "    $($repo.html_url)" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "Total: $($repos.Count) repositories" -ForegroundColor Cyan
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
