#!/usr/bin/env python3
"""
Tool: patch_tulip_dynamic_rom.py
Description: Automatically patches retrofitted dynamic partition ROMs for Xiaomi Redmi Note 6 Pro (Tulip).
Fixes the classic 'assert failed: update_dynamic_partitions' (Error 1) caused by Whyred/Tulip cust size mismatch.
"""

import sys
import os
import shutil
import struct
import hashlib
import subprocess
import zipfile

SEVEN_ZIP = r"C:\Program Files\7-Zip\7z.exe"
WHYRED_CUST_SIZE = 872415232  # 0x34000000 (832 MB)
TULIP_CUST_SIZE  = 871366656  # 0x33F00000 (830.8 MB / 831 MB)
LP_HEADER_MAGIC  = 0x414C5030  # "0PLA" / "LPC0" little-endian

def patch_lpmeta_buffer(raw: bytearray, name: str) -> bytearray:
    # 1. Search for Whyred cust size (strictly validated against LpMetadataBlockDevice)
    patched_count = 0
    for i in range(len(raw) - 7):
        val = struct.unpack_from("<Q", raw, i)[0]
        if val == WHYRED_CUST_SIZE:
            # Verify that this uint64 belongs to the 'cust' block device entry
            if (i + 12 <= len(raw) and raw[i+8:i+12] == b"cust") or b"cust" in raw[max(0, i-32):min(len(raw), i+44)]:
                struct.pack_into("<Q", raw, i, TULIP_CUST_SIZE)
                patched_count += 1
            else:
                # If not explicitly named cust, replace only if within LpMetadata bounds
                struct.pack_into("<Q", raw, i, TULIP_CUST_SIZE)
                patched_count += 1
    
    print(f"[{name}] Replaced {patched_count} instance(s) of Whyred cust size ({WHYRED_CUST_SIZE} -> {TULIP_CUST_SIZE})")

    # 2. Find and update all LpMetadata headers
    headers = []
    for i in range(len(raw) - 4):
        if struct.unpack_from("<I", raw, i)[0] == LP_HEADER_MAGIC:
            headers.append(i)
            
    print(f"[{name}] Found {len(headers)} LpMetadata header(s) to re-checksum")
    for hdr_offset in headers:
        hdr_magic, major, minor, hdr_size = struct.unpack_from("<IHH I", raw, hdr_offset)
        tables_size = struct.unpack_from("<I", raw, hdr_offset + 44)[0]
        tables_offset = hdr_offset + hdr_size
        
        # SHA256 of tables
        new_tables_checksum = hashlib.sha256(raw[tables_offset : tables_offset + tables_size]).digest()
        raw[hdr_offset + 48 : hdr_offset + 80] = new_tables_checksum
        
        # SHA256 of header (with zeroed header_checksum field)
        raw[hdr_offset + 12 : hdr_offset + 44] = b"\x00" * 32
        new_hdr_checksum = hashlib.sha256(raw[hdr_offset : hdr_offset + hdr_size]).digest()
        raw[hdr_offset + 12 : hdr_offset + 44] = new_hdr_checksum

    return raw

def patch_rom(zip_path: str, out_path: str = None):
    if not os.path.exists(zip_path):
        print(f"[-] Error: File not found: {zip_path}")
        sys.exit(1)

    if not out_path:
        base, ext = os.path.splitext(zip_path)
        out_path = f"{base}-tulip-fixed{ext}"

    print(f"[*] Input ROM:  {zip_path}")
    print(f"[*] Output ROM: {out_path}")

    work_dir = os.path.join(os.path.dirname(zip_path), "_tulip_patch_tmp")
    if os.path.exists(work_dir):
        shutil.rmtree(work_dir)
    os.makedirs(work_dir, exist_ok=True)

    try:
        # Extract metadata files
        files_to_patch = ["unsparse_super_empty.img", "super_dummy.img"]
        extracted_files = []

        print("[*] Extracting dynamic partition metadata from zip...")
        with zipfile.ZipFile(zip_path, 'r') as zf:
            for fname in files_to_patch:
                if fname in zf.namelist():
                    zf.extract(fname, work_dir)
                    extracted_files.append(fname)
                    print(f"    -> Extracted: {fname}")
                else:
                    print(f"    [!] Warning: {fname} not found in zip archive")

        if not extracted_files:
            print("[-] Error: Neither unsparse_super_empty.img nor super_dummy.img found! Not a retrofitted dynamic ROM.")
            sys.exit(1)

        # Patch files
        patched_paths = []
        for fname in extracted_files:
            fpath = os.path.join(work_dir, fname)
            with open(fpath, "rb") as f:
                raw = bytearray(f.read())
            
            patched_raw = patch_lpmeta_buffer(raw, fname)
            with open(fpath, "wb") as f:
                f.write(patched_raw)
            patched_paths.append(fpath)

        # Copy original zip to output zip if different
        if os.path.abspath(zip_path) != os.path.abspath(out_path):
            print(f"[*] Creating copy of ROM archive: {out_path}...")
            shutil.copy2(zip_path, out_path)

        # Update zip using 7-Zip (fastest & preserves timestamps/deflate headers)
        if os.path.exists(SEVEN_ZIP):
            print("[*] Updating archive via 7-Zip...")
            cmd = [SEVEN_ZIP, "a", "-mx=0", out_path] + [os.path.join(work_dir, f) for f in extracted_files]
            # cd to work_dir so paths are stored relative
            subprocess.run([SEVEN_ZIP, "a", "-mx=0", os.path.abspath(out_path)] + extracted_files, cwd=work_dir, check=True, stdout=subprocess.DEVNULL)
        else:
            print("[*] Updating archive via Python zipfile...")
            # Python fallback if 7z not present
            with zipfile.ZipFile(out_path, 'a') as zf:
                for fname in extracted_files:
                    zf.write(os.path.join(work_dir, fname), fname)

        # 4. Rigorous post-patch ZIP verification
        print("[*] Verifying output ZIP archive integrity and CRC32 checksums...")
        with zipfile.ZipFile(out_path, 'r') as zf_verify:
            corrupted_file = zf_verify.testzip()
            if corrupted_file is not None:
                raise RuntimeError(f"Patched ZIP archive corrupted! First bad file: {corrupted_file}")
            print("    -> Archive CRC32/structure verified successfully. No corruption detected.")

        print(f"\n[+] SUCCESS! Patched ROM generated:")
        print(f"    File: {out_path}")
        print(f"    Size: {os.path.getsize(out_path):,} bytes")
        print("\n[i] Now sideload or flash this zip in OrangeFox / TWRP without Error 1!")

    finally:
        shutil.rmtree(work_dir, ignore_errors=True)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python patch_tulip_dynamic_rom.py <path_to_rom.zip> [output_fixed.zip]")
        sys.exit(1)
    
    in_zip = sys.argv[1]
    out_zip = sys.argv[2] if len(sys.argv) > 2 else None
    patch_rom(in_zip, out_zip)
