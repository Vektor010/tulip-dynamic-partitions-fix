# Redmi Note 6 Pro (Tulip) — Android 17 Toolkit & Fixes

[🇷🇺 Инструкция на русском](#-инструкция-на-русском) | [🇬🇧 English Guide](#-english-guide)

---

## 🇷🇺 Инструкция на русском

Инструменты и пошаговые инструкции для установки и оптимизации Android 17 на **Xiaomi Redmi Note 6 Pro (Tulip / Snapdragon 636)**.

### ❓ В чём проблема с прошивками?
1. **Ошибка при установке (`assert failed: update_dynamic_partitions` / Error 1):**  
   Разработчики создают общий образ для Redmi Note 5 Pro (Whyred) и Redmi Note 6 Pro (Tulip).  
   У Whyred раздел `cust` равен **832 МБ**, а у Tulip с завода — **831 МБ** (на 1 МБ меньше).  
   Рекавери видит нехватку 1 МБ и прерывает установку.
2. **Вечная перезагрузка в рекавери (Bootloop to Recovery):**  
   В Android 17 ядро 4.19 требует шифрование `fscrypt v2`.  
   Стандартный формат ext4 не поддерживает нужные флаги, поэтому разделы `/data` и `/cache` **обязательно** должны быть в файловой системе **F2FS**.

---

### 📱 КАК СДЕЛАТЬ ВСЁ САМОМУ В RECOVERY (ПО КНОПКАМ)

После успешной прошивки архива **НЕ ПЕРЕЗАГРУЖАЙТЕСЬ СРАЗУ**! Выполните смену файловой системы:

#### 🦊 Способ 1: В OrangeFox Recovery
1. На главном экране нажмите иконку **Меню** (три полоски / иконка меню в правом нижнем углу).
2. Выберите пункт **Manage Partitions** (Управление разделами).
3. В списке разделов нажмите на **Data**.
4. Нажмите кнопку **Change FS** (Сменить ФС).
5. Выберите **F2FS** и проведите внизу свайп для подтверждения (**Swipe to Apply**).
6. Вернитесь назад, нажмите на раздел **Cache**.
7. Нажмите **Change FS** → выберите **F2FS** → проведите свайп.
8. Нажмите **Reboot System** (Перезагрузка в систему).

#### 🔷 Способ 2: В TWRP Recovery
1. На главном экране нажмите **Wipe** (Очистка).
2. Нажмите **Advanced Wipe** (Выборочная очистка).
3. Поставьте галочку **ТОЛЬКО** напротив пункта **Data** (не проводите свайп очистки!).
4. Внизу нажмите кнопку **Repair or Change File System** (Восстановить или изменить ФС).
5. Нажмите **Change File System** (Изменить файловую систему).
6. Выберите **F2FS** и проведите свайп (**Swipe to Change**).
7. Вернитесь назад, отметьте галочкой **Cache**.
8. Нажмите **Repair or Change File System** → **Change File System** → выберите **F2FS** → свайп.
9. Перейдите в **Reboot** → **System**.

---

### 💻 ШАГ-ЗА-ШАГОМ: ПРОШИВКА И ПАТЧ

#### Шаг 1: Исправление архива прошивки (от Error 1)
1. Скачайте архив прошивки (например, Infinity-X).
2. Запустите скрипт `patch_tulip_dynamic_rom.ps1` в PowerShell:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\patch_tulip_dynamic_rom.ps1 -RomZip "путь_к_прошивке.zip"
   ```
3. Через несколько секунд рядом появится готовый файл `*-tulip-fixed.zip`.

#### Шаг 2: Установка через Recovery
```powershell
adb sideload имя_файла-tulip-fixed.zip
```
*(либо скиньте архив на карту памяти MicroSD и прошейте через меню Install в рекавери).*

#### Шаг 3: Смена ФС на F2FS
Выполните действия по кнопкам в OrangeFox или TWRP, описанные выше.

#### Шаг 4: Оптимизация системы (в 1 клик через ПК)
После загрузки системы включите «Отладку по USB» в меню разработчика и запустите:
```powershell
powershell -ExecutionPolicy Bypass -File .\optimize_android17.ps1
```
Скрипт отключит 20 фоновых служб, настроит ZRAM 2.5 ГБ (LZ4) и устранит микрофризы UI.

---

## 🇬🇧 English Guide

Toolkit and button-by-button guide for flashing and optimizing Android 17 on **Xiaomi Redmi Note 6 Pro (Tulip / Snapdragon 636)**.

### ❓ Why do unified dynamic ROMs fail on Tulip?
1. **Installation Error (`assert failed: update_dynamic_partitions` / Error 1):**  
   ROMs are built as unified "bouquet" packages for both Whyred and Tulip.  
   Whyred's factory `cust` partition size is **872,415,232 bytes (832 MB)**, while Tulip's factory size is **871,366,656 bytes (831 MB)**.  
   Because of this 1 MB difference, recovery's `liblp` throws an assertion failure (`cust size too small`).
2. **Bootloop to Recovery:**  
   Android 17 on 4.19 kernel uses `fscrypt v2` encryption.  
   Standard ext4 formatting fails to mount with v2 encryption flags. Data and cache **must** be formatted as **F2FS**.

---

### 📱 HOW TO DO IT MANUALLY IN RECOVERY (BUTTON-BY-BUTTON)

After installing the ROM zip, **DO NOT REBOOT IMMEDIATELY**! Change the filesystem to F2FS:

#### 🦊 Method 1: In OrangeFox Recovery
1. On the main screen, tap the **Menu** icon (bottom right corner).
2. Tap **Manage Partitions**.
3. Select **Data** from the list.
4. Tap **Change FS**.
5. Select **F2FS** and swipe to apply (**Swipe to Apply**).
6. Go back and select **Cache**.
7. Tap **Change FS** → select **F2FS** → swipe to apply.
8. Tap **Reboot System**.

#### 🔷 Method 2: In TWRP Recovery
1. Tap **Wipe** on the main menu.
2. Tap **Advanced Wipe**.
3. Check **ONLY** the **Data** box (do NOT swipe yet!).
4. Tap **Repair or Change File System** at the bottom.
5. Tap **Change File System**.
6. Select **F2FS** and swipe to confirm (**Swipe to Change**).
7. Go back, check **Cache**.
8. Tap **Repair or Change File System** → **Change File System** → choose **F2FS** → swipe.
9. Go to **Reboot** → **System**.

---

### 💻 FLASHING & OPTIMIZATION WORKFLOW

#### Step 1: Patch the ROM ZIP (Fixes Error 1)
```powershell
powershell -ExecutionPolicy Bypass -File .\patch_tulip_dynamic_rom.ps1 -RomZip "path\to\rom.zip"
```
A patched file named `*-tulip-fixed.zip` will be generated in seconds.

#### Step 2: Flash via Recovery
```powershell
adb sideload path\to\rom-tulip-fixed.zip
```
*(or flash via Install menu from MicroSD card).*

#### Step 3: Switch Data & Cache to F2FS
Follow the OrangeFox / TWRP button guide above.

#### Step 4: Run Performance Optimization
```powershell
powershell -ExecutionPolicy Bypass -File .\optimize_android17.ps1
```
Removes 20 background bloatware services, tunes 2.5 GB LZ4 ZRAM, and stabilizes 60 FPS UI rendering.
