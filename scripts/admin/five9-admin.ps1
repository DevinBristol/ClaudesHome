<#
.SYNOPSIS
    Five9 administration functions for ClaudesHome
#>

# Ensure connected
function Ensure-Five9Connected {
    if (-not $global:Five9Connected) {
        . "$PSScriptRoot\..\auth\connect-five9.ps1"
        Connect-Five9
    }
}

# User Management
function Get-Five9Users {
    Ensure-Five9Connected
    Get-Five9User
}

function New-Five9Agent {
    param(
        [Parameter(Mandatory)][string]$FirstName,
        [Parameter(Mandatory)][string]$LastName,
        [Parameter(Mandatory)][string]$Email,
        [string]$Password = (New-RandomPassword)
    )

    Ensure-Five9Connected

    $username = $Email
    New-Five9User -DefaultRole Agent -FirstName $FirstName -LastName $LastName `
        -UserName $username -Email $Email -Password $Password

    Write-Host "Created Five9 agent: $username" -ForegroundColor Green
    Write-Host "Temporary password: $Password" -ForegroundColor Yellow

    return @{
        Username = $username
        Password = $Password
    }
}

function Reset-Five9UserPassword {
    param(
        [Parameter(Mandatory)][string]$Username,
        [string]$NewPassword = (New-RandomPassword)
    )

    Ensure-Five9Connected

    Set-Five9User -Username $Username -Password $NewPassword

    Write-Host "Password reset for: $Username" -ForegroundColor Green
    Write-Host "New password: $NewPassword" -ForegroundColor Yellow

    return $NewPassword
}

function Disable-Five9User {
    param([Parameter(Mandatory)][string]$Username)

    Ensure-Five9Connected
    Set-Five9User -Username $Username -Active $false
    Write-Host "Disabled Five9 user: $Username" -ForegroundColor Green
}

function Enable-Five9User {
    param([Parameter(Mandatory)][string]$Username)

    Ensure-Five9Connected
    Set-Five9User -Username $Username -Active $true
    Write-Host "Enabled Five9 user: $Username" -ForegroundColor Green
}

# Campaign Management
function Get-Five9Campaigns {
    Ensure-Five9Connected
    Get-Five9Campaign
}

function Start-Five9Campaign {
    param([Parameter(Mandatory)][string]$Name)
    Ensure-Five9Connected
    Start-Five9Campaign -Name $Name
    Write-Host "Started campaign: $Name" -ForegroundColor Green
}

function Stop-Five9Campaign {
    param([Parameter(Mandatory)][string]$Name)
    Ensure-Five9Connected
    Stop-Five9Campaign -Name $Name
    Write-Host "Stopped campaign: $Name" -ForegroundColor Green
}

# ANI Management
function Get-Five9ANIs {
    Ensure-Five9Connected
    Get-Five9DNIS
}

function Set-Five9ANIStatus {
    param(
        [Parameter(Mandatory)][string]$ANI,
        [Parameter(Mandatory)][string]$Campaign,
        [Parameter(Mandatory)][ValidateSet("Active","Inactive")][string]$Status
    )

    Ensure-Five9Connected

    if ($Status -eq "Active") {
        Add-Five9CampaignDNIS -CampaignName $Campaign -DNISName $ANI
        Write-Host "Activated ANI $ANI on campaign $Campaign" -ForegroundColor Green
    } else {
        Remove-Five9CampaignDNIS -CampaignName $Campaign -DNISName $ANI
        Write-Host "Deactivated ANI $ANI on campaign $Campaign" -ForegroundColor Yellow
    }
}

# Skills
function Get-Five9Skills {
    Ensure-Five9Connected
    Get-Five9Skill
}

function Add-Five9UserSkill {
    param(
        [Parameter(Mandatory)][string]$Username,
        [Parameter(Mandatory)][string]$SkillName
    )

    Ensure-Five9Connected
    Add-Five9SkillMember -Name $SkillName -Username $Username
    Write-Host "Added skill '$SkillName' to user '$Username'" -ForegroundColor Green
}

function Remove-Five9UserSkill {
    param(
        [Parameter(Mandatory)][string]$Username,
        [Parameter(Mandatory)][string]$SkillName
    )

    Ensure-Five9Connected
    Remove-Five9SkillMember -Name $SkillName -Username $Username
    Write-Host "Removed skill '$SkillName' from user '$Username'" -ForegroundColor Green
}

# Utility
function New-RandomPassword {
    param([int]$Length = 12)
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%"
    -join ((1..$Length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
}
