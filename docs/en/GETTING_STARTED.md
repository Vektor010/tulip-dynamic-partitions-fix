# 🚀 Getting Started: Beginner Flashing Guide

[🇷🇺 Русская версия](../ru/GETTING_STARTED.md) | [📚 Index](README.md)

This step-by-step walkthrough guides you through installing a modern dynamic partition ROM on your **Redmi Note 6 Pro** from scratch.

---

## 📋 Pre-Flight Checklist

Before you begin, verify that you have:
- [ ] **Redmi Note 6 Pro handset** (codename `tulip` or `twolip`).
- [ ] **Unlocked Bootloader:** The phone displays an open padlock and "unlocked" during boot.
- [ ] **Compatible Custom Recovery:** **OrangeFox R11.1+** (recommended) or recent **TWRP**.
- [ ] **Reliable Micro-USB Cable** connected to a motherboard USB port (USB 2.0 preferred).
- [ ] **Battery charged to at least 50%**.
- [ ] **Full Data Backup:** Formatting the device is mandatory and will erase all data!

> [!CAUTION]
> **MANDATORY DATA LOSS WARNING:**  
> Transitioning to dynamic partitions and F2FS requires a full **Format Data** operation (`yes` confirmation). All internal storage data (photos, documents, messages) will be permanently wiped. Backup critical data before proceeding!

---

## 🗺️ High-Level Flashing Flow

| Stage | Operation | Environment |
| :---: | :--- | :---: |
| **1** | Install Windows USB Drivers | PC |
| **2** | Create EFS / Radio Backup | Recovery |
| **3** | Patch ROM ZIP (if using unified bouquet) | PC |
| **4** | Flash Patched ROM Archive | Recovery |
| **5** | Switch `/data` and `/cache` to F2FS | Recovery |
| **6** | Execute Format Data (`yes`) | Recovery |
| **7** | Initial Boot & System Optimization | Phone + PC |

---

## 🛠️ Step-by-Step Instructions

### Step 1. Windows Driver Configuration
If your computer fails to detect the phone in Fastboot or Recovery:
1. Navigate to the `drivers/` directory in the repository.
2. Right-click **`install_drivers.cmd`** and select **Run as Administrator**.
3. Allow the script to register official Xiaomi and Google driver packages. See [Driver Documentation](../../drivers/README.md) for details.

### Step 1.1. Installing Custom Recovery via Fastboot
*(If your phone is still running the factory MIUI recovery)*:
1. Put the powered-off phone into Fastboot mode: hold **Volume Down + Power**.
2. Connect to PC via USB and execute in terminal:
   ```powershell
   fastboot devices
   fastboot flash recovery recovery.img
   fastboot boot recovery.img
   ```
3. For full details on avoiding stock MIUI recovery overwrite, see the [Recovery Installation Guide](RECOVERY_INSTALLATION.md).

### Step 2. Safeguard Radio Calibration
Boot into recovery (hold **Volume Up + Power** from powered-off state):
1. Navigate to the **Backup** menu.
2. Select: **EFS**, **Persist**, **Modem (Firmware)**, and **Boot**.
3. Save the backup to a MicroSD card or copy it to your PC. See [Backup & Recovery Guide](BACKUP_AND_RESTORE.md).

### Step 3. Prepare the ROM File
If your ROM is built as a unified Whyred/Tulip image and aborts with Error 1 during testing:
* Patch the file using the [Automated Patcher](AUTOMATIC_PATCH_GUIDE.md) or follow the [Manual Binary Patch Guide](MANUAL_PATCH_GUIDE.md).

### Step 4. Install the ROM
1. In OrangeFox / TWRP, go to **Files / Install**.
2. Select your patched `*-tulip-fixed.zip` archive.
3. Swipe to flash. Confirm the installation finishes with `Status 0` / `Success`.

### Step 5. Configure F2FS & Format Data
> [!IMPORTANT]
> **DO NOT REBOOT IMMEDIATELY AFTER FLASHING!**
1. In recovery, navigate to **Manage Partitions**.
2. Select **Data** ➔ tap **Change FS** ➔ choose **F2FS** ➔ swipe to apply.
3. Select **Cache** ➔ tap **Change FS** ➔ choose **F2FS** ➔ swipe to apply.
4. Navigate to **Wipe** ➔ tap **Format Data** ➔ type `yes` and confirm.

### Step 6. Initial Boot
Tap **Reboot System**.  
The initial boot of Android 15–17 takes between 2 to 5 minutes while system caches initialize.
