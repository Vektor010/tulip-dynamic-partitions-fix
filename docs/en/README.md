# 📚 Technical Documentation (English)

[🇷🇺 Документация на русском](../ru/README.md) | [🏠 Home](../../README.md)

Welcome to the comprehensive technical documentation and toolkit for installing and optimizing dynamic partition ROMs on the **Xiaomi Redmi Note 6 Pro (Tulip)**.

---

## 📑 Documentation Index

| Section | Description | Target Audience |
| :--- | :--- | :--- |
| **[Getting Started](GETTING_STARTED.md)** | Step-by-step novice guide from unlocked bootloader to first boot. | Beginners |
| **[Device & ROM Compatibility](DEVICE_COMPATIBILITY.md)** | Supported models, hardware specs, Tulip vs Whyred differences, tested ROMs. | Everyone |
| **[Partitions & Retrofit Super Architecture](PARTITIONS_EXPLAINED.md)** | In-depth explanation of GPT, physical vs logical partitions, and `liblp` metadata. | Everyone |
| **[Errors & Solutions Catalog](ERRORS_AND_SOLUTIONS.md)** | Comprehensive troubleshooting for Error 1, bootloops, checksum mismatches, and ADB. | Everyone |
| **[Manual Binary Patch Guide](MANUAL_PATCH_GUIDE.md)** | Hands-on byte replacement and SHA-256 recalculation without closed scripts. | Advanced Users |
| **[Automated ROM Patcher](AUTOMATIC_PATCH_GUIDE.md)** | 1-click PowerShell and Python tools for preparing ROM ZIPs. | Everyone |
| **[Recovery Installation Guide](RECOVERY_INSTALLATION.md)** | Button-by-button workflows for OrangeFox and TWRP Recovery, F2FS configuration. | Everyone |
| **[Backup & Disaster Recovery](BACKUP_AND_RESTORE.md)** | Critical partition protection (EFS/Modem/Persist) and clean stock rollback. | Everyone |
| **[Frequently Asked Questions (FAQ)](FAQ.md)** | Common community inquiries, myth busting, and hardware clarifications. | Everyone |

---

## ⚡ Core Summary of the Project

1. **Issue 1 (Installation Error 1 — `cust` Size Mismatch):**  
   Retrofitted Android 15–17 custom ROMs are commonly built as unified packages (`bouquet`) using Redmi Note 5 Pro (`whyred`) metadata. Whyred's physical `cust` partition is **832 MB**, while Tulip's factory `cust` is **830.8 MB** (1 MB smaller). Recovery's `liblp` parser enforces physical block size bounds and aborts with **Error 1**.  
   👉 **Solution:** Reconcile `unsparse_super_empty.img` and `super_dummy.img` metadata to match Tulip's exact byte count (`871366656` bytes).

2. **Issue 2 (Recovery Bootloop — Encryption Failure):**  
   Modern Linux 4.19 kernel trees enforce `fscrypt v2` encryption on `/data`. Conventional ext4 formatting in older recoveries lacks the requisite inode flags, causing `vold` to crash on early boot and trigger Rescue Party into recovery.  
   👉 **Solution:** Format `/data` and `/cache` to **F2FS**, which natively provisions required encryption attributes.
