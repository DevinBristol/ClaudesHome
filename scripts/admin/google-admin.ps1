<#
.SYNOPSIS
    Google Workspace administration functions for ClaudesHome
#>

function Ensure-GoogleConnected {
    if (-not $global:GoogleConnected) {
        . "$PSScriptRoot\..\auth\connect-google.ps1"
        Connect-GoogleWorkspace
    }
}

# Utility
function New-RandomPassword {
    param([int]$Length = 12)
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    -join ((1..$Length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
}

# User Management
function Get-GoogleUsers {
    param(
        [int]$MaxResults = 100,
        [string]$Query,
        [switch]$IncludeSuspended
    )

    Ensure-GoogleConnected
    Import-Module PSGSuite -Force

    $params = @{ MaxResults = $MaxResults }
    if ($Query) { $params.Query = $Query }
    if (-not $IncludeSuspended) {
        if ($params.Query) {
            $params.Query += " isSuspended=false"
        } else {
            $params.Query = "isSuspended=false"
        }
    }

    Get-GSUser @params | Select-Object PrimaryEmail, @{N='Name';E={$_.Name.FullName}}, Suspended, OrgUnitPath, CreationTime
}

function Get-GoogleUser {
    param([Parameter(Mandatory)][string]$User)

    Ensure-GoogleConnected
    Import-Module PSGSuite -Force

    Get-GSUser -User $User
}

function New-GoogleUser {
    param(
        [Parameter(Mandatory)][string]$PrimaryEmail,
        [Parameter(Mandatory)][string]$GivenName,
        [Parameter(Mandatory)][string]$FamilyName,
        [string]$Password = (New-RandomPassword),
        [string]$OrgUnitPath = "/",
        [switch]$ChangePasswordAtNextLogin = $true
    )

    Ensure-GoogleConnected
    Import-Module PSGSuite -Force

    $user = New-GSUser -PrimaryEmail $PrimaryEmail -GivenName $GivenName -FamilyName $FamilyName `
        -Password $Password -OrgUnitPath $OrgUnitPath -ChangePasswordAtNextLogin:$ChangePasswordAtNextLogin

    Write-Host "Created Google user: $PrimaryEmail" -ForegroundColor Green
    Write-Host "Temporary password: $Password" -ForegroundColor Yellow

    return @{
        Email = $PrimaryEmail
        Password = $Password
        UserId = $user.Id
    }
}

function Reset-GoogleUserPassword {
    param(
        [Parameter(Mandatory)][string]$User,
        [string]$NewPassword = (New-RandomPassword),
        [switch]$ChangePasswordAtNextLogin = $true
    )

    Ensure-GoogleConnected
    Import-Module PSGSuite -Force

    Update-GSUser -User $User -Password $NewPassword -ChangePasswordAtNextLogin:$ChangePasswordAtNextLogin

    Write-Host "Password reset for: $User" -ForegroundColor Green
    Write-Host "New password: $NewPassword" -ForegroundColor Yellow

    return $NewPassword
}

function Suspend-GoogleUser {
    param([Parameter(Mandatory)][string]$User)

    Ensure-GoogleConnected
    Import-Module PSGSuite -Force

    Update-GSUser -User $User -Suspended $true
    Write-Host "Suspended Google user: $User" -ForegroundColor Green
}

function Resume-GoogleUser {
    param([Parameter(Mandatory)][string]$User)

    Ensure-GoogleConnected
    Import-Module PSGSuite -Force

    Update-GSUser -User $User -Suspended $false
    Write-Host "Unsuspended Google user: $User" -ForegroundColor Green
}

# Alias management
function Get-GoogleUserAliases {
    param([Parameter(Mandatory)][string]$User)

    Ensure-GoogleConnected
    Import-Module PSGSuite -Force

    Get-GSUserAlias -User $User
}

function Add-GoogleUserAlias {
    param(
        [Parameter(Mandatory)][string]$User,
        [Parameter(Mandatory)][string]$Alias
    )

    Ensure-GoogleConnected
    Import-Module PSGSuite -Force

    New-GSUserAlias -User $User -Alias $Alias
    Write-Host "Added alias $Alias to $User" -ForegroundColor Green
}

# Group Management
function Get-GoogleGroups {
    param([int]$MaxResults = 100)

    Ensure-GoogleConnected
    Import-Module PSGSuite -Force

    Get-GSGroup -MaxResults $MaxResults | Select-Object Email, Name, DirectMembersCount
}

function Get-GoogleGroup {
    param([Parameter(Mandatory)][string]$Group)

    Ensure-GoogleConnected
    Import-Module PSGSuite -Force

    Get-GSGroup -Group $Group
}

function New-GoogleGroup {
    param(
        [Parameter(Mandatory)][string]$Email,
        [Parameter(Mandatory)][string]$Name,
        [string]$Description
    )

    Ensure-GoogleConnected
    Import-Module PSGSuite -Force

    $params = @{ Email = $Email; Name = $Name }
    if ($Description) { $params.Description = $Description }

    New-GSGroup @params
    Write-Host "Created Google group: $Email" -ForegroundColor Green
}

function Get-GoogleGroupMembers {
    param([Parameter(Mandatory)][string]$Group)

    Ensure-GoogleConnected
    Import-Module PSGSuite -Force

    Get-GSGroupMember -Identity $Group | Select-Object Email, Role, Type
}

function Add-GoogleGroupMember {
    param(
        [Parameter(Mandatory)][string]$GroupEmail,
        [Parameter(Mandatory)][string]$MemberEmail,
        [ValidateSet("MEMBER","MANAGER","OWNER")][string]$Role = "MEMBER"
    )

    Ensure-GoogleConnected
    Import-Module PSGSuite -Force

    Add-GSGroupMember -Identity $GroupEmail -Member $MemberEmail -Role $Role
    Write-Host "Added $MemberEmail to group $GroupEmail as $Role" -ForegroundColor Green
}

function Remove-GoogleGroupMember {
    param(
        [Parameter(Mandatory)][string]$GroupEmail,
        [Parameter(Mandatory)][string]$MemberEmail
    )

    Ensure-GoogleConnected
    Import-Module PSGSuite -Force

    Remove-GSGroupMember -Identity $GroupEmail -Member $MemberEmail -Confirm:$false
    Write-Host "Removed $MemberEmail from group $GroupEmail" -ForegroundColor Green
}

# Org Units
function Get-GoogleOrgUnits {
    Ensure-GoogleConnected
    Import-Module PSGSuite -Force

    Get-GSOrganizationalUnit | Select-Object Name, OrgUnitPath, ParentOrgUnitPath
}

function Move-GoogleUserToOU {
    param(
        [Parameter(Mandatory)][string]$User,
        [Parameter(Mandatory)][string]$OrgUnitPath
    )

    Ensure-GoogleConnected
    Import-Module PSGSuite -Force

    Update-GSUser -User $User -OrgUnitPath $OrgUnitPath
    Write-Host "Moved $User to OU: $OrgUnitPath" -ForegroundColor Green
}

# License Management
function Get-GoogleUserLicenses {
    param([Parameter(Mandatory)][string]$User)

    Ensure-GoogleConnected
    Import-Module PSGSuite -Force

    Get-GSUserLicense -User $User
}

function Get-GoogleLicenses {
    Ensure-GoogleConnected
    Import-Module PSGSuite -Force

    Get-GSLicense
}
