<#
.SYNOPSIS
    Sends long Claude responses via email for mobile readability
.DESCRIPTION
    When using Terminus on mobile, long responses can be hard to read.
    This function emails the response to Devin for easier viewing.
.PARAMETER Content
    The content to email (markdown/text)
.PARAMETER Subject
    Optional subject line (defaults to "Claude Response")
.EXAMPLE
    Send-ClaudeResponse -Content $longResponse
    Send-ClaudeResponse -Content $output -Subject "Query Results"
#>

# Auto-detect Doppler path
$script:DopplerExe = (Get-Command doppler -ErrorAction SilentlyContinue).Source
if (-not $script:DopplerExe) {
    $wingetPath = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages"
    $script:DopplerExe = Get-ChildItem $wingetPath -Filter "doppler.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $script:DopplerExe) { $script:DopplerExe = 'doppler' }

function Get-DopplerSecret {
    param([Parameter(Mandatory)][string]$Name)
    $value = & $script:DopplerExe secrets get $Name --plain 2>$null
    return $value
}

function Send-ClaudeResponse {
    param(
        [Parameter(Mandatory)][string]$Content,
        [string]$Subject = "Claude Response"
    )

    # Get email from Doppler
    $email = Get-DopplerSecret -Name "DEVIN_EMAIL"
    if (-not $email) {
        throw "DEVIN_EMAIL not configured in Doppler. Run: doppler secrets set DEVIN_EMAIL='your@email.com'"
    }

    # Convert markdown-ish content to HTML
    $htmlContent = Convert-ToEmailHtml -Content $Content

    # Import and use MS365 mail function
    $scriptRoot = Split-Path $PSScriptRoot -Parent
    . "$scriptRoot\auth\connect-ms365.ps1"
    . "$scriptRoot\admin\ms365-admin.ps1"

    # Send the email
    try {
        Send-MS365Mail -From $email -To $email -Subject $Subject -Body $htmlContent -BodyType "HTML"
        Write-Host "Response emailed to $email" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to send email: $_" -ForegroundColor Red
        return $false
    }
}

function Convert-ToEmailHtml {
    param([string]$Content)

    # Basic HTML wrapper with styling for readability
    $html = @"
<!DOCTYPE html>
<html>
<head>
<style>
body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    line-height: 1.6;
    padding: 20px;
    max-width: 800px;
    margin: 0 auto;
    color: #333;
}
pre, code {
    font-family: 'SF Mono', Monaco, 'Courier New', monospace;
    background-color: #f4f4f4;
    padding: 2px 6px;
    border-radius: 3px;
    font-size: 14px;
}
pre {
    padding: 12px;
    overflow-x: auto;
    white-space: pre-wrap;
    word-wrap: break-word;
}
table {
    border-collapse: collapse;
    width: 100%;
    margin: 10px 0;
}
th, td {
    border: 1px solid #ddd;
    padding: 8px;
    text-align: left;
}
th {
    background-color: #f4f4f4;
}
h1, h2, h3 {
    color: #2c3e50;
    margin-top: 20px;
}
</style>
</head>
<body>
<pre>$([System.Web.HttpUtility]::HtmlEncode($Content))</pre>
<hr>
<p style="color: #888; font-size: 12px;">Sent from ClaudesHome</p>
</body>
</html>
"@

    return $html
}

# Export for module use
Export-ModuleMember -Function Send-ClaudeResponse -ErrorAction SilentlyContinue
