# Powershell Quick Reference

---

## 01 | Housekeeping

```
# Get Powershell version

$PSVersionTable.PSVersion

# Get help on any cmdlet, update help

Help Do-That
Update-Help -UICulture en-US

# Enable temp. security downgrade
# Backtick escapes the newline, multiline cmd

Set-ExecutionPolicy
-ExecutionPolicy RemoteSigned|Bypass `
-Scope CurrentUser|Process `
-Force

# Install new cmdlet module from PSGallery

Install-Module -Name Az `
<# scoped to "user" no need of admin #> `
-Scope CurrentUser `
-Repository PSGallery

# Update an already installed module

Update-Module -Name Az

# Invoke a HTTP request (download)
# Mind the system proxy too

Invoke-WebRequest 'ifconfig.me/all' `
| Select-Object -ExpandProperty Content

Invoke-Expression ( `
  ( `
    New-Object `
    System.Net.WebClient `
  ).DownloadString( `
    'https://chocolatey.org/install.ps1') `
)

# TCP connection test

$connTestResult = Test-NetConnection `
  -ComputerName foo.bar.net -Port 445

if ($connTestResult.TcpTestSucceeded) {
# TCP connect was successfull !
}

# Actual date as string
Get-Date -Format "yyyy-MM-dd--HH_mm_ss"
```

---

## 02 | Flow Control

```
# Simple condition test

if ( <condition> ) {
  Write-Host "Condition satisfied !";
  exit
}
# 'for' iteration

For ($i=1; $i -le 3; $i++)
{
  Write-Host "Counter: " + $i 
}

# Foreach - iterate over a list

foreach ($item in $list) { 
  Set-SomeThing -Name $item -Value 0
}
```

---

## 03 | Powershell objects

```
# Display all members of a result object

Get-Foo ... | Format-List -Property *
Get-Foo ... | Get-Member

# Filter list of objects - case insensitive

Get-EventLog -LogName System `
| Where-Object { $_.Message -like "*fail*" }
```


---

## 04 | Jobs and remoting

```
# Run script as background task / job

Start-Job -ScriptBlock `
  {Get-EventLog -LogName System}

# Get list of bg task / job

Get-Job

# Get the output of a given job

Receive-Job

# Run commands on remote systems in bg,
# by Powershell Remoting, using WinRM

# $sb is type "ScriptBlock", not "String" !
 
$sb = {
  Get-EventLog -LogName System;
  Get-Process
}
Invoke-Command -ComputerName srv1,srv2 `
  -ScriptBlock $sb
  -AsJob
```
