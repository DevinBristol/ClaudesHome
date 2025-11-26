param(
    [Parameter(Mandatory=$true)][string]$ClassName,
    [Parameter(Mandatory=$false)][string]$Org = "devin1",
    [Parameter(Mandatory=$false)][string]$SourcePath = "force-app/main/default/classes"
)

$classFile = Join-Path $SourcePath "$ClassName.cls"
$metaFile = Join-Path $SourcePath "$ClassName.cls-meta.xml"

if (-not (Test-Path $classFile)) {
    Write-Host "Error: Class file not found: $classFile" -ForegroundColor Red
    exit 1
}

Write-Host "=== Deploy Single Class ===" -ForegroundColor Yellow
Write-Host "Class: $ClassName" -ForegroundColor White
Write-Host "Org: $Org" -ForegroundColor White
Write-Host ""

sf project deploy start -m "ApexClass:$ClassName" -o $Org --test-level RunLocalTests

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Deployment successful!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Deployment failed." -ForegroundColor Red
}
