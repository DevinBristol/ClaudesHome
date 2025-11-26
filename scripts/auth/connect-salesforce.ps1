<#
.SYNOPSIS
    Authenticates to Salesforce using JWT Bearer Flow via Doppler secrets
#>

# Auto-detect Doppler path
$script:DopplerExe = (Get-Command doppler -ErrorAction SilentlyContinue).Source
if (-not $script:DopplerExe) {
    $wingetPath = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages"
    $script:DopplerExe = Get-ChildItem $wingetPath -Filter "doppler.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $script:DopplerExe) { $script:DopplerExe = 'doppler' }

function Get-DopplerSecret {
    param([Parameter(Mandatory)][string]$Name)
    $value = & $script:DopplerExe secrets get $Name --plain 2>$null
    return $value
}

function Connect-Salesforce {
    param(
        [string]$Alias = "prod",
        [switch]$Force
    )

    if ($global:SalesforceConnected -and $global:SalesforceAlias -eq $Alias -and -not $Force) {
        Write-Host "Already connected to Salesforce ($Alias). Use -Force to reconnect." -ForegroundColor Yellow
        return
    }

    $clientId = Get-DopplerSecret -Name "SF_CLIENT_ID"
    $username = Get-DopplerSecret -Name "SF_USERNAME"
    $instanceUrl = Get-DopplerSecret -Name "SF_INSTANCE_URL"
    $keyPath = Get-DopplerSecret -Name "SF_PRIVATE_KEY_PATH"

    # Validate
    if (-not $clientId -or $clientId -eq "CHANGE_ME") {
        throw "Salesforce client ID not configured in Doppler. Run: doppler secrets set SF_CLIENT_ID='your-consumer-key'"
    }

    if (-not $username -or $username -eq "CHANGE_ME") {
        throw "Salesforce username not configured in Doppler. Run: doppler secrets set SF_USERNAME='your-username'"
    }

    # If no path in Doppler, try default location
    if (-not $keyPath -or $keyPath -eq "") {
        $claudesHome = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
        $keyPath = Join-Path $claudesHome "certs\server.key"
    }

    if (-not (Test-Path $keyPath)) {
        throw "Salesforce private key not found at: $keyPath. Set SF_PRIVATE_KEY_PATH in Doppler or copy key to certs/server.key"
    }

    try {
        # Use sf CLI for JWT auth
        $result = sf org login jwt `
            --client-id $clientId `
            --jwt-key-file $keyPath `
            --username $username `
            --alias $Alias `
            --instance-url $instanceUrl `
            --json 2>&1

        $json = $result | ConvertFrom-Json

        if ($json.status -eq 0) {
            $global:SalesforceConnected = $true
            $global:SalesforceAlias = $Alias
            Write-Host "Connected to Salesforce as $username (alias: $Alias)" -ForegroundColor Green
        } else {
            throw $json.message
        }
    }
    catch {
        $global:SalesforceConnected = $false
        throw "Failed to connect to Salesforce: $_"
    }
}

function Get-SalesforceAccessToken {
    param([string]$Alias = $global:SalesforceAlias)

    if (-not $Alias) { $Alias = "prod" }

    $orgInfo = sf org display --target-org $Alias --json 2>&1 | ConvertFrom-Json
    if ($orgInfo.status -ne 0) {
        throw "Failed to get org info: $($orgInfo.message)"
    }
    return $orgInfo.result.accessToken
}

function Get-SalesforceInstanceUrl {
    param([string]$Alias = $global:SalesforceAlias)

    if (-not $Alias) { $Alias = "prod" }

    $orgInfo = sf org display --target-org $Alias --json 2>&1 | ConvertFrom-Json
    return $orgInfo.result.instanceUrl
}

function Invoke-SalesforceAPI {
    param(
        [Parameter(Mandatory)][string]$Endpoint,
        [string]$Method = "GET",
        [object]$Body,
        [string]$Alias = $global:SalesforceAlias
    )

    if (-not $Alias) { $Alias = "prod" }

    $token = Get-SalesforceAccessToken -Alias $Alias
    $instanceUrl = Get-SalesforceInstanceUrl -Alias $Alias

    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }

    $uri = "$instanceUrl/services/data/v59.0/$Endpoint"

    $params = @{
        Uri = $uri
        Method = $Method
        Headers = $headers
    }

    if ($Body) {
        $params.Body = ($Body | ConvertTo-Json -Depth 10)
    }

    Invoke-RestMethod @params
}

function Disconnect-Salesforce {
    $global:SalesforceConnected = $false
    $global:SalesforceAlias = $null
    Write-Host "Disconnected from Salesforce (session cleared)" -ForegroundColor Yellow
}
