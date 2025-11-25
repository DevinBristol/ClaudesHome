param(
    [Parameter(Mandatory=$false)][string]$File,
    [Parameter(Mandatory=$false)][string]$Code,
    [Parameter(Mandatory=$false)][string]$Org = "devin1"
)

if (-not $File -and -not $Code) {
    Write-Host "Error: Provide either -File or -Code parameter" -ForegroundColor Red
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\run-apex.ps1 -File path\to\apex.txt -Org devin1" -ForegroundColor Gray
    Write-Host "  .\run-apex.ps1 -Code 'System.debug(UserInfo.getUserName());' -Org devin1" -ForegroundColor Gray
    exit 1
}

Write-Host "Running anonymous Apex in $Org..." -ForegroundColor Cyan

if ($File) {
    if (-not (Test-Path $File)) {
        Write-Host "Error: File not found: $File" -ForegroundColor Red
        exit 1
    }
    Write-Host "File: $File" -ForegroundColor Gray
    sf apex run -f $File -o $Org
} else {
    # Write code to temp file and execute
    $tempFile = Join-Path $env:TEMP "anon_apex_$(Get-Date -Format 'yyyyMMddHHmmss').apex"
    $Code | Out-File -FilePath $tempFile -Encoding UTF8
    sf apex run -f $tempFile -o $Org
    Remove-Item $tempFile -Force
}
