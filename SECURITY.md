# Security Policy

## Scope and Device Safety
This project provides modification tools for Android custom ROM archives. 

To safeguard physical hardware:
1. None of our scripts write to raw hardware bootloader partitions (`xbl`, `tz`, `rpm`, `aboot`).
2. The ROM patcher functions strictly on computer archives and does not issue direct block-level commands to connected phones.
3. System optimization scripts use standard non-destructive Android package manager commands (`pm uninstall -k --user 0`) with complete reversibility via `restore_android17.ps1`.

## Reporting Issues
If you identify a safety risk, partition corruption bug, or regression, please open a security advisory or report it via the GitHub issues tab with full diagnostic logs.
