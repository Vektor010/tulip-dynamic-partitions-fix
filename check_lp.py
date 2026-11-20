import struct

path = r"C:\Users\User\Documents\redmi\zip_extracted\unsparse_super_empty.img"
with open(path, "rb") as f:
    data = f.read()

target = 872415232 # 0x34000000
for i in range(len(data) - 7):
    val = struct.unpack_from("<Q", data, i)[0]
    if val == target:
        print(f"Found target 872415232 at offset {i} (0x{i:X})")

# Also search for 'cust' string
cust_pos = data.find(b"cust")
print(f"cust string found at: {cust_pos}")
if cust_pos != -1:
    print("Hex around cust:", data[cust_pos:cust_pos+64].hex())
