<#
.SYNOPSIS
    Add a task to GitHub Issues for cross-PC sync.
.EXAMPLE
    .\Add-Task.ps1 -Title "Fix login bug" -Category development
    .\Add-Task.ps1 "Call Cameron back" urgent
    .\Add-Task.ps1 "Explore AI integrations" ideas
#>
param(
    [Parameter(Mandatory, Position = 0)]
    [string]$Title,

    [Parameter(Position = 1)]
    [ValidateSet("urgent", "development", "administration", "ideas", "waiting")]
    [string]$Category = "development",

    [string]$Body,

    [string]$WaitingOn
)

# Load GitHub token from Doppler
. "$PSScriptRoot\..\helpers\Load-GH.ps1"

if ($Category -eq "waiting" -and $WaitingOn) {
    $Title = "$Title - waiting on $WaitingOn"
}

$issueBody = if ($Body) { $Body } else { "Created from ClaudesHome" }
$args = @("issue", "create", "--title", $Title, "--label", $Category, "--body", $issueBody)

$result = gh @args 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "Task added: $Title [$Category]" -ForegroundColor Green
    Write-Host $result -ForegroundColor Cyan
} else {
    Write-Host "Failed to add task: $result" -ForegroundColor Red
}
