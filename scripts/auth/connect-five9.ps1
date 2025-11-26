<#
.SYNOPSIS
    Connects to Five9 Admin Web Service using Doppler secrets
.EXAMPLE
    . .\scripts\auth\connect-five9.ps1
    Connect-Five9
#>

# Doppler executable path
$script:DopplerExe = 'C:\Users\Devin\AppData\Local\Microsoft\WinGet\Packages\Doppler.doppler_Microsoft.Winget.Source_8wekyb3d8bbwe\doppler.exe'

function Get-DopplerSecret {
    param([Parameter(Mandatory)][string]$Name)

    $value = & $script:DopplerExe secrets get $Name --plain 2>$null
    return $value
}

function Connect-Five9 {
    param(
        [switch]$Force
    )

    # Check if already connected
    if ($global:Five9Connected -and -not $Force) {
        Write-Host "Already connected to Five9. Use -Force to reconnect." -ForegroundColor Yellow
        return
    }

    # Get credentials from Doppler
    $username = Get-DopplerSecret -Name "FIVE9_USERNAME"
    $password = Get-DopplerSecret -Name "FIVE9_PASSWORD"
    $datacenter = Get-DopplerSecret -Name "FIVE9_DATACENTER"

    if (-not $username -or $username -eq "CHANGE_ME") {
        throw "Five9 credentials not configured in Doppler. Run: doppler secrets set FIVE9_USERNAME='your-email'"
    }

    if (-not $password -or $password -eq "CHANGE_ME") {
        throw "Five9 password not configured in Doppler. Run: doppler secrets set FIVE9_PASSWORD='your-password'"
    }

    # Default datacenter if not set
    if (-not $datacenter) { $datacenter = "US" }

    # Import module if needed
    if (-not (Get-Module PSFive9Admin)) {
        Import-Module PSFive9Admin -Force
    }

    # Create credential object
    $securePass = ConvertTo-SecureString $password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($username, $securePass)

    # Connect
    try {
        Connect-Five9AdminWebService -Credential $credential -DataCenter $datacenter
        $global:Five9Connected = $true
        Write-Host "Connected to Five9 ($datacenter)" -ForegroundColor Green
    }
    catch {
        $global:Five9Connected = $false
        throw "Failed to connect to Five9: $_"
    }
}

function Disconnect-Five9 {
    # PSFive9Admin doesn't have explicit disconnect, just clear state
    $global:Five9Connected = $false
    Write-Host "Disconnected from Five9" -ForegroundColor Yellow
}
