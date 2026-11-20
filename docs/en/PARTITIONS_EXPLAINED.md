# 🧩 Partition Architecture & Retrofit Dynamic Partitions

[🇷🇺 Русская версия](../ru/PARTITIONS_EXPLAINED.md) | [📚 Index](README.md)

Understanding storage geometry and dynamic partition virtualization is key to successfully flashing modern Android versions on legacy hardware.

---

## 📖 Key Concepts for Beginners

### 1. What is GPT (GUID Partition Table)?
The physical eMMC flash memory of the phone is partitioned into fixed sectors called **partitions**. The master directory defining the precise sector offsets and lengths of these partitions is the **GUID Partition Table (GPT)**.  
Examples of factory physical partitions: `boot`, `recovery`, `system`, `vendor`, `cust`, and `userdata`.

### 2. What is the `cust` Partition?
Originally designated by Xiaomi for carrier customizations and regional bloatware in MIUI, `cust` is completely vacant and unused in modern AOSP custom ROMs.

### 3. What are Dynamic Partitions?
Introduced by Google in Android 10, dynamic partitions replace rigidly-sized physical partitions (`system`, `vendor`) with a single pooled container partition called **`super`**. Within `super`, partitions are **logical sub-volumes** that expand and contract on demand using the Linux kernel's Device Mapper (`dm-linear`) driver.

---

## 🔄 Retrofit Dynamic Partitions Explained

Because the **Redmi Note 6 Pro** launched with Android 8.1 Oreo, its physical GPT lacks a factory `super` partition.

To support modern Android 14, 15, 16, and 17, developers employ Google's **Retrofit Dynamic Partitions** standard:
1. The factory physical `system` partition serves as the primary block device.
2. The idle physical `cust` partition is linked as a secondary block device.
3. Together, they are joined into a virtual pool called **`qti_dynamic_partitions`** totaling over 6 GB of combined storage!
4. Inside this retrofitted pool, logical volumes for `system`, `vendor`, `product`, and `system_ext` are created dynamically.

```text
Physical eMMC Storage Layout:
[ ... | system (physical) | vendor | cust (830.8 MB) | userdata ... ]
             │                               │
             └───────────────┬───────────────┘
                             ▼
Virtual "qti_dynamic_partitions" Super Group:
┌────────────────┬───────────────┬───────────────┬────────────────┐
│ /system (dyn)  │ /vendor (dyn) │ /product (dyn)│ /system_ext    │
└────────────────┴───────────────┴───────────────┴────────────────┘
```

---

## 📄 Purpose of `unsparse_super_empty.img` and `super_dummy.img`

These are not Android operating system images, but **binary configuration descriptors**:
* **`unsparse_super_empty.img`** — Contains Google `liblp` metadata defining the block device geometry, group quotas, and logical partition tables.
* **`super_dummy.img`** — A preliminary metadata skeleton flashed to the header of the `system` partition by `flash_super_dummy.sh` upon initial retrofit setup.

---

## ⚠️ The Partition Wipe Myth: Why Wiping `cust` Does Not Fix Size Checks

A common misconception is that selecting *«Wipe Cust»* or *«Format Cust»* in recovery will resolve the `cust size is too small` error.

**Technical Reality:**
* Formatting a partition only wipes its internal filesystem and directory tree.
* Formatting **does NOT alter partition boundaries in the GPT table**!
* When recovery initiates `update_dynamic_partitions`, `liblp` calls `ioctl(BLKGETSIZE64)`. The kernel reports the exact physical sector capacity (`871,366,656` bytes).
* If the ROM metadata specifies Whyred's `872,415,232` bytes, recovery detects a 1 MB shortage and aborts. Wiping or formatting `cust` cannot alter this; **only modifying the metadata solves the error**.
