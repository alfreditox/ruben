$ErrorActionPreference = "Stop"

Write-Host "Building for Legacy 32-bit target (i686-pc-windows-gnu)..."
# Ensure release.zip exists
if (-not (Test-Path "src/release.zip")) {
    Write-Host "release.zip not found. Creating..."
    python zipper.py
}

# Clean previous build to ensure no mix-up
cargo clean -p flatcam_launcher

cargo build --release --target i686-pc-windows-gnu

if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed."
}

$distDir = "dist"
if (-not (Test-Path $distDir)) { New-Item -ItemType Directory -Force -Path $distDir | Out-Null }

$source = "target/i686-pc-windows-gnu/release/flatcam_launcher.exe"
$dest = "$distDir/FlatCAM_Legacy_Win7_32bit.exe"

Copy-Item -Path $source -Destination $dest -Force

Write-Host "Verifying architecture..."
python check_arch_v2.py

Write-Host "Build complete! Legacy executable: $dest"
