# 📲 Flashing via OrangeFox & TWRP Recovery

[🇷🇺 Русская версия](../ru/RECOVERY_INSTALLATION.md) | [📚 Index](README.md)

Comprehensive instructions for flashing your prepared ROM archive via custom recovery.

---

## 🦊 Method 1: In OrangeFox Recovery (Recommended)

### Step 1. Transfer ROM to Phone
* **Option A (MicroSD Card):** Copy `*-tulip-fixed.zip` to a MicroSD card or USB-OTG drive.
* **Option B (ADB Sideload):** Connect phone to PC, go to **Menu ➔ ADB Sideload ➔ swipe to start**, and run on PC:
  ```powershell
  adb sideload "C:\path\to\ROM-tulip-fixed.zip"
  ```

### Step 2. Flash the Archive
1. On the main OrangeFox screen, tap the **Files** tab (folder icon).
2. Select your `*-tulip-fixed.zip` file.
3. Swipe right to confirm (**Swipe to Install**).
4. Wait for installation to conclude with `Status 0` / `Success`.

### Step 3. Configure F2FS Storage (Prevent Bootloop)
> [!IMPORTANT]
> **DO NOT REBOOT DIRECTLY AFTER FLASHING!**
1. Tap the **Menu icon** (three horizontal bars, bottom right).
2. Tap **Manage Partitions**.
3. Select **Data** ➔ tap **Change FS** ➔ choose **F2FS** ➔ swipe to apply.
4. Go back one step, select **Cache** ➔ tap **Change FS** ➔ choose **F2FS** ➔ swipe to apply.

### Step 4. Format Data
1. Navigate to the **Wipe** tab.
2. Tap **Format Data**.
3. Type `yes` and confirm.
4. Tap **Reboot System**.

---

## 🔷 Method 2: In TWRP Recovery

1. In TWRP main menu, tap **Install**.
2. Select the ROM `.zip` file and swipe to confirm flash.
3. Once completed, return to main menu ➔ tap **Wipe ➔ Advanced Wipe**.
4. Check **ONLY** the **Data** box.
5. Tap **Repair or Change File System** ➔ tap **Change File System** ➔ choose **F2FS** ➔ swipe to confirm.
6. Return, check **Cache** ➔ tap **Repair or Change File System** ➔ choose **F2FS** ➔ swipe.
7. Return to main menu ➔ tap **Wipe ➔ Format Data** ➔ type `yes`.
8. Tap **Reboot ➔ System**.
