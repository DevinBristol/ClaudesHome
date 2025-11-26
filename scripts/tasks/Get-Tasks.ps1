<#
.SYNOPSIS
    List tasks from GitHub Issues.
.EXAMPLE
    .\Get-Tasks.ps1                    # All open tasks
    .\Get-Tasks.ps1 -Category urgent   # Just urgent
    .\Get-Tasks.ps1 -All               # Include closed
#>
param(
    [Parameter(Position = 0)]
    [ValidateSet("urgent", "development", "administration", "ideas", "waiting", "all")]
    [string]$Category = "all",

    [switch]$All,

    [switch]$Brief
)

$state = if ($All) { "all" } else { "open" }

if ($Category -eq "all") {
    # Show summary by category
    $categories = @("urgent", "development", "administration", "waiting")

    foreach ($cat in $categories) {
        $issues = gh issue list --label $cat --state $state --json number,title 2>&1 | ConvertFrom-Json
        $count = if ($issues) { $issues.Count } else { 0 }

        $color = switch ($cat) {
            "urgent" { "Red" }
            "development" { "Blue" }
            "administration" { "Magenta" }
            "waiting" { "Cyan" }
            default { "White" }
        }

        if ($count -gt 0) {
            Write-Host "`n[$cat] - $count task(s)" -ForegroundColor $color
            if (-not $Brief) {
                foreach ($issue in $issues) {
                    Write-Host "  #$($issue.number): $($issue.title)" -ForegroundColor Gray
                }
            }
        }
    }

    # Ideas shown separately
    $ideas = gh issue list --label ideas --state $state --json number,title 2>&1 | ConvertFrom-Json
    if ($ideas -and $ideas.Count -gt 0) {
        Write-Host "`n[ideas] - $($ideas.Count) in the bin" -ForegroundColor Yellow
    }
} else {
    # Show specific category
    $issues = gh issue list --label $Category --state $state --json number,title,createdAt 2>&1 | ConvertFrom-Json

    if ($issues -and $issues.Count -gt 0) {
        Write-Host "[$Category] Tasks:" -ForegroundColor Cyan
        foreach ($issue in $issues) {
            $date = ([datetime]$issue.createdAt).ToString("MM/dd")
            Write-Host "  #$($issue.number) [$date]: $($issue.title)"
        }
    } else {
        Write-Host "No $Category tasks." -ForegroundColor Green
    }
}
