#Requires -RunAsAdministrator
<#
.SYNOPSIS
    ClaudesHome Second PC Setup Script
.DESCRIPTION
    Run this script on your second PC to set up the synchronized
    Salesforce development environment.
.NOTES
    GitHub Repo: https://github.com/DevinBristol/ClaudesHome
    Run as Administrator for best results
#>

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  ClaudesHome - Second PC Setup" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$GitHubRepo = "https://github.com/DevinBristol/ClaudesHome.git"
$ProjectName = "ClaudesHome"

# Detect user's IdeaProjects folder
$IdeaProjectsPath = Join-Path $env:USERPROFILE "IdeaProjects"

Write-Host "Step 1: Checking prerequisites..." -ForegroundColor Yellow

# Check for Git
$gitVersion = git --version 2>$null
if (-not $gitVersion) {
    Write-Host "ERROR: Git is not installed. Please install Git first:" -ForegroundColor Red
    Write-Host "  https://git-scm.com/download/win" -ForegroundColor Gray
    exit 1
}
Write-Host "  Git: $gitVersion" -ForegroundColor Green

# Check for Salesforce CLI
$sfVersion = sf --version 2>$null
if (-not $sfVersion) {
    $sfdxVersion = sfdx --version 2>$null
    if ($sfdxVersion) {
        Write-Host "  WARNING: Legacy SFDX CLI detected. Consider upgrading to 'sf' CLI" -ForegroundColor Yellow
        Write-Host "  Run: npm install -g @salesforce/cli" -ForegroundColor Gray
    } else {
        Write-Host "  WARNING: Salesforce CLI not found. Install from:" -ForegroundColor Yellow
        Write-Host "  https://developer.salesforce.com/tools/salesforcecli" -ForegroundColor Gray
    }
} else {
    Write-Host "  Salesforce CLI: $($sfVersion.Split("`n")[0])" -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 2: Setting up project directory..." -ForegroundColor Yellow

# Create IdeaProjects if needed
if (-not (Test-Path $IdeaProjectsPath)) {
    Write-Host "  Creating $IdeaProjectsPath..." -ForegroundColor Gray
    New-Item -ItemType Directory -Path $IdeaProjectsPath -Force | Out-Null
}

$ClaudesHomePath = Join-Path $IdeaProjectsPath $ProjectName

# Check if already cloned
if (Test-Path $ClaudesHomePath) {
    Write-Host "  ClaudesHome already exists at $ClaudesHomePath" -ForegroundColor Yellow
    $overwrite = Read-Host "  Pull latest changes? (y/n)"
    if ($overwrite -eq 'y') {
        Push-Location $ClaudesHomePath
        git pull
        Pop-Location
    }
} else {
    Write-Host "  Cloning repository..." -ForegroundColor Gray
    Push-Location $IdeaProjectsPath

    Write-Host ""
    Write-Host "  You'll be prompted for GitHub credentials:" -ForegroundColor Cyan
    Write-Host "  Username: DevinBristol" -ForegroundColor White
    Write-Host "  Password: Use your Personal Access Token (PAT)" -ForegroundColor White
    Write-Host ""

    git clone $GitHubRepo
    Pop-Location

    if (-not (Test-Path $ClaudesHomePath)) {
        Write-Host "ERROR: Clone failed. Check your credentials and try again." -ForegroundColor Red
        exit 1
    }
}

Write-Host "  Project location: $ClaudesHomePath" -ForegroundColor Green

Write-Host ""
Write-Host "Step 3: Configuring Git credentials..." -ForegroundColor Yellow

git config --global credential.helper store
Write-Host "  Credential helper configured (credentials will be saved after first use)" -ForegroundColor Green

Write-Host ""
Write-Host "Step 4: Configuring machine paths..." -ForegroundColor Yellow

$Hostname = hostname
Write-Host "  This machine's hostname: $Hostname" -ForegroundColor Cyan

$MachinesJsonPath = Join-Path $ClaudesHomePath "config\machines.json"
$machinesConfig = Get-Content $MachinesJsonPath -Raw | ConvertFrom-Json

if ($machinesConfig.$Hostname) {
    Write-Host "  Machine already configured in machines.json" -ForegroundColor Green
} else {
    Write-Host "  Adding this PC to machines.json..." -ForegroundColor Gray
    $machineName = Read-Host "  Enter a name for this PC (e.g., 'Home PC', 'Laptop')"

    $newEntry = [PSCustomObject]@{
        name = $machineName
        projectsRoot = $IdeaProjectsPath
        claudesHome = $ClaudesHomePath
    }

    $machinesConfig | Add-Member -NotePropertyName $Hostname -NotePropertyValue $newEntry
    $machinesConfig | ConvertTo-Json -Depth 3 | Set-Content $MachinesJsonPath -Encoding UTF8

    Write-Host "  Added $Hostname to machines.json" -ForegroundColor Green
    Write-Host "  Don't forget to commit and push this change!" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 5: Setting up PowerShell profile..." -ForegroundColor Yellow

$ProfileDir = Split-Path $PROFILE -Parent
$ProfilePath = $PROFILE

if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
}

$ProfileContent = @"

# ClaudesHome quick navigation
function home {
    Set-Location "$ClaudesHomePath"
}

# Quick sync (git pull, commit, push)
function sync {
    & "$ClaudesHomePath\scripts\sync.ps1"
}
"@

if (Test-Path $ProfilePath) {
    $existingProfile = Get-Content $ProfilePath -Raw
    if ($existingProfile -match "function home") {
        Write-Host "  PowerShell profile already configured" -ForegroundColor Green
    } else {
        Add-Content -Path $ProfilePath -Value $ProfileContent
        Write-Host "  Added 'home' and 'sync' functions to profile" -ForegroundColor Green
    }
} else {
    Set-Content -Path $ProfilePath -Value $ProfileContent
    Write-Host "  Created PowerShell profile with 'home' and 'sync' functions" -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 6: Setting up WSL tmux for persistent mobile sessions..." -ForegroundColor Yellow

# Check if WSL is available
$wslList = wsl --list 2>$null
if ($wslList -match "Ubuntu") {
    Write-Host "  WSL Ubuntu detected" -ForegroundColor Green

    # Check if tmux is installed
    $tmuxCheck = wsl -d Ubuntu -e which tmux 2>$null
    if ($tmuxCheck) {
        Write-Host "  tmux is installed" -ForegroundColor Green

        # Check if auto-attach is already configured
        $bashrcCheck = wsl -d Ubuntu -e bash -c "grep -c 'Auto-attach to tmux' ~/.bashrc 2>/dev/null"
        if ($bashrcCheck -gt 0) {
            Write-Host "  tmux auto-attach already configured" -ForegroundColor Green
        } else {
            Write-Host "  Configuring tmux auto-attach..." -ForegroundColor Gray
            $tmuxConfig = @'
wsl -d Ubuntu -e bash -c 'cat >> ~/.bashrc << "EOFBASHRC"

# Auto-attach to tmux session (for persistent mobile sessions)
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    # Try to attach to existing session, or create new one named "main"
    tmux attach-session -t main 2>/dev/null || tmux new-session -s main
fi
EOFBASHRC
'
'@
            Invoke-Expression $tmuxConfig
            Write-Host "  tmux auto-attach configured" -ForegroundColor Green
        }
    } else {
        Write-Host "  Installing tmux in WSL..." -ForegroundColor Gray
        wsl -d Ubuntu -e sudo apt-get update
        wsl -d Ubuntu -e sudo apt-get install -y tmux
        Write-Host "  tmux installed" -ForegroundColor Green
    }

    # Create tm.bat shortcut
    $binPath = Join-Path $env:USERPROFILE "bin"
    if (-not (Test-Path $binPath)) {
        New-Item -ItemType Directory -Path $binPath -Force | Out-Null
    }
    $tmBat = Join-Path $binPath "tm.bat"
    if (-not (Test-Path $tmBat)) {
        Set-Content -Path $tmBat -Value "@echo off`nwsl -d Ubuntu"
        Write-Host "  Created tm.bat shortcut" -ForegroundColor Green

        # Add to PATH if not already there
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($userPath -notlike "*$binPath*") {
            [Environment]::SetEnvironmentVariable("Path", "$userPath;$binPath", "User")
            Write-Host "  Added bin folder to PATH" -ForegroundColor Green
        }
    }
} else {
    Write-Host "  WSL Ubuntu not found - skipping tmux setup" -ForegroundColor Yellow
    Write-Host "  (Mobile persistence via tmux requires WSL with Ubuntu)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Step 7: Checking Salesforce org authentication..." -ForegroundColor Yellow

$orgs = sf org list --json 2>$null | ConvertFrom-Json

if ($orgs -and $orgs.result) {
    Write-Host "  Currently authenticated orgs:" -ForegroundColor Gray
    foreach ($org in $orgs.result.nonScratchOrgs) {
        $status = if ($org.connectedStatus -eq "Connected") { "Connected" } else { "Needs Auth" }
        $color = if ($status -eq "Connected") { "Green" } else { "Yellow" }
        Write-Host "    $($org.alias): $status" -ForegroundColor $color
    }
} else {
    Write-Host "  No orgs authenticated yet" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Restart PowerShell for 'home' and 'sync' commands to work" -ForegroundColor White
Write-Host ""
Write-Host "2. Commit and push the machines.json change:" -ForegroundColor White
Write-Host "   cd $ClaudesHomePath" -ForegroundColor Gray
Write-Host "   sync                    # Or: git add -A && git commit -m 'Add $Hostname' && git push" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Copy the server.key file to certs/ folder:" -ForegroundColor White
Write-Host "   (Get it from your other PC or secure storage)" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Authenticate Salesforce production via JWT:" -ForegroundColor White
Write-Host "   .\scripts\setup\sf-jwt-auth.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Authenticate sandbox orgs (browser login):" -ForegroundColor White
Write-Host "   sf org login web -a devin1" -ForegroundColor Gray
Write-Host "   sf org login web -a PartialCopy" -ForegroundColor Gray
Write-Host ""
Write-Host "6. Test the setup:" -ForegroundColor White
Write-Host "   home                    # Navigate to ClaudesHome" -ForegroundColor Gray
Write-Host "   sf org list             # Verify orgs" -ForegroundColor Gray
Write-Host "   .\scripts\debug\check-limits.ps1 -Org devin1" -ForegroundColor Gray
Write-Host ""
Write-Host "7. For mobile access (Terminus):" -ForegroundColor White
Write-Host "   wsl                     # Enter Ubuntu + tmux (persistent session)" -ForegroundColor Gray
Write-Host "   tm                      # Same thing (shortcut)" -ForegroundColor Gray
Write-Host "   Ctrl+b d                # Detach from tmux (leave running)" -ForegroundColor Gray
Write-Host ""
Write-Host "Machine: $Hostname" -ForegroundColor Cyan
Write-Host "Project Path: $ClaudesHomePath" -ForegroundColor Cyan
Write-Host ""
