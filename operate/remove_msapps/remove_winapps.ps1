
# It is not an app, uninstall is done silently in the background
ps onedrive | Stop-Process -Force
start-process "$env:windir\SysWOW64\OneDriveSetup.exe" "/uninstall"

# OMG, this is Cortana...
Get-AppxPackage -AllUsers Microsoft.549981C3F5F10 | Remove-AppxPackage

Get-AppxPackage -AllUsers Microsoft.SkypeApp* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.Zune* | Remove-AppxPackage
Get-AppxPackage -AllUsers Spotify* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.YourPhone* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.Xbox* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.BioEnrollment* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.People* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.MixedReality.Portal* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.BingWeather* | Remove-AppxPackage

Get-AppxPackage -AllUsers Microsoft.MicrosoftStickyNotes* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.MicrosoftSolitaireCollection* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.ScreenSketch* | Remove-AppxPackage
Get-AppxPackage -AllUsers microsoft.windowscommunicationsapps* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.GetHelp | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.GetStarted | Remove-AppxPackage

Get-AppxPackage -AllUsers Microsoft.WindowsCamera* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.WindowsSoundRecorder* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.WindowsMaps* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.WindowsFeedbackHub* | Remove-AppxPackage

Get-AppxPackage -AllUsers Microsoft.MicrosoftOfficeHub* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.Office.OneNote* | Remove-AppxPackage
