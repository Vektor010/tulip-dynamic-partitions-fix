import struct
import hashlib

path = r"C:\Users\User\Documents\redmi\zip_extracted\unsparse_super_empty.img"
with open(path, "rb") as f:
    raw = bytearray(f.read())

hdr_offset = 4096
hdr_size = 128
tables_size = struct.unpack_from("<I", raw, hdr_offset + 44)[0]

# Check cust size before
cust_size_before = struct.unpack_from("<Q", raw, 4724)[0]
print(f"cust size before: {cust_size_before} (0x{cust_size_before:08x})")

# Patch to tulip's cust size: 871366656 (0x33f00000)
tulip_cust_size = 871366656
struct.pack_into("<Q", raw, 4724, tulip_cust_size)
print(f"cust size after: {struct.unpack_from('<Q', raw, 4724)[0]}")

# 1. Update tables checksum in header
tables_offset = hdr_offset + hdr_size
new_tables_checksum = hashlib.sha256(raw[tables_offset : tables_offset + tables_size]).digest()
raw[hdr_offset + 48 : hdr_offset + 80] = new_tables_checksum

# 2. Update header checksum
raw[hdr_offset + 12 : hdr_offset + 44] = b"\x00" * 32
new_hdr_checksum = hashlib.sha256(raw[hdr_offset : hdr_offset + hdr_size]).digest()
raw[hdr_offset + 12 : hdr_offset + 44] = new_hdr_checksum

# Save patched file
patched_path = r"C:\Users\User\Documents\redmi\zip_extracted\unsparse_super_empty_tulip.img"
with open(patched_path, "wb") as f:
    f.write(raw)

print(f"Successfully generated patched {patched_path}")
