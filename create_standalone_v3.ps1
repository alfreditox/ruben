$ErrorActionPreference = "Stop"

$distDir = Resolve-Path "dist"
$outputExe = "$distDir\FlatCAM_Setup_32bit.exe"
$sedFile = "$distDir\package_v3.sed"

# Clean up previous artifacts
Remove-Item "$distDir\*.sed" -ErrorAction SilentlyContinue
Remove-Item "$distDir\*.DDF" -ErrorAction SilentlyContinue
Remove-Item "$distDir\*.Rpt" -ErrorAction SilentlyContinue
Remove-Item $outputExe -ErrorAction SilentlyContinue

# Get all files to include, explicitly excluding build artifacts
$files = Get-ChildItem -Path $distDir -File | Where-Object { 
    $_.Extension -ne ".sed" -and 
    $_.Extension -ne ".DDF" -and 
    $_.Extension -ne ".Rpt" -and
    $_.Name -ne "FlatCAM_Setup_32bit.exe"
}

$sourceFilesList = "" 
$stringMappings = ""

$i = 0
foreach ($f in $files) {
    $key = "File$i"
    $sourceFilesList += "%$key%=" + "`r`n"
    $stringMappings += "$key=""$($f.Name)""" + "`r`n"
    $i++
}

# IExpress SED Content - RELATIVE PATHS
$sedContent = @"
[Version]
Class=IEXPRESS
SEDVersion=3.0
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=0
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
TargetName=FlatCAM_Setup_32bit.exe
FriendlyName=FlatCAM Launcher 32-bit
AppLaunched=flatcam_launcher_32bit.exe
PostInstallCmd=<None>
AdminPrivileges=false
$stringMappings
[SourceFiles]
SourceFiles0=.\
[SourceFiles0]
$sourceFilesList
"@

# Write SED file
Set-Content -Path $sedFile -Value $sedContent -Encoding Ascii

Write-Host "Generated IExpress directive file: $sedFile"
Write-Host "Building standalone executable..."

# Run IExpress from INSIDE the dist directory
Push-Location $distDir
try {
    Write-Host "Running IExpress in $(Get-Location)..."
    $process = Start-Process "iexpress.exe" -ArgumentList "/N package_v3.sed" -PassThru -Wait -NoNewWindow
    
    if ($process.ExitCode -eq 0) {
        if (Test-Path "FlatCAM_Setup_32bit.exe") {
            Write-Host "Success! Standalone binary created at: $(Resolve-Path FlatCAM_Setup_32bit.exe)"
        }
        else {
            Write-Error "IExpress exited successfully but output file is missing."
        }
    }
    else {
        Write-Error "Failed to create standalone binary. Exit Code: $($process.ExitCode). Check *.Rpt files."
    }
}
finally {
    Pop-Location
}
