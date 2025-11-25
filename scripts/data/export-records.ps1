param(
    [Parameter(Mandatory=$true)][string]$Query,
    [Parameter(Mandatory=$false)][string]$Org = "devin1",
    [Parameter(Mandatory=$false)][string]$OutputPath = ".\temp"
)

Write-Host "Exporting records from $Org..." -ForegroundColor Cyan
Write-Host "Query: $Query" -ForegroundColor Gray

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outputFile = Join-Path $OutputPath "export_$timestamp.csv"

sf data query -q $Query -o $Org -r csv > $outputFile

if (Test-Path $outputFile) {
    $lineCount = (Get-Content $outputFile | Measure-Object -Line).Lines - 1
    Write-Host "Exported $lineCount records to $outputFile" -ForegroundColor Green
} else {
    Write-Host "Export failed or no records found." -ForegroundColor Red
}
