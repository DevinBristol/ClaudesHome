<#
.SYNOPSIS
    Authenticate to Salesforce using JWT Bearer Flow
.DESCRIPTION
    Uses the Connected App (bristol-sf-project) and private key to
    authenticate to Salesforce production without a browser.
.EXAMPLE
    .\sf-jwt-auth.ps1
    .\sf-jwt-auth.ps1 -Alias prod-jwt
#>

param(
    [Parameter(Mandatory=$false)][string]$Alias = "prod-jwt"
)

# Load environment
. "$PSScriptRoot\..\helpers\Load-Env.ps1"

$clientId = $env:SF_CLIENT_ID
$username = $env:SF_USERNAME
$instanceUrl = $env:SF_INSTANCE_URL
$keyFile = $env:SF_KEY_FILE

# Resolve key file path relative to ClaudesHome
$claudesHome = $PSScriptRoot | Split-Path | Split-Path
$keyPath = Join-Path $claudesHome $keyFile

Write-Host "=== Salesforce JWT Authentication ===" -ForegroundColor Cyan
Write-Host ""

# Validate required settings
if (-not $clientId) {
    Write-Host "Error: SF_CLIENT_ID not set in .env" -ForegroundColor Red
    exit 1
}

if (-not $username) {
    Write-Host "Error: SF_USERNAME not set in .env" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $keyPath)) {
    Write-Host "Error: Private key not found at $keyPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "The server.key file needs to be copied to this machine." -ForegroundColor Yellow
    Write-Host "Copy it from another authorized machine to: $keyPath" -ForegroundColor Gray
    exit 1
}

Write-Host "Client ID: $($clientId.Substring(0, 20))..." -ForegroundColor Gray
Write-Host "Username: $username" -ForegroundColor Gray
Write-Host "Key File: $keyPath" -ForegroundColor Gray
Write-Host "Alias: $Alias" -ForegroundColor Gray
Write-Host ""

Write-Host "Authenticating..." -ForegroundColor Yellow

try {
    # Use sf CLI to authenticate with JWT
    $result = sf org login jwt `
        --client-id $clientId `
        --jwt-key-file $keyPath `
        --username $username `
        --alias $Alias `
        --set-default-dev-hub `
        --json 2>&1

    $json = $result | ConvertFrom-Json

    if ($json.status -eq 0) {
        Write-Host ""
        Write-Host "Authentication successful!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Org Details:" -ForegroundColor Cyan
        Write-Host "  Alias: $Alias" -ForegroundColor White
        Write-Host "  Username: $($json.result.username)" -ForegroundColor White
        Write-Host "  Org ID: $($json.result.orgId)" -ForegroundColor White
        Write-Host "  Instance URL: $($json.result.instanceUrl)" -ForegroundColor White
        Write-Host ""
        Write-Host "You can now use: sf data query -q ""SELECT..."" -o $Alias" -ForegroundColor Gray
    } else {
        Write-Host ""
        Write-Host "Authentication failed!" -ForegroundColor Red
        Write-Host $json.message -ForegroundColor Red
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
