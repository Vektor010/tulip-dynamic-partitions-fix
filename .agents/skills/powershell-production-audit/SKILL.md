---
name: powershell-production-audit
description: Production-grade PowerShell script auditing, validation, and safety engineering for Windows PowerShell 5.1 and .NET 4.8.
---

# PowerShell Production Audit Skill

## Overview
This skill governs the rigorous review, linting, and refactoring of PowerShell scripts intended to run reliably in production and consumer desktop environments (specifically targeting **Windows PowerShell 5.1** on Windows 10 and Windows 11).

## 1. Syntax & Engine Compatibility Rules
- **Target Runtime:** Windows PowerShell 5.1 (`powershell.exe`) running atop .NET Framework 4.8.
- **Prohibited PowerShell 7+ Syntax:**
  - Do NOT use the ternary operator (`$condition ? $trueVal : $falseVal`).
  - Do NOT use the null-coalescing operators (`??`, `??=`).
  - Do NOT use pipeline chain operators (`&&`, `||`).
  - Do NOT use PowerShell Core specific cmdlets without availability guards.
- **AST Validation Requirement:**
  Every script must be verified clean using `[System.Management.Automation.Language.Parser]::ParseFile`.

## 2. Process Execution & Error Handling
- **External Command Verification:**
  - Always check `$LASTEXITCODE` immediately after invoking native binaries (`adb.exe`, `fastboot.exe`, `python.exe`, `7z.exe`).
  - In automated pipelines, non-zero exit codes must terminate execution with `exit $LASTEXITCODE` or throw a terminating error.
- **String Interpolation Safety:**
  - Never place a colon directly after a simple variable name inside double quotes (e.g. `"$pkg: $res"`). PowerShell interprets `: ` as a scope qualifier. Always use `$($pkg):` or `${pkg}:`.
- **Fail-Closed Execution:**
  - Set `$ErrorActionPreference = "Stop"` at script entry.
  - Wrap external side effects in `try / catch` blocks to ensure temporary scratch files are always cleaned up in a `finally` block.

## 3. Safe Mutation & Idempotency
- **SupportsShouldProcess:**
  - Any script modifying disk state, device packages, or system settings must declare `[CmdletBinding(SupportsShouldProcess=$true)]` and guard mutations with `$PSCmdlet.ShouldProcess()`.
- **Pre-Flight Environment Checks:**
  - Check `Test-Path` on all input files and dependencies.
  - Verify executable availability using `Get-Command <tool> -ErrorAction SilentlyContinue`.
  - Never assume write access to current directory; use `$env:TEMP` for intermediate artifacts.
