import struct
import hashlib

path = r"C:\Users\User\Documents\redmi\zip_extracted\unsparse_super_empty.img"
with open(path, "rb") as f:
    raw = bytearray(f.read())

hdr_offset = 4096
hdr_size = 128
orig_hdr_checksum = bytes(raw[hdr_offset+12 : hdr_offset+44])

# Test checksum of header with checksum zeroed:
hdr_copy = bytearray(raw[hdr_offset : hdr_offset + hdr_size])
hdr_copy[12:44] = b"\x00" * 32
calc_hdr_checksum = hashlib.sha256(hdr_copy).digest()
print("Matches original hdr_checksum?", calc_hdr_checksum == orig_hdr_checksum)

# Test geometry checksum:
geom_size = 52
orig_geom_checksum = bytes(raw[6:38])
geom_copy = bytearray(raw[0:geom_size])
geom_copy[6:38] = b"\x00" * 32
calc_geom_checksum = hashlib.sha256(geom_copy).digest()
print("Matches original geom_checksum?", calc_geom_checksum == orig_geom_checksum)
