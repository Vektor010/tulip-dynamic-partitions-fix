# 💾 Backup, Disaster Recovery & Rollback

[🇷🇺 Русская версия](../ru/BACKUP_AND_RESTORE.md) | [📚 Index](README.md)

Critical safety instructions for creating radio firmware backups and performing a clean rollback to factory MIUI.

---

## 🛡️ Critical Hardware Partitions

| Partition | Data Stored | Failure Consequence |
| :--- | :--- | :--- |
| **EFS (Modemst1 / Modemst2 / FSG)** | Unique NVRAM calibration, serials, and device **IMEI**. | Complete loss of cellular baseband ("No Service", null IMEI). |
| **Persist** | Factory sensor calibration (fingerprint sensor, accelerometer, proximity). | Proximity sensor fails during calls, fingerprint reader inoperative. |
| **Modem (NON-HLOS.bin)** | Qualcomm Snapdragon 636 baseband firmware. | Inability to connect to LTE or 5GHz Wi-Fi. |
| **Boot** | Linux kernel and initial ramdisk. | Device bootloop at early splash stage. |

---

## 📦 How to Create a Partition Backup

1. Boot into recovery (hold **Volume Up + Power**).
2. Tap **Backup**.
3. Check the following partitions:
   * [x] **EFS**
   * [x] **Persist**
   * [x] **Modem (Firmware)**
   * [x] **Boot**
4. Set storage destination to **MicroSD Card** or **USB-OTG**.
5. Swipe to backup.
6. Transfer a copy of the backup folder to your PC for long-term safe-keeping.

---

## 🔄 Emergency Rollback to Stock MIUI (MiFlash)

If you need to return your Redmi Note 6 Pro to stock factory condition:
1. Download official MIUI Global Stable Fastboot ROM (`.tgz` package).
2. Extract the archive directly to `C:\` (ensure path contains no spaces).
3. Put phone into **Fastboot Mode** (hold **Volume Down + Power**).
4. Launch official **Xiaomi MiFlash Tool**.
5. Click **Select** and point to the extracted firmware folder.
6. > [!CAUTION]
   > At the bottom of MiFlash, **ALWAYS select `clean all` (flash_all.bat)**!  
   > **NEVER select `clean all and lock`!** Relocking the bootloader on non-stock partitions will hard-brick the device!
7. Click **Flash** and wait for the `success` status.
