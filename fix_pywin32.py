import os
import shutil

python_root = "src/python"
site_packages = os.path.join(python_root, "Lib", "site-packages")

# 1. Move DLLs from pywin32_system32 to python root
sys32_dir = os.path.join(site_packages, "pywin32_system32")
if os.path.exists(sys32_dir):
    for f in os.listdir(sys32_dir):
        src = os.path.join(sys32_dir, f)
        dst = os.path.join(python_root, f)
        print(f"Moving {f} to {python_root}")
        shutil.copy2(src, dst)

# 2. Create __init__.py in win32comext if missing
win32comext_dir = os.path.join(site_packages, "win32comext")
init_py = os.path.join(win32comext_dir, "__init__.py")
if os.path.exists(win32comext_dir) and not os.path.exists(init_py):
    print(f"Creating {init_py}")
    with open(init_py, "w") as f:
        f.write("# namespace package\n")
        f.write("__path__ = __import__('pkgutil').extend_path(__path__, __name__)\n")

print("pywin32 portable fix completed.")
