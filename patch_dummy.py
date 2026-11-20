import struct
import hashlib

path = r"C:\Users\User\Documents\redmi\zip_extracted\super_dummy.img"
with open(path, "rb") as f:
    raw = bytearray(f.read())

print("super_dummy.img length:", len(raw))

# Find all occurrences of 872415232 (0x34000000)
tulip_size = 871366656 # 0x33f00000
for i in range(len(raw) - 7):
    if struct.unpack_from("<Q", raw, i)[0] == 872415232:
        print(f"Found 872415232 at offset {i} (0x{i:X})")
        # Check if 'cust' follows within 32 bytes
        sub = raw[i:i+64]
        if b"cust" in sub:
            print(f"  -> Confirmed cust block device at offset {i}")
            struct.pack_into("<Q", raw, i, tulip_size)

# Now check all LpMetadataHeader locations (magic 0x414c5030)
headers = []
for i in range(len(raw) - 4):
    if struct.unpack_from("<I", raw, i)[0] == 0x414c5030:
        headers.append(i)
print(f"Found {len(headers)} LpMetadata headers at offsets:", headers)

for hdr_offset in headers:
    hdr_magic, major, minor, hdr_size = struct.unpack_from("<IHH I", raw, hdr_offset)
    tables_size = struct.unpack_from("<I", raw, hdr_offset + 44)[0]
    tables_offset = hdr_offset + hdr_size
    
    # Recalculate tables checksum
    new_tables_checksum = hashlib.sha256(raw[tables_offset : tables_offset + tables_size]).digest()
    raw[hdr_offset + 48 : hdr_offset + 80] = new_tables_checksum
    
    # Recalculate header checksum
    raw[hdr_offset + 12 : hdr_offset + 44] = b"\x00" * 32
    new_hdr_checksum = hashlib.sha256(raw[hdr_offset : hdr_offset + hdr_size]).digest()
    raw[hdr_offset + 12 : hdr_offset + 44] = new_hdr_checksum
    print(f"Updated header at {hdr_offset}, tables_size={tables_size}")

out_path = r"C:\Users\User\Documents\redmi\zip_extracted\super_dummy_tulip.img"
with open(out_path, "wb") as f:
    f.write(raw)
print("Saved patched super_dummy_tulip.img!")
