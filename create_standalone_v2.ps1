$distDir = Resolve-Path "dist"
$outputExe = "$distDir\FlatCAM_Standalone_32bit.exe"
$sedFile = "$distDir\package.sed"

# Get all files to include
$files = Get-ChildItem -Path $distDir -File | Where-Object { $_.Name -ne "package.sed" -and $_.Name -ne "FlatCAM_Standalone_32bit.exe" }

$sourceFilesList = "" # For [SourceFiles0]
$stringMappings = ""  # For [Strings]

$i = 0
foreach ($f in $files) {
    $key = "File$i"
    $sourceFilesList += "%$key%=" + "`r`n"
    $stringMappings += "$key=""$($f.Name)""" + "`r`n"
    $i++
}

# IExpress SED Content
# Note: SourceFiles0 path is empty because we will put full paths in [Strings]? 
# No, standard way: SourceFiles0=SourceDir. Then Strings maps Key="Filename".
# If we want to support absolute paths, we can hack it, but standard is easier.

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
$stringMappings
[SourceFiles]
SourceFiles0=$distDir\
[SourceFiles0]
$sourceFilesList
"@

# Write SED file
Set-Content -Path $sedFile -Value $sedContent -Encoding Ascii

Write-Host "Generated IExpress directive file: $sedFile"
Write-Host "Building standalone executable..."

# Use CMD /C to avoid PowerShell argument parsing issues with /N
$cmdArgs = "/C iexpress /N `"$sedFile`""
Start-Process "cmd.exe" -ArgumentList $cmdArgs -Wait -NoNewWindow
# iexpress /N $sedFile

if (Test-Path $outputExe) {
    Write-Host "Success! Standalone binary created at: $outputExe"
}
else {
    Write-Error "Failed to create standalone binary. Please check the SED file manually."
}
