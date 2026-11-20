import struct
import hashlib

# Android LpMetadata format definitions:
# LP_METADATA_GEOMETRY_MAGIC = 0x616c4430 ("0Dla" little-endian)
# LP_METADATA_HEADER_MAGIC = 0x3043504c ("LPC0" little-endian)

path = r"C:\Users\User\Documents\redmi\zip_extracted\unsparse_super_empty.img"
with open(path, "rb") as f:
    raw = bytearray(f.read())

print("File size:", len(raw))
magic = struct.unpack_from("<I", raw, 0)[0]
print(f"Geometry magic: 0x{magic:08x} (expected 0x616c4430)")

# LpMetadataGeometry is 4096 bytes:
# struct LpMetadataGeometry {
#     uint32_t magic;
#     uint16_t struct_size;
#     uint8_t checksum[32]; // SHA256 of geometry without magic & checksum
#     uint32_t metadata_max_size;
#     uint32_t metadata_slot_count;
#     uint32_t logical_block_size;
# };

geom_magic, geom_size = struct.unpack_from("<IH", raw, 0)
geom_checksum = raw[6:38]
metadata_max_size, metadata_slot_count, logical_block_size = struct.unpack_from("<III", raw, 38)
print(f"geom_size={geom_size}, metadata_max_size={metadata_max_size}, slot_count={metadata_slot_count}, block_size={logical_block_size}")

# After 4096 bytes is the primary metadata (LpMetadataHeader):
# struct LpMetadataHeader {
#     uint32_t magic;
#     uint16_t major_version;
#     uint16_t minor_version;
#     uint32_t header_size;
#     uint8_t header_checksum[32];
#     uint32_t tables_size;
#     uint8_t tables_checksum[32];
#     LpMetadataTableDescriptor partitions;
#     LpMetadataTableDescriptor extents;
#     LpMetadataTableDescriptor groups;
#     LpMetadataTableDescriptor block_devices;
# };

hdr_offset = 4096
hdr_magic, major, minor, hdr_size = struct.unpack_from("<IHH I", raw, hdr_offset)
print(f"Header magic: 0x{hdr_magic:08x} (expected 0x3043504c), version={major}.{minor}, hdr_size={hdr_size}")
hdr_checksum = raw[hdr_offset+12:hdr_offset+44]
tables_size = struct.unpack_from("<I", raw, hdr_offset+44)[0]
tables_checksum = raw[hdr_offset+48:hdr_offset+80]
print(f"tables_size={tables_size}")

tables_offset = hdr_offset + hdr_size
tables_data = raw[tables_offset : tables_offset + tables_size]
calc_tables_checksum = hashlib.sha256(tables_data).digest()
print("Matches original tables_checksum?", calc_tables_checksum == bytes(tables_checksum))
