# courses.ps1
##########################
#Customisation des stages#
##########################
#[Attention] les commentaires dans ce fichier ne doivent pas comporter d'espace après le #
break

# m20411d
connect-ib1VMNet
$nic=Get-NetAdapter | where-object {$_.Status -eq 'up' -and $_.Virtual} | Get-NetIPInterface -AddressFamily IPv4 -ErrorAction SilentlyContinue
if (!(wait-ib1network -nicName $nic.interfaceAlias)) {write-ib1log "Le réseau ne semble pas fonctionnel, essayez de désactiver/réactiver la carte '$($nic.name)' puis relancez la commande." -errorLog}
set-ib1VMExternalMac
get-vm 'MSL-TMG1'|Remove-VMSnapshot
get-vm 'MSL-TMG1'|Checkpoint-VM -SnapshotName 'Accès Internet.'|out-null


# m20742b
if (!(get-vm *lon-dc1).notes.Contains('Switch clavier FR')) {switch-ib1VMFr}
connect-ib1VMNet "External Network"
set-ib1VMExternalMac
set-ib1VMCheckpointType
get-VM|Checkpoint-VM|Out-Null


# m20741b
  $ipConfig='-rearm -user "adatum\administrator" -password "Pa55w.rd" -ipSubnet 16 -dNSServers "(''172.16.0.10'')" -ipGateway "172.16.0.1"'
  if ($env:COMPUTERNAME -like "*host1*") {
    cscript c:\windows\system32\slmgr.vbs -rearm|out-null
    $nic = Get-NetAdapter | where-object {$_.Status -eq 'up' -and !$_.Virtual -and $_.InterfaceDescription -notlike '*loopback*'} | Get-NetIPInterface -AddressFamily IPv4 -ErrorAction SilentlyContinue
    If ($nic.Dhcp -like 'Disabled') {
      If (($nic|Get-NetIPConfiguration).Ipv4DefaultGateway) {$nic|Remove-NetRoute -Confirm:$false -errorAction silentlyContinue}
      $nic|Set-NetIPInterface -DHCP Enabled}
    $nic|Set-DnsClientServerAddress -ResetServerAddresses
    if (!(wait-ib1network -nicName $nic.interfaceAlias)) {write-ib1log "Le réseau ne semble pas fonctionnel, essayez de désactiver/réactiver la carte '$($nic.name)' puis relancez la commande." -errorLog}
    if (Get-NetAdapter|Where-Object {$_.interfacedescription -like "*loopback*"}) {
      $loop=Get-NetAdapter|Where-Object {$_.interfacedescription -like "*loopback*"}
      if ($loop.name -ne 'loopback') {$loop|Rename-NetAdapter -NewName loopback}}
    else {
      Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force|out-null
      Install-Module -Name LoopbackAdapter -MinimumVersion 1.2.0.0 -Force -SkipPublisherCheck|out-null
      $loop = New-LoopbackAdapter -Name loopback -Force -warningaction silentlycontinue|out-null}
    Get-VMSwitch|where name -like "*Private Network*"|Set-VMSwitch -SwitchType Internal
    start-sleep -seconds 20
    Remove-NetIPAddress 172.16.0.30 -defaultGateway 172.16.0.1 -confirm:$false -errorAction silentlyContinue
    $vNic = Get-NetAdapter | where-object {$_.Status -like 'up' -and $_.Virtual -and $_.Name -like "*$((Get-VMSwitch|where SwitchType -like 'Internal').name)*"}
    New-NetIPAddress -InterfaceAlias $vNic.InterfaceAlias -IPAddress '172.16.0.30' -PrefixLength 16 -AddressFamily ipv4 -defaultGateway '172.16.0.1'|out-null
    Set-DnsClientServerAddress -InterfaceAlias $vNic.InterfaceAlias -ServerAddresses ('172.16.0.10')
    if (!(get-vm *dc1-b).notes.Contains('Switch clavier FR')) {switch-ib1VMFr -nocheckpoint}
    if (!(get-vm *dc1-b-ib* -ErrorAction SilentlyContinue)) {copy-ib1VM -vmsuffix ib -nocheckpoint -WarningAction SilentlyContinue}
    if (!(get-vm *dc1-b-ib*).Notes.Contains('Customisation de la VM')) {invoke-expression "set-ib1VMCusto -vmName dc1-b-ib -ipAddress '172.16.0.10' $ipConfig" -errorAction silentlyContinue}
    if (!(get-vm *svr1-b-ib*).Notes.Contains('Customisation de la VM')) {invoke-expression "set-ib1VMCusto -vmName svr1-b-ib -ipAddress '172.16.0.21' $ipconfig" -errorAction silentlyContinue}
    if (!(get-vm *cl1-b-ib*).Notes.Contains('Customisation de la VM')) {invoke-expression "set-ib1VMCusto -vmName cl1-b-ib -ipAddress '172.16.0.50' $ipconfig -switchName 'Private Network'" -errorAction silentlyContinue}}

# m20740c
  $ipConfig='-rearm -user "adatum\administrator" -password "Pa55w.rd" -ipSubnet 16 -dNSServers "(''172.16.0.10'')" -ipGateway "172.16.0.1"'
  if ($env:COMPUTERNAME -like '*host1*') {
    set-ib1VMCheckpointType
    if (!(get-vm *dc1-b).notes.Contains('Switch clavier FR')) {switch-ib1VMFr -nocheckpoint}
    if (!(get-vm -name *dc1-b-ib* -ErrorAction SilentlyContinue)) {copy-ib1VM -vmsuffix ib -nocheckpoint}
    $nvHost2='20740C-LON-NVHOST2-ib'
    set-VMProcessor -VMName $nvHost2 -ExposeVirtualizationExtensions $true
    get-VMNetWorkAdapter -VMName $nvHost2|Set-VMNetworkAdapter -MacAddressSpoofing On
    Set-VM -VMName $nvhost2 -MemoryStartupBytes 4GB
    invoke-expression "set-ib1VMCusto -vmName dc1-b-ib -ipAddress '172.16.0.10' $ipConfig"
    invoke-expression "set-ib1VMCusto -vmName svr1-b-ib -ipAddress '172.16.0.21' $ipconfig"
    invoke-expression "set-ib1VMCusto -vmName nvhost2-ib -ipAddress '172.16.0.32' $ipconfig -switchName 'Host Internal Network'"
    set-ib1VMCusto -vmName nat-ib -ipAddress '172.16.0.1' -VMcommand 'while ((get-NetConnectionProfile).Name -like "*identifying*") {start-sleep -seconds 5};Get-NetConnectionProfile|Set-NetConnectionProfile -NetworkCategory Private -switchName "Host Internal Network" -rearm -user "administrator" -password "Pa55w.rd" -ipsubnet 16 -dNSServer "(''172.16.0.10'')"'
    echo "Dans la machine NAT-ib, dans [Routing and Remote Access], ouvrir [IPv4] et, sur le [NAT], ajouter les deux interfaces."}
  elseif ($env:COMPUTERNAME -like '*host2*') {
    set-ib1VMCheckpointType
    if (!(get-vm *dc1-c).notes.Contains('Switch clavier FR')) {switch-ib1VMFr -nocheckpoint}
    if (!(get-vm -name *dc1-c-ib* -ErrorAction SilentlyContinue)) {copy-ib1VM -vmsuffix ib -nocheckpoint}
    invoke-expression "set-ib1VMCusto -vmName dc1-c-ib -ipAddress '172.16.0.10' $ipConfig"
    invoke-expression "set-ib1VMCusto -vmName nvhost3-ib -ipAddress '172.16.0.33' $ipconfig -switchName 'Private Network'"
    invoke-expression "set-ib1VMCusto -vmName nvhost4-ib -ipAddress '172.16.0.34' $ipconfig -switchName 'Private Network'"}

# ms100
  $dest=[Environment]::GetFolderPath('CommonDesktopDirectory')+'\Ateliers MS100'
  New-Item -ItemType directory -Path $dest -erroraction silentlycontinue|out-null
  if ($trainer) {  invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/MS-100AIntro.pptx -OutFile "$env:userprofile\documents\MS-100AIntro.pptx"}
  new-ib1Shortcut -URL 'https://lms.godeploy.it' -title 'Labs Online' -dest $dest
  new-ib1Shortcut -URL 'https://portal.office.com' -title 'Office 365 - Portail principal' -dest $dest
  new-ib1Shortcut -URL 'https://admin.microsoft.com' -title 'Microsoft 365 - Portail d''administration' -dest $dest

# m10979
  new-ib1Shortcut -URL 'https://github.com/MicrosoftLearning/10979-MicrosoftAzureFundamentals/tree/master/Instructions' -title 'Ateliers stage m10979'

# m20533
  new-ib1Shortcut -URL 'https://github.com/MicrosoftLearning/20533-ImplementingMicrosoftAzureInfrastructureSolutions/tree/master/Instructions' -title 'Ateliers stage m20533'
  if ($env:COMPUTERNAME -like '*mia-cl1*') {get-ib1Repo 20533-ImplementingMicrosoftAzureInfrastructureSolutions -srcPath Allfiles -destPath F:\}

# msaz900
  $dest=[Environment]::GetFolderPath('CommonDesktopDirectory')+'\Manipulations MSAZ900'
  New-Item -ItemType directory -Path $dest -erroraction silentlycontinue|out-null
  if ($trainer) {invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/AZ-900AIntro.pptx -OutFile "$env:userprofile\documents\AZ-900AIntro.pptx"}
  new-ib1Shortcut -URL 'https://azure.microsoft.com/en-us/free/' -title 'Azure - Free Account' -dest $dest
  new-ib1Shortcut -URL 'https://portal.azure.com' -title 'Azure - Portail' -dest $dest
  new-ib1Shortcut -URL 'https://shell.azure.com' -title 'Azure - Cloud Shell' -dest $dest
  install-module AZ -force

# msaz100
  $dest=[Environment]::GetFolderPath('CommonDesktopDirectory')+'\Ateliers MSAZ100'
  get-ib1Repo AZ-100-MicrosoftAzureInfrastructureDeployment -destPath $dest -srcPath Allfiles/labfiles
  if ($trainer) {
    invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/AZ-100AIntro.pptx -OutFile "$env:userprofile\documents\AZ-100AIntro.pptx"
    invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/AZ-100AExtraAutomation.pptx -OutFile "$env:userprofile\documents\AZ-100A-Extra-Automation.pptx"}
  new-ib1Shortcut -URL 'https://portal.azure.com' -title 'Azure - Portail' -dest $dest
  new-ib1Shortcut -URL 'https://shell.azure.com' -title 'Azure - Cloud Shell' -dest $dest
  new-ib1Shortcut -URL 'https://www.microsoftazurepass.com' -title 'Azure - Validation pass' -dest $dest
  new-ib1Shortcut -URL 'https://github.com/MicrosoftLearning/AZ-100-MicrosoftAzureInfrastructureDeployment/tree/master/Instructions' -title 'Instructions Ateliers' -dest $dest
  install-module azureRM -maximumVersion 6.12.0 -force
  
# msaz103
  $dest=[Environment]::GetFolderPath('CommonDesktopDirectory')+'\Ateliers MSAZ103'
  get-ib1Repo AZ-103-MicrosoftAzureAdministrator -destPath $dest -srcPath Allfiles/labfiles
  if ($trainer) {
    invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/AZ-103AIntro.pptx -OutFile "$env:userprofile\documents\AZ-100AIntro.pptx"
    invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/AZ-103AExtraAutomation.pptx -OutFile "$env:userprofile\documents\AZ-100A-Extra-Automation.pptx"}
  new-ib1Shortcut -URL 'https://portal.azure.com' -title 'Azure - Portail' -dest $dest
  new-ib1Shortcut -URL 'https://shell.azure.com' -title 'Azure - Cloud Shell' -dest $dest
  new-ib1Shortcut -URL 'https://www.microsoftazurepass.com' -title 'Azure - Validation pass' -dest $dest
  new-ib1Shortcut -URL 'https://github.com/MicrosoftLearning/AZ-103-MicrosoftAzureAdministrator/tree/master/Instructions/Labs' -title 'Instructions Ateliers' -dest $dest
  install-module az -Force

# msaz101
  $dest=[Environment]::GetFolderPath('CommonDesktopDirectory')+'\Ateliers MSAZ101'
  get-ib1Repo AZ-101-MicrosoftAzureIntegrationandSecurity -destPath $dest -srcPath Allfiles/labfiles
  if ($trainer) {invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/AZ-101AIntro.pptx -OutFile "$env:userprofile\documents\AZ-101AIntro.pptx"}
  new-ib1Shortcut -URL 'https://portal.azure.com' -title 'Azure - Portail' -dest $dest
  new-ib1Shortcut -URL 'https://shell.azure.com' -title 'Azure - Cloud Shell' -dest $dest
  new-ib1Shortcut -URL 'https://www.microsoftazurepass.com' -title 'AZure - Validation pass' -dest $dest
  new-ib1Shortcut -URL 'https://github.com/MicrosoftLearning/AZ-101-MicrosoftAzureIntegrationandSecurity/tree/master/Instructions' -title 'Instructions Ateliers' -dest $dest
  install-module azureRM -maximumVersion 6.12.0 -force

# Fin

#'msaz100old'='
$dest=[Environment]::GetFolderPath("CommonDesktopDirectory")+"\Ateliers MSAZ100"
get-ib1Repo AZ-100-MicrosoftAzureInfrastructureDeployment -destPath $dest
Add-Type -AssemblyName System.IO.Compression.FileSystem
remove-item "$($dest)\AZ-100T03A-ENU-LabFiles.zip" -force -errorAction SilentlyContinue
remove-item "$($dest)\AZ-100T04A-ENU-LabFiles.zip" -force -errorAction SilentlyContinue
remove-item "$($dest)\labfiles" -force -recurse -errorAction silentlyContinue
get-childitem ($dest)|foreach-object {unzip $_.fullName $dest;remove-item $_.fullName -force -errorAction SilentlyContinue}
get-childitem ($dest) -directory|foreach-object {move-item "$($_.fullname)\*" -destination $dest;remove-item $_.fullName -force}
get-childitem ($dest) -file|foreach-object {rename-item -path $_.fullName -newName "Partie $($_.name[8]).pdf"}';
