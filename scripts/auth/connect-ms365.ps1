<#
.SYNOPSIS
    Connects to Microsoft Graph and Exchange Online using Doppler secrets
#>

# Doppler executable path
$script:DopplerExe = 'C:\Users\Devin\AppData\Local\Microsoft\WinGet\Packages\Doppler.doppler_Microsoft.Winget.Source_8wekyb3d8bbwe\doppler.exe'

function Get-DopplerSecret {
    param([Parameter(Mandatory)][string]$Name)
    $value = & $script:DopplerExe secrets get $Name --plain 2>$null
    return $value
}

function Connect-MS365 {
    param(
        [switch]$Force,
        [switch]$IncludeExchange
    )

    if ($global:MS365Connected -and -not $Force) {
        Write-Host "Already connected to Microsoft 365. Use -Force to reconnect." -ForegroundColor Yellow
        return
    }

    # Get credentials from Doppler
    $tenantId = Get-DopplerSecret -Name "MS365_TENANT_ID"
    $clientId = Get-DopplerSecret -Name "MS365_CLIENT_ID"
    $certThumbprint = Get-DopplerSecret -Name "MS365_CERT_THUMBPRINT"
    $clientSecret = Get-DopplerSecret -Name "MS365_CLIENT_SECRET"

    if (-not $tenantId -or $tenantId -eq "CHANGE_ME") {
        throw "MS365 tenant ID not configured in Doppler. Run: doppler secrets set MS365_TENANT_ID='your-tenant-id'"
    }

    if (-not $clientId -or $clientId -eq "CHANGE_ME") {
        throw "MS365 client ID not configured in Doppler. Run: doppler secrets set MS365_CLIENT_ID='your-client-id'"
    }

    # Import modules
    Import-Module Microsoft.Graph.Authentication -Force
    Import-Module Microsoft.Graph.Users -Force
    Import-Module Microsoft.Graph.Groups -Force

    try {
        # Connect to Graph
        if ($certThumbprint -and $certThumbprint -ne "") {
            # Certificate-based auth
            Connect-MgGraph -ClientId $clientId -TenantId $tenantId `
                -CertificateThumbprint $certThumbprint -NoWelcome
        } elseif ($clientSecret -and $clientSecret -ne "CHANGE_ME") {
            # Client secret auth
            $secureSecret = ConvertTo-SecureString $clientSecret -AsPlainText -Force
            $credential = New-Object System.Management.Automation.PSCredential($clientId, $secureSecret)
            Connect-MgGraph -ClientSecretCredential $credential -TenantId $tenantId -NoWelcome
        } else {
            throw "No valid MS365 credentials found. Configure either MS365_CERT_THUMBPRINT or MS365_CLIENT_SECRET in Doppler."
        }

        Write-Host "Connected to Microsoft Graph" -ForegroundColor Green

        # Optionally connect to Exchange Online
        if ($IncludeExchange) {
            if (Get-Module -ListAvailable ExchangeOnlineManagement) {
                Import-Module ExchangeOnlineManagement -Force
                if ($certThumbprint) {
                    $org = "$tenantId.onmicrosoft.com"
                    Connect-ExchangeOnline -CertificateThumbprint $certThumbprint `
                        -AppId $clientId -Organization $org -ShowBanner:$false
                }
                Write-Host "Connected to Exchange Online" -ForegroundColor Green
            } else {
                Write-Warning "ExchangeOnlineManagement module not installed. Skipping Exchange connection."
            }
        }

        $global:MS365Connected = $true
    }
    catch {
        $global:MS365Connected = $false
        throw "Failed to connect to MS365: $_"
    }
}

function Disconnect-MS365 {
    Disconnect-MgGraph -ErrorAction SilentlyContinue
    if (Get-Module ExchangeOnlineManagement) {
        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    }
    $global:MS365Connected = $false
    Write-Host "Disconnected from Microsoft 365" -ForegroundColor Yellow
}
