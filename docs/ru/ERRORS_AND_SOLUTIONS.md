# 🚨 Каталог ошибок и проверенные решения

[🇬🇧 English Version](../en/ERRORS_AND_SOLUTIONS.md) | [📚 К оглавлению](README.md)

В этом каталоге собраны все известные ошибки, возникающие при установке кастомных прошивок на **Redmi Note 6 Pro (Tulip)**, причины их появления и пошаговые методы устранения.

---

## 1. Ошибка 1: `Block device cust size is too small`

### Как выглядит в логе Recovery:
```text
assert failed: update_dynamic_partitions(package_extract_file("dynamic_partitions_op_list"), package_extract_file("unsparse_super_empty.img"))
[liblp] Block device cust size is too small (expected 872415232, got 871366656)
Updater process ended with ERROR: 1
```

* **Причина:** Несоответствие метаданных прошивки (собранных под Whyred с размером `cust` 832 МБ) реальному физическому размеру раздела `cust` на Tulip (830.8 МБ).
* **Чего НЕЛЬЗЯ делать:**  
  ❌ Не пытайтесь изменять таблицу GPT через `parted` в консоли рекавери (риск превратить аппарат в кирпич EDL 9008).  
  ❌ Не делайте бессмысленных повторных форматирований раздела `cust` — это не меняет физический размер сектора.
* **Решение:**  
  ✅ Подготовьте архив через [Автоматический патчер](AUTOMATIC_PATCH_GUIDE.md) или выполните [Ручное исправление](MANUAL_PATCH_GUIDE.md).

---

## 2. Ошибка 2: Вечная перезагрузка в Recovery (Bootloop to Recovery)

### Как проявляется:
Прошивка успешно установилась со статусом 0, но при перезагрузке телефон висит 1–2 минуты на заставке, затем экран гаснет и телефон автоматически загружается обратно в **OrangeFox / TWRP**.

* **Причина:** Служба Android `vold` на ядре 4.19 не может смонтировать раздел `/data` с шифрованием `fscrypt v2` (`fileencryption=aes-256-xts:aes-256-cts:v2+emmc_optimized`), если он отформатирован в старый ext4 без флагов инспекции ин-одов.
* **Решение:**
  1. В OrangeFox / TWRP перейдите в **Manage Partitions**.
  2. Переключите файловую систему **Data** на **F2FS** (**Change FS ➔ F2FS**).
  3. Переключите файловую систему **Cache** на **F2FS**.
  4. Перейдите в **Wipe ➔ Format Data** (введите `yes`).
  5. Перезагрузитесь в систему.

---

## 3. Ошибка 3: `Logical partition metadata has invalid checksum`

### Как выглядит:
```text
[liblp] Logical partition metadata has invalid checksum
Updater process ended with ERROR: 1
```

* **Причина:** Файл `unsparse_super_empty.img` был отредактирован в шестнадцатеричном редакторе вручную, но контрольная сумма SHA-256 в заголовке `LpMetadataHeader` не была пересчитана. Google `liblp` отклоняет повреждённые метаданные.
* **Решение:**  
  Используйте официальный алгоритм пересчёта SHA-256 заголовка и таблицы (см. [Ручное исправление](MANUAL_PATCH_GUIDE.md) или скрипт `patch_tulip_dynamic_rom.py`).

---

## 4. Ошибка 4: `Signature verification failed / error: 21`

### Как выглядит в AOSP / OrangeFox Recovery:
```text
Signature verification failed
Install anyway?
E:Zip signature verification failed: 21
```

* **Причина:** Неофициальные прошивки подписаны открытыми тестовыми ключами разработчиков (`test-keys`), а не закрытым приватным сертификатом производителя.
* **Решение:**  
  Это предупреждение безопасности, а не поломка. Нажмите **Yes** (Install anyway) в AOSP Recovery или отключите опцию *«Zip signature verification»* в настройках OrangeFox.

---

## 5. Ошибка 5: ПК не видит телефон в Fastboot / зависание на AMD Ryzen

### Как проявляется:
Команда `fastboot devices` не выводит серийный номер, либо команда прошивки зависает на строке `< waiting for any device >`.

* **Причина:** Несовместимость старого протокола USB 2.0 Fastboot с хост-контроллерами USB 3.0/3.1 на материнских платах AMD (B450, B550, X570).
* **Решение:**
  1. Подключайте кабель **только в чёрные порты USB 2.0** на задней панели ПК.
  2. При отсутствии USB 2.0 портов используйте промежуточный USB 2.0 хаб.
  3. Установите официальный драйвер Xiaomi через `drivers\install_drivers.cmd`.
