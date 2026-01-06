import tarfile
import shutil
import os

target_root = "src/python"
os.makedirs(target_root, exist_ok=True)

with tarfile.open("python_package.tar.bz2", "r:bz2") as tar:
    for member in tar.getmembers():
        # DLLs to root
        if member.name in ["DLLs/_tkinter.pyd", "DLLs/tcl86t.dll", "DLLs/tk86t.dll"]:
            print(f"Extracting {member.name}")
            f = tar.extractfile(member)
            filename = os.path.basename(member.name)
            with open(os.path.join(target_root, filename), "wb") as out:
                shutil.copyfileobj(f, out)
        
        # Lib/tkinter/ to src/python/Lib/tkinter/
        elif member.name.startswith("Lib/tkinter/"):
            print(f"Extracting {member.name}")
            tar.extract(member, target_root)
            
        # tcl/ to src/python/tcl/
        elif member.name.startswith("tcl/"):
            print(f"Extracting {member.name}")
            tar.extract(member, target_root)
