# ==============================================================================
# ONE-CLICK ROM PATCHER FOR REDMI NOTE 6 PRO (TULIP)
# Usage:
#   .\patch_tulip_dynamic_rom.ps1 -RomZip "C:\path\to\ROM.zip"
#   or simply drag & drop the ROM.zip onto this script!
# ==============================================================================

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$RomZip,

    [Parameter(Position=1, Mandatory=$false)]
    [string]$OutZip,

    [switch]$Force
)

$ErrorActionPreference = "Stop"

if (-not $RomZip) {
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host " REDMI NOTE 6 PRO (TULIP) — DYNAMIC PARTITIONS ROM PATCHER" -ForegroundColor Green
    Write-Host "==================================================================" -ForegroundColor Cyan
    $RomZip = Read-Host "Enter full path to the ROM ZIP file (or drag & drop here)"
    $RomZip = $RomZip.Trim('"').Trim("'")
}

if (-not (Test-Path $RomZip)) {
    Write-Error "File not found: $RomZip"
    exit 1
}

$pyCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pyCmd) {
    Write-Error "Python 3 is not installed or not in PATH! Please install Python 3.8+."
    exit 1
}

$pyScript = Join-Path $PSScriptRoot "patch_tulip_dynamic_rom.py"
if (-not (Test-Path $pyScript)) {
    Write-Error "Patcher script missing: $pyScript"
    exit 1
}

if ($PSCmdlet.ShouldProcess($RomZip, "Patch dynamic partition metadata for Tulip")) {
    Write-Host "[*] Executing patch on: $RomZip" -ForegroundColor Yellow
    $pyArgs = @("$pyScript", "$RomZip")
    if ($OutZip) { $pyArgs += "$OutZip" }
    if ($Force) { $pyArgs += "--force" }

    & python $pyArgs

    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n[+] ROM successfully patched for Tulip! Ready to flash via Recovery." -ForegroundColor Green
    } else {
        Write-Host "`n[-] Patch failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}
