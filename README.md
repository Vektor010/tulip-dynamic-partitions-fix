# 📱 REDMI NOTE 6 PRO (TULIP) — ВСЁ ДЛЯ ПРОШИВКИ И ОПТИМИЗАЦИИ ANDROID 17

> **Простая памятка на русском языке**, чтобы ты всегда помнил, почему вылетали ошибки и как за 2 минуты прошить и настроить абсолютно любую прошивку на наш телефон.

---

## 💡 ДВЕ ГЛАВНЫЕ ПРИЧИНЫ, ПОЧЕМУ ПРОШИВКИ НЕ РАБОТАЛИ (НА ПАЛЬЦАХ)

1. **Ошибка 1 при установке (`assert failed: update_dynamic_partitions`):**
   * **В чём суть:** Наш телефон — **Tulip** (Redmi Note 6 Pro). Его брат — **Whyred** (Redmi Note 5 Pro).  
     У Whyred с завода раздел `cust` равен **832 МБ**, а у нашего Tulip — **831 МБ** (ровно на 1 Мегабайт меньше!).
   * **Почему не шилось:** Разработчики ленятся и собирают один архив под оба телефона (Bouquet), прописывая размер от Whyred. Рекавери на Tulip видит нехватку 1 МБ и выдает ошибку: `Block device cust size is too small`.
   * **Решение:** Прогнать прошивку через наш патчер [patch_tulip_dynamic_rom.ps1](file:///C:/Users/User/Documents/redmi/patch_tulip_dynamic_rom.ps1) (меняет эту цифру за 3 секунды).

2. **Ошибка 2: Телефон уходит в вечный бутлуп обратно в рекавери:**
   * **В чём суть:** В Android 17 включено новое шифрование `fscrypt v2`.  
     Обычный сброс ("Format Data") в OrangeFox форматирует раздел в **старый формат ext4**, на котором это шифрование вылетает при включении.
   * **Решение:** В OrangeFox всегда форматировать Data и Cache в **F2FS** (`Change File System -> F2FS`)!

---

## 🚀 БЫСТРАЯ ИНСТРУКЦИЯ ИЗ 4 ШАГОВ (ДЛЯ ЛЮБОЙ ПРОШИВКИ)

### Шаг 1: Пропатчить ZIP прошивки
1. Скачал любую новую прошивку (Infinity-X, EvolutionX, LineageOS и т.д.).
2. Нажми правой кнопкой на [patch_tulip_dynamic_rom.ps1](file:///C:/Users/User/Documents/redmi/patch_tulip_dynamic_rom.ps1) → **Выполнить с помощью PowerShell** (или просто перетащи архив на скрипт).
3. Через 5 секунд рядом появится готовый файл: `Имя_прошивки-tulip-fixed.zip`.

### Шаг 2: Прошить архив
1. Зайди в **OrangeFox Recovery** (или AOSP Recovery).
2. Подключи кабель к ПК и выполни команду:
   ```bash
   adb sideload Имя_прошивки-tulip-fixed.zip
   ```
   *(Или закинь на MicroSD флешку и нажми Install в рекавери).*
3. Прошивка завершится успешно на 100% без Error 1!

### Шаг 3: Сменить файловую систему на F2FS (ОБЯЗАТЕЛЬНО!)
Не перезагружай телефон сразу!
1. В OrangeFox нажми иконку меню снизу справа → **Manage Partitions** (Управление разделами).
2. Нажми на **Data** → кнопка **Change File System** (Сменить ФС) → выбери **F2FS** → проведи свайп.
3. Нажми на **Cache** → **Change File System** → выбери **F2FS** → проведи свайп.
4. Нажми **Reboot System** (Перезагрузка).  
   Телефон спокойно включится в Android 17!

### Шаг 4: Глубокая оптимизация (в 1 клик через ПК)
Чтобы телефон летал, не грелся и держал батарею:
1. Включи отладку по USB на телефоне и запусти:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "C:\Users\User\Documents\redmi\optimize_android17.ps1"
   ```
2. Скрипт сам:
   - Отключит 20 фоновых пожирателей памяти (рекламу Google, неработающий NFC, оверлеи).
   - Настроит быстрый ZRAM 2.5 ГБ (lz4) и устранит фризы флэш-памяти.
   - Скомпилирует все важные приложения в нативный код (`dex2oat speed`).
   - Уменьшит лаги отрисовки на 62%!

---

## 🗂️ ЧТО НАХОДИТСЯ В ЭТОМ РЕПОЗИТОРИИ:

* **[patch_tulip_dynamic_rom.ps1](file:///C:/Users/User/Documents/redmi/patch_tulip_dynamic_rom.ps1)** — волшебная палочка: патчер любых прошивок для Tulip в 1 клик.
* **[patch_tulip_dynamic_rom.py](file:///C:/Users/User/Documents/redmi/patch_tulip_dynamic_rom.py)** — движок патчера на Python (работает на Windows, Linux, Mac).
* **[optimize_android17.ps1](file:///C:/Users/User/Documents/redmi/optimize_android17.ps1)** — скрипт полной оптимизации системы и памяти Android 17.
* **[restore_android17.ps1](file:///C:/Users/User/Documents/redmi/restore_android17.ps1)** — скрипт 100% отката всех настроек к заводским.
* **[HOWTO_FIX_TULIP_DYNAMIC_ROMS.md](file:///C:/Users/User/Documents/redmi/HOWTO_FIX_TULIP_DYNAMIC_ROMS.md)** — глубокая техническая статья с разбором HEX-кодов и устройства динамических разделов.
* **[optimization_report.md](file:///C:/Users/User/Documents/redmi/optimization_report.md)** — полный инженерный отчёт со сравнительными графиками и бенчмарками До/После.
* **[android17_baseline.txt](file:///C:/Users/User/Documents/redmi/android17_baseline.txt)** — замеры системы до оптимизации.
* **[android17_optimized.txt](file:///C:/Users/User/Documents/redmi/android17_optimized.txt)** — замеры системы после оптимизации.
* **`diagnostics/`** — 56 подробных логов и дампов телеметрии Snapdragon 636 / eMMC / RAM.
