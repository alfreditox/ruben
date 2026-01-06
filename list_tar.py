import tarfile

with tarfile.open("python_package.tar.bz2", "r:bz2") as tar:
    for member in tar.getmembers():
        if "tkinter" in member.name or "tcl" in member.name or "tk" in member.name:
            if member.name.startswith("Lib/tkinter") or member.name.startswith("DLLs") or member.name.startswith("tcl"):
                print(member.name)
