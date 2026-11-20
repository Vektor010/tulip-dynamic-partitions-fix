# 🛠️ Manual Binary Patch Guide

[🇷🇺 Русская версия](../ru/MANUAL_PATCH_GUIDE.md) | [📚 Index](README.md)

Designed for security-conscious developers and advanced users who prefer auditing every byte directly rather than executing automated scripts.

---

## 🧰 Prerequisites
1. Archive utility: **7-Zip** or **WinRAR**.
2. Freeware Hex Editor: **HxD** ([official website](https://mh-nexus.de/en/hxd/)) or **ImHex**.
3. Python 3.x environment (used solely for offline SHA-256 recalculation).

---

## 🔍 Step 1. Extract Metadata Images
1. Open your ROM archive (`rom-name.zip`) in **7-Zip**.
2. Extract the following root files to your desktop:
   * `unsparse_super_empty.img`
   * `super_dummy.img` (if present).

---

## ✏️ Step 2. Byte Replacement via Hex Editor

ARM architecture stores integer values in **Little-Endian** format (least significant byte first):

| Parameter | Decimal Value | Hexadecimal | File Byte Sequence (8-byte Little-Endian) |
| :--- | :--- | :--- | :--- |
| **Whyred (Original)** | `872,415,232` bytes | `0x34000000` | `00 00 00 34 00 00 00 00` |
| **Tulip (Target)** | `871,366,656` bytes | `0x33F00000` | `00 00 F0 33 00 00 00 00` |

### Hex Editor Steps (HxD):
1. Open `unsparse_super_empty.img` in **HxD**.
2. Press **Ctrl + F** ➔ select the **Hex-values** tab.
3. Search for:  
   `00 00 00 34 00 00 00 00`
4. Replace with:  
   `00 00 F0 33 00 00 00 00`
5. Press **F3** to replace any additional instances in the `cust` block device descriptor.
6. Repeat for `super_dummy.img` (contains 4 instances across active/backup metadata slots).

---

## 🔒 Step 3. Recalculate AOSP `liblp` SHA-256 Checksums

> [!WARNING]
> Saving without updating the SHA-256 checksums causes `liblp` to reject the image with `Logical partition metadata has invalid checksum`.

Execute this clean, dependency-free Python snippet to recalculate the header and partition table hashes:

```python
import hashlib, struct

def recalculate_lpmeta_checksums(filepath):
    with open(filepath, "r+b") as f:
        raw = bytearray(f.read())

    # Locate Google LpMetadata header magic (0x414C5030 / '0PLA')
    for pos in range(len(raw) - 4):
        if raw[pos:pos+4] == b"\x30\x50\x4c\x41":
            hdr_size = struct.unpack_from("<I", raw, pos + 8)[0]
            tbl_size = struct.unpack_from("<I", raw, pos + 44)[0]

            # 1. SHA-256 of partition tables
            tbl_hash = hashlib.sha256(raw[pos + hdr_size : pos + hdr_size + tbl_size]).digest()
            raw[pos + 48 : pos + 80] = tbl_hash

            # 2. SHA-256 of header with header_checksum zeroed
            raw[pos + 12 : pos + 44] = b"\x00" * 32
            hdr_hash = hashlib.sha256(raw[pos : pos + hdr_size]).digest()
            raw[pos + 12 : pos + 44] = hdr_hash

    with open(filepath, "wb") as f:
        f.write(raw)
    print(f"[OK] Checksums updated successfully for: {filepath}")

recalculate_lpmeta_checksums("unsparse_super_empty.img")
recalculate_lpmeta_checksums("super_dummy.img")
```

---

## 📦 Step 4. Repack into the ROM Archive

1. Open the original ROM `.zip` in **7-Zip**.
2. Drag and drop the modified `unsparse_super_empty.img` and `super_dummy.img` directly into 7-Zip, confirming file overwrites.
3. In 7-Zip, click **Test** to ensure archive CRC32 consistency.
4. Your ROM is ready to flash without Error 1!
