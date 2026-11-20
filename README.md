# 📱 Redmi Note 6 Pro (Tulip) — Руководство по динамическим прошивкам (Android 15 / 16 / 17)

[🇷🇺 Инструкция на русском](#-инструкция-на-русском) | [🇬🇧 English Guide](#-english-guide)

---

## 📁 Структура репозитория

```text
├── docs/                        # 📚 Подробные инструкции, отчеты и замеры
│   ├── HOWTO_FIX_TULIP_DYNAMIC_ROMS.md
│   ├── optimization_report.md
│   ├── android17_baseline.txt
│   └── android17_optimized.txt
├── scripts/                     # ⚙️ Скрипты оптимизации и ПК-утилиты
│   ├── optimize_android17.ps1
│   ├── restore_android17.ps1
│   ├── patch_tulip_dynamic_rom.ps1
│   ├── patch_tulip_dynamic_rom.py
│   └── 99-performance-tuning.sh
├── diagnostics/                 # 📊 Логи и аппаратные дампы телеметрии
└── README.md                    # 📖 Главное руководство
```

---

## 🇷🇺 Инструкция на русском

Подробное руководство, как устанавливать **любые динамические прошивки** (Android 15, 16, 17 — Project Infinity-X, EvolutionX, LineageOS и др.) на **Redmi Note 6 Pro (Tulip)** **БЕЗ КОМПЬЮТЕРА (только через телефон)** и как исправить ошибки бутлупа и разметки.

---

### 🔥 ГЛАВНЫЙ МЕТОД: КАК ПРОШИТЬ БЕЗ КОМПЬЮТЕРА (ТОЛЬКО ЧЕРЕЗ ТЕЛЕФОН)

Если у вас нет ПК или вы не хотите ничего патчить — весь процесс делается **напрямую в OrangeFox / TWRP** перед установкой прошивки!

#### 🦊 Пошагово в OrangeFox Recovery:

1. **Шаг 1: Подготовка файловой системы к динамическим разделам**
   * В OrangeFox нажмите иконку **Меню** (три полоски в нижнем правом углу) → **Manage Partitions** (Управление разделами).
   * Нажмите на раздел **Data** → кнопка **Change FS** (Сменить ФС) → выберите **F2FS** → проведите свайп (**Swipe to Apply**).
   * Нажмите на раздел **Cache** → кнопка **Change FS** → выберите **F2FS** → проведите свайп.
   * Нажмите на раздел **Cust** → нажмите **Format / Wipe**.

2. **Шаг 2: Форматирование данных**
   * Перейдите во вкладку **Wipe (Очистка)** → нажмите кнопку **Format Data**.
   * Введите слово `yes` и подтвердите.

3. **Шаг 3: Прошивка архива**
   * Перейдите во вкладку **Files (Файлы)**.
   * Выберите скачанный оригинальный ZIP архив прошивки (скачанный напрямую на телефон или на MicroSD флешку).
   * Проведите свайп для установки (**Swipe to Install**).
   * *Установка пройдёт штатно!*

4. **Шаг 4: Проверка F2FS перед включением**
   * Снова зайдите в **Manage Partitions** → проверьте, что **Data** остался в **F2FS** (если сбросился в ext4 — ещё раз переключите на F2FS).
   * Нажмите **Reboot System** (Перезагрузка в систему).  
   * Система загрузится за 1–2 минуты без бутлупа!

---

#### 🔷 Пошагово в TWRP Recovery:

1. Нажмите **Wipe** → **Advanced Wipe**.
2. Отметьте галочкой **Data** → нажмите **Repair or Change File System** → **Change File System** → **F2FS** → свайп.
3. Отметьте галочкой **Cache** → **Repair or Change File System** → **Change File System** → **F2FS** → свайп.
4. Вернитесь в меню **Wipe** → нажмите **Format Data** → напишите `yes`.
5. Установите архив прошивки через кнопку **Install**.
6. Перезагрузитесь в систему (**Reboot System**).

---

### 💻 АЛЬТЕРНАТИВНЫЙ МЕТОД: ЧЕРЕЗ ПК (ЕСЛИ ВЫЛЕТАЕТ ERROR 1)

Если на телефоне была старая нестандартная переразметка (например, расширение `system` под GSI), рекавери может выдать `Block device cust size is too small (Error 1)`.

В этом случае используйте скрипт патча в 1 клик на ПК:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\patch_tulip_dynamic_rom.ps1 -RomZip "путь_к_прошивке.zip"
```
Скрипт за 3 секунды подгонит метаданные архива под заводские размеры Tulip, после чего архив прошьется без ошибок.

---

### ⚡ ОПТИМИЗАЦИЯ ПОСЛЕ УСТАНОВКИ (ДЛЯ 4 GB RAM)

После первой загрузки подключите телефон к ПК, включите «Отладку по USB» и запустите:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\optimize_android17.ps1
```
* Скрипт отключит 20 фоновых служб-пожирателей памяти.
* Настроит быстрый ZRAM 2.5 ГБ (LZ4) и планировщик eMMC 5.1 (`mq-deadline`).
* Скомпилирует ключевые приложения в машинный код (`dex2oat speed`), снижая лаги интерфейса на 62.5%.

---

## 🇬🇧 English Guide

Guide on how to install **any Dynamic Partition ROM** (Android 15, 16, 17 — Infinity-X, EvolutionX, LineageOS, etc.) on **Redmi Note 6 Pro (Tulip)** **DIRECTLY ON THE PHONE (WITHOUT PC)** and fix installation/bootloop errors.

---

### 🔥 MAIN METHOD: DIRECTLY ON PHONE (NO PC REQUIRED)

You do NOT need a PC or patch script if you configure partitions properly in OrangeFox / TWRP before installing:

#### 🦊 In OrangeFox Recovery:
1. **Prepare Partitions:**
   * Tap the **Menu icon** (bottom right) → **Manage Partitions**.
   * Select **Data** → tap **Change FS** → choose **F2FS** → swipe to apply.
   * Select **Cache** → tap **Change FS** → choose **F2FS** → swipe to apply.
   * Select **Cust** → tap **Format / Wipe**.
2. **Format Data:**
   * Go to **Wipe** tab → tap **Format Data** → type `yes` to confirm.
3. **Flash the ROM:**
   * Go to **Files** tab → select your original unpatched ROM zip → swipe to install.
4. **Verify & Reboot:**
   * Go to **Manage Partitions** to ensure **Data** is still **F2FS**.
   * Tap **Reboot System**. The ROM will boot cleanly!

#### 🔷 In TWRP Recovery:
1. Tap **Wipe** → **Advanced Wipe**.
2. Select **Data** → **Repair or Change File System** → **Change File System** → **F2FS** → swipe.
3. Select **Cache** → **Repair or Change File System** → **Change File System** → **F2FS** → swipe.
4. Go to **Wipe** → **Format Data** → type `yes`.
5. Flash the ROM zip via **Install**.
6. Tap **Reboot System**.
