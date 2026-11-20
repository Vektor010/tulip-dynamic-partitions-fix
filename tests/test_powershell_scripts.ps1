# ==============================================================================
# Comprehensive Automated Test Suite for PowerShell Scripts
# Validates AST syntax, error paths, parameter binding, -WhatIf, and fail-closed gates
# Environment: Windows PowerShell 5.1+
# ==============================================================================

$repoRoot = Split-Path $PSScriptRoot -Parent
$failedTests = 0
$totalTests = 0

function Assert-Test($name, [scriptblock]$condition) {
    $script:totalTests++
    try {
        $result = & $condition
        if ($result) {
            Write-Host "  [PASS] $name" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] $name (Assertion returned false)" -ForegroundColor Red
            $script:failedTests++
        }
    } catch {
        Write-Host "  [FAIL] $name (Exception: $($_.Exception.Message))" -ForegroundColor Red
        $script:failedTests++
    }
}

Write-Host "`n=== 1. AST SYNTAX & PARSER VERIFICATION ===" -ForegroundColor Cyan
$psFiles = Get-ChildItem -Path $repoRoot -Recurse -Filter "*.ps1"
foreach ($f in $psFiles) {
    Assert-Test "AST Syntax Valid: $($f.Name)" {
        $tokens = $null; $errors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($f.FullName, [ref]$tokens, [ref]$errors) | Out-Null
        return ($errors.Count -eq 0)
    }
}

Write-Host "`n=== 2. PATCHER SCRIPT TESTS (patch_tulip_dynamic_rom.ps1) ===" -ForegroundColor Cyan
$patcherScript = Join-Path $repoRoot "scripts\patch_tulip_dynamic_rom.ps1"

Assert-Test "Rejects non-existent file path with non-zero exit" {
    $p = Start-Process powershell -ArgumentList "-NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$patcherScript`" -RomZip `"$repoRoot\nonexistent_test.zip`"" -PassThru -WindowStyle Hidden
    $finished = $p.WaitForExit(5000)
    if (-not $finished) { $p.Kill(); return $false }
    return ($p.ExitCode -ne 0)
}

Assert-Test "Supports -WhatIf without executing binary mutations" {
    $dummyFile = Join-Path $env:TEMP "tulip_dummy_rom.zip"
    "DUMMY_DATA" | Out-File $dummyFile -Encoding ascii
    try {
        $output = powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "$patcherScript" -RomZip "$dummyFile" -WhatIf
        return ($output -match "What if:")
    } finally {
        Remove-Item $dummyFile -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "`n=== 3. ADB SCRIPTS FAIL-CLOSED GATES (WHEN DISCONNECTED) ===" -ForegroundColor Cyan
$optimizeScript = Join-Path $repoRoot "scripts\optimize_android17.ps1"
$restoreScript = Join-Path $repoRoot "scripts\restore_android17.ps1"

Assert-Test "optimize_android17.ps1 aborts safely when no device connected" {
    $p = Start-Process powershell -ArgumentList "-NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$optimizeScript`"" -PassThru -WindowStyle Hidden
    $finished = $p.WaitForExit(5000)
    if (-not $finished) { $p.Kill(); return $false }
    return ($p.ExitCode -eq 1)
}

Assert-Test "restore_android17.ps1 aborts safely when no device connected" {
    $p = Start-Process powershell -ArgumentList "-NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$restoreScript`"" -PassThru -WindowStyle Hidden
    $finished = $p.WaitForExit(5000)
    if (-not $finished) { $p.Kill(); return $false }
    return ($p.ExitCode -eq 1)
}

Write-Host "`n=======================================================" -ForegroundColor Cyan
Write-Host " Test Summary: $totalTests run, $failedTests failed." -ForegroundColor $(if ($failedTests -eq 0) { "Green" } else { "Red" })
Write-Host "=======================================================`n" -ForegroundColor Cyan

if ($failedTests -gt 0) {
    exit 1
}
