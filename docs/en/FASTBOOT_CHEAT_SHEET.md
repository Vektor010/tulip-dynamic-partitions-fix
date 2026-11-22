# ⚡ Fastboot: Comprehensive Command Reference (Redmi Note 6 Pro / Tulip)

[🇷🇺 Русская версия](../ru/FASTBOOT_CHEAT_SHEET.md) | [📚 Table of Contents](README.md) | [📲 Recovery Installation](RECOVERY_INSTALLATION.md)

Comprehensive, production-grade Fastboot command reference and hardware cheat sheet for the **Xiaomi Redmi Note 6 Pro (codename: `tulip` / `twolip`)** powered by the **Qualcomm Snapdragon 636 (SDM636)** mobile platform.

---

## 🧭 Table of Contents
1. [Hardware Fastboot Specifics (Tulip)](#-hardware-fastboot-specifics-tulip)
2. [Entering Fastboot Mode](#-entering-fastboot-mode)
3. [Device Inspection & Diagnostic Commands](#-device-inspection--diagnostic-commands)
4. [Anti-Rollback (ARB) Protection & Safety](#-anti-rollback-arb-protection--safety)
5. [Recovery Flashing & Tethered Boot](#-recovery-flashing--tethered-boot)
6. [Flashing System & Firmware Partitions](#-flashing-system--firmware-partitions)
7. [Wipe & Partition Erase Commands](#-wipe--partition-erase-commands)
8. [Reboot & Power Management](#-reboot--power-management)
9. [Physical Partition Map (Tulip eMMC)](#-physical-partition-map-tulip-emmc)
10. [Troubleshooting Common Fastboot Errors](#-troubleshooting-common-fastboot-errors)

---

## ⚙️ Hardware Fastboot Specifics (Tulip)

Before running commands, understand device architecture:

| Parameter | Redmi Note 6 Pro Specification | Practical Rule |
| :--- | :--- | :--- |
| **Slot Architecture** | **A-only** (Legacy, No A/B slots) | Commands like `flash recovery_a` will fail. Always use direct names: `recovery`, `boot`. |
| **Interface** | USB 2.0 (Micro-USB connector) | High sensitivity to USB 3.0/3.2 ports and AMD Ryzen host controllers. |
| **Storage Technology** | eMMC 5.1 (Sandisk / Micron / Samsung) | Standard GPT partition layout on raw block devices (not UFS). |
| **Bootloader** | Qualcomm Little Kernel (LK / Aboot) | Supports `getvar`, `oem device-info`, and tethered `boot`. |
| **Anti-Rollback (ARB)** | **Version 4 (ARB 4)** | Downgrading to early MIUI fastboot packages causes a permanent QFPROM hard-brick. |

---

## 🔌 Entering Fastboot Mode

### Method 1. Hardware Buttons (From Power Off)
1. Power down the smartphone completely.
2. Press and hold **Volume Down + Power** simultaneously.
3. Keep holding for 5–7 seconds until the device vibrates and displays the Xiaomi Fastboot Bunny logo (or **FASTBOOT** text).
4. Connect the Micro-USB cable to your PC.

### Method 2. Software ADB Command (From Running Android)
With USB Debugging enabled:
```powershell
adb reboot bootloader
```

---

## 🔍 Device Inspection & Diagnostic Commands

### 1. Verify USB Connection and Serial Number
```powershell
fastboot devices
```
* **Expected Output:**
  ```text
  6357460b    fastboot
  ```
  *(If empty, verify physical cable and install [official USB drivers](../../drivers/README.md)).*

---

### 2. Confirm Hardware Codename
Protects against accidentally flashing firmware intended for a different smartphone:
```powershell
fastboot getvar product
```
* **Expected Output (Tulip):**
  ```text
  product: tulip
  ```
  *(Some global packaging variants return `twolip` — both are hardware identical).*

---

### 3. Check Bootloader Lock Status (OEM Unlock)
```powershell
fastboot oem device-info
```
* **Expected Output:**
  ```text
  (bootloader)    Device critical unlocked: true
  (bootloader)    Device unlocked: true
  (bootloader)    Charger screen enabled: false
  (bootloader)    Device authorized: false
  OKAY [  0.005s]
  ```
  > [!IMPORTANT]
  > **`Device unlocked: true`** is strictly required. If `false`, the bootloader is locked. Flashing commands will immediately fail with `FAILED (remote: Flashing is not allowed in Lock State)`.

---

### 4. Query All Bootloader Variables
```powershell
fastboot getvar all
```
Returns complete low-level hardware parameters: block sizes, bootloader version, sparse download limits (`max-download-size`), and partition statuses.

---

## 🛡️ Anti-Rollback (ARB) Protection & Safety

Xiaomi enforces hardware **Anti-Rollback (ARB)** using Qualcomm QFPROM eFuses. Flashing firmware with an older ARB index triggers a permanent, non-recoverable hardware lock (Qualcomm Emergency Download EDL 9008).

### Query Current ARB Index:
```powershell
fastboot getvar anti
```

* **Interpreting Output:**
  * `anti: 4` — **Factory standard for Tulip.**
    * ✅ **SAFE:** Flash any custom recovery (OrangeFox, TWRP), custom kernels, or custom ROMs (Android 10–17).
    * ✅ **SAFE:** Flash official MIUI Fastboot ROMs containing `anti: 4` (MIUI 10, 11, 12).
    * ⛔ **FATAL DANGER:** NEVER flash older MIUI fastboot packages (early MIUI 9/10 builds) that have `anti: 3` or missing roll-back protection. This blows Qualcomm fuses and hard-bricks the device.
  * `anti:` (empty) or error: Bootloader does not expose the variable (rare early prototypes).

---

## 📥 Recovery Flashing & Tethered Boot

### 1. Flash Recovery to Persistent Storage (eMMC)
```powershell
fastboot flash recovery recovery.img
```
* **Expected Output:**
  ```text
  Sending 'recovery' (35728 KB)... OKAY [  1.085s]
  Writing 'recovery'...            OKAY [  0.312s]
  Finished. Total time: 1.458s
  ```

---

### 2. Direct Tethered Boot from Host RAM (Non-Destructive)
Streams the recovery kernel directly into device RAM and boots it without overwriting persistent eMMC storage:
```powershell
fastboot boot recovery.img
```
* **Why this is critical:**
  1. **Stock MIUI Protection:** On stock MIUI, `/system/bin/install-recovery.sh` automatically overwrites custom recoveries back to stock on a regular reboot. Booting directly via `fastboot boot` bypasses stock MIUI and allows immediate OrangeFox survival patching.
  2. **Emergency Diagnostic:** Allows pulling backups or fixing partitions without permanently writing to the `recovery` partition.

---

### 3. Proper Post-Flash Recovery Transition
To ensure custom recovery persists without MIUI overwrite:
1. Flash the image:
   ```powershell
   fastboot flash recovery recovery.img
   ```
2. Immediately boot into it:
   ```powershell
   fastboot boot recovery.img
   ```
   *Alternative:* Hold hardware **Volume Up + Power** on the phone and execute `fastboot reboot`. When the screen goes dark, release Power but keep holding Volume Up until the OrangeFox logo appears.

---

## 💾 Flashing System & Firmware Partitions

> [!CAUTION]
> Flash only partition images built strictly for the Redmi Note 6 Pro (`tulip`). Flashing foreign bootloader or modem bins will break cellular connectivity or brick the device.

### 1. Flash Kernel / Ramdisk (Boot Partition)
Used when updating kernels or applying Magisk / KernelSU patched images:
```powershell
fastboot flash boot boot.img
```

### 2. Flash Device Tree Blob Overlay (DTBO)
Required by newer Android 14–17 custom ROM trees:
```powershell
fastboot flash dtbo dtbo.img
```

### 3. Flash Cellular Modem / Baseband Firmware
Updates baseband firmware (GSM, LTE, Wi-Fi, Bluetooth stack):
```powershell
fastboot flash modem NON-HLOS.bin
```

### 4. Flash Hexagon DSP (Digital Signal Processor)
```powershell
fastboot flash dsp dspso.bin
```

### 5. Flash Boot Splash Screen (Boot Logo)
Replaces initial "Mi" boot logo prior to kernel initialization:
```powershell
fastboot flash splash splash.img
```

---

## 🧹 Wipe & Partition Erase Commands

Low-level eMMC partition formatting via bootloader protocols.

### 1. Erase Fastboot Cache Partition
```powershell
fastboot erase cache
```

### 2. Factory Reset User Data Partition
> [!WARNING]
> Erases all photos, files, installed apps, and personal settings!
```powershell
fastboot erase userdata
```

### 3. Full Factory Reset (UserData + Cache)
```powershell
fastboot -w
```
Formats both `userdata` and `cache`. Recommended before clean-installing ROMs if older encryption keys cause boot conflicts.

> [!IMPORTANT]
> **RESTRICTIONS:**  
> Do NOT execute `fastboot erase system` or `fastboot erase cust` on dynamic/retrofit partition setups. The `cust` partition holds the Retrofit Super block device container. Erasing it via fastboot corrupts dynamic metadata.

---

## 🔄 Reboot & Power Management

| Command | Action |
| :--- | :--- |
| `fastboot reboot` | Standard reboot into installed Android OS. |
| `fastboot reboot bootloader` | Soft restart back into Fastboot mode (useful after changing USB ports). |
| `fastboot reboot-bootloader` | Alias for `reboot bootloader`. |
| `fastboot oem reboot-recovery` | Direct reboot into Recovery mode (supported on specific aboot revisions). |
| `fastboot oem edl` | **Enter Qualcomm EDL Mode (9008)** without opening device or using motherboard test-points. |
| `fastboot reboot edl` | Alternative syntax to enter Emergency Download (EDL) mode. |

---

## 📊 Physical Partition Map (Tulip eMMC)

Master reference of physical partitions on Redmi Note 6 Pro (Snapdragon 636) accessible via Fastboot:

| Partition Name | GPT Size | Function | Safe to Flash via Fastboot? |
| :--- | :---: | :--- | :---: |
| `recovery` | ~64 MB | Custom / Stock recovery image (OrangeFox/TWRP) | ✅ **YES** (`fastboot flash recovery`) |
| `boot` | 64 MB | Linux Kernel + Ramdisk | ✅ **YES** (`fastboot flash boot`) |
| `dtbo` | 8 MB | Device Tree Blob Overlay | ✅ **YES** (`fastboot flash dtbo`) |
| `modem` | 100 MB | Qualcomm Baseband / Cellular firmware | ✅ **YES** (`fastboot flash modem`) |
| `splash` | 32 MB | Early-stage boot logo | ✅ **YES** (`fastboot flash splash`) |
| `dsp` | 16 MB | Hexagon DSP firmware | ✅ **YES** (`fastboot flash dsp`) |
| `cust` | **830.8 MB** | Physical partition (`871366656` bytes). Base for Retrofit Super | ⚠️ **ROM ZIP / Patch only** |
| `system` | 3.0 GB | System image (part of dynamic super in A15–17) | ⚠️ Flash via Recovery |
| `userdata` | ~51–110 GB | Internal storage and user data | ⚠️ Erase only (`fastboot erase`) |
| `fsg`, `modemst1`, `modemst2` | 1.5–2 MB ea | **EFS (IMEI, RF calibration, MAC addresses)** | ⛔ **DO NOT TOUCH IN FASTBOOT** |
| `xbl`, `tz`, `rpm`, `aboot` | 512K–2MB ea | Primary Qualcomm bootloaders | ⛔ **HIGH BRICK RISK** |

---

## 🛠️ Troubleshooting Common Fastboot Errors

### 1. Terminal hangs on `<waiting for any device>`
* **Cause 1:** Missing or broken WinUSB / Android Bootloader drivers.
  * *Fix:* Run [`drivers/install_drivers.cmd`](../../drivers/README.md) as Administrator.
* **Cause 2 (AMD Ryzen Chipset Issue):** Fastboot protocol hangs on AMD B450/B550/X570 USB 3.0/3.1 controllers.
  * *Fix:* Plug cable into a **black USB 2.0 port** on the back of the motherboard. If using a modern laptop with only USB 3.0/Type-C, connect through an inexpensive **passive USB 2.0 Hub**.

### 2. `FAILED (remote: Flashing is not allowed in Lock State)`
* **Cause:** Bootloader is locked.
* *Fix:* Unlock bootloader via official Xiaomi Mi Unlock Tool.

### 3. `FAILED (remote: Partition table doesn't exist)` or `No such partition`
* **Cause:** Typo in partition name or using A/B slot syntax (e.g. `fastboot flash recovery_a`).
* *Fix:* Tulip is an A-only device. Always use bare partition names: `recovery`, `boot`.

### 4. `FAILED (remote: data too large)` or `max-download-size exceeded`
* **Cause:** Image file exceeds bootloader RAM buffer size.
* *Fix:* Recovery images for Tulip should be ~30–45 MB, never exceeding 64 MB. Verify file integrity.

---

## 🔗 Related Documentation
* [📲 Step-by-Step Recovery Installation & F2FS](RECOVERY_INSTALLATION.md)
* [🚀 Getting Started Guide](GETTING_STARTED.md)
* [🛡️ EFS Partition Backup and Rollback](BACKUP_AND_RESTORE.md)
* [🚗 Official Signed Fastboot Drivers Installation](../../drivers/README.md)
