$file = "d:\Udimagen\ruben\flatcam_launcher\dist\flatcam_launcher_32bit.exe"

if (Test-Path $file) {
    $hash = Get-FileHash -Path $file -Algorithm SHA256
    Write-Host "File: $($hash.Path)"
    Write-Host "Size: $( (Get-Item $file).Length ) bytes"
    Write-Host "SHA256 Hash: $($hash.Hash)"
}
else {
    Write-Error "File not found: $file"
}
