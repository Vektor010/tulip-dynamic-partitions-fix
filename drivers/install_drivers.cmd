@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: 1. Проверка и автоматический запрос прав Администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [i] Требуются права Администратора для установки драйверов Windows...
    powershell -NoProfile -Command "Start-Process cmd -ArgumentList '/k \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
title Установка драйверов Fastboot и ADB для Redmi Note 6 Pro (Tulip)

echo =====================================================================
echo    УСТАНОВКА ДРАЙВЕРОВ ADB И FASTBOOT ДЛЯ REDMI NOTE 6 PRO (TULIP)
echo =====================================================================
echo.

set "FAILED=0"

:: 2. Установка драйверов Xiaomi (Fastboot, ADB, Recovery, MDB)
echo [*] Шаг 1/2: Установка официальных драйверов Xiaomi USB Driver...
if exist "%~dp0xiaomi_usb_driver\android_winusb.inf" (
    pnputil.exe /add-driver "%~dp0xiaomi_usb_driver\android_winusb.inf" /install
    if !errorlevel! equ 0 (
        echo [OK] Драйверы Xiaomi успешно зарегистрированы в хранилище Windows!
    ) else if !errorlevel! equ 3010 (
        echo [OK] Драйверы Xiaomi зарегистрированы (требуется перезагрузка).
    ) else (
        echo [!] Предупреждение: pnputil вернул код !errorlevel! для Xiaomi драйвера.
        set "FAILED=1"
    )
) else (
    echo [-] Ошибка: Файл "%~dp0xiaomi_usb_driver\android_winusb.inf" не найден!
    set "FAILED=1"
)

echo.

:: 3. Установка драйверов Google (Generic WinUSB ADB & Bootloader)
echo [*] Шаг 2/2: Установка официальных драйверов Google USB Driver...
if exist "%~dp0google_usb_driver\android_winusb.inf" (
    pnputil.exe /add-driver "%~dp0google_usb_driver\android_winusb.inf" /install
    if !errorlevel! equ 0 (
        echo [OK] Драйверы Google успешно зарегистрированы в хранилище Windows!
    ) else if !errorlevel! equ 3010 (
        echo [OK] Драйверы Google зарегистрированы (требуется перезагрузка).
    ) else (
        echo [!] Предупреждение: pnputil вернул код !errorlevel! для Google драйвера.
        set "FAILED=1"
    )
) else (
    echo [-] Ошибка: Файл "%~dp0google_usb_driver\android_winusb.inf" не найден!
    set "FAILED=1"
)

echo.
echo =====================================================================
if %FAILED% equ 0 (
    echo [УСПЕХ] Все драйверы Fastboot и ADB успешно установлены!
    echo         Теперь Windows автоматически распознает телефон в режимах:
    echo         - Fastboot (загрузчик)
    echo         - Recovery (OrangeFox / TWRP)
    echo         - Включенная система (ADB / Отладка по USB)
) else (
    echo [!] Некоторые драйверы не установились автоматически.
    echo     Если устройство отображается с желтым знаком в Диспетчере устройств,
    echo     установите драйвер вручную через: Обновить драйвер -^> Выбрать на этом ПК.
)
echo =====================================================================
echo.
pause
