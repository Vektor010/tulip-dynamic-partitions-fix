# 🚨 Errors & Solutions Catalog

[🇷🇺 Русская версия](../ru/ERRORS_AND_SOLUTIONS.md) | [📚 Index](README.md)

Comprehensive reference for troubleshooting every known error encountered when flashing dynamic partition custom ROMs on the **Redmi Note 6 Pro (Tulip)**.

---

## 1. Error 1: `Block device cust size is too small`

### Recovery Log Output:
```text
assert failed: update_dynamic_partitions(package_extract_file("dynamic_partitions_op_list"), package_extract_file("unsparse_super_empty.img"))
[liblp] Block device cust size is too small (expected 872415232, got 871366656)
Updater process ended with ERROR: 1
```

* **Root Cause:** Unified `bouquet` ROM metadata contains Whyred's `cust` physical size (832 MB), exceeding Tulip's factory eMMC allocation (830.8 MB) by exactly 1,048,576 bytes.
* **Prohibited Actions:**  
  ❌ Do not attempt to modify the GPT table using `parted` or `gdisk` on the phone (extreme risk of hard-bricking to EDL 9008).  
  ❌ Do not repeatedly format `cust` in recovery—it does not alter sector counts.
* **Solution:**  
  ✅ Apply the [Automated Patcher](AUTOMATIC_PATCH_GUIDE.md) or follow the [Manual Binary Patch Guide](MANUAL_PATCH_GUIDE.md) to reconcile metadata byte values.

---

## 2. Error 2: Recovery Bootloop (Rescue Party Triggered)

### Symptoms:
The ROM flashes cleanly with Status 0, but during initial boot the phone sits at the boot logo for 1–2 minutes, shuts down, and reboots straight back into **OrangeFox / TWRP**.

* **Root Cause:** Android's `vold` daemon on Linux 4.19 fails to mount `/data` using `fscrypt v2` encryption (`fileencryption=aes-256-xts:aes-256-cts:v2+emmc_optimized`) because the partition was formatted in legacy ext4 without inode encryption flags.
* **Solution:**
  1. In OrangeFox / TWRP, open **Manage Partitions**.
  2. Select **Data** ➔ tap **Change FS** ➔ choose **F2FS** ➔ swipe to apply.
  3. Select **Cache** ➔ tap **Change FS** ➔ choose **F2FS** ➔ swipe to apply.
  4. Navigate to **Wipe ➔ Format Data** ➔ type `yes`.
  5. Tap **Reboot System**.

---

## 3. Error 3: `Logical partition metadata has invalid checksum`

### Recovery Log Output:
```text
[liblp] Logical partition metadata has invalid checksum
Updater process ended with ERROR: 1
```

* **Root Cause:** `unsparse_super_empty.img` or `super_dummy.img` was manually hex-edited without recalculating SHA-256 hashes in `LpMetadataHeader`. Google `liblp` rejects corrupt metadata.
* **Solution:**  
  Use the official AOSP SHA-256 recalculation procedure documented in the [Manual Patch Guide](MANUAL_PATCH_GUIDE.md) or use `scripts/patch_tulip_dynamic_rom.py`.

---

## 4. Error 4: `Signature verification failed / error: 21`

### Recovery Log Output:
```text
Signature verification failed
Install anyway?
E:Zip signature verification failed: 21
```

* **Root Cause:** Unofficial custom ROMs are signed with public developer `test-keys` rather than Google's private release keys.
* **Solution:**  
  This is a non-fatal warning. Select **Yes** (Install anyway) in AOSP recovery, or disable *«Zip signature verification»* in OrangeFox settings.

---

## 5. Error 5: Fastboot Connection Hangs on AMD Ryzen

### Symptoms:
`fastboot devices` returns empty output, or commands hang indefinitely at `< waiting for any device >`.

* **Root Cause:** Asynchronous USB 3.0/3.1 controllers on AMD AM4/AM5 motherboards (B450, B550, X570) exhibit packet dropouts with legacy USB 2.0 Fastboot protocols.
* **Solution:**
  1. Connect the phone exclusively to **black USB 2.0 ports** on the rear I/O shield.
  2. If only USB 3.0 ports are present, connect through an unpowered USB 2.0 hub.
  3. Install official signed drivers via `drivers\install_drivers.cmd`.
