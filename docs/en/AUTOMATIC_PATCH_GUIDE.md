# ⚡ Automated ROM Patcher Guide

[🇷🇺 Русская версия](../ru/AUTOMATIC_PATCH_GUIDE.md) | [📚 Index](README.md)

1-click automation toolchain to patch dynamic partition custom ROMs for **Redmi Note 6 Pro (Tulip)**.

---

## 🎯 Patcher Capabilities
1. Preserves the original file by creating a clone named `*-tulip-fixed.zip`.
2. Extracts `unsparse_super_empty.img` and `super_dummy.img`.
3. Replaces Whyred's `cust` size (`872415232` bytes) with Tulip's physical size (`871366656` bytes).
4. Recalculates official Google `liblp` SHA-256 header and table checksums.
5. Injects patched files back into the ZIP and runs a post-patch **CRC32 archive integrity verification**.

---

## 💻 System Prerequisites
* **OS:** Windows 7, 8.1, 10, or 11 (64-bit).
* **PowerShell:** Version 5.1+ (built into Windows 10/11).
* **Python:** Version 3.8+ available in system PATH.
* **7-Zip (Recommended):** Located at `C:\Program Files\7-Zip\7z.exe` (falls back to Python `zipfile` if absent).

---

## 🚀 Execution Methods

### Method 1: Drag-and-Drop
1. Open the `scripts/` folder.
2. Drag and drop your downloaded ROM `.zip` file directly onto **`patch_tulip_dynamic_rom.ps1`**.
3. A terminal will launch, execute the patch within 3–5 seconds, and generate `*-tulip-fixed.zip`.

### Method 2: PowerShell Terminal
Open PowerShell and run:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\patch_tulip_dynamic_rom.ps1 -RomZip "C:\path\to\ROM.zip"
```

---

## 📋 Standard Terminal Output

```text
[*] Input ROM:  C:\ROMs\InfinityX-4.2-bouquet.zip
[*] Output ROM: C:\ROMs\InfinityX-4.2-bouquet-tulip-fixed.zip
[*] Extracting dynamic partition metadata from zip...
    -> Extracted: unsparse_super_empty.img
    -> Extracted: super_dummy.img
[unsparse_super_empty.img] Replaced 1 instance(s) of Whyred cust size (872415232 -> 871366656)
[unsparse_super_empty.img] Found 1 LpMetadata header(s) to re-checksum
[super_dummy.img] Replaced 4 instance(s) of Whyred cust size (872415232 -> 871366656)
[super_dummy.img] Found 4 LpMetadata header(s) to re-checksum
[*] Updating archive via 7-Zip...
[*] Verifying output ZIP archive integrity and CRC32 checksums...
    -> Archive CRC32/structure verified successfully. No corruption detected.

[+] SUCCESS! Patched ROM generated:
    File: C:\ROMs\InfinityX-4.2-bouquet-tulip-fixed.zip
```
