<#
.SYNOPSIS
    Move a task to a different category.
.EXAMPLE
    .\Move-Task.ps1 42 urgent        # Make task #42 urgent
    .\Move-Task.ps1 15 waiting       # Move to waiting
#>
param(
    [Parameter(Mandatory, Position = 0)]
    [int]$Number,

    [Parameter(Mandatory, Position = 1)]
    [ValidateSet("urgent", "development", "administration", "ideas", "waiting")]
    [string]$Category
)

$allCategories = @("urgent", "development", "administration", "ideas", "waiting")
$removeLabels = $allCategories | Where-Object { $_ -ne $Category }

# Remove old category labels, add new one
foreach ($label in $removeLabels) {
    gh issue edit $Number --remove-label $label 2>&1 | Out-Null
}
gh issue edit $Number --add-label $Category 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "Task #$Number moved to [$Category]" -ForegroundColor Green
} else {
    Write-Host "Failed to move task #$Number" -ForegroundColor Red
}
