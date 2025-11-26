<#
.SYNOPSIS
    Loads environment variables from Doppler (primary) or .env file (fallback)
.DESCRIPTION
    Call this at the start of any script that needs API credentials.
    Dot-source it: . .\scripts\helpers\Load-Env.ps1

    Priority:
    1. Doppler (if available and configured)
    2. .env file (fallback)
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$EnvFile = (Join-Path $PSScriptRoot "..\..\..\.env"),
    [Parameter(Mandatory=$false)]
    [switch]$ForceDotEnv
)

$ClaudesHome = $PSScriptRoot | Split-Path | Split-Path

# Try Doppler first (unless forced to use .env)
if (-not $ForceDotEnv) {
    $dopplerAvailable = Get-Command doppler -ErrorAction SilentlyContinue
    if ($dopplerAvailable) {
        try {
            # Check if Doppler is configured for this project
            $dopplerCheck = doppler secrets --only-names 2>&1
            if ($LASTEXITCODE -eq 0) {
                # Load all secrets from Doppler into environment
                $secrets = doppler secrets download --no-file --format json 2>$null | ConvertFrom-Json
                if ($secrets) {
                    $secrets.PSObject.Properties | ForEach-Object {
                        [Environment]::SetEnvironmentVariable($_.Name, $_.Value, "Process")
                    }
                    Write-Host "Environment loaded from Doppler" -ForegroundColor Green
                    return
                }
            }
        }
        catch {
            # Doppler failed, fall through to .env
        }
    }
}

# Fallback to .env file
$EnvPath = Join-Path $ClaudesHome ".env"

if (-not (Test-Path $EnvPath)) {
    Write-Host "Warning: No Doppler config and .env file not found at $EnvPath" -ForegroundColor Yellow
    Write-Host "Either run 'doppler setup' or copy .env.example to .env" -ForegroundColor Gray
    return
}

# Parse and load environment variables from .env
Get-Content $EnvPath | ForEach-Object {
    $line = $_.Trim()

    # Skip comments and empty lines
    if ($line -eq "" -or $line.StartsWith("#")) {
        return
    }

    # Parse KEY=VALUE
    if ($line -match "^([^=]+)=(.*)$") {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()

        # Remove quotes if present
        if ($value.StartsWith('"') -and $value.EndsWith('"')) {
            $value = $value.Substring(1, $value.Length - 2)
        }
        if ($value.StartsWith("'") -and $value.EndsWith("'")) {
            $value = $value.Substring(1, $value.Length - 2)
        }

        # Set environment variable for this session
        [Environment]::SetEnvironmentVariable($key, $value, "Process")
    }
}

Write-Host "Environment loaded from .env" -ForegroundColor Green
