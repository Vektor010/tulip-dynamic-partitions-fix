#!/usr/bin/env python3
"""
Unit and integration tests for patch_tulip_dynamic_rom.py.
Tests binary LpMetadata buffer replacement, SHA-256 recalculation,
ZIP integrity verification, fail-closed error handling, and archive isolation.
"""

import unittest
import os
import sys
import tempfile
import struct
import hashlib
import zipfile
import shutil

# Ensure scripts folder is on sys.path
SCRIPTS_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "scripts"))
if SCRIPTS_DIR not in sys.path:
    sys.path.insert(0, SCRIPTS_DIR)

from patch_tulip_dynamic_rom import (
    patch_lpmeta_buffer,
    patch_rom,
    WHYRED_CUST_SIZE,
    TULIP_CUST_SIZE,
    LP_HEADER_MAGIC
)

class TestPatchLpMetadata(unittest.TestCase):

    def setUp(self):
        self.test_dir = tempfile.mkdtemp(prefix="tulip_test_")

    def tearDown(self):
        shutil.rmtree(self.test_dir, ignore_errors=True)

    def _create_mock_lpmeta_buffer(self, cust_size=WHYRED_CUST_SIZE):
        """Constructs a mock LpMetadata binary buffer with valid AOSP layout."""
        raw = bytearray(512)
        # 1. Header at offset 0
        hdr_size = 80
        tbl_size = 128
        struct.pack_into("<IHH I", raw, 0, LP_HEADER_MAGIC, 1, 0, hdr_size)
        struct.pack_into("<I", raw, 44, tbl_size)

        # 2. Block device entry at offset 80 (tables start)
        # LpMetadataBlockDevice:
        # uint32 first_logical_sector;
        # uint32 alignment;
        # uint32 alignment_offset;
        # uint64 size;
        # char partition_name[36];
        # uint32 flags;
        blk_offset = 80
        struct.pack_into("<III", raw, blk_offset, 0, 4096, 0)
        struct.pack_into("<Q", raw, blk_offset + 12, cust_size)
        raw[blk_offset + 20 : blk_offset + 24] = b"cust"

        # 3. Calculate initial checksums
        tbl_hash = hashlib.sha256(raw[hdr_size : hdr_size + tbl_size]).digest()
        raw[48:80] = tbl_hash

        raw[12:44] = b"\x00" * 32
        hdr_hash = hashlib.sha256(raw[:hdr_size]).digest()
        raw[12:44] = hdr_hash

        return raw

    def test_patch_lpmeta_buffer_replaces_whyred_size(self):
        buf = self._create_mock_lpmeta_buffer(WHYRED_CUST_SIZE)
        patched = patch_lpmeta_buffer(buf, "test_device")

        # Verify size replaced
        val = struct.unpack_from("<Q", patched, 92)[0]
        self.assertEqual(val, TULIP_CUST_SIZE)

        # Verify table hash valid
        tbl_hash = hashlib.sha256(patched[80:208]).digest()
        self.assertEqual(patched[48:80], tbl_hash)

        # Verify header hash valid
        hdr_copy = bytearray(patched[:80])
        hdr_copy[12:44] = b"\x00" * 32
        hdr_hash = hashlib.sha256(hdr_copy).digest()
        self.assertEqual(patched[12:44], hdr_hash)

    def test_patch_lpmeta_buffer_already_patched(self):
        buf = self._create_mock_lpmeta_buffer(TULIP_CUST_SIZE)
        orig = bytes(buf)
        patched = patch_lpmeta_buffer(buf, "test_already_patched")
        # Should remain identical
        val = struct.unpack_from("<Q", patched, 92)[0]
        self.assertEqual(val, TULIP_CUST_SIZE)

    def test_patch_rom_full_workflow(self):
        in_zip = os.path.join(self.test_dir, "test_rom.zip")
        out_zip = os.path.join(self.test_dir, "test_rom_fixed.zip")

        # Create mock ROM archive
        mock_meta = self._create_mock_lpmeta_buffer(WHYRED_CUST_SIZE)
        with zipfile.ZipFile(in_zip, "w") as zf:
            zf.writestr("unsparse_super_empty.img", mock_meta)
            zf.writestr("super_dummy.img", mock_meta)
            zf.writestr("boot.img", b"MOCK_BOOT_IMAGE_DATA")

        in_stat_before = os.path.getsize(in_zip)

        # Execute patch
        patch_rom(in_zip, out_zip)

        # 1. Output exists and is valid
        self.assertTrue(os.path.exists(out_zip))
        with zipfile.ZipFile(out_zip, "r") as zf_out:
            bad = zf_out.testzip()
            self.assertIsNone(bad)
            patched_meta = zf_out.read("unsparse_super_empty.img")
            val = struct.unpack_from("<Q", patched_meta, 92)[0]
            self.assertEqual(val, TULIP_CUST_SIZE)

        # 2. Input file remains strictly unmodified
        self.assertEqual(os.path.getsize(in_zip), in_stat_before)
        with zipfile.ZipFile(in_zip, "r") as zf_in:
            orig_meta = zf_in.read("unsparse_super_empty.img")
            orig_val = struct.unpack_from("<Q", orig_meta, 92)[0]
            self.assertEqual(orig_val, WHYRED_CUST_SIZE)

    def test_patch_rom_missing_file_raises(self):
        with self.assertRaises(SystemExit):
            patch_rom(os.path.join(self.test_dir, "nonexistent.zip"))

    def test_patch_rom_missing_metadata_raises(self):
        in_zip = os.path.join(self.test_dir, "invalid_rom.zip")
        with zipfile.ZipFile(in_zip, "w") as zf:
            zf.writestr("boot.img", b"NO_DYNAMIC_METADATA")

        with self.assertRaises(SystemExit):
            patch_rom(in_zip)

    def test_patch_rom_rejects_inplace_without_force(self):
        in_zip = os.path.join(self.test_dir, "same_path.zip")
        with zipfile.ZipFile(in_zip, "w") as zf:
            zf.writestr("boot.img", b"TEST")

        with self.assertRaises(SystemExit):
            patch_rom(in_zip, in_zip, force=False)

if __name__ == "__main__":
    unittest.main()
