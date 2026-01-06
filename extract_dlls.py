import tarfile
import shutil
import os

with tarfile.open("libspatialindex.tar.bz2", "r:bz2") as tar:
    for member in tar.getmembers():
        if member.name.endswith(".dll") and "spatialindex" in member.name:
            print(f"Extracting {member.name}")
            f = tar.extractfile(member)
            filename = os.path.basename(member.name)
            with open(os.path.join("src/python", filename), "wb") as out:
                shutil.copyfileobj(f, out)
            print(f"Saved to src/python/{filename}")
