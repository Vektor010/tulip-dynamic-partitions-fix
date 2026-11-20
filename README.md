# Redmi Note 6 Pro (Tulip) — Android 17 Toolkit & Fixes

[🇷🇺 Инструкция на русском](#-инструкция-на-русском) | [🇬🇧 English Guide](#-english-guide)

---

## 🇷🇺 Инструкция на русском

Инструменты для установки и оптимизации Android 17 на **Xiaomi Redmi Note 6 Pro (Tulip / Snapdragon 636)**.

### ❓ В чём проблема с прошивками?
1. **Ошибка при установке (`assert failed: update_dynamic_partitions` / Error 1):**  
   Разработчики создают общий образ для Redmi Note 5 Pro (Whyred) и Redmi Note 6 Pro (Tulip).  
   У Whyred раздел `cust` равен **832 МБ**, а у Tulip с завода — **831 МБ** (на 1 МБ меньше).  
   Рекавери видит нехватку 1 МБ и прерывает установку.
2. **Вечная перезагрузка в рекавери (Bootloop to Recovery):**  
   В Android 17 ядро 4.19 требует шифрование `fscrypt v2`.  
   Стандартный формат ext4 не поддерживает нужные флаги, поэтому разделы `/data` и `/cache` **обязательно** должны быть в файловой системе **F2FS**.

---

### 🚀 Пошаговое руководство для новичков

#### Шаг 1: Исправление архива прошивки
1. Скачайте архив прошивки (например, Infinity-X).
2. Запустите скрипт `patch_tulip_dynamic_rom.ps1` в PowerShell:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\patch_tulip_dynamic_rom.ps1 -RomZip "путь_к_прошивке.zip"
   ```
   *(или просто запустите скрипт и введите путь к файлу).*
3. Через несколько секунд рядом появится готовый файл `*-tulip-fixed.zip`.

#### Шаг 2: Прошивка через Recovery
1. Перезагрузите телефон в OrangeFox или TWRP.
2. Подключите кабель к ПК и выполните:
   ```powershell
   adb sideload имя_файла-tulip-fixed.zip
   ```
   *(либо скопируйте архив на карту памяти MicroSD и установите через меню Install).*

#### Шаг 3: Настройка файловой системы в F2FS (Обязательно!)
Не перезагружайте телефон сразу после прошивки!
1. В OrangeFox откройте **Manage Partitions** (Управление разделами).
2. Выберите раздел **Data** → **Change File System** → выберите **F2FS** → проведите свайп.
3. Выберите раздел **Cache** → **Change File System** → выберите **F2FS** → проведите свайп.
4. Нажмите **Reboot System** (Перезагрузка в систему).

#### Шаг 4: Оптимизация системы (через ПК)
После включения телефона включите «Отладку по USB» в настройках разработчика и запустите:
```powershell
powershell -ExecutionPolicy Bypass -File .\optimize_android17.ps1
```
Скрипт отключит ненужные службы, настроит быстрый ZRAM (2.5 ГБ LZ4) и оптимизирует графику.

---

## 🇬🇧 English Guide

Toolkit for flashing and optimizing Android 17 on **Xiaomi Redmi Note 6 Pro (Tulip / Snapdragon 636)**.

### ❓ Why do unified dynamic ROMs fail on Tulip?
1. **Installation Error (`assert failed: update_dynamic_partitions` / Error 1):**  
   ROMs are built as unified "bouquet" packages for both Whyred and Tulip.  
   Whyred's factory `cust` partition size is **872,415,232 bytes (832 MB)**, while Tulip's factory size is **871,366,656 bytes (831 MB)**.  
   Because of this 1 MB difference, recovery's `liblp` throws an assertion failure (`cust size too small`).
2. **Bootloop to Recovery:**  
   Android 17 on 4.19 kernel uses `fscrypt v2` encryption.  
   Standard ext4 formatting fails to mount with v2 encryption flags. Data and cache **must** be formatted as **F2FS**.

---

### 🚀 Step-by-Step Beginner Guide

#### Step 1: Patch the ROM ZIP
1. Download your desired dynamic ROM ZIP.
2. Run the patcher in PowerShell:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\patch_tulip_dynamic_rom.ps1 -RomZip "path\to\rom.zip"
   ```
3. A patched file named `*-tulip-fixed.zip` will be generated in seconds.

#### Step 2: Flash via Recovery
1. Boot into OrangeFox or TWRP recovery.
2. Flash the patched archive via ADB sideload:
   ```powershell
   adb sideload path\to\rom-tulip-fixed.zip
   ```
   *(or copy to MicroSD card and flash via recovery install menu).*

#### Step 3: Format Data and Cache to F2FS (Mandatory!)
Do NOT reboot immediately after flashing!
1. In OrangeFox go to: **Manage Partitions**.
2. Select **Data** → **Change File System** → choose **F2FS** → swipe to apply.
3. Select **Cache** → **Change File System** → choose **F2FS** → swipe to apply.
4. Tap **Reboot System**.

#### Step 4: Run Performance Optimization
Once booted, enable USB Debugging in Developer Options and run:
```powershell
powershell -ExecutionPolicy Bypass -File .\optimize_android17.ps1
```
This script trims background bloat, configures 2.5 GB LZ4 ZRAM, and optimizes UI frame pacing.

---

### 📂 Repository Contents
* `patch_tulip_dynamic_rom.ps1` / `.py` — 1-click ROM metadata patcher for Tulip.
* `optimize_android17.ps1` — Automated Android 17 performance tuning script.
* `restore_android17.ps1` — Full rollback script to restore stock configuration.
* `HOWTO_FIX_TULIP_DYNAMIC_ROMS.md` — In-depth technical explanation of partition layouts.
* `optimization_report.md` — Engineering report with before/after benchmarks.
