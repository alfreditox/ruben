$ErrorActionPreference = "Stop"

$scriptDir = $PSScriptRoot
$workspaceDir = Join-Path $scriptDir "downloads"
$srcDir = Join-Path $scriptDir "src"

# Python 3.8.10 is the last version supporting Windows 7
$pythonUrl = "https://www.python.org/ftp/python/3.8.10/python-3.8.10-embed-win32.zip"
$flatcamUrl = "https://bitbucket.org/jpcgt/flatcam/downloads/FlatCAM_beta_8.994_sources.zip"

If (Test-Path "$workspaceDir") {
    Remove-Item "$workspaceDir" -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $workspaceDir | Out-Null

# Clean up previous partial downloads in src if exist
If (Test-Path "$srcDir\python") { Remove-Item "$srcDir\python" -Recurse -Force }
If (Test-Path "$srcDir\FlatCAM") { Remove-Item "$srcDir\FlatCAM" -Recurse -Force }

Write-Host "Downloading Python 3.8.10 (Win7 Compatible)..."
Invoke-WebRequest -Uri $pythonUrl -OutFile "$workspaceDir\python.zip"

Write-Host "Downloading FlatCAM Sources..."
try {
    Invoke-WebRequest -Uri $flatcamUrl -OutFile "$workspaceDir\flatcam.zip"
}
catch {
    Write-Host "Bitbucket download failed. Trying GitHub mirror..."
    $flatcamUrl = "https://github.com/versatileninja/FlatCAM_Beta_8.994/archive/refs/heads/master.zip"
    Invoke-WebRequest -Uri $flatcamUrl -OutFile "$workspaceDir\flatcam.zip"
}

Write-Host "Extracting Python..."
Expand-Archive -Path "$workspaceDir\python.zip" -DestinationPath "$srcDir\python" -Force

Write-Host "Extracting FlatCAM..."
Expand-Archive -Path "$workspaceDir\flatcam.zip" -DestinationPath "$workspaceDir\flatcam_temp" -Force

# Move the inner folder content
$extractedRoot = Get-ChildItem "$workspaceDir\flatcam_temp" | Select-Object -First 1
New-Item -ItemType Directory -Force -Path "$srcDir\FlatCAM" | Out-Null
Move-Item -Path "$($extractedRoot.FullName)\*" -Destination "$srcDir\FlatCAM" -Force

Write-Host "Cleanup..."
Remove-Item "$workspaceDir" -Recurse -Force

Write-Host "Done! Win7-compatible files are in src/python and src/FlatCAM"
