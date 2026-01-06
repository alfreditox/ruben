import struct
import sys
import os

def check_exe_arch(filepath):
    try:
        with open(filepath, 'rb') as f:
            dos_header = f.read(64)
            if len(dos_header) < 64: return "Error: File too small"
            pe_offset = struct.unpack('<I', dos_header[60:64])[0]
            f.seek(pe_offset)
            pe_header = f.read(6)
            machine_type = struct.unpack('<H', pe_header[4:6])[0]
            if machine_type == 0x014c: return "32-bit"
            elif machine_type == 0x8664: return "64-bit"
            else: return f"Unknown {hex(machine_type)}"
    except Exception as e: return str(e)

files = [
    r"dist\flatcam_launcher_32bit.exe",
    r"dist\ucrtbase.dll",
    r"dist\api-ms-win-core-synch-l1-2-0.dll"
]

for f in files:
    if os.path.exists(f):
        print(f"{f}: {check_exe_arch(f)}")
    else:
        print(f"{f}: Not found")
