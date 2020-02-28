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
    set-ib1VMExternalMac
    $nvHost2='20740C-LON-NVHOST2-ib'
    set-VMProcessor -VMName $nvHost2 -ExposeVirtualizationExtensions $true
    get-VMNetWorkAdapter -VMName $nvHost2|Set-VMNetworkAdapter -MacAddressSpoofing On
    Set-VM -VMName $nvhost2 -MemoryStartupBytes 4GB
    invoke-expression "set-ib1VMCusto -vmName dc1-b-ib -ipAddress '172.16.0.10' $ipConfig"
    invoke-expression "set-ib1VMCusto -vmName svr1-b-ib -ipAddress '172.16.0.21' $ipconfig"
    invoke-expression "set-ib1VMCusto -vmName nvhost2-ib -ipAddress '172.16.0.32' $ipconfig -switchName 'Host Internal Network'"
    set-ib1VMCusto -vmName nat-ib -ipAddress '172.16.0.1' -VMcommand 'while ((get-NetConnectionProfile).Name -like "*identifying*") {start-sleep -seconds 5};Get-NetConnectionProfile|Set-NetConnectionProfile -NetworkCategory Private' -switchName "Host Internal Network" -rearm -user "administrator" -password "Pa55w.rd" -ipsubnet 16 -dNSServer "('172.16.0.10')"
    echo "Dans la machine NAT-ib, dans [Routing and Remote Access], ouvrir [IPv4] et, sur le [NAT], ajouter les deux interfaces."}
  elseif ($env:COMPUTERNAME -like '*host2*') {
    set-ib1VMCheckpointType
    if (!(get-vm *dc1-c).notes.Contains('Switch clavier FR')) {switch-ib1VMFr -nocheckpoint}
    if (!(get-vm -name *dc1-c-ib* -ErrorAction SilentlyContinue)) {copy-ib1VM -vmsuffix ib -nocheckpoint}
    invoke-expression "set-ib1VMCusto -vmName dc1-c-ib -ipAddress '172.16.0.10' $ipConfig"
    invoke-expression "set-ib1VMCusto -vmName nvhost3-ib -ipAddress '172.16.0.33' $ipconfig -switchName 'Private Network'"
    invoke-expression "set-ib1VMCusto -vmName nvhost4-ib -ipAddress '172.16.0.34' $ipconfig -switchName 'Private Network'"}

# goDeploy
  new-ib1Shortcut -URL 'https://lms.godeploy.it' -title 'Ateliers en ligne' -dest ([Environment]::GetFolderPath('CommonDesktopDirectory'))

# msms100
  $dest=[Environment]::GetFolderPath('DesktopDirectory')+'\Ateliers MSMS100'
  New-Item -ItemType directory -Path $dest -erroraction silentlycontinue|out-null
  if ($trainer) {  invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/MS-100AIntro.pptx -OutFile "$env:userprofile\documents\MS-100AIntro.pptx"}
  new-ib1Shortcut -URL 'https://lms.godeploy.it' -title 'Labs Online' -dest $dest
  new-ib1Shortcut -URL 'https://portal.office.com' -title 'Office 365 - Portail principal' -dest $dest
  new-ib1Shortcut -URL 'https://admin.microsoft.com' -title 'Microsoft 365 - Portail d''administration' -dest $dest

# msms101
  $dest=[Environment]::GetFolderPath('DesktopDirectory')+'\Ateliers MSMS101'
  New-Item -ItemType directory -Path $dest -erroraction silentlycontinue|out-null
  new-ib1Shortcut -URL 'https://lms.godeploy.it' -title 'Labs Online' -dest $dest
  new-ib1Shortcut -URL 'https://portal.office.com' -title 'Office 365 - Portail principal' -dest $dest
  new-ib1Shortcut -URL 'https://admin.microsoft.com' -title 'Microsoft 365 - Portail d''administration' -dest $dest

# msms200
  $dest=[Environment]::GetFolderPath('DesktopDirectory')+'\Ateliers MSMS200'
  New-Item -ItemType directory -Path $dest -erroraction silentlycontinue|out-null
  if ($trainer) {  invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/MS-200AIntro.pptx -OutFile "$env:userprofile\documents\MS-200AIntro.pptx"}
  new-ib1Shortcut -URL 'https://lms.godeploy.it' -title 'Labs Online' -dest $dest
  new-ib1Shortcut -URL 'https://portal.office.com' -title 'Office 365 - Portail principal' -dest $dest
  new-ib1Shortcut -URL 'https://admin.microsoft.com' -title 'Microsoft 365 - Portail d''administration' -dest $dest

# msms300
  $dest=[Environment]::GetFolderPath('DesktopDirectory')+'\Ateliers MSMS300'
  New-Item -ItemType directory -Path $dest -erroraction silentlycontinue|out-null
  if ($trainer) {  invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/MS-300AIntro.pptx -OutFile "$env:userprofile\documents\MS-300AIntro.pptx"}
  new-ib1Shortcut -URL 'https://lms.godeploy.it' -title 'Labs Online' -dest $dest
  new-ib1Shortcut -URL 'https://portal.office.com' -title 'Office 365 - Portail principal' -dest $dest
  new-ib1Shortcut -URL 'https://admin.microsoft.com' -title 'Microsoft 365 - Portail d''administration' -dest $dest

# msms500
  $dest=[Environment]::GetFolderPath('DesktopDirectory')+'\Ateliers MSMS500'
  New-Item -ItemType directory -Path $dest -erroraction silentlycontinue|out-null
  if ($trainer) {  invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/MS-500AIntro.pptx -OutFile "$env:userprofile\documents\MS-500AIntro.pptx"}
  new-ib1Shortcut -URL 'https://lms.godeploy.it' -title 'Labs Online' -dest $dest
  new-ib1Shortcut -URL 'https://portal.office.com' -title 'Office 365 - Portail principal' -dest $dest
  new-ib1Shortcut -URL 'https://admin.microsoft.com' -title 'Microsoft 365 - Portail d''administration' -dest $dest

# msaz900
  $dest=[Environment]::GetFolderPath('DesktopDirectory')+'\Manipulations MSAZ900'
  New-Item -ItemType directory -Path $dest -erroraction silentlycontinue|out-null
  if ($trainer) {invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/AZ-900AIntro.pptx -OutFile "$env:userprofile\documents\AZ-900AIntro.pptx"}
  new-ib1Shortcut -URL 'https://azure.microsoft.com/en-us/free/' -title 'Azure - Free Account' -dest $dest
  new-ib1Shortcut -URL 'https://www.microsoftazurepass.com' -title 'Azure - Validation pass' -dest $dest
  new-ib1Shortcut -URL 'https://portal.azure.com' -title 'Azure - Portail' -dest $dest
  new-ib1Shortcut -URL 'https://shell.azure.com' -title 'Azure - Cloud Shell' -dest $dest
  new-ib1Shortcut -URL 'https://microsoftlearning.github.io/AZ-900T0x-MicrosoftAzureFundamentals/' -title 'Instructions Ateliers' -dest $dest
  echo "Installation Framework .Net 4.8"
  if ([version](Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\' -Recurse|Get-ItemProperty -Name version,release -EA 0|where {$_.pschildName -match '^(?!S)\p{L}'}|Sort-Object -Descending -Property version|Select-Object -First 1).version -lt [version]'4.8.0') {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri https://go.microsoft.com/fwlink/?linkid=2088631 -OutFile "$env:TEMP\Net48.exe"
    Start-Process -FilePath "$env:TEMP\Net48.exe" -ArgumentList "/q /norestart" -wait
    $restart=$true}
  if ([version](Find-Module az).version -gt [version](Get-Module -ListAvailable Az*|Sort-Object -Descending -Property version|Select-Object -First 1).version) {
    echo "Installation module 'AZ'"
    install-module az -Force}
  if ($restart) { Restart-Computer -Force}

# msaz103
  $dest=[Environment]::GetFolderPath('DesktopDirectory')+'\Ateliers MSAZ103'
  $restart=$false
  get-ib1Repo AZ-103-MicrosoftAzureAdministrator -destPath $dest -srcPath Allfiles/labfiles
  if ($trainer) {
    invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/AZ-103AIntro.pptx -OutFile "$env:userprofile\documents\AZ-103AIntro.pptx"
    invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/AZ-103APrequel.pptx -OutFile "$env:userprofile\documents\AZ-103APrequel.pptx"
    invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/AZ-103AExtraAutomation.pptx -OutFile "$env:userprofile\documents\AZ-103A-Extra-Automation.pptx"}
  new-ib1Shortcut -URL 'https://portal.azure.com' -title 'Azure - Portail' -dest $dest
  new-ib1Shortcut -URL 'https://shell.azure.com' -title 'Azure - Cloud Shell' -dest $dest
  new-ib1Shortcut -URL 'https://www.microsoftazurepass.com' -title 'Azure - Validation pass' -dest $dest
  new-ib1Shortcut -URL 'https://microsoftlearning.github.io/AZ-103-MicrosoftAzureAdministrator/' -title 'Instructions Ateliers' -dest $dest
  if ([version](Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\' -Recurse|Get-ItemProperty -Name version,release -EA 0|where {$_.pschildName -match '^(?!S)\p{L}'}|Sort-Object -Descending -Property version|Select-Object -First 1).version -lt [version]'4.8.0') {
    echo "Installation Framework .Net 4.8"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri https://go.microsoft.com/fwlink/?linkid=2088631 -OutFile "$env:TEMP\Net48.exe"
    Start-Process -FilePath "$env:TEMP\Net48.exe" -ArgumentList "/q /norestart" -wait
    $restart=$true}
  $azModule=Get-Module -ListAvailable Az*|Sort-Object -Descending -Property version|Select-Object -First 1
  if (!($azModule) -or ((Find-Module $azModule.Name).version -gt [version]$azModule.version)) {
    echo "Installation module 'AZ'"
    install-module az -Force}
  if ($restart) { Restart-Computer -Force}

# msaz104
  $dest=[Environment]::GetFolderPath('DesktopDirectory')+'\Ateliers MSAZ104'
  $restart=$false
  get-ib1Repo AZ-104-MicrosoftAzureAdministrator -destPath $dest -srcPath Allfiles/labfiles
  if ($trainer) {
    invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/AZ-104AIntro.pptx -OutFile "$env:userprofile\documents\AZ-104AIntro.pptx"
    invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/AzurePrequel.pptx -OutFile "$env:userprofile\documents\AzurePrequel.pptx"}
  new-ib1Shortcut -URL 'https://portal.azure.com' -title 'Azure - Portail' -dest $dest
  new-ib1Shortcut -URL 'https://shell.azure.com' -title 'Azure - Cloud Shell' -dest $dest
  new-ib1Shortcut -URL 'https://www.microsoftazurepass.com' -title 'Azure - Validation pass' -dest $dest
  new-ib1Shortcut -URL 'https://microsoftlearning.github.io/AZ-104-MicrosoftAzureAdministrator/' -title 'Instructions Ateliers' -dest $dest
  if ([version](Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\' -Recurse|Get-ItemProperty -Name version,release -EA 0|where {$_.pschildName -match '^(?!S)\p{L}'}|Sort-Object -Descending -Property version|Select-Object -First 1).version -lt [version]'4.8.0') {
    echo "Installation Framework .Net 4.8"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri https://go.microsoft.com/fwlink/?linkid=2088631 -OutFile "$env:TEMP\Net48.exe"
    Start-Process -FilePath "$env:TEMP\Net48.exe" -ArgumentList "/q /norestart" -wait
    $restart=$true}
  $azModule=Get-Module -ListAvailable Az*|Sort-Object -Descending -Property version|Select-Object -First 1
  if (!($azModule) -or ((Find-Module $azModule.Name).version -gt [version]$azModule.version)) {
    echo "Installation module 'AZ'"
    install-module az -Force}
  if ($restart) { Restart-Computer -Force}


# msaz300
  $dest=[Environment]::GetFolderPath('DesktopDirectory')+'\Ateliers MSAZ300'
  $restart=$false
  get-ib1Repo AZ-300-MicrosoftAzureArchitectTechnologies -destPath $dest -srcPath Allfiles
  if ($trainer) {
    invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/AZ-300AIntro.pptx -OutFile "$env:userprofile\documents\AZ-300AIntro.pptx"
    invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/AZ-103APrequel.pptx -OutFile "$env:userprofile\documents\AZ-103APrequel.pptx"}
  new-ib1Shortcut -URL 'https://portal.azure.com' -title 'Azure - Portail' -dest $dest
  new-ib1Shortcut -URL 'https://shell.azure.com' -title 'Azure - Cloud Shell' -dest $dest
  new-ib1Shortcut -URL 'https://www.microsoftazurepass.com' -title 'Azure - Validation pass' -dest $dest
  new-ib1Shortcut -URL 'https://github.com/MicrosoftLearning/AZ-300-MicrosoftAzureArchitectTechnologies/tree/master/Instructions' -title 'Instructions Ateliers' -dest $dest
  if ([version](Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\' -Recurse|Get-ItemProperty -Name version,release -EA 0|where {$_.pschildName -match '^(?!S)\p{L}'}|Sort-Object -Descending -Property version|Select-Object -First 1).version -lt [version]'4.8.0') {
    echo "Installation Framework .Net 4.8"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri https://go.microsoft.com/fwlink/?linkid=2088631 -OutFile "$env:TEMP\Net48.exe"
    Start-Process -FilePath "$env:TEMP\Net48.exe" -ArgumentList "/q /norestart" -wait
    $restart=$true}
  $azModule=Get-Module -ListAvailable Az*|Sort-Object -Descending -Property version|Select-Object -First 1
  if (!($azModule) -or ((Find-Module $azModule.Name).version -gt [version]$azModule.version)) {
    echo "Installation module 'AZ'"
    install-module az -Force}
  if ($restart) { Restart-Computer -Force}

# msaz301
  $dest=[Environment]::GetFolderPath('DesktopDirectory')+'\Ateliers MSAZ301'
  $restart=$false
  get-ib1Repo AZ-301-MicrosoftAzureArchitectDesign -destPath $dest -srcPath Allfiles
  invoke-webRequest -uri https://aka.ms/win32-x64-user-stable -OutFile "$env:TEMP\vsCode.exe"
  & $env:TEMP\vsCode.exe /VERYSILENT /MERGETASKS=!runcode
  $vsLnk="$env:AppDATA\Microsoft\Windows\Start Menu\Programs\Visual Studio Code\Visual Studio Code.lnk"
  while (!(Test-Path $vsLnk)) { Start-Sleep 10 }
  new-ib1Shortcut -File $vsLnk -TaskBar
  if ($trainer) {
    invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/AZ-301AIntro.pptx -OutFile "$env:userprofile\documents\AZ-301AIntro.pptx"
    invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/AZ-103APrequel.pptx -OutFile "$env:userprofile\documents\AZ-103APrequel.pptx"}
  new-ib1Shortcut -URL 'https://portal.azure.com' -title 'Azure - Portail' -dest $dest
  new-ib1Shortcut -URL 'https://shell.azure.com' -title 'Azure - Cloud Shell' -dest $dest
  new-ib1Shortcut -URL 'https://www.microsoftazurepass.com' -title 'Azure - Validation pass' -dest $dest
  new-ib1Shortcut -URL 'https://github.com/MicrosoftLearning/AZ-301-MicrosoftAzureArchitectDesign/tree/master/Instructions' -title 'Instructions Ateliers' -dest $dest
  if ([version](Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\' -Recurse|Get-ItemProperty -Name version,release -EA 0|where {$_.pschildName -match '^(?!S)\p{L}'}|Sort-Object -Descending -Property version|Select-Object -First 1).version -lt [version]'4.8.0') {
    echo "Installation Framework .Net 4.8"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri https://go.microsoft.com/fwlink/?linkid=2088631 -OutFile "$env:TEMP\Net48.exe"
    Start-Process -FilePath "$env:TEMP\Net48.exe" -ArgumentList "/q /norestart" -wait
    $restart=$true}
  $azModule=Get-Module -ListAvailable Az*|Sort-Object -Descending -Property version|Select-Object -First 1
  if (!($azModule) -or ((Find-Module $azModule.Name).version -gt [version]$azModule.version)) {
    echo "Installation module 'AZ'"
    install-module az -Force}
  if ($restart) { Restart-Computer -Force}

# Fin