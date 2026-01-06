$distDir = Resolve-Path "dist"
$outputExe = "$distDir\FlatCAM_Standalone_32bit.exe"
$sedFile = "$distDir\package.sed"

# Get all files to include
$files = Get-ChildItem -Path $distDir -File | Where-Object { $_.Name -ne "package.sed" -and $_.Name -ne "FlatCAM_Standalone_32bit.exe" }

$fileList = ""
$sourceFiles = ""

foreach ($f in $files) {
    $fileList += "%FILE$($f.Name)%=" + "`r`n"
    $sourceFiles += "FILE$($f.Name)=""$($f.FullName)""" + "`r`n"
}

# IExpress SED Content
$sedContent = @"
[Version]
Class=IEXPRESS
SEDVersion=3.0
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=1
HideExtractAnimation=0
UseLongFileName=1
InsideCompressed=0
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=%InstallPrompt%
DisplayLicense=%DisplayLicense%
FinishMessage=%FinishMessage%
TargetName=%TargetName%
FriendlyName=%FriendlyName%
AppLaunched=%AppLaunched%
PostInstallCmd=%PostInstallCmd%
AdminPrivileges=%AdminPrivileges%
SourceFiles=SourceFiles
[Strings]
InstallPrompt=
DisplayLicense=
FinishMessage=
TargetName=$outputExe
FriendlyName=FlatCAM Launcher 32-bit
AppLaunched=flatcam_launcher_32bit.exe
PostInstallCmd=<None>
AdminPrivileges=false
[SourceFiles]
SourceFiles0=$distDir\
[SourceFiles0]
$fileList
"@

# Write SED file
Set-Content -Path $sedFile -Value $sedContent -Encoding Ascii

# Append Source paths (doing it manually to avoid encoding issues with complex strings in here-string)
Add-Content -Path $sedFile -Value $sourceFiles -Encoding Ascii

Write-Host "Generated IExpress directive file: $sedFile"
Write-Host "Building standalone executable..."

iexpress /N $sedFile

if (Test-Path $outputExe) {
    Write-Host "Success! Standalone binary created at: $outputExe"
}
else {
    Write-Error "Failed to create standalone binary."
}
