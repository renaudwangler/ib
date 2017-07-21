###########################################################
#                      Variables globales                 #
###########################################################
#
$global:ib1Version='1.0.1.5'
$global:ib1DISMUrl="https://msdn.microsoft.com/en-us/windows/hardware/dn913721(v=vs.8.5).aspx"
$global:ib1DISMPath='C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\dism.exe'

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
      write-progress -Activity "demarrage de $SWVmname" -currentOperation "Attente de signal de demarrage reussi de la VM"
      start-sleep 2}
    write-progress -Activity "Demarrage de $SWVmname" -complete}}

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

function global:reset-ib1VM {
<#
.SYNOPSIS
Cette commande permet de retablir les VMs du serveur Hyper-v a leur dernier checkpoint.
.PARAMETER VMName
Nom de la VMs Ã  retablir. si ce parametre est omis toutes les VMs seront retablies
.PARAMETER keepVMUp
N'arrete pas les VMs allumee avant de les retablir
.EXAMPLE
reset-ib1VM -VMName 'lon-dc1'
Retablit la VM 'lon-dc1' a son dernier point de controle.
.EXAMPLE
reset-ib1VM -keepVMUp
Retablir toutes les VMS a leur dernier point de controle, sans les eteindre.
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
      Write-Debug "ArrÃªt de la VM $($VM2reset.vmname)."
      stop-vm -VMName $VM2reset.vmname -confirm:$false}
    Write-Debug "Restauration du snapshot $($snapshot.Name) sur la VM $($VM2reset.vmname)."
    Restore-VMSnapshot $snapshot -confirm:$false}
  else {write-debug "La VM $($VM2reset.vmname) n'a pas de snapshot"}}}
  end {echo "Fin de l'operation"}}

function global:set-ib1VhdBoot {
<#
.SYNOPSIS
Cette commande permet de monter le disque virtuel contenu dans le fichier VHD et de rajouter le demarrage sur la partition non reservee contenue au BCD.
.PARAMETER VHDFile
Nom du fichier VHD contenant le disque virtuel a monter.
.PARAMETER restart
Redemarre l'ordinateur a la fin du script (inactif par defaut)
.EXAMPLE
set-ib1vhboot -VHDFile 'c:\program files\microsoft learning\base\20470b-lon-host1.vhd
Monte la partition contenue dans le fichier VHD fourni.
.EXAMPLE
set-ib1vhboot -VHDFile 'c:\program files\microsoft learning\base\20470b-lon-host1.vhd -restart
Monte la partition contenue dans le fichier VHD fourni et redemarre dessus.
#>
[CmdletBinding(
DefaultParameterSetName='VHDFile')]
PARAM(
[parameter(Mandatory=$true,ValueFromPipeLine=$true,HelpMessage='Fichier VHD contenant le disque virtuel a monter (avec une partition systeme)')]
[string]$VHDfile,
[switch]$restart=$false)
begin{get-ib1elevated $true; compare-ib1PSVersion "4.0"}
# Attacher un VHD et le rajouter au menu de demarrage
process {
write-debug "`$VHDfile=$VHDfile"
try { Mount-VHD -Path $vhdFile -ErrorAction stop }
catch {
  write-error "Impossible de monter le disque virtuel contenu dans le fichier $VHDFile." -Category ObjectNotFound
  break}
$dLetter=(get-disk|where friendlyname -ilike "*microsoft*"|Get-Partition|Get-Volume|where {$_.filesystemlabel -ine "system reserved" -and $_.filesystemlabel -ine "réservée au système"}).driveletter+":"
write-debug "Disque(s) de lecteur Windows trouve(s) : $dLetter"
if ($dLetter.Count -ne 1) {
 write-error 'Impossible de trouver un disque virtuel monte qui contienne une unique partition non reservee au systeme.' -Category ObjectNotFound
 break}
bcdboot $dLetter\windows /l fr-FR >> $null
bcdedit /set '{default}' Description ([io.path]::GetFileNameWithoutExtension($VHDFile)) >> $null
bcdedit /set '{default}' hypervisorlaunchtype auto
echo 'BCD modifie'
if ($restart) {Restart-Computer}}}

function global:remove-ib1VhdBoot {
<#
.SYNOPSIS
Cette commande permet de supprimer l'entree par defaut du BCD et de demonter tous les disques virtuels montes sur la machine.
.PARAMETER restart
Redemarre l'ordinateur Ã  la fin du script (inactif par defaut)
.EXAMPLE
remove-ib1vhboot -restart
supprimer l'entree par defaut du BCD et redemarre la machine.
#>
[CmdletBinding(
DefaultParameterSetName='restart')]
PARAM(
[switch]$restart=$false)
begin{get-ib1elevated $true; compare-ib1PSVersion "4.0"}
process {
get-disk|where FriendlyName -ilike "*microsoft*"|foreach {write-debug $_;get-partition|dismount-vhd -erroraction silentlycontinue}
write-debug "Supression de l'entree {Default} du BCD"
bcdedit /delete '{default}' >> $null
echo 'BCD modifie'
if ($restart) {Restart-Computer}}}

function global:switch-ib1VMFr {
<#
.SYNOPSIS
Cette commande permet de changer le clavier d'une marchine virtuelle en Francais.
(Ne fonctionne que sur les VMs eteinte au moment ou la commande est lancee)
.PARAMETER VMName
Nom de la VM sur laquelle agir (agit sur toutes les VMs si parametre non specifie)
.PARAMETER noCheckpoint
Ne cree pas les points de controle sur la VM avant et apres action
.EXAMPLE
switch-ib1VMFr
Change le clavier de la VM en Francais.
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
  if ($VM2switch.state -ine 'off') {echo "La VM $($VM2switch.name) n'est pas eteinte et ne sera pas traitee"}
  else {
    Write-Debug "Changement des parametres lingustiques de la VM $($VM2switch.name)"
    write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Montage du disque virtuel."
    $vhdPath=($VM2switch|Get-VMHardDiskDrive|where {$_.ControllerNumber -eq 0 -and $_.controllerLocation -eq 0}).path
    $testMount=$null
    mount-vhd -path $vhdPath -NoDriveLetter -passthru -ErrorVariable testMount -ErrorAction SilentlyContinue|get-disk|Get-Partition|where isactive -eq $false|Set-Partition -newdriveletter Z
    if ($testMount -eq $null) {Write-Error "Impossible de monter le disque dur... de la VM $($VM2switch.name)" -Category invalidResult}
    else {
      if (-not $noCheckpoint) {
        write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Creation du checkpoint ib1SwitchFR-Avant."
        Dismount-VHD $vhdPath
        Checkpoint-VM -VM $VM2switch -SnapshotName "ib1SwitchFR-Avant"
        mount-vhd -path $vhdPath -NoDriveLetter -passthru -ErrorVariable testMount -ErrorAction SilentlyContinue|get-disk|Get-Partition|where isactive -eq $false|Set-Partition -newdriveletter Z}
      write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Changement des options linguistiques."
      DISM /image:z: /set-allIntl:en-US /set-inputLocale:0409:0000040c >>$ $null
      if ($LASTEXITCODE -eq 50) {
        if (Test-Path $ib1DISMPath) {& $ib1DISMPath /image:z: /set-allIntl:en-US /set-inputLocale:0409:0000040c >>$ $null} else {$LASTEXITCODE=50}}
      if ($LASTEXITCODE -eq 50) {
        Start-Process -FilePath $ib1DISMUrl
        write-error "Si le probleme vient de la version de DISM, merci de l'installer depuis la fenetre de navigateur ouverte (installer localement et choisir les 'Deployment Tools' uniquement." -Category InvalidResult
        dismount-vhd $vhdpath
        if (-not $noCheckpoint) {
          Restore-VMSnapshot -VM $VM2switch -Name "ib1SwitchFR-Avant"
          Remove-VMSnapshot -VM $VM2switch -Name "ib1SwitchFR-Avant"}
        break}
      elseif ($LASTEXITCODE -ne 0) {
        write-warning "Probleme pendant le changemement de langue de la VM '$($VM2switch.name)'. Merci de verifier!' (Detail de l'erreur ci-dessous)."
        write-output $error|select -last 1
        if (-not $noCheckpoint) {
          Restore-VMSnapshot -VM $VM2switch -Name "ib1SwitchFR-Avant"
          Remove-VMSnapshot -VM $VM2switch -Name "ib1SwitchFR-Avant"}}
      write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Demontage du disque."
      dismount-vhd $vhdpath
      Start-Sleep 1}
    if (-not $noCheckpoint) {
      write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Creation du checkpoint ib1SwitchFR-Apres."
      Checkpoint-VM -VM $VM2switch -SnapshotName "ib1SwitchFR-Apres"}
    write-progress -Activity "Traitement de $($VM2switch.name)" -complete}}
}}

function global:test-ib1VMNet {
<#
.SYNOPSIS
Cette commande permet de tester si les VMs sont bien connectees aux reseaux virtuel de l'hote Hyper-V.
.EXAMPLE
test-ib1VMNet
Indiquera si des VMs sont branchees sur des switchs virtuels non declares.
#>
$vSwitchs=(Get-VMSwitch).name
$VMs=Get-VM
foreach ($VM in $VMs) {
  Write-progress -Activity "Verification de la configuration reseau de la VM $($VM.Name)."
  foreach ($VMnetwork in $VM.NetworkAdapters) {
    Write-progress -Activity "Verification de la configuration reseau de la VM $($VM.Name)." -CurrentOperation "Verification de la presence du switch $($VMnetwork.name)"
    if ($VMnetwork.SwitchName -notin $vSwitchs) {Write-Warning "La VM '$($VM.Name)' est branchee sur le switch virtuel '$($VMnetwork.SwitchName)' qui est introuvable. Merci de verifier !"}}
  Write-progress -Activity "Verification de la configuration reseau de la VM $($VM.Name)." -Completed}}

function global:connect-ib1VMNet {
<#
.SYNOPSIS
Cette commande permet de mettre en place les prerequis reseau sur la machine Hyper-V Hote.
(Une et une seule carte reseau physique doit etre connectee au reseau)
.PARAMETER externalNetworkname
Nom (obligatoire) du reseau virtuel qui sera connecte au reseau externe
.EXAMPLE
connect-ib1VMNet "External Network"
Creer un reseau virtuel nomme "External Network" et le connecte a la carte reseau physique branchee (ou Wi-Fi connectee).
#>
[CmdletBinding(
DefaultParameterSetName='externalNetworkName')]
PARAM(
[parameter(Mandatory=$true,ValueFromPipeLine=$true,HelpMessage='Nom du reseau virtuel a connecter au reseau externe.')]
[string]$externalNetworkname='External Network')
get-ib1elevated $true
compare-ib1PSVersion "4.0"
$extNic=Get-NetIPAddress -AddressFamily IPv4 -AddressState Preferred -PrefixOrigin Dhcp|Get-NetAdapter
if ($extNic.PhysicalMediaType -eq "Unspecified") {
  if ((Get-VMSwitch $externalNetworkname  -switchtype External -ErrorAction SilentlyContinue).NetAdapterInterfaceDescription -eq (Get-NetAdapter -Physical|where status -eq up).InterfaceDescription) {
    Write-warning "La configuration reseau externe est deja correcte"
    break}
  else {
    Write-Warning "La carte reseau est deja connectee a un switch virtuel. Suppression!"
    $switch2Remove=Get-VMSwitch -SwitchType External|where {$extNic.name -like '*'+$_.name+'*'}
    Write-Progress -Activity "Suppression de switch virtuel existant" -currentOperation "Attente pour suppression de '$($switch2Remove.name)'."
    Remove-VMSwitch -Force -VMSwitch $switch2Remove
    for ($sleeper=0;$sleeper -lt 20;$sleeper++) {
      Write-Progress -Activity "Suppression de switch virtuel existant" -currentOperation "Attente pour suppression de '$($switch2Remove.name)'." -PercentComplete ($sleeper*5)
      Start-Sleep 1}
    Write-Progress -Activity "Suppression de switch virtuel existant" -Completed}
    $extNic=Get-NetIPAddress -AddressFamily IPv4 -AddressState Preferred -PrefixOrigin Dhcp|Get-NetAdapter}
  if (Get-VMSwitch $externalNetworkname -ErrorAction SilentlyContinue) {
    Write-Warning "Le switch '$externalNetworkname' existe. Branchement sur la bonne carte reseau"
    Get-VMSwitch $externalNetworkname|Set-VMSwitch -netadaptername $extNic.Name
    start-sleep 2}
  else {
    Write-Progress -Activity "Creation du switch" -CurrentOperation "Creation du switch virtuel '$externalNetworkname' et branchement sur la carte reseau."
    New-VMSwitch -Name $externalNetworkname -netadaptername $extNic.Name >> $null
    Write-Progress -Activity "Creation du switch" -Completed}
test-ib1VMNet}

function global:set-ib1TSSecondScreen {
<#
.SYNOPSIS
Cette commande permet de basculer l'ecran distant d'une connexion RDP sur l'ecran secondaire (seuls 2 ecrans geres).
.PARAMETER TSCFilename
Nom (obligatoire) du fichier .rdp dont la configuration par la presente commande doit etre modifiee
.EXAMPLE
set-ib1TSSecondScreen "c:\users\ib\desktop\myremoteVM.rdp"
Modifiera le fichier indique pour que l'affichage de la machine distante se fasse sur le second ecran.
#>
[CmdletBinding(
DefaultParameterSetName='TSCFilename')]
PARAM(
[parameter(Mandatory=$true,ValueFromPipeLine=$true,HelpMessage='Nom du fichier RDP a modifier.')]
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

function global:import-ib1TrustedCertificate {
<#
.SYNOPSIS
Cette commande permet d'importer un certificat depuis une URL afin de l'ajouter aux racines de confiance de l'utilisateur en cours.
.PARAMETER CertificateUrl
Chemin (obligatoire) complet du certificat .rdp à télécharger
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
