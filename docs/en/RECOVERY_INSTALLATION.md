# 📲 Custom Recovery Installation & ROM Flashing (OrangeFox / TWRP)

[🇷🇺 Русская версия](../ru/RECOVERY_INSTALLATION.md) | [📚 Index](README.md)

This comprehensive guide covers:
1. **How to install the custom recovery (OrangeFox / TWRP) onto your phone from a PC via Fastboot.**
2. **How to flash the prepared ROM archive inside recovery and configure F2FS storage.**

---

## 📥 Part 1: Installing Custom Recovery via Fastboot

Follow this procedure if your phone is currently running stock MIUI recovery or if you are flashing custom recovery for the first time.

### 📋 Prerequisites:
1. **Unlocked Bootloader:** Ensure "unlocked" with an open padlock icon is displayed at boot.
2. **Fastboot USB Drivers:** Run [`drivers/install_drivers.cmd`](../../drivers/README.md) as Administrator on your PC.
3. **ADB & Fastboot CLI Tools:** Installed via `winget install Google.PlatformTools` or unpacked from the Google Platform Tools archive.
4. **Recovery Image File:** Download an up-to-date image for **Redmi Note 6 Pro (Tulip)**:
   * **OrangeFox Recovery** (Recommended) — Download the `OrangeFox-*.zip` archive and extract `recovery.img` from it.
   * **TWRP Recovery** — Download `twrp-*-tulip.img` and rename it to `recovery.img` for convenience.

---

### 🔌 Step-by-Step Fastboot Commands:

#### Step 1. Put the Phone into Fastboot Mode
1. Power off the smartphone completely.
2. Press and hold **Volume Down + Power** simultaneously.
3. Keep holding for 5–7 seconds until the screen displays the orange **FASTBOOT** banner (or the Xiaomi bunny mascot).
4. Connect the phone to your PC using a reliable Micro-USB cable (preferably a black USB 2.0 rear port on your motherboard).

#### Step 2. Verify Fastboot Connection
Open a PowerShell or Command Prompt terminal in the directory where your `recovery.img` is saved, and execute:
```powershell
fastboot devices
```
> **Expected Output:** Your device serial number alongside the `fastboot` keyword:  
> `6357460b    fastboot`  
> *(If the output is blank, review cable connections and install drivers via [`drivers/install_drivers.cmd`](../../drivers/README.md)).*

#### Step 3. Flash Recovery Image to the Hardware Partition
Write the recovery image directly to the physical `recovery` partition:
```powershell
fastboot flash recovery recovery.img
```
> **Expected Output:**
> ```text
> Sending 'recovery' (35728 KB)... OKAY [  1.120s]
> Writing 'recovery'...            OKAY [  0.345s]
> Finished. Total time: 1.512s
> ```

#### Step 4. Initial Boot into Custom Recovery
> [!CAUTION]
> **CRITICAL: PREVENTING STOCK MIUI OVERWRITE!**  
> If you reboot normally into the Android operating system at this point, stock MIUI will **automatically overwrite your custom recovery with the factory recovery** on its first startup!  
> You MUST boot directly into your newly flashed custom recovery immediately.

Initiate an immediate direct boot from RAM:
```powershell
fastboot boot recovery.img
```
*(Alternative manual method: Press and hold **Volume Up + Power** on the phone, then execute `fastboot reboot`. The moment the display goes dark, release the Power button but keep holding Volume Up until the OrangeFox/TWRP splash screen appears).*

#### Step 5. Persist OrangeFox Installation (OrangeFox Only)
If you downloaded OrangeFox as a full ZIP package:
1. After booting into OrangeFox, transfer the complete `OrangeFox-*.zip` archive to your MicroSD card or phone storage.
2. In the OrangeFox interface, navigate to the **Files** tab ➔ select `OrangeFox-*.zip` ➔ **Swipe to Install**.
3. OrangeFox will flash its survival engine, kernel ramdisk patches, and automatic recovery maintenance scripts, then reboot back into permanent OrangeFox.

---

## 🦊 Part 2: Flashing ROM via OrangeFox (Recommended)

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
