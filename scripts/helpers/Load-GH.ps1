<#
.SYNOPSIS
    Sets GH_TOKEN from Doppler for GitHub CLI authentication
.DESCRIPTION
    Dot-source this at the start of any script that uses gh commands.
    Usage: . .\scripts\helpers\Load-GH.ps1
#>

# Fallback: check if already set
if ($env:GH_TOKEN) {
    return
}

# Try Doppler (native Windows)
$dopplerAvailable = Get-Command doppler -ErrorAction SilentlyContinue
if ($dopplerAvailable) {
    try {
        $token = doppler secrets get GITHUB_PAT --plain 2>$null
        if ($token -and $LASTEXITCODE -eq 0) {
            $env:GH_TOKEN = $token
            return
        }
    }
    catch { }
}

# Try Doppler via WSL (from Linux ClaudesHome path where Doppler is scoped)
try {
    $token = wsl -d Ubuntu-24.04 -- bash -c "cd /home/devin/IdeaProjects/ClaudesHome && doppler secrets get GITHUB_PAT --plain" 2>$null
    if ($token -and $LASTEXITCODE -eq 0) {
        $env:GH_TOKEN = $token.Trim()
        return
    }
}
catch { }

# Fallback: try .env file
$ClaudesHome = $PSScriptRoot | Split-Path | Split-Path
$EnvPath = Join-Path $ClaudesHome ".env"

if (Test-Path $EnvPath) {
    $match = Select-String -Path $EnvPath -Pattern "^GITHUB_PAT=(.+)$"
    if ($match) {
        $env:GH_TOKEN = $match.Matches[0].Groups[1].Value.Trim('"', "'")
        return
    }
}

Write-Host "Warning: Could not load GitHub token. Run 'doppler secrets set GITHUB_PAT=your_token'" -ForegroundColor Yellow
