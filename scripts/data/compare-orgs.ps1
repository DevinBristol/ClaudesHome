param(
    [Parameter(Mandatory=$true)][string]$Query,
    [Parameter(Mandatory=$true)][string]$Org1,
    [Parameter(Mandatory=$true)][string]$Org2,
    [Parameter(Mandatory=$false)][string]$CompareField = "Id"
)

Write-Host "=== Org Comparison ===" -ForegroundColor Yellow
Write-Host "Query: $Query" -ForegroundColor Gray
Write-Host "Comparing $Org1 vs $Org2" -ForegroundColor White
Write-Host ""

Write-Host "Querying $Org1..." -ForegroundColor Cyan
$result1 = sf data query -q $Query -o $Org1 -r json | ConvertFrom-Json
$count1 = $result1.totalSize

Write-Host "Querying $Org2..." -ForegroundColor Cyan
$result2 = sf data query -q $Query -o $Org2 -r json | ConvertFrom-Json
$count2 = $result2.totalSize

Write-Host ""
Write-Host "=== Results ===" -ForegroundColor Yellow
Write-Host "$Org1 : $count1 records" -ForegroundColor White
Write-Host "$Org2 : $count2 records" -ForegroundColor White

$diff = $count1 - $count2
if ($diff -gt 0) {
    Write-Host "Difference: $Org1 has $diff more records" -ForegroundColor Cyan
} elseif ($diff -lt 0) {
    Write-Host "Difference: $Org2 has $([Math]::Abs($diff)) more records" -ForegroundColor Cyan
} else {
    Write-Host "Record counts match!" -ForegroundColor Green
}
