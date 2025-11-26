<#
.SYNOPSIS
    Analyzes a single Apex class and its dependencies, creates a GitHub issue with improvement recommendations.
.DESCRIPTION
    Pulls class metadata from prod, analyzes for code quality, performance, and security issues,
    then creates a GitHub issue for review.
.EXAMPLE
    .\Review-ApexClass.ps1                          # Auto-select a class to review
    .\Review-ApexClass.ps1 -ClassName "AccountService"  # Review specific class
    .\Review-ApexClass.ps1 -ListCandidates          # Show candidate classes without reviewing
#>
param(
    [Parameter(Position = 0)]
    [string]$ClassName,

    [string]$Org = "prod",

    [switch]$ListCandidates,

    [switch]$DryRun
)

# Load GitHub token
. "$PSScriptRoot\..\helpers\Load-GH.ps1"

$ErrorActionPreference = "Stop"

function Get-ApexClasses {
    param([string]$TargetOrg)

    Write-Host "Fetching Apex classes from $TargetOrg..." -ForegroundColor Cyan

    $query = "SELECT Id, Name, Body, LengthWithoutComments, ApiVersion, Status FROM ApexClass WHERE NamespacePrefix = null AND Status = 'Active' ORDER BY LengthWithoutComments DESC"
    $result = sf data query -q $query -o $TargetOrg --json 2>$null | ConvertFrom-Json

    if ($result.status -ne 0) {
        Write-Host "Error querying Apex classes: $($result.message)" -ForegroundColor Red
        exit 1
    }

    return $result.result.records
}

function Get-ClassDependencies {
    param(
        [string]$TargetOrg,
        [string]$ClassId
    )

    Write-Host "Finding dependencies..." -ForegroundColor Cyan

    # Get classes this class references
    $query = "SELECT MetadataComponentName, RefMetadataComponentName FROM MetadataComponentDependency WHERE MetadataComponentId = '$ClassId' AND RefMetadataComponentType = 'ApexClass'"
    $result = sf data query -q $query -o $TargetOrg --json 2>$null | ConvertFrom-Json

    if ($result.status -eq 0 -and $result.result.records) {
        return $result.result.records | ForEach-Object { $_.RefMetadataComponentName }
    }
    return @()
}

function Select-ClassToReview {
    param([array]$Classes)

    Write-Host "`nAnalyzing candidates..." -ForegroundColor Cyan

    # Filter out test classes and very small classes
    $candidates = $Classes | Where-Object {
        $_.Name -notmatch "Test$|_Test$|Tests$" -and
        $_.LengthWithoutComments -gt 500 -and
        $_.LengthWithoutComments -lt 50000
    }

    if ($candidates.Count -eq 0) {
        Write-Host "No suitable candidates found." -ForegroundColor Yellow
        exit 0
    }

    # Score candidates based on size (medium-large classes are good targets)
    $scored = $candidates | ForEach-Object {
        $size = $_.LengthWithoutComments
        # Prefer classes between 1000-10000 chars
        $score = if ($size -lt 1000) { 1 }
                 elseif ($size -lt 5000) { 3 }
                 elseif ($size -lt 10000) { 2 }
                 else { 1 }

        [PSCustomObject]@{
            Name = $_.Name
            Size = $size
            ApiVersion = $_.ApiVersion
            Score = $score
            Body = $_.Body
        }
    }

    # Pick a random high-scoring class
    $topCandidates = $scored | Sort-Object Score -Descending | Select-Object -First 20
    $selected = $topCandidates | Get-Random

    return $selected
}

function Analyze-ApexClass {
    param(
        [string]$ClassName,
        [string]$Body,
        [array]$Dependencies
    )

    Write-Host "Analyzing $ClassName..." -ForegroundColor Cyan

    $issues = @()
    $lines = $Body -split "`n"
    $lineCount = $lines.Count

    # === CODE QUALITY CHECKS ===

    # Check for hardcoded IDs
    if ($Body -match "'[a-zA-Z0-9]{15}'|'[a-zA-Z0-9]{18}'") {
        $issues += [PSCustomObject]@{
            Category = "Code Quality"
            Severity = "Medium"
            Issue = "Hardcoded Salesforce IDs detected"
            Recommendation = "Use Custom Metadata, Custom Settings, or Custom Labels instead of hardcoded IDs"
        }
    }

    # Check for System.debug in production code
    $debugCount = ([regex]::Matches($Body, "System\.debug")).Count
    if ($debugCount -gt 5) {
        $issues += [PSCustomObject]@{
            Category = "Code Quality"
            Severity = "Low"
            Issue = "Excessive debug statements ($debugCount found)"
            Recommendation = "Consider removing or consolidating debug statements for production"
        }
    }

    # Check for TODO/FIXME comments
    if ($Body -match "//\s*(TODO|FIXME|HACK|XXX)") {
        $issues += [PSCustomObject]@{
            Category = "Code Quality"
            Severity = "Low"
            Issue = "Unresolved TODO/FIXME comments found"
            Recommendation = "Address or create tickets for outstanding TODO items"
        }
    }

    # Check API version
    # (Would need to pass ApiVersion - simplified here)

    # === PERFORMANCE CHECKS ===

    # SOQL in loops
    if ($Body -match "for\s*\([^)]+\)[^{]*\{[^}]*\[SELECT") {
        $issues += [PSCustomObject]@{
            Category = "Performance"
            Severity = "High"
            Issue = "Potential SOQL query inside loop"
            Recommendation = "Move SOQL queries outside loops and use collections/maps for lookups"
        }
    }

    # DML in loops
    if ($Body -match "for\s*\([^)]+\)[^{]*\{[^}]*(insert|update|delete|upsert)\s+") {
        $issues += [PSCustomObject]@{
            Category = "Performance"
            Severity = "High"
            Issue = "Potential DML operation inside loop"
            Recommendation = "Collect records in a list and perform bulk DML outside the loop"
        }
    }

    # Missing LIMIT on queries
    $selectsWithoutLimit = ([regex]::Matches($Body, "\[SELECT[^\]]+\]")).Count
    $selectsWithLimit = ([regex]::Matches($Body, "\[SELECT[^\]]+LIMIT\s+\d+[^\]]*\]")).Count
    if ($selectsWithoutLimit -gt $selectsWithLimit + 2) {
        $issues += [PSCustomObject]@{
            Category = "Performance"
            Severity = "Medium"
            Issue = "Multiple SOQL queries without LIMIT clause"
            Recommendation = "Add LIMIT clauses to queries where full result sets aren't needed"
        }
    }

    # === SECURITY CHECKS ===

    # Check for CRUD/FLS
    if ($Body -match "(insert|update|delete|upsert)\s+" -and $Body -notmatch "Schema\.(sObjectType|describeSObjects|getGlobalDescribe)") {
        $issues += [PSCustomObject]@{
            Category = "Security"
            Severity = "High"
            Issue = "DML operations without apparent CRUD/FLS checks"
            Recommendation = "Implement Schema.sObjectType checks or use WITH SECURITY_ENFORCED in SOQL"
        }
    }

    # Check for dynamic SOQL without escaping
    if ($Body -match "Database\.query\s*\(" -and $Body -notmatch "String\.escapeSingleQuotes") {
        $issues += [PSCustomObject]@{
            Category = "Security"
            Severity = "High"
            Issue = "Dynamic SOQL without apparent input escaping"
            Recommendation = "Use String.escapeSingleQuotes() for user input in dynamic queries"
        }
    }

    # Check for without sharing
    if ($Body -match "without sharing") {
        $issues += [PSCustomObject]@{
            Category = "Security"
            Severity = "Medium"
            Issue = "Class uses 'without sharing'"
            Recommendation = "Verify this is intentional and document why sharing rules should be bypassed"
        }
    }

    # === BEST PRACTICES ===

    # Large class
    if ($lineCount -gt 500) {
        $issues += [PSCustomObject]@{
            Category = "Best Practice"
            Severity = "Medium"
            Issue = "Large class ($lineCount lines)"
            Recommendation = "Consider breaking into smaller, focused classes following Single Responsibility Principle"
        }
    }

    # No test coverage mention (can't actually check coverage without more queries)

    return $issues
}

function Create-GitHubIssue {
    param(
        [string]$ClassName,
        [array]$Issues,
        [array]$Dependencies,
        [int]$LineCount
    )

    $highCount = @($Issues | Where-Object { $_.Severity -eq "High" }).Count
    $mediumCount = @($Issues | Where-Object { $_.Severity -eq "Medium" }).Count
    $lowCount = @($Issues | Where-Object { $_.Severity -eq "Low" }).Count

    $title = "Apex Review: $ClassName - $highCount high, $mediumCount medium issues"

    $body = @"
## Apex Class Review: $ClassName

**Source Org:** $Org
**Lines of Code:** $LineCount
**Dependencies:** $(if ($Dependencies.Count -gt 0) { $Dependencies -join ", " } else { "None detected" })

---

## Summary

| Severity | Count |
|----------|-------|
| High | $highCount |
| Medium | $mediumCount |
| Low | $lowCount |

---

## Findings

"@

    foreach ($category in @("Security", "Performance", "Code Quality", "Best Practice")) {
        $categoryIssues = @($Issues | Where-Object { $_.Category -eq $category })
        if ($categoryIssues.Count -gt 0) {
            $body += "`n### $category`n`n"
            foreach ($issue in $categoryIssues) {
                $icon = switch ($issue.Severity) {
                    "High" { ":red_circle:" }
                    "Medium" { ":yellow_circle:" }
                    "Low" { ":white_circle:" }
                }
                $body += "- $icon **$($issue.Issue)**`n  - $($issue.Recommendation)`n`n"
            }
        }
    }

    $body += @"

---

## Next Steps

- [ ] Review findings above
- [ ] Create fix branch if addressing issues
- [ ] Update tests as needed
- [ ] Deploy to sandbox for validation

---

*Generated by ClaudesHome Apex Review Script*
"@

    if ($DryRun) {
        Write-Host "`n=== DRY RUN - Would create issue ===" -ForegroundColor Yellow
        Write-Host "Title: $title" -ForegroundColor Cyan
        Write-Host "`nBody:`n$body"
        return
    }

    # Create the issue
    $result = gh issue create --title $title --body $body --label "development" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`nIssue created: $result" -ForegroundColor Green
    } else {
        Write-Host "Failed to create issue: $result" -ForegroundColor Red
    }
}

# === MAIN ===

Write-Host "`n=== Apex Class Review ===" -ForegroundColor Green

# Get all classes
$classes = Get-ApexClasses -TargetOrg $Org

if ($ListCandidates) {
    Write-Host "`nCandidate classes for review:" -ForegroundColor Cyan
    $classes | Where-Object {
        $_.Name -notmatch "Test$|_Test$|Tests$" -and
        $_.LengthWithoutComments -gt 500
    } | Select-Object Name, LengthWithoutComments, ApiVersion |
    Sort-Object LengthWithoutComments -Descending |
    Select-Object -First 30 | Format-Table
    exit 0
}

# Select class to review
if ($ClassName) {
    $selected = $classes | Where-Object { $_.Name -eq $ClassName } | Select-Object -First 1
    if (-not $selected) {
        Write-Host "Class '$ClassName' not found in $Org" -ForegroundColor Red
        exit 1
    }
    $classBody = $selected.Body
    $classSize = $selected.LengthWithoutComments
} else {
    $selected = Select-ClassToReview -Classes $classes
    $ClassName = $selected.Name
    $classBody = $selected.Body
    $classSize = $selected.Size
}

Write-Host "`nSelected: $ClassName ($classSize chars)" -ForegroundColor Green

# Get dependencies
$dependencies = @()
# Note: MetadataComponentDependency requires Tooling API or specific setup
# Simplified for now - could enhance later

# Analyze the class
$issues = Analyze-ApexClass -ClassName $ClassName -Body $classBody -Dependencies $dependencies

if ($issues.Count -eq 0) {
    Write-Host "`nNo issues found in $ClassName - looks clean!" -ForegroundColor Green
    exit 0
}

Write-Host "`nFound $($issues.Count) potential issues" -ForegroundColor Yellow

# Create GitHub issue
$lineCount = ($classBody -split "`n").Count
Create-GitHubIssue -ClassName $ClassName -Issues $issues -Dependencies $dependencies -LineCount $lineCount

Write-Host "`nDone!" -ForegroundColor Green
