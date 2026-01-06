$ErrorActionPreference = "Stop"

Write-Host "Checking for src/release.zip..."
if (-not (Test-Path "src/release.zip")) {
    Write-Host "release.zip not found. Attempting to create it..."
    python zipper.py
    if (-not (Test-Path "src/release.zip")) {
        Write-Error "Failed to create src/release.zip. Please run setup_files.ps1 first."
    }
}

Write-Host "Building for 32-bit target (i686-pc-windows-msvc)..."
cargo build --release --target i686-pc-windows-msvc

if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed."
}

$source = "target/i686-pc-windows-msvc/release/flatcam_launcher.exe"
$distDir = "dist"
$dest = "$distDir/flatcam_launcher_32bit.exe"

if (-not (Test-Path $distDir)) {
    New-Item -ItemType Directory -Force -Path $distDir | Out-Null
}

Write-Host "Copying binary to $dest..."
Copy-Item -Path $source -Destination $dest -Force

Write-Host "Verifying architecture..."
python check_arch_v2.py

# Bundle UCRT DLLs for Windows 7 compatibility
$ucrtDir = "C:\Program Files (x86)\Windows Kits\10\Redist\ucrt\DLLs\x86"
if (Test-Path $ucrtDir) {
    Write-Host "Bundling UCRT DLLs from $ucrtDir..."
    Copy-Item "$ucrtDir\api-ms-win-*.dll" -Destination $distDir -Force
    Copy-Item "$ucrtDir\ucrtbase.dll" -Destination $distDir -Force
}
else {
    Write-Warning "UCRT Redist folder not found at $ucrtDir. You may need to manually install KB2999226 on the target machine."
}

Write-Host "Build complete! The 32-bit executable is located at: $dest"
