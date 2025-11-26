param(
    [Parameter(Mandatory=$true)][string]$SObject,
    [Parameter(Mandatory=$true)][string]$CsvFile,
    [Parameter(Mandatory=$false)][string]$Org = "devin1",
    [Parameter(Mandatory=$false)][switch]$Upsert,
    [Parameter(Mandatory=$false)][string]$ExternalId
)

if (-not (Test-Path $CsvFile)) {
    Write-Host "Error: CSV file not found: $CsvFile" -ForegroundColor Red
    exit 1
}

$recordCount = (Get-Content $CsvFile | Measure-Object -Line).Lines - 1
Write-Host "=== Bulk Update ===" -ForegroundColor Yellow
Write-Host "Object: $SObject" -ForegroundColor White
Write-Host "File: $CsvFile ($recordCount records)" -ForegroundColor White
Write-Host "Org: $Org" -ForegroundColor White

if ($Upsert) {
    Write-Host "Operation: UPSERT (External ID: $ExternalId)" -ForegroundColor White
} else {
    Write-Host "Operation: UPDATE" -ForegroundColor White
}

Write-Host ""
$confirm = Read-Host "Proceed with bulk update? (y/n)"

if ($confirm -eq 'y') {
    if ($Upsert -and $ExternalId) {
        sf data upsert bulk -s $SObject -f $CsvFile -i $ExternalId -o $Org -w 10
    } else {
        sf data update bulk -s $SObject -f $CsvFile -o $Org -w 10
    }
} else {
    Write-Host "Bulk update cancelled." -ForegroundColor Red
}
