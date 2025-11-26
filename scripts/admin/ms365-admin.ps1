<#
.SYNOPSIS
    Microsoft 365 administration functions for ClaudesHome
#>

function Ensure-MS365Connected {
    if (-not $global:MS365Connected) {
        . "$PSScriptRoot\..\auth\connect-ms365.ps1"
        Connect-MS365
    }
}

# Utility
function New-RandomPassword {
    param([int]$Length = 12)
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    -join ((1..$Length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
}

# User Management
function Get-MS365Users {
    param(
        [int]$Top = 100,
        [string]$Filter
    )

    Ensure-MS365Connected
    Import-Module Microsoft.Graph.Users -Force

    $params = @{ Top = $Top; Property = @('DisplayName','UserPrincipalName','Mail','AccountEnabled') }
    if ($Filter) { $params.Filter = $Filter }

    Get-MgUser @params | Select-Object DisplayName, UserPrincipalName, Mail, AccountEnabled
}

function Get-MS365User {
    param([Parameter(Mandatory)][string]$UserPrincipalName)

    Ensure-MS365Connected
    Import-Module Microsoft.Graph.Users -Force

    Get-MgUser -UserId $UserPrincipalName
}

function New-MS365User {
    param(
        [Parameter(Mandatory)][string]$DisplayName,
        [Parameter(Mandatory)][string]$UserPrincipalName,
        [Parameter(Mandatory)][string]$MailNickname,
        [string]$Password = (New-RandomPassword),
        [switch]$ForceChangePassword = $true
    )

    Ensure-MS365Connected
    Import-Module Microsoft.Graph.Users -Force

    $passwordProfile = @{
        Password = $Password
        ForceChangePasswordNextSignIn = $ForceChangePassword.IsPresent
    }

    $user = New-MgUser -DisplayName $DisplayName -UserPrincipalName $UserPrincipalName `
        -MailNickname $MailNickname -AccountEnabled -PasswordProfile $passwordProfile

    Write-Host "Created MS365 user: $UserPrincipalName" -ForegroundColor Green
    Write-Host "Temporary password: $Password" -ForegroundColor Yellow

    return @{
        UserId = $user.Id
        UserPrincipalName = $UserPrincipalName
        Password = $Password
    }
}

function Reset-MS365UserPassword {
    param(
        [Parameter(Mandatory)][string]$UserPrincipalName,
        [string]$NewPassword = (New-RandomPassword),
        [switch]$ForceChange = $true
    )

    Ensure-MS365Connected
    Import-Module Microsoft.Graph.Users -Force

    $params = @{
        passwordProfile = @{
            forceChangePasswordNextSignIn = $ForceChange.IsPresent
            password = $NewPassword
        }
    }

    Update-MgUser -UserId $UserPrincipalName -BodyParameter $params

    Write-Host "Password reset for: $UserPrincipalName" -ForegroundColor Green
    Write-Host "New password: $NewPassword" -ForegroundColor Yellow

    return $NewPassword
}

function Disable-MS365User {
    param([Parameter(Mandatory)][string]$UserPrincipalName)

    Ensure-MS365Connected
    Import-Module Microsoft.Graph.Users -Force

    Update-MgUser -UserId $UserPrincipalName -AccountEnabled:$false
    Write-Host "Disabled MS365 user: $UserPrincipalName" -ForegroundColor Green
}

function Enable-MS365User {
    param([Parameter(Mandatory)][string]$UserPrincipalName)

    Ensure-MS365Connected
    Import-Module Microsoft.Graph.Users -Force

    Update-MgUser -UserId $UserPrincipalName -AccountEnabled:$true
    Write-Host "Enabled MS365 user: $UserPrincipalName" -ForegroundColor Green
}

# Group Management
function Get-MS365Groups {
    param([int]$Top = 100)

    Ensure-MS365Connected
    Import-Module Microsoft.Graph.Groups -Force

    Get-MgGroup -Top $Top | Select-Object DisplayName, Mail, GroupTypes
}

function Get-MS365GroupMembers {
    param([Parameter(Mandatory)][string]$GroupId)

    Ensure-MS365Connected
    Import-Module Microsoft.Graph.Groups -Force

    Get-MgGroupMember -GroupId $GroupId | ForEach-Object {
        Get-MgUser -UserId $_.Id -ErrorAction SilentlyContinue
    } | Select-Object DisplayName, UserPrincipalName
}

function Add-MS365GroupMember {
    param(
        [Parameter(Mandatory)][string]$GroupId,
        [Parameter(Mandatory)][string]$UserId
    )

    Ensure-MS365Connected
    Import-Module Microsoft.Graph.Groups -Force

    New-MgGroupMember -GroupId $GroupId -DirectoryObjectId $UserId
    Write-Host "Added user to group" -ForegroundColor Green
}

function Remove-MS365GroupMember {
    param(
        [Parameter(Mandatory)][string]$GroupId,
        [Parameter(Mandatory)][string]$UserId
    )

    Ensure-MS365Connected
    Import-Module Microsoft.Graph.Groups -Force

    Remove-MgGroupMemberByRef -GroupId $GroupId -DirectoryObjectId $UserId
    Write-Host "Removed user from group" -ForegroundColor Green
}

# Mail Operations (requires Microsoft.Graph.Mail)
function Get-MS365UserMail {
    param(
        [Parameter(Mandatory)][string]$UserPrincipalName,
        [int]$Top = 10,
        [string]$Filter
    )

    Ensure-MS365Connected

    if (-not (Get-Module -ListAvailable Microsoft.Graph.Mail)) {
        throw "Microsoft.Graph.Mail module not installed"
    }
    Import-Module Microsoft.Graph.Mail -Force

    $params = @{ UserId = $UserPrincipalName; Top = $Top }
    if ($Filter) { $params.Filter = $Filter }

    Get-MgUserMessage @params | Select-Object Subject, @{N='From';E={$_.From.EmailAddress.Address}}, ReceivedDateTime, IsRead
}

function Send-MS365Mail {
    param(
        [Parameter(Mandatory)][string]$From,
        [Parameter(Mandatory)][string]$To,
        [Parameter(Mandatory)][string]$Subject,
        [Parameter(Mandatory)][string]$Body,
        [ValidateSet("Text","HTML")][string]$BodyType = "Text"
    )

    Ensure-MS365Connected

    if (-not (Get-Module -ListAvailable Microsoft.Graph.Mail)) {
        throw "Microsoft.Graph.Mail module not installed"
    }
    Import-Module Microsoft.Graph.Mail -Force

    $message = @{
        Message = @{
            Subject = $Subject
            Body = @{
                ContentType = $BodyType
                Content = $Body
            }
            ToRecipients = @(
                @{ EmailAddress = @{ Address = $To } }
            )
        }
    }

    Send-MgUserMail -UserId $From -BodyParameter $message
    Write-Host "Email sent from $From to $To" -ForegroundColor Green
}
