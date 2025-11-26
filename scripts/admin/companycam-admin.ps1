<#
.SYNOPSIS
    Company Cam administration functions for ClaudesHome
    HYBRID: Reads go direct to Company Cam API, Writes go through Salesforce
#>

# ============================================
# READ OPERATIONS (Direct Company Cam API)
# ============================================

function Ensure-CompanyCamConnected {
    if (-not $global:CompanyCamConnected) {
        . "$PSScriptRoot\..\auth\connect-companycam.ps1"
        Test-CompanyCamConnection | Out-Null
    }
}

function Get-CompanyCamProjects {
    param(
        [int]$Page = 1,
        [int]$PerPage = 25,
        [ValidateSet("active","completed","all")][string]$Status
    )

    Ensure-CompanyCamConnected
    . "$PSScriptRoot\..\auth\connect-companycam.ps1"

    $params = @{ page = $Page; per_page = $PerPage }
    if ($Status -and $Status -ne "all") { $params.status = $Status }

    Invoke-CompanyCamReadAPI -Endpoint "projects" -QueryParams $params
}

function Get-CompanyCamProject {
    param([Parameter(Mandatory)][string]$ProjectId)

    Ensure-CompanyCamConnected
    . "$PSScriptRoot\..\auth\connect-companycam.ps1"

    Invoke-CompanyCamReadAPI -Endpoint "projects/$ProjectId"
}

function Search-CompanyCamProjects {
    param(
        [string]$Query,
        [int]$Page = 1,
        [int]$PerPage = 25
    )

    Ensure-CompanyCamConnected
    . "$PSScriptRoot\..\auth\connect-companycam.ps1"

    $params = @{ page = $Page; per_page = $PerPage }
    if ($Query) { $params.query = $Query }

    Invoke-CompanyCamReadAPI -Endpoint "projects" -QueryParams $params
}

function Get-CompanyCamPhotos {
    param(
        [Parameter(Mandatory)][string]$ProjectId,
        [int]$Page = 1,
        [int]$PerPage = 25
    )

    Ensure-CompanyCamConnected
    . "$PSScriptRoot\..\auth\connect-companycam.ps1"

    Invoke-CompanyCamReadAPI -Endpoint "projects/$ProjectId/photos" -QueryParams @{
        page = $Page
        per_page = $PerPage
    }
}

function Get-CompanyCamPhoto {
    param([Parameter(Mandatory)][string]$PhotoId)

    Ensure-CompanyCamConnected
    . "$PSScriptRoot\..\auth\connect-companycam.ps1"

    Invoke-CompanyCamReadAPI -Endpoint "photos/$PhotoId"
}

function Get-CompanyCamComments {
    param([Parameter(Mandatory)][string]$PhotoId)

    Ensure-CompanyCamConnected
    . "$PSScriptRoot\..\auth\connect-companycam.ps1"

    Invoke-CompanyCamReadAPI -Endpoint "photos/$PhotoId/comments"
}

function Get-CompanyCamUsers {
    Ensure-CompanyCamConnected
    . "$PSScriptRoot\..\auth\connect-companycam.ps1"

    Invoke-CompanyCamReadAPI -Endpoint "users"
}

function Get-CompanyCamCurrentUser {
    Ensure-CompanyCamConnected
    . "$PSScriptRoot\..\auth\connect-companycam.ps1"

    Invoke-CompanyCamReadAPI -Endpoint "users/current"
}

function Get-CompanyCamTags {
    Ensure-CompanyCamConnected
    . "$PSScriptRoot\..\auth\connect-companycam.ps1"

    Invoke-CompanyCamReadAPI -Endpoint "tags"
}

function Get-CompanyCamProjectsByTag {
    param(
        [Parameter(Mandatory)][string]$TagId,
        [int]$Page = 1,
        [int]$PerPage = 25
    )

    Ensure-CompanyCamConnected
    . "$PSScriptRoot\..\auth\connect-companycam.ps1"

    Invoke-CompanyCamReadAPI -Endpoint "tags/$TagId/projects" -QueryParams @{
        page = $Page
        per_page = $PerPage
    }
}

# ============================================
# WRITE OPERATIONS (Via Salesforce Proxy)
# ============================================

<#
.SYNOPSIS
    Write operations require routing through Salesforce.

    Before using these functions, you need to:
    1. Discover your existing Company Cam integration in Salesforce
    2. Deploy the CompanyCamProxy Apex class
    3. Configure the Named Credential

    Run the discovery queries first:
    sf data query --query "SELECT QualifiedApiName FROM EntityDefinition WHERE QualifiedApiName LIKE '%Cam%'" --target-org Production
#>

function Invoke-CompanyCamWriteViaSalesforce {
    <#
    .SYNOPSIS
        Execute Company Cam write operation through Salesforce Apex
    .DESCRIPTION
        This function executes anonymous Apex to call the CompanyCamProxy class.
        Requires the CompanyCamProxy Apex class to be deployed in Salesforce.
    #>
    param(
        [Parameter(Mandatory)][string]$ApexCode,
        [string]$Org = "prod"
    )

    # Ensure Salesforce is connected
    if (-not $global:SalesforceConnected) {
        . "$PSScriptRoot\..\auth\connect-salesforce.ps1"
        Connect-Salesforce -Alias $Org
    }

    # Write apex to temp file and execute
    $tempFile = [System.IO.Path]::GetTempFileName() -replace '\.tmp$', '.apex'
    $ApexCode | Set-Content $tempFile -Encoding UTF8

    try {
        $output = sf apex run --file $tempFile --target-org $Org 2>&1

        # Check for success
        if ($output -match "COMPANYCAM_RESULT:(.+)") {
            $resultJson = $matches[1].Trim()
            try {
                return $resultJson | ConvertFrom-Json
            }
            catch {
                return $resultJson
            }
        }

        # Check for errors
        if ($output -match "Error|Exception|FATAL") {
            throw "Apex execution failed: $output"
        }

        return $output
    }
    finally {
        Remove-Item $tempFile -ErrorAction SilentlyContinue
    }
}

function New-CompanyCamProject {
    <#
    .SYNOPSIS
        Create a new Company Cam project (via Salesforce)
    .DESCRIPTION
        Routes through Salesforce's authorized Company Cam integration.
        Requires CompanyCamProxy Apex class to be deployed.
    #>
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$StreetAddress,
        [string]$City,
        [string]$State,
        [string]$PostalCode,
        [string]$Org = "prod"
    )

    # Escape single quotes
    $escapedName = $Name -replace "'", "\\'"
    $escapedStreet = if ($StreetAddress) { $StreetAddress -replace "'", "\\'" } else { "" }
    $escapedCity = if ($City) { $City } else { "" }
    $escapedState = if ($State) { $State } else { "" }
    $escapedPostal = if ($PostalCode) { $PostalCode } else { "" }

    $apex = @"
String result = CompanyCamProxy.createProject(
    '$escapedName',
    '$escapedStreet',
    '$escapedCity',
    '$escapedState',
    '$escapedPostal'
);
System.debug('COMPANYCAM_RESULT:' + result);
"@

    try {
        $result = Invoke-CompanyCamWriteViaSalesforce -ApexCode $apex -Org $Org
        Write-Host "Created Company Cam project: $Name" -ForegroundColor Green
        return $result
    }
    catch {
        Write-Host "Failed to create project. Ensure CompanyCamProxy Apex class is deployed." -ForegroundColor Red
        throw $_
    }
}

function Add-CompanyCamComment {
    <#
    .SYNOPSIS
        Add a comment to a Company Cam photo (via Salesforce)
    #>
    param(
        [Parameter(Mandatory)][string]$PhotoId,
        [Parameter(Mandatory)][string]$Content,
        [string]$Org = "prod"
    )

    # Escape single quotes
    $escapedContent = $Content -replace "'", "\\'"

    $apex = @"
String result = CompanyCamProxy.addPhotoComment('$PhotoId', '$escapedContent');
System.debug('COMPANYCAM_RESULT:' + result);
"@

    try {
        $result = Invoke-CompanyCamWriteViaSalesforce -ApexCode $apex -Org $Org
        Write-Host "Added comment to photo $PhotoId" -ForegroundColor Green
        return $result
    }
    catch {
        Write-Host "Failed to add comment. Ensure CompanyCamProxy Apex class is deployed." -ForegroundColor Red
        throw $_
    }
}

function Update-CompanyCamProject {
    <#
    .SYNOPSIS
        Update a Company Cam project (via Salesforce)
    #>
    param(
        [Parameter(Mandatory)][string]$ProjectId,
        [string]$Name,
        [ValidateSet("active","completed")][string]$Status,
        [string]$Org = "prod"
    )

    $updates = @{}
    if ($Name) { $updates.name = $Name }
    if ($Status) { $updates.status = $Status }

    $updatesJson = ($updates | ConvertTo-Json -Compress) -replace '"', '\"'

    $apex = @"
Map<String, Object> updates = (Map<String, Object>) JSON.deserializeUntyped('$updatesJson');
String result = CompanyCamProxy.updateProject('$ProjectId', updates);
System.debug('COMPANYCAM_RESULT:' + result);
"@

    try {
        $result = Invoke-CompanyCamWriteViaSalesforce -ApexCode $apex -Org $Org
        Write-Host "Updated project $ProjectId" -ForegroundColor Green
        return $result
    }
    catch {
        Write-Host "Failed to update project. Ensure CompanyCamProxy Apex class is deployed." -ForegroundColor Red
        throw $_
    }
}

# ============================================
# DATA RECONCILIATION
# ============================================

function Sync-CompanyCamData {
    <#
    .SYNOPSIS
        Reconcile data between Company Cam and Salesforce
    .DESCRIPTION
        Compares Company Cam projects with Salesforce records to find discrepancies.
        Use -DryRun to see what would be synced without making changes.
    #>
    param(
        [Parameter(Mandatory)][string]$SalesforceObjectName,  # e.g., "CompanyCam_Project__c"
        [Parameter(Mandatory)][string]$ExternalIdField,       # e.g., "CC_Project_Id__c"
        [string]$Org = "prod",
        [switch]$DryRun
    )

    Write-Host "Fetching projects from Company Cam..." -ForegroundColor Cyan
    $ccProjects = Get-CompanyCamProjects -PerPage 100

    Write-Host "Fetching records from Salesforce..." -ForegroundColor Cyan

    # Ensure Salesforce is connected
    if (-not $global:SalesforceConnected) {
        . "$PSScriptRoot\..\auth\connect-salesforce.ps1"
        Connect-Salesforce -Alias $Org
    }
    . "$PSScriptRoot\salesforce-admin.ps1"

    $query = "SELECT Id, $ExternalIdField, Name FROM $SalesforceObjectName"
    $sfRecords = Invoke-SalesforceQuery -Query $query -Org $Org

    # Build lookup
    $sfLookup = @{}
    foreach ($rec in $sfRecords) {
        $ccId = $rec.$ExternalIdField
        if ($ccId) {
            $sfLookup[$ccId] = $rec
        }
    }

    # Find discrepancies
    $missing = @()
    $nameMismatch = @()

    foreach ($ccProj in $ccProjects) {
        if (-not $sfLookup.ContainsKey($ccProj.id)) {
            $missing += $ccProj
        } elseif ($sfLookup[$ccProj.id].Name -ne $ccProj.name) {
            $nameMismatch += @{
                CompanyCam = $ccProj
                Salesforce = $sfLookup[$ccProj.id]
            }
        }
    }

    Write-Host ""
    Write-Host "=== Sync Report ===" -ForegroundColor Cyan
    Write-Host "Company Cam projects: $($ccProjects.Count)"
    Write-Host "Salesforce records: $($sfRecords.Count)"

    $missingColor = if ($missing.Count -gt 0) { "Yellow" } else { "Green" }
    Write-Host "Missing in Salesforce: $($missing.Count)" -ForegroundColor $missingColor

    $mismatchColor = if ($nameMismatch.Count -gt 0) { "Yellow" } else { "Green" }
    Write-Host "Name mismatches: $($nameMismatch.Count)" -ForegroundColor $mismatchColor

    if ($missing.Count -gt 0) {
        Write-Host ""
        Write-Host "Missing projects:" -ForegroundColor Yellow
        $missing | ForEach-Object { Write-Host "  - $($_.name) (CC ID: $($_.id))" }
    }

    if ($nameMismatch.Count -gt 0) {
        Write-Host ""
        Write-Host "Name mismatches:" -ForegroundColor Yellow
        $nameMismatch | ForEach-Object {
            Write-Host "  - CC: '$($_.CompanyCam.name)' vs SF: '$($_.Salesforce.Name)'"
        }
    }

    return @{
        Missing = $missing
        NameMismatches = $nameMismatch
        CompanyCamCount = $ccProjects.Count
        SalesforceCount = $sfRecords.Count
    }
}
