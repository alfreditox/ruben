import struct
import sys
import os

def get_imports(filepath):
    try:
        with open(filepath, 'rb') as f:
            # DOS Header
            dos_header = f.read(64)
            if len(dos_header) < 64 or dos_header[0:2] != b'MZ': return "Invalid PE"
            pe_offset = struct.unpack('<I', dos_header[60:64])[0]
            
            # PE Header
            f.seek(pe_offset)
            if f.read(4) != b'PE\0\0': return "Invalid PE"
            
            # File Header
            f.read(20)
            
            # Optional Header
            magic = struct.unpack('<H', f.read(2))[0]
            if magic == 0x10b: # PE32
                rva_offset = 96
            elif magic == 0x20b: # PE32+
                rva_offset = 112
            else:
                return "Unknown Magic"
                
            # Seek to Data Directories (Import Table is index 1)
            f.seek(pe_offset + 24 + rva_offset + 8) 
            import_rva, import_size = struct.unpack('<II', f.read(8))
            
            if import_rva == 0:
                return "No Import Table"

            # We need to map RVA to File Offset. 
            # Read Section Headers to find the section containing the Import Table.
            # Section headers start after Optional Header. 
            # Size of Optional Header is at pe_offset + 20.
            f.seek(pe_offset + 20)
            opt_header_size = struct.unpack('<H', f.read(2))[0]
            section_table_offset = pe_offset + 24 + opt_header_size
            
            f.seek(pe_offset + 6)
            num_sections = struct.unpack('<H', f.read(2))[0]
            
            file_offset_import = -1
            
            f.seek(section_table_offset)
            for i in range(num_sections):
                name = f.read(8)
                misc, virt_addr, size_raw, ptr_raw = struct.unpack('<IIII', f.read(16))
                f.read(16) # Skip rest
                
                # Check if this section contains the import table RVA
                if virt_addr <= import_rva < virt_addr + max(size_raw, misc):
                    file_offset_import = ptr_raw + (import_rva - virt_addr)
                    break
            
            if file_offset_import == -1:
                return "Import Table not found in sections"
                
            imports = []
            f.seek(file_offset_import)
            while True:
                # Import Descriptor
                # OriginalFirstThunk, TimeDateStamp, ForwarderChain, Name, FirstThunk (all DWORDs)
                data = f.read(20)
                if data == b'\x00'*20: break # End of table
                
                name_rva = struct.unpack('<I', data[12:16])[0]
                
                # Convert Name RVA to Offset
                # Assuming name is in same section (usually .rdata) or we rescan sections.
                # For simplicity, rescan sections for name_rva
                name_offset = -1
                cur_pos = f.tell()
                
                f.seek(section_table_offset)
                for i in range(num_sections):
                    sect_data = f.read(40) # Header size is 40
                    virt_addr = struct.unpack('<I', sect_data[12:16])[0]
                    ptr_raw = struct.unpack('<I', sect_data[20:24])[0]
                    raw_size = struct.unpack('<I', sect_data[16:20])[0]
                    misc = struct.unpack('<I', sect_data[8:12])[0]
                    
                    if virt_addr <= name_rva < virt_addr + max(raw_size, misc):
                        name_offset = ptr_raw + (name_rva - virt_addr)
                        break
                
                if name_offset != -1:
                    f.seek(name_offset)
                    name_bytes = b''
                    while True:
                        b = f.read(1)
                        if b == b'\x00': break
                        name_bytes += b
                    imports.append(name_bytes.decode('ascii', errors='ignore'))
                
                f.seek(cur_pos)
            
            return imports
            
    except Exception as e:
        return f"Error: {e}"

files = [
    r"dist\flatcam_launcher_32bit.exe",
    r"dist\test_32bit.exe"
]

for p in files:
    if os.path.exists(p):
        print(f"Imports for {p}: {get_imports(p)}")
    else:
        print(f"{p} not found")
