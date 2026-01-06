import struct
import sys
import os

def check_exe_arch(filepath):
    try:
        with open(filepath, 'rb') as f:
            # Read DOS header
            dos_header = f.read(64)
            if len(dos_header) < 64:
                return "Error: File too small"
            
            # Check magic number
            if dos_header[0:2] != b'MZ':
                return "Not a valid EXE (missing MZ)"

            # Get offset to PE header
            pe_offset = struct.unpack('<I', dos_header[60:64])[0]
            
            f.seek(pe_offset)
            pe_header = f.read(6)
            
            if pe_header[0:4] != b'PE\0\0':
                return "Not a valid PE file"
                
            machine_type = struct.unpack('<H', pe_header[4:6])[0]
            
            if machine_type == 0x014c:
                return "32-bit (i386)"
            elif machine_type == 0x8664:
                return "64-bit (AMD64)"
            else:
                return f"Unknown architecture: {hex(machine_type)}"
    except Exception as e:
        return str(e)

files_to_check = [
    r"d:\Udimagen\ruben\flatcam_launcher\target\release\flatcam_launcher.exe",
    r"d:\Udimagen\ruben\flatcam_launcher\target\i686-pc-windows-msvc\release\flatcam_launcher.exe"
]

for f in files_to_check:
    if os.path.exists(f):
        print(f"{f}: {check_exe_arch(f)}")
    else:
        print(f"{f}: File not found")
