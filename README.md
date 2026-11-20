# tulip-dynamic-partitions-fix

[![Device](https://img.shields.io/badge/Device-Redmi%20Note%206%20Pro%20(Tulip)-blue.svg)](#-device-compatibility)
[![SoC](https://img.shields.io/badge/SoC-Qualcomm%20Snapdragon%20636-orange.svg)](#-device-compatibility)
[![Android](https://img.shields.io/badge/Android-15%20%7C%2016%20%7C%2017-green.svg)](#-device-compatibility)
[![Kernel](https://img.shields.io/badge/Kernel-4.19%20CIP-lightgrey.svg)](#-device-compatibility)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)

[🇷🇺 Документация на русском](docs/ru/README.md) | [🇬🇧 English Documentation](docs/en/README.md)

Open-source toolkit and technical reference for resolving **Error 1 (`update_dynamic_partitions`)** and **Recovery Bootloop** on the **Xiaomi Redmi Note 6 Pro (Tulip / Snapdragon 636)** across retrofitted Android 15, 16, and 17 custom ROMs.

---

## 🎯 Purpose and Scope

### What this project fixes:
1. **Installation Error 1 (`Block device cust size is too small`):**  
   Resolves the physical partition size mismatch where unified `bouquet` ROMs expect Whyred's 832 MB `cust` size instead of Tulip's factory 830.8 MB allocation.
2. **First-Boot Recovery Bootloop:**  
   Resolves `vold` storage encryption crashes (`fscrypt v2` on Linux kernel 4.19) by guiding proper F2FS filesystem configuration.
3. **RAM & Storage Stalls on 4GB Hardware:**  
   Provides optional, reversible post-install ADB scripts for 2.5 GB LZ4 ZRAM and eMMC scheduler optimization.

### What this project does NOT do:
* It does **not** alter bootloader partitions (`xbl`, `tz`, `rpm`, `aboot`).
* It does **not** modify raw eMMC GPT partition boundaries on the device.
* It does **not** bypass carrier or SIM locks.

> [!CAUTION]
> **Data Loss Warning:** Flashing dynamic ROMs and transitioning to F2FS requires formatting user data. Back up all personal files and radio partitions (EFS/Modem) prior to flashing.

---

## ⚡ Capability Overview

| Feature | Purpose | PC Required? | Recovery Method |
| :--- | :--- | :---: | :---: |
| **Diagnostics** | Hardware, partition, and RAM verification | Yes (ADB) | Not applicable |
| **ROM Patcher** | Automated `unsparse_super_empty.img` byte & SHA-256 fix | Yes (Windows/Python) | Flash patched ZIP |
| **Manual Patch** | In-depth hex editing and independent checksum validation | Yes (Hex Editor) | Flash modified ZIP |
| **F2FS Setup** | Eliminates kernel 4.19 encryption bootloops | **No (Phone only)** | OrangeFox / TWRP |
| **System Tuning** | Optional bloatware cleanup & ZRAM tuning for 4GB RAM | Yes (ADB Root) | Post-boot script |

---

## 🧭 Navigation & Documentation Index

### 🇷🇺 Документация (Русский)
* [Быстрый старт](docs/ru/GETTING_STARTED.md) — Пошаговое руководство для новичков.
* [Совместимость устройств](docs/ru/DEVICE_COMPATIBILITY.md) — Tulip vs Whyred, проверенные ROM.
* [Архитектура разделов](docs/ru/PARTITIONS_EXPLAINED.md) — Что такое Retrofit Super, GPT и `liblp`.
* [Каталог ошибок](docs/ru/ERRORS_AND_SOLUTIONS.md) — Подробный разбор Error 1, bootloop, Error 21.
* [Ручной способ правки](docs/ru/MANUAL_PATCH_GUIDE.md) — Редактирование в HxD без закрытых скриптов.
* [Автоматический патчер](docs/ru/AUTOMATIC_PATCH_GUIDE.md) — Использование PowerShell/Python утилит.
* [Установка в Recovery](docs/ru/RECOVERY_INSTALLATION.md) — Кнопка-за-кнопкой в OrangeFox и TWRP.
* [Бэкап и откат](docs/ru/BACKUP_AND_RESTORE.md) — Защита IMEI (EFS), откат на стоковую MIUI.
* [Частые вопросы (FAQ)](docs/ru/FAQ.md) — Ответы на популярные вопросы.

### 🇬🇧 Documentation (English)
* [Getting Started](docs/en/GETTING_STARTED.md) — Step-by-step guide for beginners.
* [Device Compatibility](docs/en/DEVICE_COMPATIBILITY.md) — Tulip vs Whyred specs, tested ROMs.
* [Partition Architecture](docs/en/PARTITIONS_EXPLAINED.md) — Retrofit Super, GPT geometry, `liblp`.
* [Errors and Solutions](docs/en/ERRORS_AND_SOLUTIONS.md) — Comprehensive Error 1 & bootloop teardown.
* [Manual Binary Patch](docs/en/MANUAL_PATCH_GUIDE.md) — Direct HxD hex modification instructions.
* [Automated Patcher](docs/en/AUTOMATIC_PATCH_GUIDE.md) — PowerShell & Python 1-click workflows.
* [Recovery Installation](docs/en/RECOVERY_INSTALLATION.md) — OrangeFox and TWRP workflows.
* [Backup and Rollback](docs/en/BACKUP_AND_RESTORE.md) — EFS protection, clean MIUI rollback.
* [FAQ](docs/en/FAQ.md) — Answers to community questions.

---

## 📁 Repository Structure

```text
tulip-dynamic-partitions-fix/
├── docs/
│   ├── ru/                      # Русскоязычная документация (10 руководств)
│   ├── en/                      # English documentation (10 guides)
│   ├── diagrams/                # Схемы архитектуры и Mermaid-диаграммы
│   └── reference/               # Аппаратные замеры и технические отчеты
├── drivers/
│   ├── install_drivers.cmd      # Установщик драйверов Windows в 1 клик
│   ├── xiaomi_usb_driver/       # Официальные драйверы Xiaomi Technology Inc.
│   ├── google_usb_driver/       # Официальные драйверы Google WinUSB (r13)
│   └── README.md                # Руководство по установке драйверов
├── scripts/
│   ├── patch_tulip_dynamic_rom.ps1   # PowerShell-обертка с drag-and-drop
│   ├── patch_tulip_dynamic_rom.py    # Кроссплатформенный бинарный патчер
│   ├── optimize_android17.ps1        # Скрипт тонкой настройки Android 17
│   ├── restore_android17.ps1         # Полный откат изменений оптимизации
│   └── 99-performance-tuning.sh      # Сервисный скрипт для zram и eMMC
├── diagnostics/                 # 56 аппаратных дампов телеметрии с реального Tulip
└── README.md                    # Главная страница проекта
```

---

## 🏷️ Search Keywords / Поисковые запросы

```text
- "assert failed: update_dynamic_partitions"
- "ERROR: 1"
- "Block device cust size is too small (expected 872415232, got 871366656)"
- "Tulip bootloop to recovery fix F2FS"
- "Redmi Note 6 Pro dynamic partitions"
```
