<#
.SYNOPSIS
    List CompanyCam projects
.DESCRIPTION
    Retrieves recent projects from CompanyCam.
    Requires COMPANYCAM_API_KEY in .env
.EXAMPLE
    .\list-projects.ps1
    .\list-projects.ps1 -Limit 50
    .\list-projects.ps1 -Status active
#>

param(
    [Parameter(Mandatory=$false)][int]$Limit = 20,
    [Parameter(Mandatory=$false)][string]$Status = ""
)

# Load environment
. "$PSScriptRoot\..\..\helpers\Load-Env.ps1"

$apiKey = $env:COMPANYCAM_API_KEY

if (-not $apiKey) {
    Write-Host "Error: COMPANYCAM_API_KEY not set in .env" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $apiKey"
    "Accept" = "application/json"
}

$url = "https://api.companycam.com/v2/projects?per_page=$Limit"
if ($Status) { $url += "&status=$Status" }

Write-Host "CompanyCam Projects" -ForegroundColor Cyan
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get

    foreach ($project in $response) {
        Write-Host "  $($project.name)" -ForegroundColor White
        if ($project.address) {
            $addr = $project.address
            Write-Host "    $($addr.street_address_1), $($addr.city), $($addr.state)" -ForegroundColor Gray
        }
        Write-Host "    ID: $($project.id)" -ForegroundColor DarkGray
        Write-Host ""
    }

    Write-Host "Total: $($response.Count) projects" -ForegroundColor Cyan
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
