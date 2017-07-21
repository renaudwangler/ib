###########################################################
#                      Variables globales                 #
###########################################################
#
$global:ib1Version='1.0.1.3'
$global:ib1DISMUrl="https://msdn.microsoft.com/en-us/windows/hardware/dn913721(v=vs.8.5).aspx"
$global:ib1DISMPath='C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\dism.exe'

function compare-ib1PSVersion ($ibVersion='4.0') {
if ($PSVersionTable.PSCompatibleVersions -notcontains $ibVersion) {
  write-warning "Attention, script prévu pour Fonctionner avec Powershell $ibVersion"}}

function get-ib1elevated ($ibElevationNeeded=$false) {
if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{ if (-not $ibElevationNeeded) { return $true}}
else {
if ($ibElevationNeeded) {
  write-error "Attention, cette commande nécessite d'être executée en tant qu'administrateur" -Category AuthenticationError; break}
else { return $false}}}

function start-ib1VMWait ($SWVmname) {
  if ((get-vm $SWVmname).state -ne "Running") {
    Start-VM $SWVmname
    while ((get-vm $SWVmname).heartbeat -ne 'OKApplicationsHealthy') {
      write-progress -Activity "Démarrage de $SWVmname" -currentOperation "Attente de signal de démarrage réussi de la VM"
      start-sleep 2}
    write-progress -Activity "Démarrage de $SWVmname" -complete}}

function get-ib1VM ($gVMName) {
  if ($gVMName -eq '') {
  try { $gResult=Get-VM -ErrorAction stop }
  catch {
    write-error "Impossible de trouver des machines virtuelles sur ce Windows." -Category ObjectNotFound
    break}}
  else {
  try { $gResult=Get-VM $gVMName -ErrorAction stop }
  catch {
  write-error "Impossible de trouver une machine virtuelle nommée $gVMName." -Category ObjectNotFound
    break}}
  return $gResult}

function global:reset-ib1VM {
<#
.SYNOPSIS
Cette commande permet de rétablir les VMs du serveur Hyper-v à leur dernier checkpoint.
.PARAMETER VMName
Nom de la VMs à rétablir. si ce paramètre est omis toutes les VMs trouvées seront rétablies
.PARAMETER keepVMUp
N'arrête pas les VMs dont le dernier checkpoint est dans l'état allumé avant de les rétablir
.EXAMPLE
reset-ib1VM -VMName 'lon-dc1'
Rétablit la VM 'lon-dc1' à son dernier point de contrôle.
.EXAMPLE
reset-ib1VM -keepVMUp
Rétablir toutes les VMS à leur dernier point de contrôle, sans les éteindre.
#>
[CmdletBinding(
DefaultParameterSetName='keepVMUp')]
PARAM(
[switch]$keepVMUp=$false,
[string]$VMName)
begin{get-ib1elevated $true; compare-ib1PSVersion "4.0"}
process {
$VMs2Reset=get-ib1VM $VMName
foreach ($VM2reset in $VMs2Reset) {
  if ($snapshot=Get-VMSnapshot -VMName $VM2reset.vmname|sort creationtime|select -last 1 -ErrorAction SilentlyContinue) {
    if (-not $keepVMUp -and $VM2reset.state -ieq 'running') {
      Write-Debug "Arrêt de la VM $($VM2reset.vmname)."
      stop-vm -VMName $VM2reset.vmname -confirm:$false}
    Write-Debug "Restauration du snapshot $($snapshot.Name) sur la VM $($VM2reset.vmname)."
    Restore-VMSnapshot $snapshot -confirm:$false}
  else {write-debug "La VM $($VM2reset.vmname) n'a pas de snapshot"}}}
  end {echo "Fin de l'opération"}}

function global:set-ib1VhdBoot {
<#
.SYNOPSIS
Cette commande permet de monter le disque virtuel contenu dans le fichier VHD spécifié et de rajouter le démarrage sur la partition non réservée contenue au BCD.
.PARAMETER VHDFile
Nom du fichier VHD contenant le disque virtuel à monter.
.PARAMETER restart
Redémarre l'ordinateur à la fin du script (inactif par défaut)
.EXAMPLE
set-ib1vhboot -VHDFile 'c:\program files\microsoft learning\base\20470b-lon-host1.vhd
Monte la partition contenue dans le fichier VHD fourni.
.EXAMPLE
set-ib1vhboot -VHDFile 'c:\program files\microsoft learning\base\20470b-lon-host1.vhd -restart
Monte la partition contenue dans le fichier VHD fourni et redémarre dessus.
#>
[CmdletBinding(
DefaultParameterSetName='VHDFile')]
PARAM(
[parameter(Mandatory=$true,ValueFromPipeLine=$true,HelpMessage='Fichier VHD contenant le disque virtuel à monter (avec une partition système)')]
[string]$VHDfile,
[switch]$restart=$false)
begin{get-ib1elevated $true; compare-ib1PSVersion "4.0"}
# Attacher un VHD et le rajouter au menu de démarrage
process {
write-debug "`$VHDfile=$VHDfile"
try { Mount-VHD -Path $vhdFile -ErrorAction stop }
catch {
  write-error "Impossible de monter le disque virtuel contenu dans le fichier $VHDFile." -Category ObjectNotFound
  break}
$dLetter=(get-disk|where friendlyname -ilike "*microsoft*"|Get-Partition|Get-Volume|where {$_.filesystemlabel -ine "system reserved" -and $_.filesystemlabel -ine "réservée au système"}).driveletter+":"
write-debug "Disque(s) de lecteur Windows trouvé(s) : $dLetter"
if ($dLetter.Count -ne 1) {
 write-error 'Impossible de trouver un disque virtuel monté qui contienne une unique partition non réservée au système.' -Category ObjectNotFound
 break}
bcdboot $dLetter\windows /l fr-FR >> $null
bcdedit /set '{default}' Description ([io.path]::GetFileNameWithoutExtension($VHDFile)) >> $null
bcdedit /set '{default}' hypervisorlaunchtype auto
echo 'BCD modifié'
if ($restart) {Restart-Computer}}}

function global:remove-ib1VhdBoot {
<#
.SYNOPSIS
Cette commande permet de supprimer l'entrée par défaut du BCD et de démonter tous les disques virtuels montés sur la machine.
.PARAMETER restart
Redémarre l'ordinateur à la fin du script (inactif par défaut)
.EXAMPLE
remove-ib1vhboot -restart
supprimer l'entrée par défaut du BCD et redémarre la machine.
#>
[CmdletBinding(
DefaultParameterSetName='restart')]
PARAM(
[switch]$restart=$false)
begin{get-ib1elevated $true; compare-ib1PSVersion "4.0"}
#Trouve tous les disques virtuels pour les démonter
process {
get-disk|where FriendlyName -ilike "*microsoft*"|foreach {write-debug $_;get-partition|dismount-vhd -erroraction silentlycontinue}
write-debug "Supression de l'entrée {Default} du BCD"
bcdedit /delete '{default}' >> $null
echo 'BCD modifié'
if ($restart) {Restart-Computer}}}

function global:switch-ib1VMFr {
<#
.SYNOPSIS
Cette commande permet de changer le clavier d'une marchine virtuelle en Français.
(Ne fonctionne que sur les VMs éteinte au moment ou la commande est lançée)
.PARAMETER VMName
Nom de la VM sur laquelle agir (agit sur toutes les VMs si paramètre non spécifié)
.PARAMETER noCheckpoint
Ne crée pas les points de contrôle sur la VM avant et après action
.EXAMPLE
switch-ib1VMFr
Change le clavier de la VM en Français.
#>
[CmdletBinding(
DefaultParameterSetName='VMName')]
PARAM(
[string]$VMName='',
[switch]$noCheckpoint=$false)
begin{get-ib1elevated $true; compare-ib1PSVersion "4.0"}
process {
$VMs2switch=get-ib1VM $VMName
foreach ($VM2switch in $VMs2switch) {
  if ($VM2switch.state -ine 'off') {echo "La VM $($VM2switch.name) n'est pas éteinte et ne sera pas traitée"}
  else {
    #Remove-VMSnapshot -vm $VM2switch -ErrorAction SilentlyContinue
    #Checkpoint-VM -VM $VM2switch -SnapshotName "Original"
    Write-Debug "Changement des paramètres lingustiques de la VM $($VM2switch.name)"
    write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Montage du disque virtuel."
    $vhdPath=($VM2switch|Get-VMHardDiskDrive|where {$_.ControllerNumber -eq 0 -and $_.controllerLocation -eq 0}).path
    $testMount=$null
    mount-vhd -path $vhdPath -NoDriveLetter -passthru -ErrorVariable testMount -ErrorAction SilentlyContinue|get-disk|Get-Partition|where isactive -eq $false|Set-Partition -newdriveletter Z
    if ($testMount -eq $null) {Write-Error "Impossible de monter le disque dur... de la VM $($VM2switch.name)" -Category invalidResult}
    else {
      if (-not $noCheckpoint) {
        write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Création du checkpoint ib1SwitchFR-Avant."
        Dismount-VHD $vhdPath
        Checkpoint-VM -VM $VM2switch -SnapshotName "ib1SwitchFR-Avant"
        mount-vhd -path $vhdPath -NoDriveLetter -passthru -ErrorVariable testMount -ErrorAction SilentlyContinue|get-disk|Get-Partition|where isactive -eq $false|Set-Partition -newdriveletter Z}
      write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Changement des options linguistiques."
      & $ib1DISMPath /image:z: /set-allIntl:en-US /set-inputLocale:0409:0000040c >>$ $null
      if ($LASTEXITCODE -eq 50) {
        Start-Process -FilePath $ib1DISMUrl
        write-error "Si le problème vient de la version de DISM, merci de l'installer depuis la fenêtre de navigateur ouverte (installer localement et choisir les 'Deployment Tools' uniquement." -Category InvalidResult
        dismount-vhd $vhdpath
        if (-not $noCheckpoint) {
          Restore-VMSnapshot -VM $VM2switch -Name "ib1SwitchFR-Avant"
          Remove-VMSnapshot -VM $VM2switch -Name "ib1SwitchFR-Avant"}
        break}
      elseif ($LASTEXITCODE -ne 0) {
        write-warning "Problème pendant le changemement de langue de la VM '$($VM2switch.name)'. Merci de vérifier!' (Détail de l'erreur ci-dessous)."
        write-output $error|select -last 1
        if (-not $noCheckpoint) {
          Restore-VMSnapshot -VM $VM2switch -Name "ib1SwitchFR-Avant"
          Remove-VMSnapshot -VM $VM2switch -Name "ib1SwitchFR-Avant"}}
      write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Démontage du disque."
      dismount-vhd $vhdpath
      Start-Sleep 1}
    if (-not $noCheckpoint) {
      write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Création du checkpoint ib1SwitchFR-Après."
      Checkpoint-VM -VM $VM2switch -SnapshotName "ib1SwitchFR-Après"}
    write-progress -Activity "Traitement de $($VM2switch.name)" -complete}}
}}

function global:test-ib1VMNet {
<#
.SYNOPSIS
Cette commande permet de tester si les VMs sont bien connectées aux réseaux virtuel de l'hôte Hyper-V.
.EXAMPLE
test-ib1VMNet
Indiquera si des VMs sont branchées sur des switchs virtuels non déclarés.
#>
$vSwitchs=(Get-VMSwitch).name
$VMs=Get-VM
foreach ($VM in $VMs) {
  Write-progress -Activity "Vérification de la configuration réseau de la VM $($VM.Name)."
  foreach ($VMnetwork in $VM.NetworkAdapters) {
    Write-progress -Activity "Vérification de la configuration réseau de la VM $($VM.Name)." -CurrentOperation "Vérification de la présence du switch $($VMnetwork.name)"
    if ($VMnetwork.SwitchName -notin $vSwitchs) {Write-Warning "La VM '$($VM.Name)' est branchée sur le switch virtuel '$($VMnetwork.SwitchName)' qui est introuvable. Merci de vérifier !"}}
  Write-progress -Activity "Vérification de la configuration réseau de la VM $($VM.Name)." -Completed}}

function global:connect-ib1VMNet {
<#
.SYNOPSIS
Cette commande permet de mettre en place les prérequis réseau sur la machine Hyper-V Hôte.
(Une et une seule carte réseau physique doit être connectée au réseau)
.PARAMETER externalNetworkname
Nom (obligatoire) du réseau virtuel qui sera connecté au réseau externe
.EXAMPLE
connect-ib1VMNet "External Network"
Créer un réseau virtuel nommé "External Network" et le connecte à la carte réseau physique branchée (ou Wi-Fi connectée).
#>
[CmdletBinding(
DefaultParameterSetName='externalNetworkName')]
PARAM(
[parameter(Mandatory=$true,ValueFromPipeLine=$true,HelpMessage='Nom du réseau virtuel à connecter au réseau externe.')]
[string]$externalNetworkname='External Network')
get-ib1elevated $true
compare-ib1PSVersion "4.0"
$extNic=Get-NetIPAddress -AddressFamily IPv4 -AddressState Preferred -PrefixOrigin Dhcp|Get-NetAdapter
if ($extNic.PhysicalMediaType -eq "Unspecified") {
  if ((Get-VMSwitch $externalNetworkname  -switchtype External -ErrorAction SilentlyContinue).NetAdapterInterfaceDescription -eq (Get-NetAdapter -Physical|where status -eq up).InterfaceDescription) {
    Write-warning "La configuration réseau externe est déja correcte"
    break}
  else {
    Write-Warning "La carte réseau est déja connectée à un switch virtuel. Suppression!"
    $switch2Remove=Get-VMSwitch -SwitchType External|where {$extNic.name -like '*'+$_.name+'*'}
    Write-Progress -Activity "Suppression de switch virtuel existant" -currentOperation "Attente pour suppression de '$($switch2Remove.name)'."
    Remove-VMSwitch -Force -VMSwitch $switch2Remove
    for ($sleeper=0;$sleeper -lt 20;$sleeper++) {
      Write-Progress -Activity "Suppression de switch virtuel existant" -currentOperation "Attente pour suppression de '$($switch2Remove.name)'." -PercentComplete ($sleeper*5)
      Start-Sleep 1}
    Write-Progress -Activity "Suppression de switch virtuel existant" -Completed}
    $extNic=Get-NetIPAddress -AddressFamily IPv4 -AddressState Preferred -PrefixOrigin Dhcp|Get-NetAdapter}
  if (Get-VMSwitch $externalNetworkname -ErrorAction SilentlyContinue) {
    Write-Warning "Le switch '$externalNetworkname' existe. Branchement sur la bonne carte réseau"
    Get-VMSwitch $externalNetworkname|Set-VMSwitch -netadaptername $extNic.Name
    start-sleep 2}
  else {
    Write-Progress -Activity "Création du switch" -CurrentOperation "Création du switch virtuel '$externalNetworkname' et branchement sur la carte réseau."
    New-VMSwitch -Name $externalNetworkname -netadaptername $extNic.Name >> $null
    Write-Progress -Activity "Création du switch" -Completed}
test-ib1VMNet}

function global:set-ib1TSSecondScreen {
<#
.SYNOPSIS
Cette commande permet de basculer l'écran distant d'une connexion RDP sur l'écran sécondaire (seuls 2 écrans gérés).
.PARAMETER TSCFilename
Nom (obligatoire) du fichier .rdp dont la configuration par la présente commande doit être modifiée
.EXAMPLE
set-ib1TSSecondScreen "c:\users\ib\desktop\myremoteVM.rdp"
Modifiera le fichier indiqué pour que l'affichage de la machine distante se fasse sur le second écran.
#>
[CmdletBinding(
DefaultParameterSetName='TSCFilename')]
PARAM(
[parameter(Mandatory=$true,ValueFromPipeLine=$true,HelpMessage='Nom du fichier RDP à modifier.')]
[string]$TSCFilename='')
begin {compare-ib1PSVersion "4.0"}
process {
if (Test-Path $TSCFilename) {
  $oldFile=Get-Content $TSCFilename
  $newFile=@()
  Add-Type -AssemblyName System.Windows.Forms
  $Monitors = [System.Windows.Forms.Screen]::AllScreens
  foreach ($fileLine in (get-content C:\Users\ib\Desktop\marsAdmin11.rdp)){
    if ($fileLine -ilike '*winposstr*') {
      $newFile+="$($fileLine.split(",")[0]),$($fileLine.split(",")[1]),$($Monitors[1].WorkingArea.X),$($Monitors[1].WorkingArea.Y),$($Monitors[1].WorkingArea.X+$Monitors[1].Bounds.Width),$($Monitors[1].WorkingArea.Y+$Monitors[1].Bounds.Height)"}
    else {$newFile+=$fileLine}}
  Set-Content $TSCFilename $newFile}
else {write-error "Le fichier '$TSCFilename' est introuvable" -Category ObjectNotFound;break}
}}
