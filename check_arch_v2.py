import struct
import sys
import os

def analyze_pe(filepath):
    try:
        size = os.path.getsize(filepath)
        with open(filepath, 'rb') as f:
            dos_header = f.read(64)
            if len(dos_header) < 64:
                return "Error: File too small"
            
            if dos_header[0:2] != b'MZ':
                return "Not a valid EXE (missing MZ)"

            pe_offset = struct.unpack('<I', dos_header[60:64])[0]
            
            # Seek to PE header
            if pe_offset + 264 > size: # Minimal size check
                return "Error: Truncated file"

            f.seek(pe_offset)
            pe_signature = f.read(4)
            if pe_signature != b'PE\0\0':
                return "Not a valid PE file"
            
            # File Header (20 bytes)
            file_header = f.read(20)
            machine = struct.unpack('<H', file_header[0:2])[0]
            
            # Optional Header
            # Magic is first 2 bytes of Optional Header
            magic_bytes = f.read(2)
            magic = struct.unpack('<H', magic_bytes)[0]
            
            arch_str = "Unknown"
            if machine == 0x014c:
                arch_str = "32-bit (i386)"
            elif machine == 0x8664:
                arch_str = "64-bit (AMD64)"
            
            pe_type = "Unknown"
            if magic == 0x10b:
                pe_type = "PE32"
                # Subsystem Version is at offset 48 from start of Optional Header
                # We read 2 bytes magic already.
                # Standard fields (28 bytes) + Windows Specific fields. 
                # MajorSubsystemVersion is at offset 48, Minor at 50.
                f.seek(pe_offset + 24 + 48) 
                subs_major, subs_minor = struct.unpack('<HH', f.read(4))
                
            elif magic == 0x20b:
                pe_type = "PE32+"
                # For PE32+, MajorSubsystemVersion is at offset 48 as well?
                # PE32+ Standard fields are 24 bytes.
                # Windows fields start at 24.
                # MajorSubsystemVersion is at offset 48. Yes.
                f.seek(pe_offset + 24 + 48)
                subs_major, subs_minor = struct.unpack('<HH', f.read(4))
            else:
                 return f"Error: Unknown Optional Header Magic {hex(magic)}"

            return f"Arch: {arch_str}, Type: {pe_type}, Subsystem Version: {subs_major}.{subs_minor}"
            
    except Exception as e:
        return f"Error analyzing: {str(e)}"

files_to_check = [
    r"d:\Udimagen\ruben\flatcam_launcher\target\release\flatcam_launcher.exe",
    r"d:\Udimagen\ruben\flatcam_launcher\target\i686-pc-windows-msvc\release\flatcam_launcher.exe",
    r"d:\Udimagen\ruben\flatcam_launcher\src\python\python38.dll", 
    r"d:\Udimagen\ruben\flatcam_launcher\src\python\python.exe"
]

for f in files_to_check:
    if os.path.exists(f):
        print(f"{os.path.basename(f)}: {analyze_pe(f)}")
    else:
        print(f"{os.path.basename(f)}: File not found")
