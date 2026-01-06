import json

with open("repodata_main.json", "r") as f:
    data = json.load(f)

packages = data.get("packages", {})
packages.update(data.get("packages.conda", {}))

best_pkg = None
best_ver = ""
found = False

for pkg_name, pkg_data in packages.items():
    if pkg_data["name"] == "tcl":
        found = True
        print(pkg_name)
        if pkg_data["version"] >= best_ver:
            best_ver = pkg_data["version"]
            best_pkg = pkg_name

if best_pkg:
    print(best_pkg)
else:
    print("Not Found. Keys:", list(packages.keys())[:5])
