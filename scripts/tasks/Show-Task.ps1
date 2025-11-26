<#
.SYNOPSIS
    Show details of a specific task.
.EXAMPLE
    .\Show-Task.ps1 42
#>
param(
    [Parameter(Mandatory, Position = 0)]
    [int]$Number
)

# Load GitHub token from Doppler
. "$PSScriptRoot\..\helpers\Load-GH.ps1"

gh issue view $Number
