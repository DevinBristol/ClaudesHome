<#
.SYNOPSIS
    Salesforce administration functions for ClaudesHome
#>

function Ensure-SalesforceConnected {
    if (-not $global:SalesforceConnected) {
        . "$PSScriptRoot\..\auth\connect-salesforce.ps1"
        Connect-Salesforce
    }
}

# Utility
function New-RandomPassword {
    param([int]$Length = 12)
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    -join ((1..$Length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
}

# SOQL Query
function Invoke-SalesforceQuery {
    param(
        [Parameter(Mandatory)][string]$Query,
        [string]$Org = $global:SalesforceAlias
    )

    if (-not $Org) { $Org = "prod" }

    $result = sf data query --query $Query --target-org $Org --json 2>&1 | ConvertFrom-Json
    if ($result.status -ne 0) {
        throw "Query failed: $($result.message)"
    }
    return $result.result.records
}

# User Management
function Get-SalesforceUsers {
    param(
        [switch]$ActiveOnly,
        [int]$Limit = 100,
        [string]$Org
    )

    if (-not $Org) { $Org = $global:SalesforceAlias; if (-not $Org) { $Org = "prod" } }

    $query = "SELECT Id, Username, Email, Name, IsActive, Profile.Name FROM User"
    if ($ActiveOnly) { $query += " WHERE IsActive = true" }
    $query += " ORDER BY Name LIMIT $Limit"

    Invoke-SalesforceQuery -Query $query -Org $Org
}

function Get-SalesforceUser {
    param(
        [Parameter(Mandatory)][string]$Email,
        [string]$Org
    )

    if (-not $Org) { $Org = $global:SalesforceAlias; if (-not $Org) { $Org = "prod" } }

    $query = "SELECT Id, Username, Email, Name, IsActive, Profile.Name, ProfileId FROM User WHERE Email = '$Email' LIMIT 1"
    Invoke-SalesforceQuery -Query $query -Org $Org
}

function New-SalesforceUser {
    param(
        [Parameter(Mandatory)][string]$FirstName,
        [Parameter(Mandatory)][string]$LastName,
        [Parameter(Mandatory)][string]$Email,
        [Parameter(Mandatory)][string]$Username,
        [Parameter(Mandatory)][string]$ProfileId,
        [string]$Alias,
        [string]$Org
    )

    Ensure-SalesforceConnected
    . "$PSScriptRoot\..\auth\connect-salesforce.ps1"

    if (-not $Org) { $Org = $global:SalesforceAlias; if (-not $Org) { $Org = "prod" } }

    # Generate alias if not provided
    if (-not $Alias) {
        $Alias = ($FirstName.Substring(0,1) + $LastName).ToLower()
        if ($Alias.Length -gt 8) { $Alias = $Alias.Substring(0,8) }
    }

    $user = @{
        FirstName = $FirstName
        LastName = $LastName
        Email = $Email
        Username = $Username
        Alias = $Alias
        ProfileId = $ProfileId
        TimeZoneSidKey = "America/Chicago"
        LocaleSidKey = "en_US"
        EmailEncodingKey = "UTF-8"
        LanguageLocaleKey = "en_US"
    }

    $result = Invoke-SalesforceAPI -Endpoint "sobjects/User" -Method POST -Body $user -Alias $Org

    Write-Host "Created Salesforce user: $Username (ID: $($result.id))" -ForegroundColor Green
    Write-Host "User will receive password reset email" -ForegroundColor Yellow

    return $result
}

function Reset-SalesforceUserPassword {
    param(
        [Parameter(Mandatory)][string]$UserId,
        [string]$Org
    )

    Ensure-SalesforceConnected
    . "$PSScriptRoot\..\auth\connect-salesforce.ps1"

    if (-not $Org) { $Org = $global:SalesforceAlias; if (-not $Org) { $Org = "prod" } }

    # DELETE on password endpoint triggers reset email
    Invoke-SalesforceAPI -Endpoint "sobjects/User/$UserId/password" -Method DELETE -Alias $Org

    Write-Host "Password reset triggered for user $UserId - they will receive an email" -ForegroundColor Green
}

function Disable-SalesforceUser {
    param(
        [Parameter(Mandatory)][string]$UserId,
        [string]$Org
    )

    Ensure-SalesforceConnected
    . "$PSScriptRoot\..\auth\connect-salesforce.ps1"

    if (-not $Org) { $Org = $global:SalesforceAlias; if (-not $Org) { $Org = "prod" } }

    Invoke-SalesforceAPI -Endpoint "sobjects/User/$UserId" -Method PATCH -Body @{ IsActive = $false } -Alias $Org

    Write-Host "Deactivated Salesforce user: $UserId" -ForegroundColor Green
}

function Enable-SalesforceUser {
    param(
        [Parameter(Mandatory)][string]$UserId,
        [string]$Org
    )

    Ensure-SalesforceConnected
    . "$PSScriptRoot\..\auth\connect-salesforce.ps1"

    if (-not $Org) { $Org = $global:SalesforceAlias; if (-not $Org) { $Org = "prod" } }

    Invoke-SalesforceAPI -Endpoint "sobjects/User/$UserId" -Method PATCH -Body @{ IsActive = $true } -Alias $Org

    Write-Host "Activated Salesforce user: $UserId" -ForegroundColor Green
}

# Profile and Permission Set Management
function Get-SalesforceProfiles {
    param([string]$Org)
    if (-not $Org) { $Org = $global:SalesforceAlias; if (-not $Org) { $Org = "prod" } }
    Invoke-SalesforceQuery -Query "SELECT Id, Name FROM Profile ORDER BY Name" -Org $Org
}

function Get-SalesforcePermissionSets {
    param([string]$Org)
    if (-not $Org) { $Org = $global:SalesforceAlias; if (-not $Org) { $Org = "prod" } }
    Invoke-SalesforceQuery -Query "SELECT Id, Name, Label FROM PermissionSet WHERE IsOwnedByProfile = false ORDER BY Name" -Org $Org
}

function Get-SalesforceUserPermissionSets {
    param(
        [Parameter(Mandatory)][string]$UserId,
        [string]$Org
    )
    if (-not $Org) { $Org = $global:SalesforceAlias; if (-not $Org) { $Org = "prod" } }
    Invoke-SalesforceQuery -Query "SELECT PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId = '$UserId'" -Org $Org
}

function Add-SalesforcePermissionSetAssignment {
    param(
        [Parameter(Mandatory)][string]$UserId,
        [Parameter(Mandatory)][string]$PermissionSetId,
        [string]$Org
    )

    Ensure-SalesforceConnected
    . "$PSScriptRoot\..\auth\connect-salesforce.ps1"

    if (-not $Org) { $Org = $global:SalesforceAlias; if (-not $Org) { $Org = "prod" } }

    $assignment = @{
        AssigneeId = $UserId
        PermissionSetId = $PermissionSetId
    }

    Invoke-SalesforceAPI -Endpoint "sobjects/PermissionSetAssignment" -Method POST -Body $assignment -Alias $Org
    Write-Host "Assigned permission set to user" -ForegroundColor Green
}

# Org Info
function Get-SalesforceOrgLimits {
    param([string]$Org)
    if (-not $Org) { $Org = $global:SalesforceAlias; if (-not $Org) { $Org = "prod" } }

    $result = sf org list limits --target-org $Org --json 2>&1 | ConvertFrom-Json
    if ($result.status -ne 0) {
        throw "Failed to get limits: $($result.message)"
    }

    # Return limits that are above 75% usage
    $result.result | Where-Object {
        $_.max -gt 0 -and ($_.remaining / $_.max) -lt 0.25
    } | Select-Object name, remaining, max, @{N='UsedPercent';E={[math]::Round((1 - $_.remaining/$_.max) * 100, 1)}}
}
