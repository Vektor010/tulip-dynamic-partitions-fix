# ❓ Frequently Asked Questions (FAQ)

[🇷🇺 Русская версия](../ru/FAQ.md) | [📚 Index](README.md)

Answers to common community inquiries regarding Redmi Note 6 Pro custom ROMs.

---

### 1. Why upgrade to Android 15, 16, or 17 on a 2018 smartphone?
Official MIUI updates for Redmi Note 6 Pro ceased at Android 9 (MIUI 12).  
Older systems no longer support modern security protocols, current web browsers, banking applications, or modern messaging apps. Modern Android builds provide up-to-date security patches, enhanced battery longevity, and Material You theming.

---

### 2. Can the patcher brick my phone?
**No.** The patcher operates strictly offline on your computer, modifying only files within the ROM `.zip`. It does not execute commands on your phone or touch raw bootloader partitions (`xbl`, `tz`, `aboot`). If an archive contains invalid metadata, recovery simply rejects the install without modifying the device.

---

### 3. Why did someone claim they flashed without patching?
1. **Regarding F2FS:** Many seasoned users converted `/data` to F2FS months ago on previous ROMs. Because recovery does not revert `/data` to ext4 during standard wipes, their phone boots without issue. Novices coming from stock ext4 encounter immediate bootloops.
2. **Regarding Error 1:** Certain custom recoveries have partition size checks bypassed (`IGNORE_PARTITION_SIZE_CHECK`). Official recoveries enforcing strict Google AOSP `liblp` specifications reject Whyred-sized metadata on Tulip.

---

### 4. Does Redmi Note 6 Pro have NFC?
**No.** The Redmi Note 6 Pro does not have a physical NFC controller. Any background NFC daemons (such as `com.android.se`) are superfluous and are disabled in the optimization script to conserve RAM.

---

### 5. How do I restore uninstalled apps after running the optimizer?
Connect the phone via USB with USB Debugging enabled, and run:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\restore_android17.ps1
```
All debloated packages will be re-installed for user 0 in seconds.
