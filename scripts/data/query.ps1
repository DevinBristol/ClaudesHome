param(
    [Parameter(Mandatory=$true)][string]$Query,
    [Parameter(Mandatory=$false)][string]$Org = "devin1",
    [Parameter(Mandatory=$false)][string]$OutputFile
)

Write-Host "Running query against $Org..." -ForegroundColor Cyan

if ($OutputFile) {
    sf data query -q $Query -o $Org -r csv > $OutputFile
    Write-Host "Results saved to $OutputFile" -ForegroundColor Green
} else {
    sf data query -q $Query -o $Org
}
