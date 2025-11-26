<#
.SYNOPSIS
    Company Cam API helper functions using Doppler secrets
    NOTE: This is READ-ONLY. Write operations go through Salesforce.
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

function Get-CompanyCamHeaders {
    $token = Get-DopplerSecret -Name "COMPANYCAM_ACCESS_TOKEN"

    if (-not $token -or $token -eq "CHANGE_ME") {
        throw "Company Cam token not configured in Doppler. Run: doppler secrets set COMPANYCAM_ACCESS_TOKEN='your-token'"
    }

    return @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
}

function Invoke-CompanyCamReadAPI {
    <#
    .SYNOPSIS
        Invoke Company Cam API for READ operations only
    .DESCRIPTION
        This function only supports GET requests. For write operations,
        use the Salesforce proxy functions in companycam-admin.ps1
    #>
    param(
        [Parameter(Mandatory)][string]$Endpoint,
        [hashtable]$QueryParams
    )

    $headers = Get-CompanyCamHeaders
    $baseUrl = "https://api.companycam.com/v2"

    $uri = "$baseUrl/$Endpoint"

    if ($QueryParams -and $QueryParams.Count -gt 0) {
        $queryString = ($QueryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&"
        $uri += "?$queryString"
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers
        return $response
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq 429) {
            Write-Warning "Rate limited. Waiting 60 seconds..."
            Start-Sleep -Seconds 60
            return Invoke-RestMethod -Uri $uri -Method GET -Headers $headers
        }
        elseif ($statusCode -eq 401) {
            throw "Company Cam authentication failed. Check your access token in Doppler."
        }
        else {
            throw "Company Cam API error ($statusCode): $_"
        }
    }
}

function Test-CompanyCamConnection {
    try {
        $user = Invoke-CompanyCamReadAPI -Endpoint "users/current"
        Write-Host "Connected to Company Cam (READ-ONLY) as: $($user.email_address)" -ForegroundColor Green
        Write-Host "Write operations will route through Salesforce" -ForegroundColor Yellow
        $global:CompanyCamConnected = $true
        return $true
    }
    catch {
        Write-Host "Failed to connect to Company Cam: $_" -ForegroundColor Red
        $global:CompanyCamConnected = $false
        return $false
    }
}
