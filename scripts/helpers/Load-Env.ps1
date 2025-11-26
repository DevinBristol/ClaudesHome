<#
.SYNOPSIS
    Loads environment variables from .env file
.DESCRIPTION
    Call this at the start of any script that needs API credentials.
    Dot-source it: . .\scripts\helpers\Load-Env.ps1
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$EnvFile = (Join-Path $PSScriptRoot "..\..\..\.env")
)

# Find .env file relative to ClaudesHome root
$ClaudesHome = $PSScriptRoot | Split-Path | Split-Path
$EnvPath = Join-Path $ClaudesHome ".env"

if (-not (Test-Path $EnvPath)) {
    Write-Host "Warning: .env file not found at $EnvPath" -ForegroundColor Yellow
    Write-Host "Copy .env.example to .env and fill in your API keys" -ForegroundColor Gray
    return
}

# Parse and load environment variables
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
