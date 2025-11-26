<#
.SYNOPSIS
    Mark a task as complete (close the issue).
.EXAMPLE
    .\Complete-Task.ps1 42
    .\Complete-Task.ps1 -Number 42 -Comment "Deployed to prod"
#>
param(
    [Parameter(Mandatory, Position = 0)]
    [int]$Number,

    [string]$Comment
)

if ($Comment) {
    gh issue close $Number --comment $Comment 2>&1 | Out-Null
} else {
    gh issue close $Number 2>&1 | Out-Null
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "Task #$Number completed!" -ForegroundColor Green
} else {
    Write-Host "Failed to close task #$Number" -ForegroundColor Red
}
