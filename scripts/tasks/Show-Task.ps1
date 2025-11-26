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

gh issue view $Number
