param(
    [Parameter(Mandatory=$false)][string]$Org = "devin1",
    [Parameter(Mandatory=$false)][switch]$All
)

Write-Host "Checking org limits for $Org..." -ForegroundColor Cyan
Write-Host ""

$limits = sf org list limits -o $Org --json | ConvertFrom-Json

if ($limits.status -eq 0) {
    $results = $limits.result

    # Filter to show important limits or all
    $importantLimits = @(
        "DailyApiRequests",
        "DailyAsyncApexExecutions",
        "DailyBulkApiRequests",
        "DataStorageMB",
        "FileStorageMB",
        "DailyStreamingApiEvents",
        "HourlyDashboardRefreshes",
        "HourlyODataCallout",
        "HourlySyncReportRuns",
        "DailyWorkflowEmails",
        "SingleEmail",
        "MassEmail"
    )

    Write-Host "=== Org Limits ===" -ForegroundColor Yellow

    foreach ($limit in $results) {
        if ($All -or $importantLimits -contains $limit.name) {
            $used = $limit.max - $limit.remaining
            $pct = if ($limit.max -gt 0) { [math]::Round(($used / $limit.max) * 100, 1) } else { 0 }

            $color = "Green"
            if ($pct -gt 75) { $color = "Yellow" }
            if ($pct -gt 90) { $color = "Red" }

            Write-Host "$($limit.name): " -NoNewline
            Write-Host "$used / $limit.max ($pct%)" -ForegroundColor $color
        }
    }

    if (-not $All) {
        Write-Host ""
        Write-Host "Use -All to see all limits" -ForegroundColor Gray
    }
} else {
    Write-Host "Error fetching limits" -ForegroundColor Red
}
