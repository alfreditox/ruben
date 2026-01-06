import zipfile
import os

def zipFolder(foldername, target_name):
    zipobj = zipfile.ZipFile(target_name, 'w', zipfile.ZIP_DEFLATED)
    rootlen = len(foldername) + 1
    for base, dirs, files in os.walk(foldername):
        for file in files:
            fn = os.path.join(base, file)
            zipobj.write(fn, fn[rootlen:])
    zipobj.close()
    
# We need to zip 'python' and 'FlatCAM' into 'src/release.zip'.
# But to preserve structure python/..., we should be careful.
# My rust code expects directories inside the zip.
# So we should zip contents of 'src' basically?
# No, only 'python' and 'FlatCAM'.

with zipfile.ZipFile('src/release.zip', 'w', zipfile.ZIP_DEFLATED) as zipf:
    for root, dirs, files in os.walk('src/python'):
        for file in files:
            abspath = os.path.join(root, file)
            # archive name should be relative to src/
            arcname = os.path.relpath(abspath, 'src')
            zipf.write(abspath, arcname)
            
    for root, dirs, files in os.walk('src/FlatCAM'):
        for file in files:
            abspath = os.path.join(root, file)
            arcname = os.path.relpath(abspath, 'src')
            zipf.write(abspath, arcname)

print("Zip created successfully.")
