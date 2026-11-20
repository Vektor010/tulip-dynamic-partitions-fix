# Contributing Guidelines

Thank you for helping improve the **tulip-dynamic-partitions-fix** toolkit!

## How to Contribute
1. **Reporting Bugs:**  
   Open an issue with the exact recovery error logs, ROM name, Android version, and kernel version.
2. **Submitting Patches:**  
   Fork the repository, create a descriptive branch, ensure scripts parse with zero AST errors in PowerShell 5.1 and Python 3.8+, and submit a Pull Request.
3. **Documentation:**  
   When updating documentation, ensure parity between Russian (`docs/ru/`) and English (`docs/en/`) versions.

## Code Standards
* All PowerShell scripts must pass AST validation (`[System.Management.Automation.Language.Parser]::ParseFile`).
* Python scripts must follow PEP 8 and have no external dependencies outside standard library modules.
* Never publish dangerous commands that modify raw bootloader or partition structures without explicit warnings.
