###########################################################
#                      Variables globales                 #
###########################################################
#
$ib1DISMUrl="https://msdn.microsoft.com/en-us/windows/hardware/dn913721(v=vs.8.5).aspx"
$ib1DISMPath='C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\dism.exe'
$driverFolder='C:\Dell'

function compare-ib1PSVersion ($ibVersion='4.0') {
if ($PSVersionTable.PSCompatibleVersions -notcontains $ibVersion) {
  write-warning "Attention, script  fonctionnant au mieux avec Powershell $ibVersion"}}

function get-ib1elevated ($ibElevationNeeded=$false) {
if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{ if (-not $ibElevationNeeded) { Set-PSRepositery PSGallery -InstallationPolicy Trusted;return $true}}
else {
if ($ibElevationNeeded) {
  write-error "Attention, commande à utiliser en tant qu'administrateur" -Category AuthenticationError; break}
else { return $false}}}

function start-ib1VMWait ($SWVmname) {
  if ((get-vm $SWVmname).state -ne "Running") {
    Start-VM $SWVmname
    while ((get-vm $SWVmname).heartbeat -notlike '*ok*') {
      write-progress -Activity "Démarrage de $SWVmname" -currentOperation "Attente de signal de démarrage réussi de la VM '$((get-vm $SWVmname).heartbeat)'"
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

function set-ib1VMCheckpointType {
<#
.SYNOPSIS
Cette commande permet de modifier le type de checkpoint sur les VMs pour le passer en "Standard".
(pratique pour les environnement ou l'on souhaite (re)démarrer des VMs dans un était précis -enregistrées- )
.PARAMETER VMName
Nom de la VMs à modifier. si ce parametre est omis toutes les VMs qui sont en checkpoint "Production" seront passées en "standard".
.EXAMPLE
set-ib1VMCheckpointType -VMName 'lon-dc1'
Modifie le type de checkpoint de la VM 'lon-dc1'.
.EXAMPLE
set-ib1VMCheckpointType
Modifie le type de checkpoints pour toutes les VMs trouvées sur l'hyperviseur.
#>
[CmdletBinding(
DefaultParameterSetName='VMName')]
PARAM(
[string]$VMName)
begin{get-ib1elevated $true; compare-ib1PSVersion "4.0"}
process {
$VMs2Set=get-ib1VM $VMName
foreach ($VM2Set in $VMs2Set) {
  Get-VM -VMName $VM2Set.vmname|Set-VM -checkpointType Standard}}
end {Write-Output "Fin de l'opération"}}

function reset-ib1VM {
<#
.SYNOPSIS
Cette commande permet de rétablir les VMs du serveur Hyper-v à  leur dernier checkpoint.
.PARAMETER VMName
Nom de la VMs à  retablir. si ce parametre est omis toutes les VMs seront rétablies
.PARAMETER keepVMUp
N'arrete pas les VMs allumées avant de les rétablir
.PARAMETER poweroff
Eteind la machine hôte après avoir rétabli toutes les VMs.
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
[string]$VMName,
[switch]$powerOff=$false)
begin{get-ib1elevated $true; compare-ib1PSVersion "4.0"}
process {
$VMs2Reset=get-ib1VM $VMName
foreach ($VM2reset in $VMs2Reset) {
  if ($snapshot=Get-VMSnapshot -VMName $VM2reset.vmname|sort-object creationtime|select-object -last 1 -ErrorAction SilentlyContinue) {
    if (-not $keepVMUp -and $VM2reset.state -ieq 'running') {
      Write-Debug "Arrêt de la VM $($VM2reset.vmname)."
      stop-vm -VMName $VM2reset.vmname -confirm:$false -turnOff}
    Write-Debug "Restauration du snapshot $($snapshot.Name) sur la VM $($VM2reset.vmname)."
    Restore-VMSnapshot $snapshot -confirm:$false}
  else {write-debug "La VM $($VM2reset.vmname) n'a pas de snapshot"}}}
  end {
  Write-Output "Fin de l'opération"
  if ($powerOff) {stop-computer -force}}}

function mount-ib1VhdBoot {
<#
.SYNOPSIS
Cette commande permet de monter le disque virtuel contenu dans le fichier VHD et de rajouter le démarrage sur la partition non réservée contenue au BCD.
.PARAMETER VHDFile
Nom du fichier VHD contenant le disque virtuel à monter.
.PARAMETER restart
Redémarre l'ordinateur à la fin du script (inactif par défaut)
.PARAMETER noDrivers
N'installe pas les drivers présents dans le dossier de référence dans le disque virtuel
.PARAMETER copyFolder
Chemin d'un dossier de la machine hôte à copier dans le VHD pendant l'opération (sera copié dans un dossier \ib)
.EXAMPLE
mount-ib1vhboot -VHDFile 'c:\program files\microsoft learning\base\20470b-lon-host1.vhd' -copyFolder c:\ib
Monte la partition contenue dans le fichier VHD fourni. et y copie le contenu du dossier c:\ib
.EXAMPLE
mount-ib1vhboot -VHDFile 'c:\program files\microsoft learning\base\20470b-lon-host1.vhd' -restart
Monte la partition contenue dans le fichier VHD fourni et redémarre dessus.
#>
[CmdletBinding(
DefaultParameterSetName='VHDFile')]
PARAM(
[parameter(Mandatory=$true,ValueFromPipeLine=$true,HelpMessage='Fichier VHD contenant le disque virtuel à monter (avec une partition système)')]
[string]$VHDfile,
[switch]$restart=$false,
[switch]$noDrivers=$false,
[string]$copyFolder='')
begin{get-ib1elevated $true; compare-ib1PSVersion "4.0"}
# Attacher un VHD et le rajouter au menu de démarrage
process {
write-debug "`$VHDfile=$VHDfile"
if (($copyFolder -ne '') -and -not (test-path $copyFolder)) {
  write-error "Le dossier '$copyFolder' n'existe pas, merci de vérifier !"
  break}
try { Mount-VHD -Path $vhdFile -ErrorAction stop }
catch {
  write-error "Impossible de monter le disque virtuel contenu dans le fichier $VHDFile." -Category ObjectNotFound
  break}
$dLetter=(get-disk|where-object Model -like "*virtual*"|Get-Partition|Get-Volume|where-object {$_.filesystemlabel -ine "system reserved" -and $_.filesystemlabel -ine "réservé au système"}).driveletter+":"
write-debug "Disque(s) de lecteur Windows trouvé(s) : $dLetter"
if (($dLetter.Count -ne 1) -or ($dLetter -eq ':')) {
 write-error 'Impossible de trouver un (et un seul) disque virtuel monté qui contienne une unique partition non réservée au systeme.' -Category ObjectNotFound
 break}
bcdboot $dLetter\windows /l fr-FR >> $null
if ((Test-Path $driverFolder) -and -not $noDrivers) {dism /image:$dLetter\ /add-driver /driver:$driverFolder /recurse}
if ($copyFolder -ne '') {Copy-Item $copyFolder\* $dLetter\ib}
bcdedit /set '{default}' Description ([io.path]::GetFileNameWithoutExtension($VHDFile)) >> $null
bcdedit /set '{default}' hypervisorlaunchtype auto
Write-Output 'BCD modifié'
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
get-disk|where-object Model -like "*virtual*"|foreach-object {write-debug $_;get-partition|dismount-vhd -erroraction silentlycontinue}
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
.PARAMETER VHDFile
Nom du fichier VHD de disque Virtuel sur lequel agir (permet de changer la langue même si le VHD n'est pas monté dans une VM)
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
[string]$VHDFile='',
[switch]$noCheckpoint=$false)
begin{get-ib1elevated $true; compare-ib1PSVersion "4.0"}
process {
if ($VHDFile -ne '') {
  if ($VMName -ne '') {
    write-Error "Les paramètres '-VHDFile' et '-VMName' ne peuvent être utilisés ensemble, merci de lancer 2 commandes distinctes"
    break}
  $testMount=$null
  mount-vhd -path $VHDFile -NoDriveLetter -passthru -ErrorVariable testMount -ErrorAction SilentlyContinue|get-disk|Get-Partition|where-object isactive -eq $false|Set-Partition -newdriveletter Z
  if ($testMount -eq $null) {
    Write-Error "Impossible de monter le disque dur... $VHDFile, merci de vérifier!"
    break}
  DISM /image:z: /set-allIntl:en-US /set-inputLocale:0409:0000040c >>$ $null
  if ($LASTEXITCODE -eq 50) {
    if (Test-Path $ib1DISMPath) {& $ib1DISMPath /image:z: /set-allIntl:en-US /set-inputLocale:0409:0000040c >>$ $null} else {$LASTEXITCODE=50}}
  if ($LASTEXITCODE -eq 50) {
    Start-Process -FilePath $ib1DISMUrl
    write-error "Si le problème vient de la version de DISM, merci de l'installer depuis la fenetre de navigateur ouverte (installer localement et choisir les 'Deployment Tools' uniquement." -Category InvalidResult
    dismount-vhd $vhdpath
    break}
  elseif ($LASTEXITCODE -ne 0) {
    write-warning "Problème pendant le changemement de langue du disque '$VHDFile'. Merci de vérifier!' (Détail de l'erreur ci-dessous)."
    write-output $error|select-object -last 1}
  dismount-vhd $VHDFile
  break}
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
        $prevSnap=Get-VMSnapshot -VMName $($VM2switch.name) -name "ib1SwitchFR-Avant" -erroraction silentlycontinue
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
      $prevSnap=Get-VMSnapshot -VMName $($VM2switch.name) -name "ib1SwitchFR-Après"  -erroraction silentlycontinue
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

function copy-ib1VM {
<#
.SYNOPSIS
Cette commande permet de copier une machine virtuelle existante en en créant une nouvelle basée sur le disque de l'originale.
(Ne fonctionne que sur les VMs éteintes au moment ou la commande est lancée)
.PARAMETER VMName
Nom de la VM à copier (agit sur toutes les VMs si paramêtre non spécifié)
.PARAMETER VMsuffix
suffixe à rajouter après le nom de la VM résultat (sera séparé du nom de la VM par un tiret "-")
.PARAMETER VMprefix
suffixe à rajouter avant le nom de la VM résultat (sera séparé du nom de la VM par un tiret "-")
.PARAMETER NoCheckpoint
Un Checkpoint Hyper-V sera créé à l'issue de la copie : utiliser le paramètre "-noCheckpoint" pour l'éviter
.EXAMPLE
copy-ib1VM lon-dc1 -VMsuffix '2'
Crée une nouvelle instance de la VM qui sera nommée "lon-dc1-2"
#>
[CmdletBinding(
DefaultParameterSetName='VMName')]
PARAM(
[string]$VMName='',
[string]$VMsuffix='',
[string]$VMprefix='',
[switch]$noCheckpoint=$false)
begin{get-ib1elevated $true; compare-ib1PSVersion "4.0"; if ($VMsuffix -eq '' -and $VMprefix -eq '') {write-error "Attention, commande nécessitant soit un préfixe, soit un suffixe pour le nom de la VM clonée." -Category SyntaxError; break}}
process {
if ($VMsuffix -ne '') {$VMsuffix="-$VMsuffix"}
if ($VMprefix -ne '') {$VMprefix="-$VMprefix"}
$VMs2copy=get-ib1VM $VMName
foreach ($VM2copy in $VMs2copy) {
  if ($VM2copy.state -ine 'off') {echo "La VM $($VM2copy.name) n'est pas éteinte et ne sera pas traitée"}
  else {
    Write-Debug "Copie de la VM $($VM2copy.name)"
    write-progress -Activity "Traitement de $($VM2copy.name)" -currentOperation "Création des dossiers."
    $vmCopyName="$VMprefix$($VM2copy.name)$VMsuffix"
    $vmCopyPath="$(split-path -path $VM2copy.path -parent)\$($vmCopyName)"
    New-Item $vmCopyPath -ItemType directory -ErrorAction SilentlyContinue -ErrorVariable createDir >> $null
    New-Item "$vmCopyPath\Virtual Hard Disks" -ItemType directory -ErrorAction SilentlyContinue >> $null
    foreach ($VHD2copy in $VM2copy.HardDrives) {
      write-progress -Activity "Traitement de $($VM2copy.name)" -currentOperation "Copie du dossier $(split-path -path $VHD2copy.path -parent)."
      Copy-Item "$(split-path -path $VHD2copy.path -parent)\" $vmCopyPath -Recurse -ErrorAction SilentlyContinue}
    $newVMdrive0 = "$vmCopyPath\$(split-path (split-path -path $vm2copy.HardDrives[0].path -parent) -leaf)\$(split-path -path $VM2copy.HardDrives[0].path -leaf)"
    $newVM=new-vm -Name $vmCopyName -VHDPath $newVMdrive0 -MemoryStartupBytes ($VM2copy.MemoryMinimum*8) -Path $(split-path -path $vmCopyPath -Parent) 
    if ($VM2copy.ProcessorCount -gt 1) {
      Set-VMProcessor -VMName $vmCopyName -Count $VM2copy.ProcessorCount}
    if ($VM2copy.DynamicMemoryEnabled) {
      $VM2copyMemory=Get-VMMemory $VM2copy.name
      Set-VMMemory $vmCopyName -DynamicMemoryEnabled $true -MinimumBytes $VM2copyMemory.Minimum -StartupBytes $VM2copyMemory.Startup -MaximumBytes $VM2copyMemory.Maximum -Buffer $VM2copyMemory.Buffer -Priority $VM2copyMemory.Priority}
    $vm2copyDVD=(Get-VMDvdDrive -VMName $VM2copy.name)[0]
    Set-VMDvdDrive $vmCopyName -Path $vm2copyDVD.Path -ControllerNumber $vm2copyDVD.ControllerNumber -ControllerLocation $vm2copyDVD.ControllerLocation
    if ($VM2copy.DVDDrives.count -gt 1) {
      $vm2copyDVDs=Get-VMDvdDrive -VMName $VM2copy.name
      for ($i=1;$i -lt $VM2copy.DVDDrives.count;$i++) {
        $vm2copyDVD=(Get-VMDvdDrive -VMName $VM2copy.name)[$i]
        Add-VMDvdDrive $vmCopyName -Path $vm2copyDVD.Path -ControllerNumber $vm2copyDVD.ControllerNumber -ControllerLocation $vm2copyDVD.ControllerLocation}}
    if ($VM2copy.HardDrives.Count -gt 1) {
      for ($i=1;$i -lt $VM2copy.HardDrives.Count;$i++) {
        $newVMdrive="$vmCopyPath\$(split-path (split-path -path $VM2copy.HardDrives[$i].path -parent) -leaf)\$(split-path -path $VM2copy.HardDrives[$i].path -leaf)"
        Add-VMHardDiskDrive -VMName $vmCopyName -Path $newVMdrive -ControllerType $vm2copy.HardDrives[$i].ControllerType -ControllerNumber $vm2copy.HardDrives[$i].ControllerNumber -ControllerLocation $vm2copy.HardDrives[$i].ControllerLocation}}
    if ($VM2copy.NetworkAdapters[0].Connected) {
      Connect-VMNetworkAdapter -VMName $vmCopyName -SwitchName $VM2copy.NetworkAdapters[0].SwitchName}
    else {
      Disconnect-VMNetworkAdapter -VMName $vmCopyName}
    if ($VM2copy.NetworkAdapters.Count -gt 1) {
      for ($i=1;$i -lt $VM2copy.NetworkAdapters.Count;$i++) {
        if ($VM2copy.NetworkAdapters[$i].connected) {
          Add-VMNetworkAdapter -VMName $vmCopyName -SwitchName $VM2copy.NetworkAdapters[$i].SwitchName}
        else {
          Add-VMNetworkAdapter -VMName $vmCopyName}}
          }}
  if (-not $noCheckpoint) {
      write-progress -Activity "Traitement de $($VM2copy.name)" -currentOperation "Création du checkpoint ib1Copy"
      Checkpoint-VM -VM $newVM -SnapshotName "ib1Copy"}
  Write-Warning 'Pensez à mettre à jour la configuration IP des cartes réseau qui ont été créées dans la machine virtuelle.'}}}

function repair-ib1VMNetwork {
<#
.SYNOPSIS
Cette commande permet de vérifier l'état de la carte réseau d'une VM et, le cas échéant, de relancer cette carte.
Cette commande est particulièrement utile sur un DC première machine virtuelle à démarrer.
Prérequis : cette commande utilise du Powershell Direct et ne fonctionne que si la VM est en Windows version 8/2012 au minimum.
.PARAMETER VMName
Nom de la VMs à vérifier (si ce paramètre est omis, toutes les VMs allumées seront vérifiées - Attention à l'ordre).
.PARAMETER userName
Nom d'uitlisateur (sous la forme 'Domain\user' si nécessaire).
.PARAMETER userPass
Mot de passe de l'utilisateur, (sera demandé si non fourni dans la commande)
.EXAMPLE
repair-ib1VMNetwork -VMName 'lon-dc1' -username 'adatum\administrator' -userpass 'Pa55w.rd'
Se connecte sur la VM lon-dc1 pour vérifier l'état de sa carte réseau et la relance si elle ne s'est pas découverte en réseau de domaine.
#>
[CmdletBinding(
DefaultParameterSetName='VMName')]
PARAM(
[string]$VMName,
[parameter(Mandatory=$true,ValueFromPipeLine=$true,HelpMessage="Nom de connexion de l'administrateur de la VM.")]
[string]$userName,
[string]$userPass='')
begin{get-ib1elevated $true; compare-ib1PSVersion "5.0"}
process {
$VMs2Repair=get-ib1VM $VMName
if ($userPass -eq '') {$userPass2=read-host "Mot de passe de '$userName'" -AsSecureString} else {$userPass2=ConvertTo-SecureString $userPass -AsPlainText -Force}
$cred=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userName,$userPass2
foreach ($VM2repair in $VMs2Repair) {
  if ((get-vm $VM2repair.name).heartbeat -notlike '*OK*') {Write-Warning "La VM '$($VM2repair.name)' n'est pas dans un état démarré correct, son réseau ne sera pas vérifié."}
  else {
    $netStatus=''
    $warningDisplay=$true
    while ($netStatus -notlike '*domain*') {
      $netStatus=(Invoke-Command -VMName $VM2repair.name -Credential $cred -ScriptBlock {(Get-NetConnectionProfile).NetworkCategory}).value
      if ($netStatus -notlike '*domain*') {
        if ($warningDisplay) {
          Write-Warning "Le réseau de la VM '$($VM2repair.name)' n'est pas en mode domaine, redémarrage de la(des) carte(s)."
          Start-Sleep -s 10
          $warningDisplay=$false}
        Invoke-Command -VMName $VM2repair.name -Credential $cred -ScriptBlock{get-netadapter|restart-netadapter}}}}}}
  end {Write-Output "Fin de l'opération"}}

function start-ib1SavedVMs {
<#
.SYNOPSIS
Cette commande permet de démarrer les VMs qui sont en état "Enregistré" sur un un serveur Hyper-V
.PARAMETER First
Nom de la première VMs à démarrer. si ce paramètre est fourni, la commande attendra que cette VM soit correctement démarrée avant de démarrer les suivantes.
.PARAMETER FirstRepairNet
Vérifie que le réseau de la première VM démarrée (spécifié par le paramètre "First") est bien en mode "Domaine" avant de démarrer les autres.
.PARAMETER DontRevert
Ne rétablit pas toutes les VMs de l'hôte avant de démarrer celles qui sont Enregistrées
.EXAMPLE
start-ib1SavedVMs -First lon-dc1 -FirstRepairNet
Rétablit toutes les VMs avant de démarrer celles qui sont su un checkpoint actif, en commençant par 'lon-dc1'
#>
[CmdletBinding(
DefaultParameterSetName='First')]
PARAM(
[switch]$DontRevert=$false,
[string]$First='',
[switch]$FirstRepairNet=$false)
begin{get-ib1elevated $true; compare-ib1PSVersion "4.0"}
process {
if ($FirstRepairNet -and $First -eq $null) {Write-Error "Le paramètre '-FirstRepairNet' ne peut être passé sans le paramètre '-First'" -Category SyntaxError; break}
if ($First -ne '') {$FirstVM2start=get-ib1VM $First}
if ($DontRevert -eq $false) {
  Write-Debug "Rétablissement des VMs avant démarrage"
  reset-ib1VM}
if ($First -ne '') {start-ib1VMWait ($First)}
$VMs2Start=get-ib1VM ('')
foreach ($VM2start in $VMs2start) {
  if ($VM2Start.state -like '*saved*') {
    write-debug "Démarrage de la VM '$($VM2Start.name)'."
    start-VM $VM2start.name}}}}
    
function new-ib1Shortcut {
<#
.SYNOPSIS
Cette commande permet de créer un raccourci sur le bureau.
.PARAMETER File
Nom et chemin complet du fichier pointé par le raccourci créé
.PARAMETER URL
Adresse Internet pointée par le raccourci créé
.PARAMETER Title
Titre du raccourci (si non mentionné, prendra le titre du site web pointé ou le nom du fichier)
.EXAMPLE
new-ib1Shortcut -URL 'https://www.ib-formation.fr'
Crée un raccourci sur le bureau qui sera nommé en fonction du titre du site web
#>
[CmdletBinding(
DefaultParameterSetName='URL')]
PARAM(
[string]$File='',
[uri]$URL='',
[string]$title='')
begin{get-ib1elevated $true; compare-ib1PSVersion "4.0"}
process {
if ((($File -eq '') -and ($URL -eq '')) -or (($File -ne '') -and ($URL -ne ''))) {Write-Error "Cette commande nécessite un et un seul paramètre '-File' ou '-URL'" -Category SyntaxError; break}
if ($URL -ne '') {
  if ($title -eq '') {
    write-debug "Recherche du titre du site Web pou nommer le raccourci"
    $title=((Invoke-WebRequest $targetUrl).parsedHtML.getElementsByTagName('title')[0].text) -replace ':','-' -replace '\\','-'}
  $title=$title+'.url'
  $target=$URL.ToString}  
if ($File -ne '') {
  if ($title -eq '') {
    write-debug "Récupération du nom du fichier pour nommer le raccourci"
    
    
    
    $title='test'}
  $title=$title+'.lnk'
  $target=$File}
$WScriptShell=new-object -ComObject WScript.Shell
$shortcut=$WScriptShell.createShortCut("$env:Public\Desktop\$title")
$shortcut.TargetPath=$target
$shortcut.save()}    

#######################
#  Gestion du module  #
#######################
Set-Alias ibreset reset-ib1VM
Set-Alias set-ib1VhdBoot mount-ib1VhdBoot
Export-moduleMember -Function new-ib1Shortcut,Reset-ib1VM,Mount-ib1VhdBoot,Remove-ib1VhdBoot,Switch-ib1VMFr,Test-ib1VMNet,Connect-ib1VMNet,Set-ib1TSSecondScreen,Import-ib1TrustedCertificate, Set-ib1VMCheckpointType, Copy-ib1VM, repair-ib1VMNetwork, start-ib1SavedVMs
Export-ModuleMember -Alias set-ib1VhdBoot,ibreset
