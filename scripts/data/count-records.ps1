param(
    [Parameter(Mandatory=$true)][string]$SObject,
    [Parameter(Mandatory=$false)][string]$Org = "devin1",
    [Parameter(Mandatory=$false)][string]$Where
)

$query = "SELECT COUNT() FROM $SObject"
if ($Where) {
    $query += " WHERE $Where"
}

Write-Host "Counting $SObject records in $Org..." -ForegroundColor Cyan

$result = sf data query -q $query -o $Org -r json | ConvertFrom-Json
$count = $result.totalSize

Write-Host "$SObject : $count records" -ForegroundColor Green

if ($Where) {
    Write-Host "Filter: $Where" -ForegroundColor Gray
}
