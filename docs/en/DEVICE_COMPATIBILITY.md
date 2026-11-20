# 📱 Device & ROM Compatibility

[🇷🇺 Русская версия](../ru/DEVICE_COMPATIBILITY.md) | [📚 Index](README.md)

This document provides a technical breakdown of device hardware parameters, partition discrepancies, and validated custom ROM compatibility statuses.

---

## 🔍 Hardware Comparison: Tulip vs Whyred

Redmi Note 6 Pro (`tulip`) and Redmi Note 5 Pro (`whyred`) share Qualcomm's Snapdragon 636 platform (SDM636), but diverge in their factory GUID Partition Tables (GPT):

| Specification | Redmi Note 6 Pro (`tulip`) | Redmi Note 5 Pro (`whyred`) |
| :--- | :--- | :--- |
| **Device Codenames** | `tulip`, `twolip` | `whyred` |
| **System on Chip (SoC)** | Qualcomm Snapdragon 636 (8x Kryo 260) | Qualcomm Snapdragon 636 (8x Kryo 260) |
| **Graphics Processing Unit (GPU)** | Qualcomm Adreno 509 | Qualcomm Adreno 509 |
| **Storage Architecture** | eMMC 5.1 (32 / 64 GB) | eMMC 5.1 (32 / 64 GB) |
| **Physical `cust` Partition Size** | **871,366,656 bytes** (`0x33F00000`, ~830.8 MB) | **872,415,232 bytes** (`0x34000000`, 832.0 MB) |
| **Partition Size Delta** | **1,048,576 bytes (1 MB) smaller** | Baseline size used by ROM maintainers |
| **Unified Tree Target** | `bouquet` | `bouquet` |

---

## ❓ The "Unified Bouquet" Dilemma

1. Maintaining separate builds for two near-identical hardware designs requires double the build time and server storage.
2. Maintainers generate unified builds under the device target **`bouquet`**.
3. During retrofit `super` generation, the build system defaults to Whyred's parameters (`872415232` bytes for `cust`).
4. When recovery executes `update_dynamic_partitions` on Tulip, `liblp` queries the Linux kernel via `ioctl(BLKGETSIZE64)`. Detecting that physical `cust` is 1 MB smaller than specified in the metadata, it aborts installation with **Error 1**.

---

## 📊 Verified ROM Compatibility Matrix

| Custom ROM | Android Version | Kernel Branch | Status on Tulip | ROM Patch Required? | F2FS Mandatory? |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Project Infinity-X v4.2** | Android 17 | 4.19 (SouthWest-NG) | ✅ **Fully Tested & Verified** | Yes (unified zip) | **Mandatory** |
| **EvolutionX** | Android 15 / 16 | 4.19 | ✅ Verified Working | Yes (unified zip) | **Mandatory** |
| **LineageOS 22.x** | Android 15 | 4.19 | ✅ Verified Working | Yes (unified zip) | **Mandatory** |
| **crDroid 10.x / 11.x** | Android 14 / 15 | 4.19 | ✅ Verified Working | Yes (unified zip) | Recommended |
| **Legacy AOSP ROMs** | Android 11 / 12 / 13 | 4.4 | ⚠️ Non-Dynamic Legacy | No | ext4 supported |

> [!NOTE]
> If a maintainer produces a dedicated build exclusively for Tulip with accurate device tree partition sizes, patching the ROM ZIP is unnecessary. However, **F2FS** remains strictly required for all 4.19-kernel ROMs utilizing modern `fscrypt v2` storage encryption.

---

## ❌ Incompatible Hardware

This toolkit must **never** be applied to:
* Redmi Note 7 (`lavender`) and newer (these feature factory Android 9+ native Super Partitions).
* Redmi Note 5A (`ugglite` / `ugg`).
* Devices powered by MediaTek processors (Helio / Dimensity series).
