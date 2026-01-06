# Script to build Legacy MinGW version on YOUR machine
# Prerequisites: 
# 1. Rust installed
# 2. Start this script from a terminal with 'MinGW-w64' (gcc.exe) in the PATH.

$ErrorActionPreference = "Stop"

Write-Host "Configuring for i686-pc-windows-gnu (Legacy Windows 7)..."
rustup target add i686-pc-windows-gnu

# Build
Write-Host "Building..."
$env:RUSTFLAGS = "-C target-feature=-sse2" 
cargo build --release --target i686-pc-windows-gnu

# Output path
$targetExe = "target/i686-pc-windows-gnu/release/flatcam_launcher.exe"

if (Test-Path $targetExe) {
    Write-Host "Build Successful!"
    Write-Host "Your legacy executable is at: $targetExe"
    Write-Host "This file has NO external dependencies (no UCRT) and should run on unpatched Win7."
}
else {
    Write-Error "Build finished but executable was not found."
}
