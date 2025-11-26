<#
.SYNOPSIS
    Verifies all ClaudesHome integrations are properly configured
.DESCRIPTION
    Checks Doppler configuration, required secrets, PowerShell modules,
    and optionally tests connections to each platform.
.PARAMETER TestConnections
    If specified, attempts to connect to each platform to verify credentials work.
.EXAMPLE
    .\verify-setup.ps1
    .\verify-setup.ps1 -TestConnections
#>

param(
    [switch]$TestConnections
)

# Auto-detect Doppler path
$DopplerExe = (Get-Command doppler -ErrorAction SilentlyContinue).Source
if (-not $DopplerExe) {
    $wingetPath = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages"
    $DopplerExe = Get-ChildItem $wingetPath -Filter "doppler.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $DopplerExe) { $DopplerExe = 'doppler' }

Write-Host ""
Write-Host "=== ClaudesHome Integration Verification ===" -ForegroundColor Cyan
Write-Host ""

# ============================================
# Check Doppler
# ============================================

Write-Host "Checking Doppler..." -ForegroundColor Yellow
try {
    if (Test-Path $DopplerExe) {
        $version = & $DopplerExe --version 2>$null
        Write-Host "  Doppler CLI: Installed ($version)" -ForegroundColor Green

        # Check if configured in this directory
        $config = & $DopplerExe configs --json 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($config) {
            Write-Host "  Project: $($config.project)" -ForegroundColor Green
            Write-Host "  Config: $($config.config)" -ForegroundColor Green
        } else {
            Write-Host "  Project: NOT CONFIGURED (run 'doppler setup' in ClaudesHome)" -ForegroundColor Red
        }
    } else {
        Write-Host "  Doppler CLI: NOT INSTALLED" -ForegroundColor Red
    }
} catch {
    Write-Host "  Doppler: Error checking - $_" -ForegroundColor Red
}

# ============================================
# Check Platform Secrets
# ============================================

Write-Host ""
Write-Host "Checking platform credentials in Doppler..." -ForegroundColor Yellow

$platforms = @{
    "Five9" = @("FIVE9_USERNAME", "FIVE9_PASSWORD")
    "MS365" = @("MS365_TENANT_ID", "MS365_CLIENT_ID")
    "Salesforce" = @("SF_CLIENT_ID", "SF_USERNAME")
    "CompanyCam" = @("COMPANYCAM_ACCESS_TOKEN")
    "Google" = @("GOOGLE_CREDENTIALS_PATH", "GOOGLE_ADMIN_EMAIL")
}

$platformStatus = @{}

foreach ($platform in $platforms.Keys) {
    $allConfigured = $true
    $missingSecrets = @()

    foreach ($secret in $platforms[$platform]) {
        $value = & $DopplerExe secrets get $secret --plain 2>$null
        if (-not $value -or $value -eq "CHANGE_ME" -or $value -eq "") {
            $allConfigured = $false
            $missingSecrets += $secret
        }
    }

    $platformStatus[$platform] = $allConfigured

    if ($allConfigured) {
        Write-Host "  $platform : Configured" -ForegroundColor Green
    } else {
        Write-Host "  $platform : Missing secrets ($($missingSecrets -join ', '))" -ForegroundColor Red
    }
}

# ============================================
# Check PowerShell Modules
# ============================================

Write-Host ""
Write-Host "Checking PowerShell modules..." -ForegroundColor Yellow

$modules = @{
    "PSFive9Admin" = "Five9"
    "Microsoft.Graph.Authentication" = "MS365"
    "Microsoft.Graph.Users" = "MS365"
    "Microsoft.Graph.Groups" = "MS365"
    "PSGSuite" = "Google"
}

foreach ($mod in $modules.Keys) {
    $installed = Get-Module -ListAvailable -Name $mod -ErrorAction SilentlyContinue
    if ($installed) {
        Write-Host "  $mod : Installed (v$($installed.Version))" -ForegroundColor Green
    } else {
        Write-Host "  $mod : NOT INSTALLED (needed for $($modules[$mod]))" -ForegroundColor Red
    }
}

# Check SF CLI
Write-Host ""
Write-Host "Checking Salesforce CLI..." -ForegroundColor Yellow
try {
    $sfVersion = sf --version 2>$null
    if ($sfVersion) {
        Write-Host "  Salesforce CLI: Installed" -ForegroundColor Green
    } else {
        Write-Host "  Salesforce CLI: NOT FOUND" -ForegroundColor Red
    }
} catch {
    Write-Host "  Salesforce CLI: NOT FOUND" -ForegroundColor Red
}

# ============================================
# Check Key Files
# ============================================

Write-Host ""
Write-Host "Checking key files..." -ForegroundColor Yellow

$claudesHome = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent

# Check for Salesforce key
$sfKeyPath = & $DopplerExe secrets get SF_PRIVATE_KEY_PATH --plain 2>$null
if (-not $sfKeyPath -or $sfKeyPath -eq "") {
    $sfKeyPath = Join-Path $claudesHome "certs\server.key"
}
if (Test-Path $sfKeyPath) {
    Write-Host "  Salesforce key: Found at $sfKeyPath" -ForegroundColor Green
} else {
    Write-Host "  Salesforce key: NOT FOUND at $sfKeyPath" -ForegroundColor Yellow
}

# Check for Google credentials
$googleCredsPath = & $DopplerExe secrets get GOOGLE_CREDENTIALS_PATH --plain 2>$null
if ($googleCredsPath -and (Test-Path $googleCredsPath)) {
    Write-Host "  Google credentials: Found at $googleCredsPath" -ForegroundColor Green
} elseif ($googleCredsPath) {
    Write-Host "  Google credentials: NOT FOUND at $googleCredsPath" -ForegroundColor Red
} else {
    Write-Host "  Google credentials: Path not configured" -ForegroundColor Yellow
}

# ============================================
# Test Connections (Optional)
# ============================================

if ($TestConnections) {
    Write-Host ""
    Write-Host "Testing connections (this may take a moment)..." -ForegroundColor Yellow

    $authPath = Join-Path $claudesHome "scripts\auth"

    # Five9
    if ($platformStatus["Five9"]) {
        try {
            . "$authPath\connect-five9.ps1"
            Connect-Five9
            Write-Host "  Five9: Connected" -ForegroundColor Green
        } catch {
            Write-Host "  Five9: Failed - $_" -ForegroundColor Red
        }
    }

    # Company Cam
    if ($platformStatus["CompanyCam"]) {
        try {
            . "$authPath\connect-companycam.ps1"
            if (Test-CompanyCamConnection) {
                Write-Host "  CompanyCam: Connected (read-only)" -ForegroundColor Green
            }
        } catch {
            Write-Host "  CompanyCam: Failed - $_" -ForegroundColor Red
        }
    }

    # Salesforce
    if ($platformStatus["Salesforce"]) {
        try {
            . "$authPath\connect-salesforce.ps1"
            Connect-Salesforce
            Write-Host "  Salesforce: Connected" -ForegroundColor Green
        } catch {
            Write-Host "  Salesforce: Failed - $_" -ForegroundColor Red
        }
    }

    # MS365
    if ($platformStatus["MS365"]) {
        try {
            . "$authPath\connect-ms365.ps1"
            Connect-MS365
            Write-Host "  MS365: Connected" -ForegroundColor Green
        } catch {
            Write-Host "  MS365: Failed - $_" -ForegroundColor Red
        }
    }

    # Google
    if ($platformStatus["Google"]) {
        try {
            . "$authPath\connect-google.ps1"
            Connect-GoogleWorkspace
            Write-Host "  Google: Connected" -ForegroundColor Green
        } catch {
            Write-Host "  Google: Failed - $_" -ForegroundColor Red
        }
    }
}

# ============================================
# Summary
# ============================================

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan

$configuredCount = ($platformStatus.Values | Where-Object { $_ -eq $true }).Count
$totalPlatforms = $platformStatus.Count

Write-Host "Platforms configured: $configuredCount / $totalPlatforms"

if ($configuredCount -lt $totalPlatforms) {
    Write-Host ""
    Write-Host "To configure missing platforms, set the required secrets in Doppler:" -ForegroundColor Yellow
    Write-Host "  doppler secrets set SECRET_NAME='value'" -ForegroundColor Gray
}

if (-not $TestConnections) {
    Write-Host ""
    Write-Host "Run with -TestConnections to verify credentials work:" -ForegroundColor Gray
    Write-Host "  .\verify-setup.ps1 -TestConnections" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== Verification Complete ===" -ForegroundColor Cyan
