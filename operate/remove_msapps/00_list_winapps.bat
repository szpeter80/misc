@ECHO OFF
powershell.exe "Get-AppxPackage | Select Name, PackageFullName"
