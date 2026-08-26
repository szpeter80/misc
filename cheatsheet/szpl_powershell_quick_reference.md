# Powershell Quick Reference

---

## 01 | Housekeeping

### Get PowerShell Version
Check the installed PowerShell version ([PowerShell Releases](https://github.com/PowerShell/powershell/releases)):
```powershell
$PSVersionTable.PSVersion
```

### Install PowerShell on Windows
Install via the official MSI-based bootstrapper:
```powershell
iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"
```

### Install PowerShell on Linux
Download and execute the official installation script:
```bash
wget -O - https://aka.ms/install-powershell.sh | sudo bash
```

### Get and Update Help
View cmdlet help and update local help documentation:
```powershell
Help Do-That
Update-Help -UICulture en-US
```

### Get Execution Policy
Display the current script execution policy:
```powershell
Get-ExecutionPolicy
```

### Set Execution Policy
Enable temporary security policy downgrade:
```powershell
Set-ExecutionPolicy `
  -ExecutionPolicy RemoteSigned|Bypass `
  -Scope CurrentUser|Process `
  -Force
```

### Install Module from PSGallery
Install a module scoped to the current user without requiring administrator privileges:
```powershell
Install-Module -Name Az `
  -Scope CurrentUser `
  -Repository PSGallery
```

### Update Installed Module
Update an existing module to the latest version:
```powershell
Update-Module -Name Az
```

### Invoke HTTP Request
Send a web request and extract response content (mind system proxy settings):
```powershell
Invoke-WebRequest 'ifconfig.me/all' `
  | Select-Object -ExpandProperty Content
```

### Download and Execute Remote Script
Download and run a remote script in memory using .NET `WebClient`:
```powershell
Invoke-Expression ( `
  ( `
    New-Object `
    System.Net.WebClient `
  ).DownloadString( `
    'https://chocolatey.org/install.ps1') `
)
```

### Chained Bootstrap One-Liner
Command-prompt (`cmd.exe` / batch) compatible one-liner to set execution policy, install Chocolatey, and install Microsoft Edge:
```cmd
powershell.exe Set-ExecutionPolicy Bypass -Scope Process -Force && powershell.exe Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) && powershell.exe c:\programdata\chocolatey\choco.exe install microsoft-edge -y
```

### TCP Connection Test
Test TCP network port connectivity:
```powershell
$connTestResult = Test-NetConnection `
  -ComputerName foo.bar.net -Port 445

if ($connTestResult.TcpTestSucceeded) {
  # TCP connect was successful
}
```

### Formatted Date String
Get the current timestamp formatted as a string:
```powershell
Get-Date -Format "yyyy-MM-dd--HH_mm_ss"
```

---

## 02 | Flow Control and Parameters

### Script Parameter Definition
Declare mandatory or optional script parameters:
```powershell
param([string] $resGrpName)
```

### Validate Parameter Input
Validate that a parameter string is not null or whitespace:
```powershell
if ( [string]::IsNullOrWhiteSpace($resGrpName) ) {
  Write-Host "Resource group parameter is mandatory !"
  exit
}
```

### Prompt User for Credentials
Prompt interactively with a custom message:
```powershell
$adminCredential = Get-Credential -Message "Enter VM administrative user and password"
```

### Simple Condition (if)
Evaluate conditions and exit early if needed:
```powershell
if ( <condition> ) {
  Write-Host "Condition satisfied !"
  exit
}
```

### For Loop Iteration
Standard counter-based loop:
```powershell
For ($i=1; $i -le 3; $i++) {
  Write-Host "Counter: " + $i
}
```

### Foreach Loop (Collection Iteration)
Iterate over elements in an array or list:
```powershell
foreach ($item in $list) {
  Set-SomeThing -Name $item -Value 0
}
```

---

## 03 | Powershell objects

### List All Object Properties
Display all formatted properties of an output object:
```powershell
Get-Foo ... | Format-List -Property *
```

### Inspect Object Members and Methods
View all methods, properties, and types available on an object:
```powershell
Get-Foo ... | Get-Member
```

### Filter Object Collections
Filter objects with case-insensitive pattern matching:
```powershell
Get-EventLog -LogName System `
  | Where-Object { $_.Message -like "*fail*" }
```

---

## 04 | Jobs and remoting

### Start Background Job
Run a script block as a background task:
```powershell
Start-Job -ScriptBlock { Get-EventLog -LogName System }
```

### List Background Jobs
View status and details of all jobs:
```powershell
Get-Job
```

### Receive Job Output
Retrieve output results from finished background jobs:
```powershell
Receive-Job
```

### Run Remote Commands via PowerShell Remoting (WinRM)
Execute a `ScriptBlock` on remote systems in the background:
```powershell
$sb = {
  Get-EventLog -LogName System
  Get-Process
}

Invoke-Command -ComputerName srv1,srv2 `
  -ScriptBlock $sb `
  -AsJob
```

### Parallel Background Deployments Loop
Spawn concurrent background jobs in a loop:
```powershell
For ($i=1; $i -le 3; $i++) {
  $vmName = "ConferenceDemo" + $i
  Start-Job -ScriptBlock {
    New-AzVM `
      -ResourceGroupName $resGrpName `
      -Name $vmName `
      -Credential $adminCredential `
      -Image UbuntuLTS
  }
}
```

---

## 05 | Azure PowerShell (Az)

### Connect to Azure Account
Sign in interactively to Azure:
```powershell
Connect-AzAccount
```

### Inspect Current Context
View active tenant, subscription, and user context:
```powershell
Get-AzContext
```

### List Available Subscriptions
List all Azure subscriptions accessible to the account:
```powershell
Get-AzSubscription
```

### Switch Active Subscription
Switch context by Subscription ID or Subscription Name:
```powershell
Set-AzContext -Subscription '00000000-0000-0000-0000-000000000000'
Set-AzContext -SubscriptionName "Company Subscription"
```

### List and Filter Resource Groups
List resource groups matching a pattern and format as a table:
```powershell
Get-AzResourceGroup -Name szpl* | Format-Table
```

### Delete Resource Group
Remove a resource group and all contained resources without interactive prompt:
```powershell
Remove-AzResourceGroup -Name szpl-rg-lab-01 -Force
```

### Set Session Default Resource Group
Set a default resource group for subsequent commands in the active session:
```powershell
Set-AzDefault -ResourceGroupName szpl-rg-lab-1109
```

### Quick VM Deployment
Create a new VM with basic parameters ([Microsoft Learn: New-AzVM](https://learn.microsoft.com/en-gb/powershell/module/az.compute/new-azvm)):
```powershell
New-AzVM `
  -Location westeurope `
  -ResourceGroupName szpl-lab-rg `
  -Name szpl-lab-vm-01 `
  -Credential (Get-Credential)
```

### Advanced VM Configuration Pipeline
Construct a custom VM object step-by-step from Marketplace images:
```powershell
$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows `
  -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine `
  -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' `
  -Skus '2022-datacenter-azure-edition-core' -Version latest

New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Verbose
```

### Discover Marketplace Images (Publisher, Offer, SKU)
Query available images, publishers, and SKUs in a region:
```powershell
# List publishers
Get-AzVMImagePublisher -Location westeurope | Where-Object { $_.PublisherName -like "canonical*" }

# List offers for a publisher
Get-AzVMImageOffer -Location westeurope -PublisherName Canonical | Where-Object { $_.Offer -like "*kinetic*" }

# List SKUs for an offer
Get-AzVMImageSku -Location westeurope -PublisherName Canonical -Offer 0001-com-ubuntu-minimal-kinetic
```

### Modify and Update VM Object
Retrieve an existing VM, update properties (such as sizing), and push changes:
```powershell
$vm = Get-AzVM -Name MyVM -ResourceGroupName $ResourceGroupName
$vm.HardwareProfile.vmSize = "Standard_DS3_v2"
Update-AzVM -ResourceGroupName $ResourceGroupName -VM $vm
```

### Install VM Extensions
Deploy extensions (such as Network Watcher Agent) across VMs:
```powershell
foreach ($vmName in $vmNames) {
  Set-AzVMExtension `
    -ResourceGroupName $rgName `
    -Location $location `
    -VMName $vmName `
    -Name 'networkWatcherAgent' `
    -Publisher 'Microsoft.Azure.NetworkWatcher' `
    -Type 'NetworkWatcherAgentWindows' `
    -TypeHandlerVersion '1.4'
}
```

### Deploy ARM Template
Deploy Azure Resource Manager JSON templates ([Bicep Reference](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/file)).

> **Note**: ARM runs in incremental (additive) mode by default. Using `-Mode Complete` will **delete** any resources in the resource group that are not defined in the template.

```powershell
New-AzResourceGroupDeployment `
  -Name ("deploy-" + (Get-Date -Format "MM-dd--HH_mm")) `
  -TemplateFile "C:\path\to\azuredeploy.json"
```

---

## 06 | Azure CLI (az)

### Azure CLI Installation and Help
Install Azure CLI on Windows ([Installation Guide](https://aka.ms/installazurecliwindows)), log in, and discover commands:
```bash
az --version
az login
az find "az vm create"
az vm --help
```

### List Resource Groups (Table & JMESPath Query)
Query and format resource group information using [JMESPath](http://jmespath.org/):
```bash
# List in table format
az group list --output table

# Filter by resource group name
az group list --query "[?name == '$RESOURCE_GROUP']"
```

### App Service and Web App Management
Create App Service plans and web applications:
```bash
# Create plan
az appservice plan create --name $AZURE_APP_PLAN --resource-group $RESOURCE_GROUP --location $AZURE_REGION --sku FREE

# Create web app
az webapp create --name $AZURE_WEB_APP --resource-group $RESOURCE_GROUP --plan $AZURE_APP_PLAN

# List web apps
az webapp list --output table
```

### Create and List Virtual Machines
Deploy and list Azure virtual machines:
```bash
# Create VM
az vm create --resource-group szpl-lab --location westeurope --name SampleVM --image UbuntuLTS --admin-username peter --generate-ssh-keys --verbose

# List VMs
az vm list --output table
```

### Search Marketplace Images
List available images and filter by SKU:
```bash
az vm image list --output table
az vm image list --sku wordpress --all
```

### Sizing and Resizing Virtual Machines
Query VM size options and resize an existing VM:
```bash
# Available sizes in region
az vm list-sizes --location eastus --output table

# Available resize options for specific VM
az vm list-vm-resize-options --resource-group szpl-lab --name SampleVM --output table

# Resize VM
az vm resize --resource-group szpl-lab --name SampleVM --size Standard_DS3_v2
```

### Query VM Properties (JMESPath)
Retrieve network details and specific metadata properties:
```bash
# IP addresses
az vm list-ip-addresses --name SampleVM --output table

# Specific properties via query
az vm show --resource-group szpl-lab --name SampleVM --query "osProfile.adminUsername"
az vm show --resource-group szpl-lab --name SampleVM --query "hardwareProfile.vmName"
az vm show --resource-group szpl-lab --name SampleVM --query "networkProfile.networkInterfaces[].id"
```

### VM Power Lifecycle Control
Start, stop, and deallocate virtual machines:
```bash
# Start VM
az vm start --resource-group szpl-lab --name SampleVM

# Stop VM
az vm stop --resource-group szpl-lab --name SampleVM

# Deallocate VM (releases compute resources)
az vm deallocate --resource-group szpl-lab --name SampleVM
```

### List Virtual Network Subnets
Query subnet details in a virtual network:
```bash
az network vnet subnet list \
  --resource-group $RESOURCE_GROUP \
  --vnet-name ManufacturingVnet \
  --output table
```
