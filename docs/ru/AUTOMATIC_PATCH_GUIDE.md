# ⚡ Автоматический патчер архивов прошивок

[🇬🇧 English Version](../en/AUTOMATIC_PATCH_GUIDE.md) | [📚 К оглавлению](README.md)

Скрипт автоматического патчинга предназначен для подготовки любых кастомных прошивок с динамической разметкой под **Redmi Note 6 Pro (Tulip)** в один клик.

---

## 🎯 Что делает патчер?
1. Создаёт безопасную копию исходного ZIP-архива с суффиксом `-tulip-fixed.zip` *(исходный файл остаётся нетронутым)*.
2. Извлекает файлы `unsparse_super_empty.img` и `super_dummy.img`.
3. Находит размер блочного устройства `cust` от Whyred (`872415232` байт) и заменяет его на реальный размер Tulip (`871366656` байт).
4. Пересчитывает официальные контрольные суммы SHA-256 для заголовков и таблиц `liblp`.
5. Запаковывает файлы обратно в архив и выполняет **полную проверку CRC32/структуры ZIP** на отсутствие повреждений.

---

## 💻 Системные требования
* **ОС:** Windows 7, 8.1, 10 или 11 (64-бит).
* **PowerShell:** Версия 5.1 или новее (встроена в Windows 10/11).
* **Python:** Версия 3.8 или новее (входит в стандартную поставку инструментов разработчика).
* **7-Zip (рекомендуется):** Установленный в `C:\Program Files\7-Zip\7z.exe` (при отсутствии скрипт переключится на встроенный модуль Python).

---

## 🚀 Как запустить (2 способа)

### Способ 1: Drag-and-Drop (Перетаскивание мышью)
1. Откройте папку `scripts/`.
2. Зажмите левой кнопкой мыши файл вашей прошивки (`.zip`) и перетащите его прямо на скрипт **`patch_tulip_dynamic_rom.ps1`**.
3. Скрипт откроет окно консоли, выполнит патч за 3–5 секунд и создаст рядом готовый файл `ИмяПрошивки-tulip-fixed.zip`.

### Способ 2: Через командную строку PowerShell
Откройте PowerShell в папке проекта и выполните команду:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\patch_tulip_dynamic_rom.ps1 -RomZip "C:\путь\к\прошивке.zip"
```

---

## 📋 Пример успешного вывода в консоли

```text
[*] Input ROM:  C:\Downloads\InfinityX-4.2-bouquet-UNOFFICIAL.zip
[*] Output ROM: C:\Downloads\InfinityX-4.2-bouquet-UNOFFICIAL-tulip-fixed.zip
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
    File: C:\Downloads\InfinityX-4.2-bouquet-UNOFFICIAL-tulip-fixed.zip
```

---

## ⚠️ Возможные сообщения об ошибках

* **`File not found: ...`** — Указан неверный путь к файлу. Проверьте правильность пути и отсутствие лишних кавычек.
* **`Neither unsparse_super_empty.img nor super_dummy.img found! Not a retrofitted dynamic ROM.`** — В архиве нет файлов динамической разметки. Это означает, что прошивка либо старого типа (без Retrofit Super), либо собрана без разделов `super`. Такой архив не требует патча.
* **`Patched ZIP archive corrupted!`** — Исходный архив был повреждён при скачивании из интернета. Скачайте прошивку заново и повторите процедуру.
