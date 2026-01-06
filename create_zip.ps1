$distDir = Resolve-Path "dist"
$zipFile = "$distDir\FlatCAM_Portable_32bit.zip"

Write-Host "Creating portable ZIP archive..."

# Remove previous zip if exists
if (Test-Path $zipFile) { Remove-Item $zipFile }

# Create temporary folder to arrange files exactly as we want them in root of zip
$tempZipDir = "$distDir\temp_zip"
if (Test-Path $tempZipDir) { Remove-Item $tempZipDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempZipDir | Out-Null

# Copy files
Get-ChildItem -Path $distDir -File | Where-Object { 
    $_.Extension -ne ".sed" -and 
    $_.Extension -ne ".DDF" -and 
    $_.Extension -ne ".Rpt" -and
    $_.Name -ne "FlatCAM_Setup_32bit.exe" -and
    $_.Name -ne "FlatCAM_Portable_32bit.zip"
} | Copy-Item -Destination $tempZipDir

# Zip it
Compress-Archive -Path "$tempZipDir\*" -DestinationPath $zipFile

# Cleanup
Remove-Item $tempZipDir -Recurse -Force

if (Test-Path $zipFile) {
    Write-Host "Success! Portable ZIP created at: $zipFile"
}
else {
    Write-Error "Failed to create ZIP."
}
