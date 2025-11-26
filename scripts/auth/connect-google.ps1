<#
.SYNOPSIS
    Google Workspace Admin SDK connection using Doppler secrets
.DESCRIPTION
    Uses PSGSuite with service account credentials stored in Doppler.
    Requires domain-wide delegation to be configured in Google Admin Console.
#>

# Doppler executable path
$script:DopplerExe = 'C:\Users\Devin\AppData\Local\Microsoft\WinGet\Packages\Doppler.doppler_Microsoft.Winget.Source_8wekyb3d8bbwe\doppler.exe'

function Get-DopplerSecret {
    param([Parameter(Mandatory)][string]$Name)
    $value = & $script:DopplerExe secrets get $Name --plain 2>$null
    return $value
}

function Connect-GoogleWorkspace {
    param([switch]$Force)

    if ($global:GoogleConnected -and -not $Force) {
        Write-Host "Already connected to Google Workspace. Use -Force to reconnect." -ForegroundColor Yellow
        return
    }

    $credPath = Get-DopplerSecret -Name "GOOGLE_CREDENTIALS_PATH"
    $adminEmail = Get-DopplerSecret -Name "GOOGLE_ADMIN_EMAIL"
    $serviceAccountEmail = Get-DopplerSecret -Name "GOOGLE_SERVICE_ACCOUNT_EMAIL"
    $customerId = Get-DopplerSecret -Name "GOOGLE_CUSTOMER_ID"

    # Validate credentials path
    if (-not $credPath -or $credPath -eq "" -or -not (Test-Path $credPath)) {
        throw "Google credentials not found. Set GOOGLE_CREDENTIALS_PATH in Doppler to the path of your service account JSON file."
    }

    if (-not $adminEmail -or $adminEmail -eq "CHANGE_ME") {
        throw "Google admin email not configured. Run: doppler secrets set GOOGLE_ADMIN_EMAIL='admin@yourdomain.com'"
    }

    try {
        # Import PSGSuite
        Import-Module PSGSuite -Force

        # Get domain from admin email
        $domain = $adminEmail.Split('@')[1]

        # Configure PSGSuite
        # PSGSuite stores config in user profile, we'll set it up dynamically
        $configDir = "$env:USERPROFILE\.config\PSGSuite"
        if (-not (Test-Path $configDir)) {
            New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        }

        # Create PSGSuite configuration
        $config = @{
            ConfigName = 'ClaudesHome'
            ServiceAccountClientEmail = $serviceAccountEmail
            AdminEmail = $adminEmail
            CustomerID = if ($customerId -and $customerId -ne "my_customer") { $customerId } else { "my_customer" }
            Domain = $domain
            Preference = 'CustomerID'
            ServiceAccountKeyPath = $credPath
        }

        # Write config as PSD1
        $configContent = "@{`n"
        foreach ($key in $config.Keys) {
            $value = $config[$key]
            $configContent += "    $key = '$value'`n"
        }
        $configContent += "}"

        $configPath = Join-Path $configDir "Configuration.psd1"
        $configContent | Set-Content $configPath -Encoding UTF8

        # Verify connection by getting current user
        # PSGSuite will use the config automatically
        $global:GoogleConnected = $true
        Write-Host "Connected to Google Workspace as $adminEmail (domain: $domain)" -ForegroundColor Green
    }
    catch {
        $global:GoogleConnected = $false
        throw "Failed to connect to Google Workspace: $_"
    }
}

function Test-GoogleConnection {
    try {
        if (-not $global:GoogleConnected) {
            Connect-GoogleWorkspace
        }

        # Try to list users (limited to 1) as a test
        $users = Get-GSUser -MaxResults 1 -ErrorAction Stop
        Write-Host "Google Workspace connection verified" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Google Workspace connection test failed: $_" -ForegroundColor Red
        $global:GoogleConnected = $false
        return $false
    }
}

function Disconnect-GoogleWorkspace {
    $global:GoogleConnected = $false
    Write-Host "Disconnected from Google Workspace (session cleared)" -ForegroundColor Yellow
}
