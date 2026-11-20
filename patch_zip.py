import zipfile
import shutil
import os
import time

src_zip = r"C:\Users\User\Downloads\Yurigram\Project_Infinity-X-4.2-bouquet-20.11.2026-VANILLA-UNOFFICIAL.zip"
dst_zip = r"C:\Users\User\Downloads\Yurigram\Project_Infinity-X-4.2-tulip-fixed.zip"
patched_img = r"C:\Users\User\Documents\redmi\zip_extracted\unsparse_super_empty_tulip.img"

print(f"[*] Creating patched ROM zip for Tulip: {dst_zip}")
start_time = time.time()

with zipfile.ZipFile(src_zip, "r") as zin:
    with zipfile.ZipFile(dst_zip, "w", compression=zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            if item.filename == "unsparse_super_empty.img":
                print(f"[*] Replacing {item.filename} with Tulip-patched version...")
                with open(patched_img, "rb") as f:
                    zout.writestr(item, f.read())
            else:
                # Direct stream copy without recompressing
                with zin.open(item) as s:
                    # preserve compress_type
                    zout.writestr(item, s.read(), compress_type=item.compress_type)

elapsed = time.time() - start_time
print(f"[+] Done in {elapsed:.1f}s! File size: {os.path.getsize(dst_zip)} bytes")
