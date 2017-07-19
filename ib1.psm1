###########################################################
#                      Variables globales                 #
###########################################################
#
$global:ib1Version='1.0.0.8'
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
  write-error "Attention, cette commande nécessite d'être executée en tant qu'administrateur"; break}
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
    write-error "Impossible de trouver des machines virtuelles sur ce Windows."
    break}}
  else {
  try { $gResult=Get-VM $gVMName -ErrorAction stop }
  catch {
  write-error "Impossible de trouver une machine virtuelle nommée $gVMName."
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
  write-error "Impossible de monter le disque virtuel contenu dans le fichier $VHDFile."
  break}
$dLetter=(get-disk|where friendlyname -ilike "*microsoft*"|Get-Partition|Get-Volume|where {$_.filesystemlabel -ine "system reserved" -and $_.filesystemlabel -ine "réservée au système"}).driveletter+":"
write-debug "Disque(s) de lecteur Windows trouvé(s) : $dLetter"
if ($dLetter.Count -ne 1) {
 write-error 'Impossible de trouver un disque virtuel monté qui contienne une unique partition non réservée au système.'
 break}
bcdboot $dLetter\windows /l fr-FR >> $null
bcdedit /set '{default}' Description ([io.path]::GetFileNameWithoutExtension($VHDFile)) >> $null
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
.PARAMETER VMName
Nom de la VM sur laquelle agir
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
[switch]$restart=$false)
begin{get-ib1elevated $true; compare-ib1PSVersion "4.0"}
process {
$VMs2switch=get-ib1VM $VMName
foreach ($VM2switch in $VMs2switch) {
  if ($VM2switch.state -ine 'off') {echo "La VM $($VM2switch.name) n'est pas éteinte et ne sera pas traitée"}
  else {
    Remove-VMSnapshot -vm $VM2switch -ErrorAction SilentlyContinue
    Checkpoint-VM -VM $VM2switch -SnapshotName "Original"
    Write-Debug "Changement des paramètres lingustiques de la VM $($VM2switch.name)"
    write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Montage du disque virtuel."
    $vhdPath=($VM2switch|Get-VMHardDiskDrive|where {$_.ControllerNumber -eq 0 -and $_.controllerLocation -eq 0}).path
    $testMount=$null
    mount-vhd -path $vhdPath -NoDriveLetter -passthru -ErrorVariable testMount -ErrorAction SilentlyContinue|get-disk|Get-Partition|where isactive -eq $false|Set-Partition -newdriveletter Z
    if ($testMount -eq $null) {Write-Error "Impossible de monter le disque dur... de la VM $($VM2switch.name)"}
    else {
      write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Changement des options linguistiques."
      & $ib1DISMPath /image:z: /set-allIntl:en-US /set-inputLocale:0409:0000040c
      if ($LASTEXITCODE -ne 0) {
        Start-Process -FilePath $ib1DISMUrl
        write-error "Si le problème vient de la version de DISM, merci de l'installer depuis la fenêtre de navigateur ouverte, avant de redémarrer la machine"
        dismount-vhd $vhdpath
        break}
      write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Démontage du disque."
      dismount-vhd $vhdpath
      Start-Sleep 1}
    write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Snapshot."
    Checkpoint-VM -VM $VM2switch -SnapshotName "Clavier FR"
    write-progress -Activity "Traitement de $vmName" -complete}}
}}
