###########################################################
#                      Variables globales                 #
###########################################################
#
$ib1DISMUrl="https://msdn.microsoft.com/en-us/windows/hardware/dn913721(v=vs.8.5).aspx"
$ib1DISMPath='C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\dism.exe'

function compare-ib1PSVersion ($ibVersion='4.0') {
if ($PSVersionTable.PSCompatibleVersions -notcontains $ibVersion) {
  write-warning "Attention, script  fonctionnant au mieux avec Powershell $ibVersion"}}

function get-ib1elevated ($ibElevationNeeded=$false) {
if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{ if (-not $ibElevationNeeded) { return $true}}
else {
if ($ibElevationNeeded) {
  write-error "Attention, commande en tant qu'administrateur" -Category AuthenticationError; break}
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
  write-error "Impossible de trouver une machine virtuelle '$gVMName'." -Category ObjectNotFound
    break}}
  return $gResult}

function reset-ib1VM {
<#
.SYNOPSIS
Cette commande permet de rétablir les VMs du serveur Hyper-v à  leur dernier checkpoint.
.PARAMETER VMName
Nom de la VMs à  retablir. si ce parametre est omis toutes les VMs seront rétablies
.PARAMETER keepVMUp
N'arrete pas les VMs allumées avant de les rétablir
.EXAMPLE
reset-ib1VM -VMName 'lon-dc1'
Rétablit la VM 'lon-dc1' à son dernier point de controle.
.EXAMPLE
reset-ib1VM -keepVMUp
Rétablir toutes les VMS à leur dernier point de controle, sans les éteindre.
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
  if ($snapshot=Get-VMSnapshot -VMName $VM2reset.vmname|sort-object creationtime|select-object -last 1 -ErrorAction SilentlyContinue) {
    if (-not $keepVMUp -and $VM2reset.state -ieq 'running') {
      Write-Debug "Arrêt de la VM $($VM2reset.vmname)."
      stop-vm -VMName $VM2reset.vmname -confirm:$false}
    Write-Debug "Restauration du snapshot $($snapshot.Name) sur la VM $($VM2reset.vmname)."
    Restore-VMSnapshot $snapshot -confirm:$false}
  else {write-debug "La VM $($VM2reset.vmname) n'a pas de snapshot"}}}
  end {Write-Output "Fin de l'opération"}}

function set-ib1VhdBoot {
<#
.SYNOPSIS
Cette commande permet de monter le disque virtuel contenu dans le fichier VHD et de rajouter le démarrage sur la partition non réservée contenue au BCD.
.PARAMETER VHDFile
Nom du fichier VHD contenant le disque virtuel à monter.
.PARAMETER restart
Redémarre l'ordinateur à la fin du script (inactif par défaut)
.EXAMPLE
set-ib1vhboot -VHDFile 'c:\program files\microsoft learning\base\20470b-lon-host1.vhd'
Monte la partition contenue dans le fichier VHD fourni.
.EXAMPLE
set-ib1vhboot -VHDFile 'c:\program files\microsoft learning\base\20470b-lon-host1.vhd' -restart
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
$dLetter=(get-disk|where-object friendlyname -ilike "*microsoft*"|Get-Partition|Get-Volume|where-object {$_.filesystemlabel -ine "system reserved" -and $_.filesystemlabel -ine "réservé au système"}).driveletter+":"
write-debug "Disque(s) de lecteur Windows trouvé(s) : $dLetter"
if ($dLetter.Count -ne 1) {
 write-error 'Impossible de trouver un disque virtuel monté qui contienne une unique partition non réservée au systeme.' -Category ObjectNotFound
 break}
bcdboot $dLetter\windows /l fr-FR >> $null
bcdedit /set '{default}' Description ([io.path]::GetFileNameWithoutExtension($VHDFile)) >> $null
bcdedit /set '{default}' hypervisorlaunchtype auto
Write-Output 'BCD modifie'
if ($restart) {Restart-Computer}}}

function remove-ib1VhdBoot {
<#
.SYNOPSIS
Cette commande permet de supprimer l'entrée par defaut du BCD et de démonter tous les disques virtuels montés sur la machine.
.PARAMETER restart
Redémarre l'ordinateur à la fin du script (inactif par defaut)
.EXAMPLE
remove-ib1vhboot -restart
supprimer l'entrée par defaut du BCD et redémarre la machine.
#>
[CmdletBinding(
DefaultParameterSetName='restart')]
PARAM(
[switch]$restart=$false)
begin{get-ib1elevated $true; compare-ib1PSVersion "4.0"}
process {
get-disk|where-object FriendlyName -ilike "*microsoft*"|foreach-object {write-debug $_;get-partition|dismount-vhd -erroraction silentlycontinue}
write-debug "Supression de l'entrée {Default} du BCD"
bcdedit /delete '{default}' >> $null
Write-Output 'BCD modifie'
if ($restart) {Restart-Computer}}}

function switch-ib1VMFr {
<#
.SYNOPSIS
Cette commande permet de changer le clavier d'une marchine virtuelle en Francais.
(Ne fonctionne que sur les VMs éteintes au moment ou la commande est lancée)
.PARAMETER VMName
Nom de la VM sur laquelle agir (agit sur toutes les VMs si paramètre non spécifié)
.PARAMETER noCheckpoint
Ne crée pas les points de contrôle sur la VM avant et après action
.EXAMPLE
switch-ib1VMFr
Change le clavier de toutes les VM en Français.
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
  if ($VM2switch.state -ine 'off') {Write-Output "La VM $($VM2switch.name) n'est pas éteinte et ne sera pas traitée"}
  else {
    Write-Debug "Changement des paramêtres lingustiques de la VM $($VM2switch.name)"
    write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Montage du disque virtuel."
    $vhdPath=($VM2switch|Get-VMHardDiskDrive|where-object {$_.ControllerNumber -eq 0 -and $_.controllerLocation -eq 0}).path
    $testMount=$null
    mount-vhd -path $vhdPath -NoDriveLetter -passthru -ErrorVariable testMount -ErrorAction SilentlyContinue|get-disk|Get-Partition|where-object isactive -eq $false|Set-Partition -newdriveletter Z
    if ($testMount -eq $null) {Write-Error "Impossible de monter le disque dur... de la VM $($VM2switch.name)" -Category invalidResult}
    else {
      if (-not $noCheckpoint) {
        Dismount-VHD $vhdPath
        $prevSnap=Get-VMSnapshot -VMName $($VM2switch.name) -name "ib1SwitchFR-Avant"
        if ($prevSnap -ne $null) {write-error 'Un checkpoint nommé "ib1SwitchFR-Avant" existe déja sur la VM "$($VM2switch.name)"';break}
        write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Création du checkpoint ib1SwitchFR-Avant." 
        Checkpoint-VM -VM $VM2switch -SnapshotName "ib1SwitchFR-Avant"
        mount-vhd -path $vhdPath -NoDriveLetter -passthru -ErrorVariable testMount -ErrorAction SilentlyContinue|get-disk|Get-Partition|where-object isactive -eq $false|Set-Partition -newdriveletter Z}
      write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Changement des options linguistiques."
      DISM /image:z: /set-allIntl:en-US /set-inputLocale:0409:0000040c >>$ $null
      if ($LASTEXITCODE -eq 50) {
        if (Test-Path $ib1DISMPath) {& $ib1DISMPath /image:z: /set-allIntl:en-US /set-inputLocale:0409:0000040c >>$ $null} else {$LASTEXITCODE=50}}
      if ($LASTEXITCODE -eq 50) {
        Start-Process -FilePath $ib1DISMUrl
        write-error "Si le problème vient de la version de DISM, merci de l'installer depuis la fenetre de navigateur ouverte (installer localement et choisir les 'Deployment Tools' uniquement." -Category InvalidResult
        dismount-vhd $vhdpath
        break}
      elseif ($LASTEXITCODE -ne 0) {
        write-warning "Problème pendant le changemement de langue de la VM '$($VM2switch.name)'. Merci de vérifier!' (Détail de l'erreur ci-dessous, utilisez éventuellement les checkpoint pour annuler complètement)."
        write-output $error|select-object -last 1}
      write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Démontage du disque."
      dismount-vhd $vhdpath
      Start-Sleep 1}
    if (-not $noCheckpoint) {
      $prevSnap=Get-VMSnapshot -VMName $($VM2switch.name) -name "ib1SwitchFR-Après"
      if ($prevSnap -ne $null) {write-error 'Un checkpoint nommé "ib1SwitchFR-Après" existe déja sur la VM "$($VM2switch.name)"';break}
      write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Création du checkpoint ib1SwitchFR-Après."
      Checkpoint-VM -VM $VM2switch -SnapshotName "ib1SwitchFR-Après"}
    write-progress -Activity "Traitement de $($VM2switch.name)" -complete}}}}

function test-ib1VMNet {
<#
.SYNOPSIS
Cette commande permet de tester si les VMs sont bien connectées aux réseaux virtuels de l'hôte Hyper-V.
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

function connect-ib1VMNet {
<#
.SYNOPSIS
Cette commande permet de mettre en place les prérequis réseau sur la machine Hyper-V Hôte.
(Une et une seule carte réseau physique doit être connectée au réseau)
.PARAMETER externalNetworkname
Nom ("External Network" par défaut) du réseau virtuel qui sera connecté au réseau externe
.EXAMPLE
connect-ib1VMNet "External Network"
Creer un réseau virtuel nomme "External Network" et le connecte a la carte reseau physique branchée (ou Wi-Fi connectée).
#>
[CmdletBinding(
DefaultParameterSetName='externalNetworkName')]
PARAM(
[parameter(Mandatory=$false,ValueFromPipeLine=$true,HelpMessage='Nom du réseau virtuel a connecter au réseau externe.')]
[string]$externalNetworkname='External Network')
get-ib1elevated $true
compare-ib1PSVersion "4.0"
$extNic=Get-NetIPAddress -AddressFamily IPv4 -AddressState Preferred -PrefixOrigin Dhcp|Get-NetAdapter
if ($extNic.PhysicalMediaType -eq "Unspecified") {
  if ((Get-VMSwitch $externalNetworkname  -switchtype External -ErrorAction SilentlyContinue).NetAdapterInterfaceDescription -eq (Get-NetAdapter -Physical|where-object status -eq up).InterfaceDescription) {
    Write-warning "La configuration réseau externe est déjà correcte"
    break}
  else {
    Write-Warning "La carte réseau est déja connectée a un switch virtuel. Suppression!"
    $switch2Remove=Get-VMSwitch -SwitchType External|where-object {$extNic.name -like '*'+$_.name+'*'}
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

function set-ib1TSSecondScreen {
<#
.SYNOPSIS
Cette commande permet de basculer l'écran distant d'une connexion RDP sur l'écran secondaire (seuls 2 écrans gérés).
.PARAMETER TSCFilename
Nom (obligatoire) du fichier .rdp dont la configuration par la présente commande doit être modifiée
.EXAMPLE
set-ib1TSSecondScreen "c:\users\ib\desktop\myremoteVM.rdp"
Modifiera le fichier indiqué pour que l'affichage de la machine distante se fasse sur le second écran.
#>
[CmdletBinding(
DefaultParameterSetName='TSCFilename')]
PARAM(
[parameter(Mandatory=$true,ValueFromPipeLine=$true,HelpMessage='Nom du fichier RDP a modifier.')]
[string]$TSCFilename)
begin {compare-ib1PSVersion "4.0"}
process {
if (Test-Path $TSCFilename) {
  $oldFile=Get-Content $TSCFilename
  $newFile=@()
  Add-Type -AssemblyName System.Windows.Forms
  $Monitors = [System.Windows.Forms.Screen]::AllScreens
  foreach ($fileLine in $oldFile){
    if ($fileLine -ilike '*winposstr*') {
      $newFile+="$($fileLine.split(",")[0]),$($fileLine.split(",")[1]),$($Monitors[1].WorkingArea.X),$($Monitors[1].WorkingArea.Y),$($Monitors[1].WorkingArea.X+$Monitors[1].Bounds.Width),$($Monitors[1].WorkingArea.Y+$Monitors[1].Bounds.Height)"}
    else {$newFile+=$fileLine}}
  Set-Content $TSCFilename $newFile}
else {write-error "Le fichier '$TSCFilename' est introuvable" -Category ObjectNotFound;break}
}}

function import-ib1TrustedCertificate {
<#
.SYNOPSIS
Cette commande permet d'importer un certificat depuis une URL afin de l'ajouter aux racines de confiance de l'utilisateur en cours.
.PARAMETER CertificateUrl
Chemin (obligatoire, certificat plateformes Mars si omis) complet du certificat .cer à télécharger
.EXAMPLE
import-ib1TrustedCertificate "http://mars.ib-formation.fr/marsca.cer"
Importera le certificat mentionné dans le magasin des certificat de confiance de l'utilisateur actuel.
#>
[CmdletBinding(
DefaultParameterSetName='CertificateUrl')]
PARAM(
[parameter(ValueFromPipeLine=$false,HelpMessage='Url du certificat à importer')]
[string]$CertificateUrl='')
begin {compare-ib1PSVersion "4.0";get-ib1elevated $true}
process {
if ($CertificateUrl -eq '') {$CertificateUrl='http://mars.ib-formation.fr/marsca.cer'}
$fileName=split-path $CertificateUrl -leaf
try {invoke-webrequest $CertificateUrl -OutFile "$($env:USERPROFILE)\downloads\$fileName" -ErrorAction stop}
catch {
  write-error "URL incrorrecte, le fichier '' est introuvable" -Category ObjectNotFound
  break}
Import-Certificate -FilePath "$($env:USERPROFILE)\downloads\$fileName" -CertStoreLocation Cert:\localmachine\root -Confirm:$false
}}

#######################
#  Gestion du module  #
#######################
#Set-Alias reset reset-ib1VM
#Set-Alias vhdBoot set-ib1VhdBoot
Export-moduleMember -Function reset-ib1VM,set-ib1VhdBoot,remove-ib1VhdBoot,switch-ib1VMFr,test-ib1VMNet,connect-ib1VMNet,set-ib1TSSecondScreen,import-ib1TrustedCertificate
#Export-ModuleMember -Alias reset,vhdBoot
