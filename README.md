# FlatCAM Launcher (32-bit Legacy Build)

This repository hosts the source code for the FlatCAM Launcher, specifically configured to build a **Windows 7 32-bit compatible** executable.

## Builds
This project uses GitHub Actions to automatically compile the binary using the `i686-pc-windows-gnu` target (MinGW), ensuring it runs on older systems without modern Visual C++ Redistributables.

## How to Download
1. Go to the [Actions](https://github.com/alfreditox/ruben/actions) tab.
2. Click on the latest "Legacy Build" workflow run.
3. Scroll down to **Artifacts** and download the executable.
