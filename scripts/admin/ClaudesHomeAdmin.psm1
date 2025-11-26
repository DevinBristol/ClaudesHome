<#
.SYNOPSIS
    ClaudesHome Unified Administration Module
    Provides cross-platform user and system management
.DESCRIPTION
    This module integrates Five9, Microsoft 365, Salesforce, Company Cam,
    and Google Workspace administration into a single unified interface.

    Credentials are managed through Doppler for secure secrets management.
#>

# Auto-detect Doppler path
$script:DopplerExe = (Get-Command doppler -ErrorAction SilentlyContinue).Source
if (-not $script:DopplerExe) {
    $wingetPath = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages"
    $script:DopplerExe = Get-ChildItem $wingetPath -Filter "doppler.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $script:DopplerExe) { $script:DopplerExe = 'doppler' }

# Get script root for importing other scripts
$script:ModuleRoot = $PSScriptRoot

# Import all auth scripts
Get-ChildItem "$script:ModuleRoot\..\auth\*.ps1" -ErrorAction SilentlyContinue | ForEach-Object {
    . $_.FullName
}

# Import all admin scripts (except this module)
Get-ChildItem "$script:ModuleRoot\*-admin.ps1" -ErrorAction SilentlyContinue | ForEach-Object {
    . $_.FullName
}

# Import helper scripts
Get-ChildItem "$script:ModuleRoot\..\helpers\*.ps1" -ErrorAction SilentlyContinue | ForEach-Object {
    . $_.FullName
}

# ============================================
# UTILITY FUNCTIONS
# ============================================

function New-RandomPassword {
    param([int]$Length = 12)
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    -join ((1..$Length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
}

# ============================================
# CONNECTION FUNCTIONS
# ============================================

function Connect-AllPlatforms {
    <#
    .SYNOPSIS
        Connects to all configured platforms
    .PARAMETER Platforms
        Array of platform names to connect to. Default: all platforms.
    .EXAMPLE
        Connect-AllPlatforms
        Connect-AllPlatforms -Platforms @("Five9", "MS365")
    #>
    param(
        [string[]]$Platforms = @("Five9", "MS365", "Salesforce", "CompanyCam", "Google")
    )

    $results = @{}

    foreach ($platform in $Platforms) {
        Write-Host "Connecting to $platform..." -ForegroundColor Cyan
        try {
            switch ($platform) {
                "Five9" {
                    . "$script:ModuleRoot\..\auth\connect-five9.ps1"
                    Connect-Five9
                    $results.Five9 = $true
                }
                "MS365" {
                    . "$script:ModuleRoot\..\auth\connect-ms365.ps1"
                    Connect-MS365
                    $results.MS365 = $true
                }
                "Salesforce" {
                    . "$script:ModuleRoot\..\auth\connect-salesforce.ps1"
                    Connect-Salesforce
                    $results.Salesforce = $true
                }
                "CompanyCam" {
                    . "$script:ModuleRoot\..\auth\connect-companycam.ps1"
                    Test-CompanyCamConnection | Out-Null
                    $results.CompanyCam = $true
                }
                "Google" {
                    . "$script:ModuleRoot\..\auth\connect-google.ps1"
                    Connect-GoogleWorkspace
                    $results.Google = $true
                }
            }
        }
        catch {
            Write-Warning "Failed to connect to $platform : $_"
            $results.$platform = $false
        }
    }

    Write-Host ""
    Write-Host "=== Connection Summary ===" -ForegroundColor Cyan
    foreach ($key in $results.Keys) {
        $status = if ($results[$key]) { "Connected" } else { "Failed" }
        $color = if ($results[$key]) { "Green" } else { "Red" }
        Write-Host "  $key : $status" -ForegroundColor $color
    }

    return $results
}

function Get-ConnectionStatus {
    <#
    .SYNOPSIS
        Shows current connection status for all platforms
    #>
    $status = @{
        Five9 = $global:Five9Connected -eq $true
        MS365 = $global:MS365Connected -eq $true
        Salesforce = $global:SalesforceConnected -eq $true
        CompanyCam = $global:CompanyCamConnected -eq $true
        Google = $global:GoogleConnected -eq $true
    }

    Write-Host "=== Connection Status ===" -ForegroundColor Cyan
    foreach ($key in $status.Keys) {
        $connected = $status[$key]
        $statusText = if ($connected) { "Connected" } else { "Not Connected" }
        $color = if ($connected) { "Green" } else { "Gray" }
        Write-Host "  $key : $statusText" -ForegroundColor $color
    }

    return $status
}

# ============================================
# UNIFIED USER MANAGEMENT
# ============================================

function New-UniversalUser {
    <#
    .SYNOPSIS
        Creates a user across multiple platforms
    .PARAMETER FirstName
        User's first name
    .PARAMETER LastName
        User's last name
    .PARAMETER Email
        User's email address (used as username on most platforms)
    .PARAMETER Platforms
        Array of platforms to create user on. Default: MS365, Google
    .PARAMETER IsFive9Agent
        If specified, also creates user as Five9 agent
    .EXAMPLE
        New-UniversalUser -FirstName "John" -LastName "Doe" -Email "john@company.com"
        New-UniversalUser -FirstName "Jane" -LastName "Smith" -Email "jane@company.com" -Platforms @("MS365","Google","Salesforce") -IsFive9Agent
    #>
    param(
        [Parameter(Mandatory)][string]$FirstName,
        [Parameter(Mandatory)][string]$LastName,
        [Parameter(Mandatory)][string]$Email,
        [string[]]$Platforms = @("MS365", "Google"),
        [string]$Department,
        [switch]$IsFive9Agent
    )

    $results = @{
        Email = $Email
        Platforms = @{}
        Passwords = @{}
    }

    foreach ($platform in $Platforms) {
        Write-Host "Creating user on $platform..." -ForegroundColor Cyan
        try {
            switch ($platform) {
                "MS365" {
                    . "$script:ModuleRoot\..\auth\connect-ms365.ps1"
                    . "$script:ModuleRoot\ms365-admin.ps1"
                    $mailNickname = ($FirstName + $LastName).ToLower() -replace '[^a-z0-9]',''
                    $result = New-MS365User -DisplayName "$FirstName $LastName" `
                        -UserPrincipalName $Email -MailNickname $mailNickname
                    $results.Platforms.MS365 = $result.UserId
                    $results.Passwords.MS365 = $result.Password
                }
                "Google" {
                    . "$script:ModuleRoot\..\auth\connect-google.ps1"
                    . "$script:ModuleRoot\google-admin.ps1"
                    $result = New-GoogleUser -PrimaryEmail $Email `
                        -GivenName $FirstName -FamilyName $LastName
                    $results.Platforms.Google = $true
                    $results.Passwords.Google = $result.Password
                }
                "Salesforce" {
                    . "$script:ModuleRoot\..\auth\connect-salesforce.ps1"
                    . "$script:ModuleRoot\salesforce-admin.ps1"
                    $profiles = Get-SalesforceProfiles
                    $standardProfile = $profiles | Where-Object { $_.Name -eq "Standard User" } | Select-Object -First 1
                    if ($standardProfile) {
                        $result = New-SalesforceUser -FirstName $FirstName -LastName $LastName `
                            -Email $Email -Username $Email -ProfileId $standardProfile.Id
                        $results.Platforms.Salesforce = $result.id
                    } else {
                        throw "Standard User profile not found"
                    }
                }
                "Five9" {
                    if ($IsFive9Agent) {
                        . "$script:ModuleRoot\..\auth\connect-five9.ps1"
                        . "$script:ModuleRoot\five9-admin.ps1"
                        $result = New-Five9Agent -FirstName $FirstName -LastName $LastName -Email $Email
                        $results.Platforms.Five9 = $result.Username
                        $results.Passwords.Five9 = $result.Password
                    }
                }
            }
            Write-Host "  Created on $platform" -ForegroundColor Green
        }
        catch {
            Write-Warning "  Failed on $platform : $_"
            $results.Platforms.$platform = "FAILED: $_"
        }
    }

    # Handle Five9 separately if requested but not in Platforms
    if ($IsFive9Agent -and "Five9" -notin $Platforms) {
        Write-Host "Creating user on Five9..." -ForegroundColor Cyan
        try {
            . "$script:ModuleRoot\..\auth\connect-five9.ps1"
            . "$script:ModuleRoot\five9-admin.ps1"
            $result = New-Five9Agent -FirstName $FirstName -LastName $LastName -Email $Email
            $results.Platforms.Five9 = $result.Username
            $results.Passwords.Five9 = $result.Password
            Write-Host "  Created on Five9" -ForegroundColor Green
        }
        catch {
            Write-Warning "  Failed on Five9 : $_"
            $results.Platforms.Five9 = "FAILED: $_"
        }
    }

    # Summary
    Write-Host ""
    Write-Host "=== User Creation Summary ===" -ForegroundColor Cyan
    Write-Host "Email: $Email"
    Write-Host "Platforms:"
    foreach ($key in $results.Platforms.Keys) {
        Write-Host "  $key : $($results.Platforms[$key])"
    }
    Write-Host "Passwords:" -ForegroundColor Yellow
    foreach ($key in $results.Passwords.Keys) {
        Write-Host "  $key : $($results.Passwords[$key])" -ForegroundColor Yellow
    }

    return $results
}

function Disable-UniversalUser {
    <#
    .SYNOPSIS
        Disables a user across all platforms
    .PARAMETER Email
        User's email address
    .PARAMETER Platforms
        Array of platforms to disable user on
    .EXAMPLE
        Disable-UniversalUser -Email "john@company.com"
    #>
    param(
        [Parameter(Mandatory)][string]$Email,
        [string[]]$Platforms = @("MS365", "Google", "Salesforce", "Five9")
    )

    $results = @{}

    foreach ($platform in $Platforms) {
        Write-Host "Disabling on $platform..." -ForegroundColor Cyan
        try {
            switch ($platform) {
                "MS365" {
                    . "$script:ModuleRoot\..\auth\connect-ms365.ps1"
                    . "$script:ModuleRoot\ms365-admin.ps1"
                    Disable-MS365User -UserPrincipalName $Email
                    $results.MS365 = "Disabled"
                }
                "Google" {
                    . "$script:ModuleRoot\..\auth\connect-google.ps1"
                    . "$script:ModuleRoot\google-admin.ps1"
                    Suspend-GoogleUser -User $Email
                    $results.Google = "Suspended"
                }
                "Salesforce" {
                    . "$script:ModuleRoot\..\auth\connect-salesforce.ps1"
                    . "$script:ModuleRoot\salesforce-admin.ps1"
                    $user = Get-SalesforceUser -Email $Email
                    if ($user) {
                        Disable-SalesforceUser -UserId $user.Id
                        $results.Salesforce = "Deactivated"
                    } else {
                        $results.Salesforce = "Not found"
                    }
                }
                "Five9" {
                    . "$script:ModuleRoot\..\auth\connect-five9.ps1"
                    . "$script:ModuleRoot\five9-admin.ps1"
                    Disable-Five9User -Username $Email
                    $results.Five9 = "Disabled"
                }
            }
        }
        catch {
            $results.$platform = "Failed: $_"
        }
    }

    Write-Host ""
    Write-Host "=== Disable Summary ===" -ForegroundColor Cyan
    foreach ($key in $results.Keys) {
        $color = if ($results[$key] -match "Failed") { "Red" } else { "Green" }
        Write-Host "  $key : $($results[$key])" -ForegroundColor $color
    }

    return $results
}

function Reset-UniversalPassword {
    <#
    .SYNOPSIS
        Resets password for a user across specified platforms
    .PARAMETER Email
        User's email address
    .PARAMETER Platforms
        Array of platforms to reset password on
    .PARAMETER SamePassword
        If specified, uses the same password for all platforms
    .EXAMPLE
        Reset-UniversalPassword -Email "john@company.com"
        Reset-UniversalPassword -Email "john@company.com" -Platforms @("MS365") -SamePassword
    #>
    param(
        [Parameter(Mandatory)][string]$Email,
        [string[]]$Platforms = @("MS365", "Google"),
        [switch]$SamePassword
    )

    $results = @{}
    $sharedPassword = if ($SamePassword) { New-RandomPassword } else { $null }

    foreach ($platform in $Platforms) {
        Write-Host "Resetting password on $platform..." -ForegroundColor Cyan
        $password = if ($SamePassword) { $sharedPassword } else { New-RandomPassword }

        try {
            switch ($platform) {
                "MS365" {
                    . "$script:ModuleRoot\..\auth\connect-ms365.ps1"
                    . "$script:ModuleRoot\ms365-admin.ps1"
                    Reset-MS365UserPassword -UserPrincipalName $Email -NewPassword $password | Out-Null
                    $results.MS365 = $password
                }
                "Google" {
                    . "$script:ModuleRoot\..\auth\connect-google.ps1"
                    . "$script:ModuleRoot\google-admin.ps1"
                    Reset-GoogleUserPassword -User $Email -NewPassword $password | Out-Null
                    $results.Google = $password
                }
                "Five9" {
                    . "$script:ModuleRoot\..\auth\connect-five9.ps1"
                    . "$script:ModuleRoot\five9-admin.ps1"
                    Reset-Five9UserPassword -Username $Email -NewPassword $password | Out-Null
                    $results.Five9 = $password
                }
                "Salesforce" {
                    . "$script:ModuleRoot\..\auth\connect-salesforce.ps1"
                    . "$script:ModuleRoot\salesforce-admin.ps1"
                    $user = Get-SalesforceUser -Email $Email
                    if ($user) {
                        Reset-SalesforceUserPassword -UserId $user.Id
                        $results.Salesforce = "(Email sent to user)"
                    } else {
                        $results.Salesforce = "Not found"
                    }
                }
            }
        }
        catch {
            $results.$platform = "Failed: $_"
        }
    }

    Write-Host ""
    Write-Host "=== Password Reset Summary ===" -ForegroundColor Cyan
    foreach ($key in $results.Keys) {
        $color = if ($results[$key] -match "Failed") { "Red" } else { "Yellow" }
        Write-Host "  $key : $($results[$key])" -ForegroundColor $color
    }

    return $results
}

# ============================================
# EXPORT ALL FUNCTIONS
# ============================================

# Connection functions
Export-ModuleMember -Function Connect-AllPlatforms
Export-ModuleMember -Function Get-ConnectionStatus
Export-ModuleMember -Function Connect-Five9
Export-ModuleMember -Function Connect-MS365
Export-ModuleMember -Function Connect-Salesforce
Export-ModuleMember -Function Connect-GoogleWorkspace
Export-ModuleMember -Function Test-CompanyCamConnection

# Unified functions
Export-ModuleMember -Function New-UniversalUser
Export-ModuleMember -Function Disable-UniversalUser
Export-ModuleMember -Function Reset-UniversalPassword
Export-ModuleMember -Function New-RandomPassword

# Five9 functions
Export-ModuleMember -Function Get-Five9Users
Export-ModuleMember -Function New-Five9Agent
Export-ModuleMember -Function Reset-Five9UserPassword
Export-ModuleMember -Function Disable-Five9User
Export-ModuleMember -Function Enable-Five9User
Export-ModuleMember -Function Get-Five9Campaigns
Export-ModuleMember -Function Start-Five9Campaign
Export-ModuleMember -Function Stop-Five9Campaign
Export-ModuleMember -Function Get-Five9ANIs
Export-ModuleMember -Function Set-Five9ANIStatus
Export-ModuleMember -Function Get-Five9Skills
Export-ModuleMember -Function Add-Five9UserSkill
Export-ModuleMember -Function Remove-Five9UserSkill

# MS365 functions
Export-ModuleMember -Function Get-MS365Users
Export-ModuleMember -Function Get-MS365User
Export-ModuleMember -Function New-MS365User
Export-ModuleMember -Function Reset-MS365UserPassword
Export-ModuleMember -Function Disable-MS365User
Export-ModuleMember -Function Enable-MS365User
Export-ModuleMember -Function Get-MS365Groups
Export-ModuleMember -Function Get-MS365GroupMembers
Export-ModuleMember -Function Add-MS365GroupMember
Export-ModuleMember -Function Remove-MS365GroupMember
Export-ModuleMember -Function Get-MS365UserMail
Export-ModuleMember -Function Send-MS365Mail

# Salesforce functions
Export-ModuleMember -Function Get-SalesforceUsers
Export-ModuleMember -Function Get-SalesforceUser
Export-ModuleMember -Function New-SalesforceUser
Export-ModuleMember -Function Reset-SalesforceUserPassword
Export-ModuleMember -Function Disable-SalesforceUser
Export-ModuleMember -Function Enable-SalesforceUser
Export-ModuleMember -Function Invoke-SalesforceQuery
Export-ModuleMember -Function Invoke-SalesforceAPI
Export-ModuleMember -Function Get-SalesforceProfiles
Export-ModuleMember -Function Get-SalesforcePermissionSets
Export-ModuleMember -Function Get-SalesforceUserPermissionSets
Export-ModuleMember -Function Add-SalesforcePermissionSetAssignment
Export-ModuleMember -Function Get-SalesforceOrgLimits

# Company Cam functions (reads)
Export-ModuleMember -Function Get-CompanyCamProjects
Export-ModuleMember -Function Get-CompanyCamProject
Export-ModuleMember -Function Search-CompanyCamProjects
Export-ModuleMember -Function Get-CompanyCamPhotos
Export-ModuleMember -Function Get-CompanyCamPhoto
Export-ModuleMember -Function Get-CompanyCamComments
Export-ModuleMember -Function Get-CompanyCamUsers
Export-ModuleMember -Function Get-CompanyCamCurrentUser
Export-ModuleMember -Function Get-CompanyCamTags
Export-ModuleMember -Function Get-CompanyCamProjectsByTag

# Company Cam functions (writes via SF)
Export-ModuleMember -Function New-CompanyCamProject
Export-ModuleMember -Function Update-CompanyCamProject
Export-ModuleMember -Function Add-CompanyCamComment
Export-ModuleMember -Function Sync-CompanyCamData

# Google functions
Export-ModuleMember -Function Get-GoogleUsers
Export-ModuleMember -Function Get-GoogleUser
Export-ModuleMember -Function New-GoogleUser
Export-ModuleMember -Function Reset-GoogleUserPassword
Export-ModuleMember -Function Suspend-GoogleUser
Export-ModuleMember -Function Resume-GoogleUser
Export-ModuleMember -Function Get-GoogleUserAliases
Export-ModuleMember -Function Add-GoogleUserAlias
Export-ModuleMember -Function Get-GoogleGroups
Export-ModuleMember -Function Get-GoogleGroup
Export-ModuleMember -Function New-GoogleGroup
Export-ModuleMember -Function Get-GoogleGroupMembers
Export-ModuleMember -Function Add-GoogleGroupMember
Export-ModuleMember -Function Remove-GoogleGroupMember
Export-ModuleMember -Function Get-GoogleOrgUnits
Export-ModuleMember -Function Move-GoogleUserToOU
Export-ModuleMember -Function Get-GoogleUserLicenses
Export-ModuleMember -Function Get-GoogleLicenses

# Helper functions
Export-ModuleMember -Function Send-ClaudeResponse
