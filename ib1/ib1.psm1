###########################################################
#                      Variables globales                 #
###########################################################
#
$ib1DISMUrl="https://msdn.microsoft.com/en-us/windows/hardware/dn913721(v=vs.8.5).aspx"
$ib1DISMPath='C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\dism.exe'
$ibppt='Présentation stagiaire automatique 2020.ppsx'
$adobeReaderUrl='http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/1901220034/AcroRdrDC1901220034_fr_FR.exe'
$remoteControlUrl='https://download.teamviewer.com/download/TeamViewerQS.exe'
$mslearnGit='MicrosoftLearning'
$defaultSwitchId='c08cb7b8-9b3c-408e-8e30-5e16a3aeb444'
$env:logStart='start'
$TechnicalSupportGit='jeremAR/STC'
$trainerComputerName='pc-formateur'

function new-ib1TaskBarShortcut {
<#
.SYNOPSIS
Cette fonction permet l'ajout de raccourcis à la barre des tâches de tous les utilisateurs du poste.
.PARAMETER Shortcut
Fichier .lnk de raccourcis à épingler sur la barre des tâches (obligatoire)
.EXAMPLE
new-ib1TaskBarShortcut -Shortcut "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows PowerShell.lnk"
Cette commande va placer dans la barre des tâches un raccourcis vers l'invite PowerShell
#>
param([string]$Shortcut='')
#Création/modification du fichier d'apparence de la barre des tâches.
write-ib1log "Mise en place du raccourcis '$Shortcut' dans la barre des tâches." -DebugLog
if (!(Test-Path $env:SystemRoot\taskBarLayout.xml)) {Set-Content -Value ('<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification" xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" Version="1">
<CustomTaskbarLayoutCollection>
<defaultlayout:TaskbarLayout>
<taskbar:TaskbarPinList>
</taskbar:TaskbarPinList>
</defaultlayout:TaskbarLayout>
</CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>') -Path $env:SystemRoot\taskBarLayout.xml}
$taskbarLayout=Get-Content $env:SystemRoot\taskBarLayout.xml
#Correction pour master défextueux :
Set-Content -Path $env:SystemRoot\taskBarLayout.xml -Value ($taskbarLayout -replace '<CustomTaskbarLayoutCollection><defaultlayout:TaskbarLayout>',"<CustomTaskbarLayoutCollection>`n<defaultlayout:TaskbarLayout>")
$TBNewLine="<taskbar:DesktopApp DesktopApplicationLinkPath=""$Shortcut"" />"
if ($taskbarLayout -notcontains $TBNewLine) {Set-Content -Path $env:SystemRoot\taskBarLayout.xml -Value ($taskbarLayout -replace '</taskbar:TaskbarPinList>',"$TBNewLine`n</taskbar:TaskbarPinList>")}
#mise en place des clefs de registre pour impliquer le fichier précédent
$layoutPath="HKLM:\Software\Policies\Microsoft\Windows"
if (!(test-path "$layoutPath\Explorer")) {New-Item -Path $layoutPath -Name "Explorer"|Out-Null}
New-ItemProperty -Name 'LockedStartLayout' -Path "$layoutPath\Explorer" -Value 1 -Force -ErrorAction SilentlyContinue|Out-Null
New-ItemProperty -Name 'StartLayoutFile' -Path "$layoutPath\Explorer" -Value "$env:SystemRoot\taskBarLayout.xml" -PropertyType expandString -Force -ErrorAction SilentlyContinue|Out-Null}

function read-ib1CourseFile {
param([string]$fileName,[string]$newLine='',[string]$readUrl='')
if ($readUrl -ne '') {$textContent=(invoke-webrequest -uri $readUrl -UseBasicParsing).content.split([Environment]::NewLine); }
else {$textContent=Get-Content "$($env:ProgramFiles)\WindowsPowerShell\Modules\ib1\$(get-ib1Version)\$fileName"}
$return=New-Object -TypeName PSOBject
$newref=''
foreach ($line in $textContent) {
if ($line[0] -ne '#' -or $line.startswith('# ') -or $line.startswith('## ')) {
  if ($line[0] -eq '#' -and $line[1] -ne '#') {
    if ($newref -ne '') {
      if ($newLine -ne "`n") {$newVal=$newVal.substring(0,$newVal.length -6)}
    $return|Add-Member -NotePropertyName $newref -NotePropertyValue $newVal}
  $newVal=''  
  $newref=$line.Substring(2)}
  else {$newVal+="$line$newLine"}}}
return $return}

function set-ib1md2html {
param([string]$chaine)
return $chaine -replace ("(## )(.*?)<br/>",'<h2>$2</h2>') -replace "(\*\*|__)(.*?)\1",'<strong>$2</strong>' -replace "(``````)(.*?)\1",'<code>$2</code>' -replace "(\*|_)(.*?)\1",'<em>$2</em>' -replace "\n -( *)",'<li>'}

function set-ib1CourseHelp {
param([string]$course)
$courseDocs=read-ib1CourseFile -fileName courses.md "<br/>`n"
$courseBody=set-ib1md2html $courseDocs.intro
if ($courseDocs.$course) {$courseBody+="<hr/>$(set-ib1md2html $courseDocs.$course)"}
$courseBody+="<hr/>$(set-ib1md2html $courseDocs.outro)"
$courseBody=$courseBody -replace ("##course##",$course)
if ($course -eq '') {$course='Stage ib'}
$courseBody > ([Environment]::GetFolderPath('CommonDesktopDirectory')+"\$course - readme.html")}

function wait-ib1Network {
param([string]$nicName,$maxwait=10)
write-ib1log "Attente du réseau ipV4 sur la carte '$nicName' pendant $($maxwait/2) minutes maximum."
while (((Get-NetAdapter $nicName|Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue).addressState -notLike 'Preferred' -or (Get-NetAdapter $nicName|Get-NetIPAddress -AddressFamily IPv4).IPAddress -like "169.254.*") -and $maxwait -gt 0) {
  Start-Sleep -Seconds 30
  $maxwait --}
  if ($maxwait -gt 0) {return $true}
  else {return $false}}

function enable-ib1Office {
$enablecommand=(Get-ChildItem -Path 'c:\program files' -Filter *ospprearm.exe -Recurse -ErrorAction SilentlyContinue).FullName
if ($enablecommand) {
  #1er lancement Powerpoint en vue d'activation
  $ppt = New-Object -ComObject powerpoint.application
  #$ppt.visible = "msoTrue"
  $ppt.run|out-null
  Start-Sleep -Seconds 2
  Get-Process|where description -Like "*powerpoint*"|Stop-Process
  write-ib1log "Tentative de réarmement de Office." -DebugLog
  & (Get-ChildItem -Path 'c:\program files' -Filter *ospprearm.exe -Recurse -ErrorAction SilentlyContinue).FullName|out-null}}

function Unzip {
param([string]$zipfile,[string]$outpath)
  [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)}

function write-ib1log {
[CmdletBinding(DefaultParameterSetName='TextLog')]
param([string]$TextLog,[switch]$ErrorLog=$false,[switch]$DebugLog=$false,[switch]$warningLog=$false,[string]$colorLog='white',[string]$progressTitleLog='',[byte]$logId=2)
$launchCommand=(Get-PSCallStack|Where-Object command -INotLike "*<scriptblock>*")[-1]
if ($env:logStart -ne ($launchCommand.Command)) {
  $env:logstart=$launchCommand.Command
  $eventText="Lancement de '$($launchCommand.Command)', Version $((get-module -ListAvailable -Name ib1|sort Version -Descending|select -First 1).Version.tostring())"
  if ($launchCommand.Arguments -inotlike '{}') {$eventText+=", Arguments: $($launchCommand.Arguments)"}
  Write-EventLog -LogName ib1 -Source powerShellib1 -Message $eventText -EntryType Warning -EventId 1}
  if ($ErrorLog) {
  Write-EventLog -LogName ib1 -Source powerShellib1 -Message "[$env:logStart]$TextLog" -EntryType Error -EventId $logId
  Write-Host "[ERREUR!] $TextLog" -ForegroundColor Red
  break}
elseif ($DebugLog) {
  Write-EventLog -LogName ib1 -Source powerShellib1 -Message "[$env:logStart]$TextLog" -EntryType Information -EventId $logId
  Write-Debug $TextLog}
elseif ($warningLog) {
  Write-EventLog -LogName ib1 -Source powerShellib1 -Message "[$env:logStart]$TextLog" -EntryType Warning -EventId $logId
  Write-Warning $TextLog}
elseif ($progressTitleLog -ne '') {
  if ($TextLog) {
    write-progress -Activity $progressTitleLog -currentOperation $TextLog
    $env:logText="$env:logText`n$TextLog"}
  else {
    write-progress -Activity $progressTitleLog -complete
    $TextLog="Fin d'activité."
    Write-EventLog -LogName ib1 -Source powerShellib1 -Message "[$env:logStart][$progressTitleLog]$env:logText" -EntryType Information -EventId $logId
    $env:logText=''}}
else {
  Write-EventLog -LogName ib1 -Source powerShellib1 -Message "[$env:logStart]$TextLog" -EntryType Information -EventId $logId
  write-host $TextLog -ForegroundColor $colorLog}}

function set-ib1VMNotes {
[CmdletBinding(DefaultParameterSetName='VMname')]
param([string]$TextNotes,[string]$VMName,[switch]$clear=$false)
if ($clear) {
  Get-VM|foreach {Set-VM $_ -Notes ''}
  write-ib1log "Les Notes des VMs ont été nettoyées." -DebugLog}
$TextNotes=(get-date -Format "[%d/%M/%y-%H:mm-V")+(get-module -ListAvailable -Name ib1|sort Version -Descending|select -First 1).Version.tostring()+']'+$TextNotes
Get-VM -VMName *$VMName* -ErrorAction SilentlyContinue|ForEach-Object {
  if ($_.Notes -ne '') {Set-VM $_ -Notes "$($_.Notes)`n$TextNotes" -ErrorAction SilentlyContinue}
  else {Set-VM $_ -Notes $TextNotes -ErrorAction SilentlyContinue}}}

function set-ib1ChromeLang {
<#
.SYNOPSIS
Cette fonction change la langue de l'interface de Chrome, ainsi que la langue des sites visités.
.PARAMETER web
Code langue présenté aux sites visités par le navigateur (valeur par défaut 'en')
.PARAMETER interface
Code langue de l'interface du navigateur (valeur par défaut 'fr')
.EXAMPLE
set-ib1ChromeLang -web en -interface fr
paramètre Chrome pour un affichage de son interface en Français et pour afficher la version anglaise des sites visités.
#>
[CmdletBinding(DefaultParameterSetName='web')]
param([string]$web='en',[string]$interface='fr')
begin{get-ib1elevated $true}
process{
write-ib1log "Modification de la langue des sites visités par Chrome en '$web'." -DebugLog
$ChromePrefFile = Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data\default\Preferences'
$Settings = Get-Content $ChromePrefFile -ErrorAction SilentlyContinue| ConvertFrom-Json
if ($settings.intl.accpet_labguages) {
  $Settings.intl.accept_languages=$web|out-null
  Set-Content -Path $ChromePrefFile (ConvertTo-Json -InputObject $Settings -Depth 12 -Compress)}
write-ib1log "Modification de la langue de l'interface de Chrome en '$interface'." -DebugLog
$gooKey='HKLM:\SOFTWARE\Policies\Google'
$gooVal='ApplicationLocaleValue'
if (!(Test-Path $gooKey)) {New-Item -Path $gooKey|Out-Null}
$gooKey+='\Chrome'
if (!(Test-Path $gooKey)) {New-Item -Path $gooKey|Out-Null}
if (Get-ItemProperty $gooKey -name $gooVal -ErrorAction SilentlyContinue ) {
  Set-ItemProperty -Path $gooKey -Name $gooVal -Value $interface|Out-Null}
else {
  New-ItemProperty -Path $gooKey -Name $gooVal -Value $interface|Out-Null}}}

function test-ib1PSDirect {
<#
.SYNOPSIS
Cette fonction teste la disponibilité de Powershell Direct pour la VM en objet.
.PARAMETER VMName
Nom de la VM à tester (ou partie du nom, mais doit identifier une VM de manière unique)
.EXAMPLE
test-ib1PSDirect -VMName LON-DC1
renvoie $true si des commandes peuvent être passées sur la VM 20410D-LON-DC1
#>
[CmdletBinding(DefaultParameterSetName='VMname')]
param(
[parameter(Mandatory=$true,ValueFromPipeLine=$true,HelpMessage="Machine virtuelle à tester pour PowerShell Direct")][string]$VMName)
process{
  $TPDVM=Get-VM -VMName *$VMName* -ErrorAction SilentlyContinue|Where-Object state -ILike *running*
  if ($TPDVM.count -ne 1) {
    write-ib1log "Impossible de trouver une et une seule VM allumée correspondant au nom '$VMName'." -warningLog
    return $false}
  else {
    if ($TPDVM.Version -lt 8) {
      write-ib1log "Powershell Direct non disponible sur la machine '$VMName': la machine est en version $($TPDVM.Version) !" -warningLog
      return $false}
    Enable-VMIntegrationService -VM $TPDVM -Name 'Guest Service Interface'
    return $true}}}

function get-ib1NetComputers {
param([string]$subNet,[Switch]$Nolocal)
if ($SubNet -and $SubNet -ne '') {
  echo "valeur de subnet '$subnet'"
  if ($NoLocal) {write-ib1log "Le paramètre -NoLocal n'est pas compatible avec le paramètre -SubNet." -ErrorLog}
  if ($SubNet.Split('.') -lt 0 -or $SubNet.Split('.') -gt 255 -or $SubNet.split('.').Count -ne 3) {write-ib1log "La syntaxe du paramètre -SubNet ne semble pas correcte: merci de vérifier !" -ErrorLog}}
else {
  write-ib1log "Récupération des informations sur le réseau local" -DebugLog
  $ipConfiguration=(Get-NetIPConfiguration|where {$_.NetAdapter.Status -like 'up' -and $_.InterfaceDescription -notlike '*VirtualBox*' -and $_.InterfaceDescription -notlike '*vmware*' -and $_.InterfaceDescription -notlike '*hyper-v*'})
  if ($ipConfiguration.count -eq 0) {
    $ipConfiguration=(Get-NetIPConfiguration|where {$_.NetAdapter.Status -like 'up' -and $_.InterfaceDescription -notlike '*VirtualBox*' -and $_.InterfaceDescription -notlike '*vmware*'})}
  if (($ipConfiguration.count -gt 1) -or ($ipConfiguration.count -eq 0)) {
    write-ib1log "Le paramètre -SubNet peut être omis si une et une seule carte réseau locale est connectée au réseau" -ErrorLog}
  $ipAddress=($ipConfiguration|Get-NetIPAddress -AddressFamily ipv4).IPAddress
  $Gateway=$ipConfiguration.ipv4defaultgateway.nexthop
  $subNet=$ipAddress.split('.')[0]+'.'+$ipAddress.split('.')[1]+'.'+$ipAddress.split('.')[2]}
  $netComputers=[ordered]@{}
  [System.Collections.ArrayList]$pingJobs=@()
  write-ib1log -progressTitleLog "Ping du réseau $subNet.0/24" "Lancement des jobs..."
  for ($i=1;$i -lt 255;$i++) {
    $pingJobs.add((Test-Connection -ComputerName "$subNet.$i" -Count 1 -BufferSize 8 -AsJob))|Out-Null}
  foreach ($pingJob in $pingJobs) {
    if ($pingJob.state -inotlike '*completed*') {Wait-Job $pingJob|Out-Null}
    $pingResult=Receive-Job $pingJob -Wait -AutoRemoveJob
    if ($pingResult.StatusCode -eq 0) {
      write-ib1log -progressTitleLog "Ping du réseau $subNet.0/24" "La machine '$($pingResult.Address)' a répondu au ping."
      $netComputers[$pingResult.address]=$true}}
  write-ib1log -progressTitleLog "Ping du réseau $subNet.0/24"
  if ($NoLocal) {$netComputers.remove($ipAddress)}
  if ($netComputers.count -eq 0) {write-ib1log "Aucune machine disponible pour lancer la commande..." -ErrorLog}
  return $netComputers}

function set-ib1WinRM {
  write-ib1log "Vérification/mise en place de la configuration pour le WinRM local" -DebugLog
  Get-NetConnectionProfile|where {$_.NetworkCategory -notlike '*Domain*'}|Set-NetConnectionProfile -NetworkCategory Private
  $saveTrustedHosts=(Get-Item WSMan:\localhost\Client\TrustedHosts).value
  Set-Item WSMan:\localhost\Client\TrustedHosts -value * -Force
  Set-ItemProperty –Path HKLM:\System\CurrentControlSet\Control\Lsa –Name ForceGuest –Value 0 -Force
  Enable-PSRemoting -Force|Out-Null
  return $saveTrustedHosts}

function get-ib1Log {
<#
.SYNOPSIS
Cette commande facilite l'affichage du journal des commandes ayant fait appel au module ib1 sur la machine locale.
.EXAMPLE
get-ib1Log
Affiche le log des commandes
#>
PARAM([switch]$clearLog=$false)
if ($clearLog) {
  Clear-EventLog ib1
  write-ib1log "Effacement du journal d'évènements ib1." -DebugLog -colorLog red}
else {eventvwr /c:ib1}}

function get-ib1Version {
<#
.SYNOPSIS
Cette commande affiche la version à jour du module ib1 présentement installé.
.EXAMPLE
get-ib1Version
Affiche la version du module
#>
(get-module -ListAvailable -Name ib1|sort Version -Descending|select -First 1).Version.tostring()}

function get-ib1elevated ($ibElevationNeeded=$false) {
if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{ if (-not $ibElevationNeeded) { Set-PSRepositery PSGallery -InstallationPolicy Trusted;return $true}}
else {
if ($ibElevationNeeded) {
  write-ib1log "Attention, commande à utiliser en tant qu'administrateur" -ErrorLog}
else { return $false}}}

function start-ib1VMWait ($SWVmname) {
  if ((get-vm *$SWVmname*).state -inotlike "*running*") {
    $vm=get-vm *$SWVmname*
    Start-VM -VM $vm
    while ((get-vm $vm.name).heartbeat -notlike '*ok*') {
      write-ib1log -progressTitleLog "Démarrage de $($vm.name)" "Attente de signal de démarrage réussi de la VM."
      start-sleep 2}
    write-ib1log -progressTitleLog "Démarrage de $($vm.name)"}}

function get-ib1VM {
param([string]$VMName,[bool]$exactVMName=$false)
  if ($VMName -eq '') {
  try { $gResult=Get-VM -ErrorAction stop }
  catch {
    write-ib1log "Impossible de trouver des machines virtuelles sur ce Windows." -ErrorLog}}
  else {
    if (!($exactVMName)) {$VMName="*$VMName*"}
    try { $gResult=Get-VM -VMName $VMName -ErrorAction stop }
    catch {
    write-ib1log "Impossible de trouver une machine virtuelle '$VMName'." -ErrorLog}}
  return $gResult}

function get-ib1Repo {
<#
.SYNOPSIS
Cette commande permet de copier en local le contenu d'un repositery Git.
.PARAMETER Repo
Nom du repositery sur GitHub (sera préfixé de l'indentifiant MS learning en l'absence de caractère "/")
.PARAMETER srcPath
Chemin des fichiers à récupérer dans le Repositery (par défaut "/")
.PARAMETER destPath
Chemin local ou seront posés les fichier récupérés du Git (par défaut, sur le bureau de l'utilisateur actuel)
.PARAMETER course
Paramètre obsolète, remplaçé par la commande install-ib1Course
.EXAMPLE
get-ib1Repo -repo '10979-MicrosoftAzureFundamentals' -srcPath 'Allfiles' -destPath 'c:\10979'
Récupère les fichiers contenu dans le répertoire 'AllFiles' du repo '10979' et le copie dans le repertoire local c:\10979
#>
[CmdletBinding(
DefaultParameterSetName='Repo')]
PARAM(
[string]$Repo,
[string]$srcPath='*',
[string]$destPath='',
[string]$course='')
begin{get-ib1elevated $true}
process {
if ($course -ne '') {install-ib1Course -course $course}
if (-not $Repo -or $Repo -eq '') {write-ib1log "Le paramétre -Repo est manquant, merci de vérifier !" -ErrorLog}
if (-not $Repo.Contains('/')) {$repo=$mslearnGit+'/'+$Repo}
#création du nom du répertoire local si non spécifié
if ($destPath -eq '') {$destPath=[Environment]::GetFolderPath("CommonDesktopDirectory")+'\'+$Repo.substring($Repo.IndexOf('/')+1)}
$ErrorActionPreference='silentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$gitRequest=[System.Net.WebRequest]::Create("https://github.com/$Repo")
$gitResponse=$gitRequest.GetResponse()
if ([int]$gitResponse.StatusCode -ne 200) {write-ib1log "L'url 'https://github.com/$Repo' n'existe pas ou est injoignable." -ErrorLog}
$ErrorActionPreference='continue'
if (-not (Test-Path $destPath)) {
  if (-not (Test-Path $destPath.substring(0,$destPath.LastIndexOf('\')))) {write-ib1log "Le répertoire '$destPath' n'existe pas et ne peut être créé." -ErrorLog}
  else {
    write-ib1log "Le répertoire '$destPath' n'existe pas et sera créé." -DebugLog
    New-Item $destPath -ItemType Directory|Out-Null}}
$srcFolder="https://api.github.com/repos/$Repo/zipball"
$destZip=$env:TEMP+'\'+$Repo.substring($Repo.IndexOf('/')+1)+'.zip'
write-ib1log "Récupération du fichier '$srcFolder' dans '$destZip'." -DebugLog
Invoke-WebRequest -Uri $srcFolder -OutFile $destZip
Add-Type -AssemblyName System.IO.Compression.FileSystem
if ($srcPath -eq '*') {$srcFind='*'} else {$srcFind="*/$srcPath*"}
$zip=[IO.Compression.ZipFile]::OpenRead($destZip)
$zip.Entries|Where-Object {$_.FullName -like $srcFind}|ForEach-Object {
  if ($srcPath -ne '*') {$destName=$_.FullName -replace "(?:[^\/]*)\/$srcPath"} else {$destName=$_.FullName.substring($_.FullName.IndexOf('/'))}
  if ($_.Name -eq '') {
    write-ib1log -progressTitleLog "Décompression des fichiers." "Création du dossier '$destName'."
    New-Item -Path $destPath$destName -ItemType Directory -Force -ErrorAction SilentlyContinue |Out-Null}
  elseif ($_.Name -notlike '*readme.md') {
    write-ib1log -progressTitleLog "Décompression des fichiers." "Décompression du fichier '$($_.Name)'."
    if(![System.IO.File]::Exists($destPath+$destName)) {[IO.Compression.ZipFileExtensions]::ExtractToFile($_,$destPath+$destName)|Out-Null}}}
$zip.dispose()
write-ib1log -progressTitleLog "Décompression des fichiers."
Remove-Item -Path $destZip -Force}}

function install-ib1Course {
<#
.SYNOPSIS
Cette commande permet de mettre en place les éléments nécessaire pour un stage.
.PARAMETER course
Référence du stage à mettre en place.
Valeurs possibles : stages référencés dans les fichiers courses.ps1 et courses.md
.PARAMETER noCourse
Si ce paramètre est passé, l'installation générique aura lieu, sans demander de nom du stage à customiser.
.PARAMETER trainer
Si mentionnée, cette option permet de copier les présentation PPT (pour faciliter l'animation) depuis gitHub
.PARAMETER net
Si cette option est mentionnée, la commande sera executée sur toutes les machines démarrées dans la salle
(à executer depuis la machine du formateur)
.EXAMPLE
install-ib1Course -course msAZ100
Met en place l'environnement pour le stage msAZ100
#>
[CmdletBinding(
DefaultParameterSetName='Course')]
PARAM([string]$course='',[switch]$Force=$false,[Switch]$trainer=$false,[Switch]$noCourse=$false,[Switch]$net)
begin{get-ib1elevated $true}
process {
if ($env:ibTrainer -eq 1) {
  write-ib1log "Détection automatique de machine instructeur." -DebugLog
  $trainer=$true}
set-ib1ChromeLang
enable-ib1Office
# Touche 'Volume UP' suivie de la touche 'Mute'
(new-object -com wscript.shell).sendKeys([char]175)|out-null
(new-object -com wscript.shell).sendKeys([char]173)|out-null
write-ib1log "Combinaison de touche pour supprimer le son (Mute) de la machine." -DebugLog
if ($env:ibSetup -ne $null -and !$force) {write-ib1log "La commande 'ibSetup' a déja été lançée ($($env:ibSetup)). utilisez le tag -Force pour la relancer." -ErrorLog}
$courseDocs=(read-ib1CourseFile -fileName courses.md "<br/>`n")
$courseDocs.psobject.Properties.Remove('intro')
$courseDocs.psobject.Properties.Remove('outro')
if ($course -eq '' -and $env:ibCourse -ne $null) {
  $course=$env:ibCourse
  write-ib1log "Détection du stage '$course' par présence de variable système." -DebugLog}
if ($course -eq '' -and !$noCourse)  {
  $objPick=foreach ($courseDoc in ($courseDocs|Get-Member -MemberType NoteProperty)) {New-Object psobject -Property @{'Quel stage installer'=$courseDoc.Name}}
  $input=$objPick|Out-GridView -Title "ib1 Installation d'environement de stage" -PassThru
  $course=$input.'Quel stage installer'}
if ($course -ne '' -and -not $courseDocs.$course) {write-ib1log "Le paramètre -course ne peut avoir que l'une des valeurs suivantes: $(($courseDocs|Get-Member -MemberType NoteProperty).name -join ', '). Merci de vérifier!" -ErrorLog}
elseif ($course -ne '') {
  if ($net) {
    $trainer=$true
    $computers=get-ib1NetComputers -Nolocal
    $saveTrustedHosts=set-ib1WinRM
    get-job|remove-job -Force
    foreach ($computer in $computers.Keys) {invoke-command -ComputerName $computer -ScriptBlock {ibSetup $Using:course -Force} -ErrorAction Stop -AsJob|out-null}
    #Attente de la fin des jobs.
    $netSetupJobs=Get-Job
    ForEach ($netSetupJob in $netSetupJobs) {
      do {Start-Sleep -Seconds 10} until ($netSetupJob.state -like 'Failed' -or $netSetupJob.state -like 'Completed')
    if ($netSetupJob.state -like 'Failed') {write-ib1log "[$($netSetupJob.Location)] Job non créé." -colorLog red}
    else {write-ib1log "[$($netSetupJob.Location)] Installation réalisée." -colorLog Green}}
    Set-Item WSMan:\localhost\Client\TrustedHosts -value $saveTrustedHosts -Force}
  write-ib1log "Mise en place de l'environnement pour le stage '$course'."
  $courseCommands=read-ib1CourseFile -fileName courses.ps1 -newLine "`n"
  if ($courseCommands.$course) {
    write-ib1log "Lancement des commandes du fichier 'courses.ps1'." -DebugLog
    Invoke-Expression $courseCommands.$course}
  if ($env:ibCourse -eq $null) {
    [System.Environment]::SetEnvironmentVariable('ibCourse',$course,[System.EnvironmentVariableTarget]::Machine)
    $env:ibCourse=$course
    write-ib1log "Inscription de l'identité du stage '$course' dans la variable système 'ibCourse'." -DebugLog}}
set-ib1CourseHelp $course
install-ib1Chrome -Force
if ($trainer) {
  $ibpptUrl="https://raw.githubusercontent.com/renaudwangler/ib/master/extra/$ibppt"
  if (-not(Get-Childitem -Path ([Environment]::GetFolderPath('CommonDesktopDirectory')+"\$ibppt") -ErrorAction SilentlyContinue)) {
    write-ib1log "Copie de la présentation ib sur le bureau depuis github." -DebugLog
    invoke-webRequest -uri $ibpptUrl -OutFile ([Environment]::GetFolderPath('CommonDesktopDirectory')+"\$ibppt") -ErrorAction SilentlyContinue}
  elseif ((Get-Childitem -Path ([Environment]::GetFolderPath('CommonDesktopDirectory')+"\$ibppt")).length -ne  (Invoke-WebRequest -uri $ibpptUrl -Method head -UseBasicParsing -ErrorAction SilentlyContinue).headers.'content-length') {
    write-ib1log "Présentation ib à priori pas à jour: Copie de la présentation ib sur le bureau depuis github." -DebugLog
    Remove-Item -Path ([Environment]::GetFolderPath('CommonDesktopDirectory')+"\$ibppt") -Force -ErrorAction SilentlyContinue
    invoke-webRequest -uri $ibpptUrl -OutFile ([Environment]::GetFolderPath('CommonDesktopDirectory')+"\$ibppt") -ErrorAction SilentlyContinue}
  #Renommage de la machine en "pc-formateur" le cas échéant.
  if ($env:COMPUTERNAME -notlike $trainerComputerName) {
    if (!(Test-Connection -Count 1 -ComputerName $trainerComputerName -Quiet)) {
      Rename-Computer -NewName $trainerComputerName -Force -WarningAction SilentlyContinue|out-null
      write-ib1log "Ordinateur renommé en '$trainerComputerName', merci de redémarrer pour prise en compte." -warningLog}
    else {write-ib1log "Un ordinateur existe déja sur le réseau nommé '$trainerComputerName', merci de vérifier !" -warningLog}}
  [System.Environment]::SetEnvironmentVariable('ibTrainer',1,[System.EnvironmentVariableTarget]::Machine)
  $env:ibTrainer=1}
  [System.Environment]::SetEnvironmentVariable('ibSetup',(Get-Date -Format 'MMdd'),[System.EnvironmentVariableTarget]::Machine)
  write-ib1log "Configuration des options d'alimentation" -DebugLog
  powercfg /hibernate off|out-null
  powercfg /SETACTIVE SCHEME_BALANCED|out-null
  powercfg /SETDCVALUEINDEX SCHEME_BALANCED SUB_SLEEP STANDBYIDLE 0|out-null
  powercfg /SETACVALUEINDEX SCHEME_BALANCED SUB_SLEEP STANDBYIDLE 0|out-null
  powercfg /SETDCVALUEINDEX SCHEME_BALANCED SUB_VIDEO VIDEOIDLE 0|out-null
  powercfg /SETACVALUEINDEX SCHEME_BALANCED SUB_VIDEO VIDEOIDLE 0|out-null
  powercfg /SETACVALUEINDEX SCHEME_BALANCED SUB_BUTTONS PBUTTONACTION 3|out-null
  $env:ibSetup=(Get-Date -Format 'MMdd')}}

function set-ib1VMCheckpointType {
<#
.SYNOPSIS
Cette commande permet de modifier le type de checkpoint sur les VMs pour le passer en "Standard".
(pratique pour les environnement ou l'on souhaite (re)démarrer des VMs dans un était précis -enregistrées- )
.PARAMETER VMName
Nom de la VMs à modifier. si ce parametre est omis toutes les VMs qui sont en checkpoint "Production" seront passées en "standard".
.PARAMETER exactVMName
Permet de spécifier que le nom de la VM fourni est précisément le nom de la VM à traiter.
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
[string]$VMName,
[switch]$exactVMName)
begin{get-ib1elevated $true}
process {
$VMs2Set=get-ib1VM -VMName $VMName -exactVMName $exactVMName
foreach ($VM2Set in $VMs2Set) {
  if ($VM2Set.checkpointType -ilike '*standard*') {write-ib1log "Les checkpoints de la VM '$($VM2Set.vmName)' sont déja en mode standard." -warningLog}
  else {
    write-ib1log "Changement des checkpoints de la VM '$())' en mode standard." -DebugLog
    set-ib1VMNotes $VM2Set.vmName -TextNotes "Checkpoints en mode standard."
    Get-VM -VMName $VM2Set.vmName|Set-VM -checkpointType Standard}}}}

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
.PARAMETER exactVMName
Permet de spécifier que le nom de la VM fourni est précisément le nom de la VM à traiter.
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
[switch]$powerOff=$false,
[switch]$exactVMName)
begin{get-ib1elevated $true}
process {
$VMs2Reset=get-ib1VM -VMName $VMName -exactVMName $exactVMName
foreach ($VM2reset in $VMs2Reset) {
  if ($snapshot=Get-VMSnapshot -VMName $VM2reset.vmname|sort-object creationtime|select-object -last 1 -ErrorAction SilentlyContinue) {
    if (-not $keepVMUp -and $VM2reset.state -ieq 'running') {
      write-ib1log "Arrêt de la VM $($VM2reset.vmname)." -DebugLog
      stop-vm -VMName $VM2reset.vmname -confirm:$false -turnOff}
    write-ib1log "Restauration du snapshot $($snapshot.Name) sur la VM $($VM2reset.vmname)." -DebugLog
    Restore-VMSnapshot $snapshot -confirm:$false}
  else {write-ib1log "La VM $($VM2reset.vmname) n'a pas de snapshot" -DebugLog}}}
  end {
  if ($powerOff) {
    write-ib1log "Extinction de la machine après opération" -DebugLog
    stop-computer -force}}}

function mount-ib1VhdBoot {
<#
.SYNOPSIS
Cette commande permet de monter le disque virtuel contenu dans le fichier VHD et de rajouter le démarrage sur la partition non réservée contenue au BCD.
.PARAMETER VHDFile
Nom du fichier VHD contenant le disque virtuel à monter.
.PARAMETER restart
Redémarre l'ordinateur à la fin du script (inactif par défaut)
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
begin{get-ib1elevated $true}
process {
if (($copyFolder -ne '') -and -not (test-path $copyFolder)) {
  write-ib1log "Le dossier '$copyFolder' n'existe pas, merci de vérifier !" -ErrorLog}
try { Mount-VHD -Path $vhdFile -ErrorAction stop }
catch {
  write-ib1log "Impossible de monter le disque virtuel contenu dans le fichier $VHDFile." -ErrorLog}
$dLetter=(get-disk|where-object Model -like "*virtual*"|Get-Partition|Get-Volume|where-object {$_.filesystemlabel -ine "system reserved" -and $_.filesystemlabel -ine "réservé au système"}).driveletter+":"
write-ib1log "Disque(s) de lecteur Windows trouvé(s) : $dLetter" -DebugLog
if (($dLetter.Count -ne 1) -or ($dLetter -eq ':')) {
 write-ib1log 'Impossible de trouver un (et un seul) disque virtuel monté qui contienne une unique partition non réservée au systeme.' -ErrorLog}
 write-ib1log "Création d'une nouvelle entrée dans le BCD." -DebugLog
bcdboot $dLetter\windows /l fr-FR |out-null
write-ib1log "Changement des otpions de clavier Français." -DebugLog
DISM /image:$dLetter /set-allIntl:en-US /set-inputLocale:0409:0000040c |out-null
if ($copyFolder -ne '') {
  write-ib1log "Copie du dossier '$copyFolder' dans le dossier \ib du disque monté" -DebugLog
  Copy-Item $copyFolder\* $dLetter\ib}
write-ib1log "Modification de la description du BCD pour : '$([io.path]::GetFileNameWithoutExtension($VHDFile))'." -DebugLog
bcdedit /set '{default}' Description ([io.path]::GetFileNameWithoutExtension($VHDFile)) |out-null
write-ib1log "Modification du BCD pour lancement Hyper-V." -DebugLog
bcdedit /set '{default}' hypervisorlaunchtype auto|out-null
write-ib1log "Mise en place du menu de multi-boot dans le BCD" -DebugLog
bcdedit /timeout 30|out-null
write-ib1log "Installation du module ib1 dans le disque monté." -DebugLog
New-Item -ItemType Directory -Path "$dLetter\Program Files\WindowsPowerShell\Modules\ib1" -ErrorAction SilentlyContinue|Out-Null
New-Item -ItemType Directory -Path "$dLetter\Program Files\WindowsPowerShell\Modules\ib1\$(get-ib1Version)" -ErrorAction SilentlyContinue|Out-Null
Copy-Item "$((get-module -ListAvailable -Name ib1|sort Version -Descending|select -First 1).path|Split-Path -Parent)\*" "$dLetter\Program Files\WindowsPowerShell\Modules\ib1\$(get-ib1Version)\" -ErrorAction SilentlyContinue|out-null
$module=get-module -ListAvailable -Name ib1|sort Version -Descending|select -First 1
Copy-Item "$((get-module -ListAvailable -Name ib1|sort Version -Descending|select -First 1).path|Split-Path -Parent)\*" "$dLetter\Program Files\WindowsPowerShell\Modules\ib1\" -ErrorAction SilentlyContinue|out-null
write-ib1log "Montage du registre 'Software' du VHD" -DebugLog
reg load HKLM\ib-offline $dLetter\Windows\System32\config\SOFTWARE
New-PSDrive -Name "ib-offline" -PSProvider Registry -Root HKLM\ib-offline
write-ib1log "Création de l'entrée de registre 'Run' pour la configuration WinRm" -DebugLog
New-ItemProperty -Path ib-offline:\Microsoft\Windows\CurrentVersion\Run -Name ibInit -Value 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -noprofile -command "& set-executionpolicy bypass -force;enable-psremoting --SkipNetworkProfileCheck -Force"' -PropertyType string -ErrorAction SilentlyContinue|out-null
Remove-PSDrive "ib-offline"
reg unload HKLM\ib-offline
if ($restart) {
  write-ib1log "Redémarrage de la machine en fin d'opération." -DebugLog
  Restart-Computer}}}

function remove-ib1VhdBoot {
<#
.SYNOPSIS
Cette commande permet de supprimer les entrées du BCD corespondant à des disques dur virtuels.
(Ne fonctionnera pas sans un rebbot depuis la commande mount-ib1VhdBoot)
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
begin{get-ib1elevated $true}
process {
$bcdVHDs=@()
foreach ($line in bcdedit) {
  if ($line -ilike 'identifier*{*}') {
    $id=$line -match '{.*}'
    $bootEntry=$matches.Values}
  elseif ($line -ilike 'device*VHD' -or $line -ilike 'device*unknown') {if ($bootEntry -inotlike '{current}') {$bcdVHDs+=$bootEntry}}}
  foreach ($bcdVHD in $bcdVHDs) {
    write-ib1log "Nettoyage de l'entrée de BCD '$($bcdVHD)'" -DebugLog
    bcdedit /delete $bcdVHD|out-null}
if ($restart) {
  write-ib1log "Redémarrage de la machine en fin d'opération." -DebugLog
  Restart-Computer}}}

function switch-ib1VMFr {
<#
.SYNOPSIS
Cette commande permet de changer le clavier d'une marchine virtuelle en Francais.
(Ne fonctionne que sur les VMs éteintes au moment ou la commande est lancée)
.PARAMETER VMName
Nom de la VM sur laquelle agir (agit sur toutes les VMs si paramètre non spécifié)
.PARAMETER exactVMName
Permet de spécifier que le nom de la VM fourni est précisément le nom de la VM à traiter.
.PARAMETER VHDFile
Nom du fichier VHD de disque Virtuel sur lequel agir (permet de changer la langue même si le VHD n'est pas monté dans une VM)
.PARAMETER Checkpoint
Crée un point de contrôle avant et un point de contrôle après modification de la VM
.EXAMPLE
switch-ib1VMFr
Change le clavier de toutes les VM en Français.
#>
[CmdletBinding(
DefaultParameterSetName='VMName')]
PARAM(
[string]$VMName='',
[string]$VHDFile='',
[switch]$noCheckpoint=$true,
[switch]$Checkpoint=$false,
[switch]$exactVMName)
begin{get-ib1elevated $true}
process {
if ($noCheckpoint -eq $false) {write-ib1log "Le paramètre -noCheckpoint est obsolète, merci de consulter l'aide en ligne (get-help)" -ErrorLog}
if ($VHDFile -ne '') {
  if ($VMName -ne '') {
    write-ib1log "Les paramètres '-VHDFile' et '-VMName' ne peuvent être utilisés ensemble, merci de lancer 2 commandes distinctes" -ErrorLog
    break}
  $testMount=$null
  #Protection contre les disques partageant le même parent que le disque système en cours
  $newDisk=(mount-vhd -Path $VHDFile -Passthru|get-disk)
  $oldSignature=$newDisk.signature
  if ((get-disk|Where-Object Signature -eq $oldSignature).count -gt 1) {
    Write-Warning "Changement de la signature du disque '$VHDFile'."
    $newDisk|Set-Disk -Signature 0}
  else {$oldSignature=0}
  dismount-VHD $VHDFile
  $partLetter=(mount-vhd -path $VHDFile -passthru -ErrorVariable testMount -ErrorAction SilentlyContinue|get-disk|Get-Partition|where-object isactive -eq $false).DriveLetter
  if ($testMount -eq $null) {
    Write-Error "Impossible de monter le disque dur... $VHDFile, merci de vérifier!"
    break}
  DISM /image:$($partLetter): /set-allIntl:en-US /set-inputLocale:0409:0000040c|out-null
  if ($LASTEXITCODE -eq 50) {
    if (Test-Path $ib1DISMPath) {
      & $ib1DISMPath /image:$($partLetter): /set-allIntl:en-US /set-inputLocale:0409:0000040c|out-null} else {$LASTEXITCODE=50}}
  if ($LASTEXITCODE -eq 50) {
    Start-Process -FilePath $ib1DISMUrl
    write-error "Si le problème vient de la version de DISM, merci de l'installer depuis la fenetre de navigateur ouverte (installer localement et choisir les 'Deployment Tools' uniquement." -Category InvalidResult
    dismount-vhd $VHDFile
    break}
  elseif ($LASTEXITCODE -ne 0) {
    write-warning "Problème pendant le changemement de langue du disque '$VHDFile'. Merci de vérifier!' (Détail éventuel de l'erreur ci-dessous)."
    write-output $error|select-object -last 1}
  dismount-vhd $VHDFile
  if ($oldSignature -ne 0) {
  Write-Warning "Remise en place de l'ancienne signature du disque '$VHDFile'"
  mount-vhd -Path $VHDFile -Passthru|Get-Disk|Set-Disk -Signature $oldSignature
  dismount-vhd $VHDFile}
  break}
$VMs2switch=get-ib1VM -VMName $VMName -exactVMName $exactVMName
foreach ($VM2switch in $VMs2switch) {
  if ($VM2switch.state -ine 'off') {write-ib1log "La VM $($VM2switch.name) n'est pas éteinte et ne sera pas traitée" -warningLog}
  else {
    write-ib1log -progressTitleLog "Traitement de $($VM2switch.name)" "Montage du disque virtuel."
    if ($VM2switch.generation -eq 1) {
      $vhdPath=($VM2switch|Get-VMHardDiskDrive|where-object {$_.ControllerNumber -eq 0 -and $_.controllerLocation -eq 0 -and $_.controllerType -like 'IDE'}).path}
    else {
      $vhdPath=($VM2switch|Get-VMHardDiskDrive|where-object {$_.ControllerNumber -eq 0 -and $_.controllerLocation -eq 0}).path}
    $testMount=$null
    #Protection contre les disques partageant le même parent que le disque système en cours
    $newDisk=(mount-vhd -Path $vhdPath -Passthru|get-disk)
    $oldSignature=$newDisk.signature
    if ((get-disk|Where-Object Signature -eq $oldSignature).count -gt 1) {
      write-ib1log write-ib1log -progressTitleLog "Traitement de $($VM2switch.name)" "Changement de la signature du disque de la VM '$($VM2switch.name)'."
      $newDisk|Set-Disk -Signature 0}
    else {$oldSignature=0}
    dismount-VHD $vhdpath
    $partLetter=(mount-vhd -path $vhdPath -Passthru -ErrorVariable testMount -ErrorAction SilentlyContinue|get-disk|Get-Partition|where-object IsActive -eq $false).DriveLetter
    if ($testMount -eq $null) {write-ib1log "Impossible de monter le disque dur... de la VM $($VM2switch.name)" -warningLog}
    else {
      if ($Checkpoint -and ($oldSignature -eq 0)) {
        Dismount-VHD $vhdPath
        $prevSnap=Get-VMSnapshot -VMName $($VM2switch.name) -name "ib1SwitchFR-Avant" -erroraction silentlycontinue
        if ($prevSnap -ne $null) {write-ib1log "Un checkpoint nommé 'ib1SwitchFR-Avant' existe déja sur la VM '$($VM2switch.name)'" -ErrorLog}
        write-ib1log -progressTitleLog "Traitement de $($VM2switch.name)" "Création du checkpoint ib1SwitchFR-Avant." 
        Checkpoint-VM -VM $VM2switch -SnapshotName "ib1SwitchFR-Avant"
        $partLetter=(mount-vhd -path $vhdPath -passthru -ErrorVariable testMount -ErrorAction SilentlyContinue|get-disk|Get-Partition|where-object isactive -eq $false).DriveLetter}
      write-ib1log -progressTitleLog "Traitement de $($VM2switch.name)" "Changement des options linguistiques."
      DISM /image:$($partLetter): /set-allIntl:en-US /set-inputLocale:0409:0000040c|out-null
      if ($LASTEXITCODE -eq 50) {
        if (Test-Path $ib1DISMPath) {
        write-ib1log -progressTitleLog "Traitement de $($VM2switch.name)" "Echec, éssai avec '$ib1DISMPath'"
        & $ib1DISMPath /image:$($partLetter): /set-allIntl:en-US /set-inputLocale:0409:0000040c|out-null
        } else {$LASTEXITCODE=50}}
      if ($LASTEXITCODE -eq 50) {
        Dismount-VHD $vhdPath
        Start-Process -FilePath $ib1DISMUrl
        write-ib1log "Si le problème vient de la version de DISM, merci de l'installer depuis la fenetre de navigateur ouverte (installer localement et choisir les 'Deployment Tools' uniquement." -ErrorLog}
      elseif ($LASTEXITCODE -ne 0) {
        write-ib1log "Problème pendant le changemement de langue de la VM '$($VM2switch.name)'. Merci de vérifier!' (Détail éventuel de l'erreur dans le log, utilisez éventuellement les checkpoint pour annuler complètement)." -warningLog}
      write-ib1log "Plus: Modifications du registre pour le clavier." -DebugLog
      reg load "HKLM\$($vm2Switch.Name)-DEFAULT" "$($partLetter):\Windows\System32\config\DEFAULT"|Out-Null
      Remove-ItemProperty -Path "HKLM:\$($vm2Switch.Name)-DEFAULT\Keyboard Layout\Preload" -Name *
      new-ItemProperty -path "HKLM:\$($vm2Switch.Name)-DEFAULT\Keyboard Layout\Preload" -Name 1 -Value '0000040c'|out-null
      reg load "HKLM\$($vm2Switch.Name)-SYSTEM" "$($partLetter):\Windows\System32\config\SYSTEM"|Out-Null
      Get-ChildItem "HKLM:\$($vm2Switch.Name)-SYSTEM\ControlSet001\Control\Keyboard Layouts"|where-object {$_.name -INotLike '*0000040c*'}|Remove-Item
      [gc]::collect()
      Start-Sleep 1
      [gc]::collect()
      reg unload "HKLM\$($vm2Switch.Name)-DEFAULT"|Out-Null
      reg unload "HKLM\$($vm2Switch.Name)-SYSTEM"|Out-Null
      write-ib1log -progressTitleLog "Traitement de $($VM2switch.name)" "Démontage du disque."
      dismount-vhd $vhdpath
      if ($oldSignature -ne 0) {
        write-ib1log -progressTitleLog "Traitement de $($VM2switch.name)" "Remise en place de l'ancienne signature du disque de la VM '$($VM2switch.name)'"
        mount-vhd -Path $vhdpath -Passthru|Get-Disk|Set-Disk -Signature $oldSignature
        dismount-vhd $vhdpath}
        Start-Sleep 1}
    if ($Checkpoint -and ($oldSignature -eq 0)) {
      $prevSnap=Get-VMSnapshot -VMName $($VM2switch.name) -name "ib1SwitchFR-Après"  -erroraction silentlycontinue
      if ($prevSnap -ne $null) {write-ib1log "Un checkpoint nommé 'ib1SwitchFR-Après' existe déja sur la VM '$($VM2switch.name)'" -ErrorLog}
      write-ib1log -progressTitleLog "Traitement de $($VM2switch.name)" "Création du checkpoint ib1SwitchFR-Après."
      Checkpoint-VM -VM $VM2switch -SnapshotName "ib1SwitchFR-Après"}
    set-ib1VMNotes $VM2switch.name -TextNotes "Switch clavier FR."
    write-ib1log -progressTitleLog "Traitement de $($VM2switch.name)"}}}}

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
  write-ib1log -progressTitleLog "Vérification de la configuration réseau de la VM $($VM.Name)." "lancement"
  foreach ($VMnetwork in $VM.NetworkAdapters) {
    write-ib1log -progressTitleLog "Vérification de la configuration réseau de la VM $($VM.Name)." "Vérification de la présence du switch $($VMnetwork.name)"
    if ($VMnetwork.SwitchName -notin $vSwitchs) {write-ib1log -progressTitleLog "Vérification de la configuration réseau de la VM $($VM.Name)." "[ATTENTION] La VM '$($VM.Name)' est branchée sur le switch virtuel '$($VMnetwork.SwitchName)' qui est introuvable. Merci de vérifier !"}}
  write-ib1log -progressTitleLog "Vérification de la configuration réseau de la VM $($VM.Name)."}}

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
$extNic=Get-NetIPAddress -AddressFamily IPv4 -AddressState Preferred -PrefixOrigin Dhcp|Get-NetAdapter
if ($extNic.PhysicalMediaType -eq "Unspecified") {
  if ((Get-VMSwitch $externalNetworkname  -switchtype External -ErrorAction SilentlyContinue).NetAdapterInterfaceDescription -eq (Get-NetAdapter -Physical|where-object status -eq up).InterfaceDescription) {
    write-ib1log "La configuration réseau externe est déjà correcte" -warningLog
    return}
  else {
    write-ib1log "La carte réseau est déja connectée a un switch virtuel. Suppression!" -warningLog
    $switch2Remove=Get-VMSwitch -SwitchType External|where-object {$extNic.name -like '*'+$_.name+'*'}
    write-ib1log -progressTitleLog "Suppression de switch virtuel existant" "Attente pour suppression de '$($switch2Remove.name)'."
    Remove-VMSwitch -Force -VMSwitch $switch2Remove
    for ($sleeper=0;$sleeper -lt 20;$sleeper++) {
      write-ib1log -progressTitleLog "Suppression de switch virtuel existant" "Attente pour suppression de '$($switch2Remove.name)'."
      Start-Sleep 1}
    write-ib1log -progressTitleLog "Suppression de switch virtuel existant"}
    $extNic=Get-NetIPAddress -AddressFamily IPv4 -AddressState Preferred -PrefixOrigin Dhcp|Get-NetAdapter}
  if (Get-VMSwitch $externalNetworkname -ErrorAction SilentlyContinue) {
    write-ib1log "Le switch '$externalNetworkname' existe. Branchement sur la bonne carte réseau" -warningLog
    Get-VMSwitch $externalNetworkname|Set-VMSwitch -SwitchType Private
    Start-Sleep 2
    Get-VMSwitch $externalNetworkname|Set-VMSwitch -netadaptername $extNic.Name
    start-sleep 2}
  else {
    write-ib1log -progressTitleLog "Création du switch" "Création du switch virtuel '$externalNetworkname' et branchement sur la carte réseau."
    New-VMSwitch -Name $externalNetworkname -netadaptername $extNic.Name|Out-Null
    write-ib1log -progressTitleLog "Création du switch"}
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
process {
if (Test-Path $TSCFilename) {
  $oldFile=Get-Content $TSCFilename
  $newFile=@()
  Add-Type -AssemblyName System.Windows.Forms
  #Recherche du moniteur secondaire.
  $Monitors=[System.Windows.Forms.Screen]::AllScreens
  $monitor=$monitors|where primary -ne $true
  if (!$monitor) {$monitor=$monitors[1]}
  foreach ($fileLine in $oldFile){
    if ($fileLine -ilike '*winposstr*') {
      $newFile+="$($fileLine.split(",")[0]),$($fileLine.split(",")[1]),$($Monitor.WorkingArea.X),$($Monitor.WorkingArea.Y),$($Monitor.WorkingArea.X+$Monitor.Bounds.Width),$($Monitor.WorkingArea.Y+$Monitor.Bounds.Height)"}
    else {$newFile+=$fileLine}}
  write-ib1log "Ecriture de la nouvelle version du fichier '$TSCFilename'." -DebugLog
  Set-Content $TSCFilename $newFile}
else {write-ib1log "Le fichier '$TSCFilename' est introuvable" -ErrorLog}}}

function import-ib1TrustedCertificate {
<#
.SYNOPSIS
Cette commande permet d'importer un certificat depuis une URL afin de l'ajouter aux racines de confiance de l'utilisateur en cours.
.PARAMETER CertificateUrl
Chemin (obligatoire) complet du certificat .cer à télécharger
.EXAMPLE
import-ib1TrustedCertificate "http://mars.ib-formation.fr/marsca.cer"
Importera le certificat mentionné dans le magasin des certificat de confiance de l'utilisateur actuel.
#>
[CmdletBinding(
DefaultParameterSetName='CertificateUrl')]
PARAM(
[parameter(Mandatory=$true,ValueFromPipeLine=$false,HelpMessage='Url du certificat à importer')]
[string]$CertificateUrl='')
begin {get-ib1elevated $true}
process {
$fileName=split-path $CertificateUrl -leaf
try {invoke-webrequest $CertificateUrl -OutFile "$($env:USERPROFILE)\downloads\$fileName" -ErrorAction stop}
catch {write-ib1log "URL incrorrecte, le fichier '' est introuvable" -ErrorLog}
write-ib1log "Insertion du certificat dans le magasin de certificats local." -DebugLog
Import-Certificate -FilePath "$($env:USERPROFILE)\downloads\$fileName" -CertStoreLocation Cert:\localmachine\root -Confirm:$false|Out-Null}}

function set-ib1VMCusto {
<#
.SYNOPSIS
Cette commande permet de customiser le Windows contenu dans une machine virtuelle.
.PARAMETER VMName
Nom de la VM à customiser (agit sur toutes les VMs si paramêtre non spécifié)
.PARAMETER exactVMName
Permet de spécifier que le nom de la VM fourni est précisément le nom de la VM à traiter.
.PARAMETER NoCheckpoint
Un Checkpoint Hyper-V sera créé à l'issue de la customisation : utiliser le paramètre "-noCheckpoint" pour l'éviter
.PARAMETER rearm
Lance le réarmement du système d'exploitation de la machine
.PARAMETER user
Nom de l'utilisateur pour connexion au système de la VM ("Administrator" par défaut)
.PARAMETER password
Mot de passe de l'utilisateur pour connexion au système de la VM (obligatoire).
.PARAMETER switchName
Nom du switch virtuel sur lequel est branché la VM
.PARAMETER ipAddress
Adresse IP de la carte réseau
.PARAMETER ipSubnet
taille du masque de sous-réseau de la VM
.PARAMETER ipGateway
Passerelle par défaut de la carte de la VM (le cas échéant).
.PARAMETER dNSServers
serveur(s) DNS à paramètrer sur la carte de la VM (ne fonctionne qu'avec le paramètre ipAddress)
Paramètre à formatter comme un tableau powershell, mais à  passer en chaine de caractère, voir exemple
.PARAMETER VMcommand
Commande à executer dans la VM en connexion directe
.EXAMPLE
set-ib1VMCusto -VMName lon-dc1 -rearm
Réarme le système Windows contenu dans la VM "lon-dc1"
.EXAMPLE
set-ib1VMCusto -VMName lon-dc1 -password 'Pa55w.rd' -switchName 'Private Network' -ipAddress 172.16.0.10 -ipSubnet 24 -ipGateway 172.16.0.1 -dNSServers '(172.16.0.10)'
Cette commande va changer la configuration IP de la carte réseau de la VM qui est branchée sur le witch "Private Network" de l'Hyper-V
#>
#>
[CmdletBinding(
DefaultParameterSetName='VMName')]
PARAM(
[string]$vmName,
[switch]$rearm=$false,
[string]$user='administrator',
[parameter(Mandatory=$true)][string]$password,
[string]$switchName,
[string]$ipAddress,
[string]$ipSubnet='24',
[string]$ipGateway,
[string]$dNSServers,
[switch]$noCheckpoint,
[string]$VMcommand)
begin{get-ib1elevated $true}
process {
if ($switchName) {if (!(Get-VMSwitch -Name "*$switchName*")) {write-ib1log "Erreur, switch virtuel '$switchName' introuvable ! Vérifier !" -ErrorLog}}
$credential=New-Object System.Management.Automation.PSCredential ($user,(ConvertTo-SecureString $password -AsPlainText -Force))
$VMs2custo=get-ib1VM -VMName $VMName
foreach ($VM2custo in $VMs2custo) {
  write-ib1log -progressTitleLog "Traitement de la VM '$($VM2custo.name)'"
  $vmState=$VM2custo.state
  if ($VM2custo.state -notlike 'running') {
    write-ib1log -progressTitleLog "Traitement de la VM '$($VM2custo.name)." "Démarrage de la VM"
    start-ib1VMWait $VM2custo.name}
  if ($ipAddress) {
    write-ib1log -progressTitleLog "Traitement de la VM '$($VM2custo.name)." "Changement de la configuration IP"
    $netAdapter='Get-NetAdapter'
    if ($switchName) {
      #récupération de la carte branchée au switch
      $vmMac=(($VM2custo|get-VMNetworkAdapter|where-object {$_.switchName -like "*$switchName*"}).macAddress)
      $vmMac=$vmMac.insert(2,"-").insert(5,"-").insert(8,"-").insert(11,"-").insert(14,"-")
      $netAdapter+='|Where-Object { $_.macAddress -like '+"'$vmMac'}"}
    $commandIP=$netAdapter+"|New-NetIPAddress -errorAction silentlyContinue -AddressFamily IPv4 -IPAddress $ipAddress -PrefixLength $ipSubnet"
    $commandRemove=$netAdapter+'|Remove-NetIPAddress -errorAction silentlyContinue -confirm $false|out-null'
    if ($ipGateway) {$commandIp+=" -DefaultGateway '$ipGateway'"}
    set-ib1VMNotes $VM2custo.name -TextNotes "Customisation de la VM ($commandRemove)."
    $commandRemove=[scriptblock]::Create($commandRemove)
    Invoke-Command -VMName $VM2custo.name -Credential $credential -ScriptBlock $commandRemove
    set-ib1VMNotes $VM2custo.name -TextNotes "Customisation de la VM ($commandIP)."
    $commandIP=[scriptblock]::Create($commandIP+'|out-null')
    Invoke-Command -VMName $VM2custo.name -Credential $credential -ScriptBlock $commandIP
    if ($dNSServers) {
      write-ib1log -progressTitleLog "Traitement de la VM '$($VM2custo.name)." "Changement des serveurs DNS"
      set-ib1VMNotes $VM2custo.name -TextNotes "Customisation de la VM (Set-DnsClientServerAddress -InterfaceAlias (($netAdapter).interfaceAlias) -ServerAddresses $dNSServers)."
      $commandDNS=[scriptblock]::create("Set-DnsClientServerAddress -InterfaceAlias (($netAdapter).interfaceAlias) -ServerAddresses $dNSServers")
      Invoke-Command -VMName $VM2custo.name -Credential $credential -ScriptBlock $commandDNS}}
  if ($rearm) {
    write-ib1log -progressTitleLog "Traitement de la VM '$($VM2custo.name)." "Réarmement du système"
    set-ib1VMNotes $VM2custo.name -TextNotes "Customisation de la VM (cscript c:\windows\system32\slmgr.vbs -rearm)."
    Invoke-Command -VMName $VM2custo.name -Credential $credential -ScriptBlock {cscript c:\windows\system32\slmgr.vbs -rearm}|out-null}
  if ($VMcommand) {
    write-ib1log -progressTitleLog "Traitement de la VM '$($VM2custo.name)." "Lancement de commande"
    Start-Sleep -Seconds 10
    set-ib1VMNotes $VM2custo.name -TextNotes "Customisation de la VM ($VMcommand)."
    $command=[scriptblock]::Create($VMcommand+'|out-null')
    Invoke-Command -VMName $VM2custo.name -Credential $credential -ScriptBlock $command}
  if ($vmState -like 'Off') {
    write-ib1log -progressTitleLog "Traitement de la VM '$($VM2custo.name)." "Extinction de la VM."
    Stop-VM $VM2custo -Force
    while ($VM2custo.state -notlike 'Off') {sleep -Milliseconds 1000}}
  if (-not $noCheckpoint) {
    write-ib1log -progressTitleLog "Traitement de la VM '$($VM2custo.name)." "Checkpoint de la VM."
      Checkpoint-VM -VM $VM2custo -SnapshotName "Set-ib1VMCusto"}
  write-ib1log -progressTitleLog "Traitement de la VM '$($VM2custo.name)."}}}

function copy-ib1VM {
<#
.SYNOPSIS
Cette commande permet de copier une machine virtuelle existante en en créant une nouvelle basée sur le disque de l'originale.
(Ne fonctionne que sur les VMs éteintes au moment ou la commande est lancée)
.PARAMETER VMName
Nom de la VM à copier (agit sur toutes les VMs si paramêtre non spécifié)
.PARAMETER exactVMName
Permet de spécifier que le nom de la VM fourni est précisément le nom de la VM à traiter.
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
[switch]$noCheckpoint=$false,
[switch]$exactVMName)
begin{get-ib1elevated $true; if ($VMsuffix -eq '' -and $VMprefix -eq '') {write-ib1log "Attention, commande nécessitant soit un préfixe, soit un suffixe pour le nom de la VM clonée." -ErrorLog}}
process {
if ($VMsuffix -ne '') {$VMsuffix="-$VMsuffix"}
if ($VMprefix -ne '') {$VMprefix="-$VMprefix"}
$VMs2copy=get-ib1VM -VMName $VMName -exactVMName $exactVMName
foreach ($VM2copy in $VMs2copy) {
  if ($VM2copy.state -ine 'off') {write-ib1log "La VM $($VM2copy.name) n'est pas éteinte et ne sera pas traitée" -warningLog}
  else {
    write-ib1log -progressTitleLog "Copie de la VM $($VM2copy.name)" "Création des dossiers."
    $vmCopyName="$VMprefix$($VM2copy.name)$VMsuffix"
    $vmCopyPath="$(split-path -path $VM2copy.path -parent)\$($vmCopyName)"
    New-Item $vmCopyPath -ItemType directory -ErrorAction SilentlyContinue -ErrorVariable createDir|out-null
    New-Item "$vmCopyPath\Virtual Hard Disks" -ItemType directory -ErrorAction SilentlyContinue|out-null
    foreach ($VHD2copy in $VM2copy.HardDrives) {
      write-ib1log -progressTitleLog "Copie de la VM $($VM2copy.name)" "Copie du dossier $(split-path -path $VHD2copy.path -parent)."
      Copy-Item "$(split-path -path $VHD2copy.path -parent)\" $vmCopyPath -Recurse -ErrorAction SilentlyContinue}
    write-ib1log -progressTitleLog "Copie de la VM $($VM2copy.name)" "Création du disque dur original."
    $newVMdrive0 = "$vmCopyPath\$(split-path (split-path -path $vm2copy.HardDrives[0].path -parent) -leaf)\$(split-path -path $VM2copy.HardDrives[0].path -leaf)"
    write-ib1log -progressTitleLog "Copie de la VM $($VM2copy.name)" "Création de la VM."
    $newVM=new-vm -Name $vmCopyName -VHDPath $newVMdrive0 -MemoryStartupBytes ($VM2copy.MemoryMinimum*8) -Path $(split-path -path $vmCopyPath -Parent) 
    if ($VM2copy.ProcessorCount -gt 1) {
      write-ib1log -progressTitleLog "Copie de la VM $($VM2copy.name)" "Affectation de $($VM2copy.ProcessorCount) processeurs"
      Set-VMProcessor -VMName $vmCopyName -Count $VM2copy.ProcessorCount}
    if ($VM2copy.DynamicMemoryEnabled) {
      write-ib1log -progressTitleLog "Copie de la VM $($VM2copy.name)" "Mise en place des paramètres de mémoire dynamique."
      $VM2copyMemory=Get-VMMemory $VM2copy.name
      Set-VMMemory $vmCopyName -DynamicMemoryEnabled $true -MinimumBytes $VM2copyMemory.Minimum -StartupBytes $VM2copyMemory.Startup -MaximumBytes $VM2copyMemory.Maximum -Buffer $VM2copyMemory.Buffer -Priority $VM2copyMemory.Priority}
    write-ib1log -progressTitleLog "Copie de la VM $($VM2copy.name)" "Création du lecteur DVD original."
    $vm2copyDVD=(Get-VMDvdDrive -VMName $VM2copy.name)[0]
    Set-VMDvdDrive $vmCopyName -Path $vm2copyDVD.Path -ControllerNumber $vm2copyDVD.ControllerNumber -ControllerLocation $vm2copyDVD.ControllerLocation
    if ($VM2copy.DVDDrives.count -gt 1) {
      write-ib1log -progressTitleLog "Copie de la VM $($VM2copy.name)" "Ajout de lecteur(s) DVD supplémentaire(s)."
      $vm2copyDVDs=Get-VMDvdDrive -VMName $VM2copy.name
      for ($i=1;$i -lt $VM2copy.DVDDrives.count;$i++) {
        $vm2copyDVD=(Get-VMDvdDrive -VMName $VM2copy.name)[$i]
        Add-VMDvdDrive $vmCopyName -Path $vm2copyDVD.Path -ControllerNumber $vm2copyDVD.ControllerNumber -ControllerLocation $vm2copyDVD.ControllerLocation}}
    if ($VM2copy.HardDrives.Count -gt 1) {
      write-ib1log -progressTitleLog "Copie de la VM $($VM2copy.name)" "Ajout de(s) disque(s) suppkémentaire."
      for ($i=1;$i -lt $VM2copy.HardDrives.Count;$i++) {
        $newVMdrive="$vmCopyPath\$(split-path (split-path -path $VM2copy.HardDrives[$i].path -parent) -leaf)\$(split-path -path $VM2copy.HardDrives[$i].path -leaf)"
        Add-VMHardDiskDrive -VMName $vmCopyName -Path $newVMdrive -ControllerType $vm2copy.HardDrives[$i].ControllerType -ControllerNumber $vm2copy.HardDrives[$i].ControllerNumber -ControllerLocation $vm2copy.HardDrives[$i].ControllerLocation}}
    if ($VM2copy.NetworkAdapters[0].Connected) {
      write-ib1log -progressTitleLog "Copie de la VM $($VM2copy.name)" "Connection de la carte réseau initiale au réseau '$($VM2copy.NetworkAdapters[0].SwitchName)'."
      Connect-VMNetworkAdapter -VMName $vmCopyName -SwitchName $VM2copy.NetworkAdapters[0].SwitchName}
    else {
      Disconnect-VMNetworkAdapter -VMName $vmCopyName}
    if ($VM2copy.NetworkAdapters.Count -gt 1) {
      write-ib1log -progressTitleLog "Copie de la VM $($VM2copy.name)" "Connexion de carte(s) réseau supplémentaire(s)."
      for ($i=1;$i -lt $VM2copy.NetworkAdapters.Count;$i++) {
        if ($VM2copy.NetworkAdapters[$i].connected) {
          Add-VMNetworkAdapter -VMName $vmCopyName -SwitchName $VM2copy.NetworkAdapters[$i].SwitchName}
        else {
          Add-VMNetworkAdapter -VMName $vmCopyName}}
          }}
  if (-not $noCheckpoint) {
      write-ib1log -progressTitleLog "Copie de la VM $($VM2copy.name)" "Création du checkpoint ib1Copy"
      Checkpoint-VM -VM $newVM -SnapshotName "ib1Copy"}
  write-ib1log -progressTitleLog "Copie de la VM $($VM2copy.name)"
  set-ib1VMNotes $newVM.Name -TextNotes "VM Copiée depuis '$($VM2copy.name)'."
  write-ib1log 'Pensez à mettre à jour la configuration IP des cartes réseau qui ont été créées dans la machine virtuelle.' -warningLog}}}

function repair-ib1VMNetwork {
<#
.SYNOPSIS
Cette commande permet de vérifier l'état de la carte réseau d'une VM et, le cas échéant, de relancer cette carte.
Cette commande est particulièrement utile sur un DC première machine virtuelle à démarrer.
Prérequis : cette commande utilise du Powershell Direct et ne fonctionne que si la VM est en version 8/2012 au minimum.
.PARAMETER VMName
Nom de la VMs à vérifier (si ce paramètre est omis, toutes les VMs allumées seront vérifiées - Attention à l'ordre).
.PARAMETER exactVMName
Permet de spécifier que le nom de la VM fourni est précisément le nom de la VM à traiter.
.PARAMETER userName
Nom d'utilisateur (sous la forme 'Domain\user' si nécessaire).
.EXAMPLE
repair-ib1VMNetwork -VMName 'lon-dc1' -username 'adatum\administrator'
Se connecte sur la VM lon-dc1 pour vérifier l'état de sa carte réseau et la relance si elle ne s'est pas découverte en réseau de domaine.
#>
[CmdletBinding(
DefaultParameterSetName='VMName')]
PARAM(
[string]$VMName,
[parameter(Mandatory=$true,ValueFromPipeLine=$true,HelpMessage="Nom de connexion de l'administrateur de la VM.")]
[string]$userName,
[switch]$exactVMName)
begin{get-ib1elevated $true}
process {
$VMs2Repair=get-ib1VM -VMName $VMName -exactVMName $exactVMName
$userPass2=read-host "Mot de passe de '$userName'" -AsSecureString
$cred=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userName,$userPass2
foreach ($VM2repair in $VMs2Repair) {
  if ((get-vm $VM2repair.name).heartbeat -notlike '*OK*') {write-ib1log "La VM '$($VM2repair.name)' n'est pas dans un état démarré correct, son réseau ne sera pas vérifié." -warningLog}
  elseif (!(test-ib1PSDirect -VMName $VM2repair.name)) {write-ib1log "Powershell Direct n'est pas disponible sur la VM '$($VM2repair.name)': son réseau ne sera pas vérifié." -warningLog}
  else {
    set-ib1VMNotes $VM2repair.name -TextNotes "Vérification/Réparation du réseau."
    $netStatus=''
    $warningDisplay=$true
    while ($netStatus -notlike '*domain*') {
      try {$netStatus=(Invoke-Command -VMName $VM2repair.name -Credential $cred -ScriptBlock {(Get-NetConnectionProfile).NetworkCategory} -ErrorAction stop).value}
      catch {
        write-ib1log "Il ne semble pas possible de faire du Powershell Direct sur la VM '$($VM2repair.name)'. merci de vérifier les prérequis et le comtpe utilisé!" -warningLog
        $netStatus='domain'}
      if ($netStatus -notlike '*domain*') {
        if ($warningDisplay) {
          write-ib1log "Le réseau de la VM '$($VM2repair.name)' n'est pas en mode domaine, redémarrage de la(des) carte(s)." -warningLog
          Start-Sleep -s 10
          $warningDisplay=$false}
        Invoke-Command -VMName $VM2repair.name -Credential $cred -ScriptBlock{get-netadapter|restart-netadapter}}}}}}}

function start-ib1SavedVMs {
<#
.SYNOPSIS
Cette commande permet de démarrer les VMs qui sont en état "Enregistré" sur un un serveur Hyper-V
.PARAMETER First
Nom de la première VMs à démarrer. si ce paramètre est fourni, la commande attendra que cette VM soit correctement démarrée avant de démarrer les suivantes.
(Le nom à forunir doit être l'exacte FIN du nom de la VM)
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
begin{get-ib1elevated $true}
process {
if ($FirstRepairNet -and $First -eq $null) {write-ib1log "Le paramètre '-FirstRepairNet' ne peut être passé sans le paramètre '-First'" -ErrorLog}
if ($First -ne '') {
  $FirstVM2start=get-vm -Name *$First -ErrorAction SilentlyContinue
  if ($FirstVM2start.count -gt 1) {write-ib1log "iL y a $($FirstVM2start.count) VMs qui correspondent au nom '$First'" -ErrorLog}
  elseif ($FirstVM2start.count -eq 0) {write-ib1log "Il y n'y a aucune VM enregistrée qui corresponde au nom '$First'" -ErrorLog}}
if ($DontRevert -eq $false) {
  write-ib1log "Rétablissement des VMs avant démarrage" -DebugLog
  reset-ib1VM}
if ($First -ne '') {
  write-ib1log "Attente du démarrage de la VM '$First'." -DebugLog
  start-ib1VMWait ($First)}
$VMs2Start=get-ib1VM ('')
foreach ($VM2start in $VMs2start) {
  if ($VM2Start.state -like '*saved*') {
    write-ib1log "Démarrage de la VM '$($VM2Start.name)'." -DebugLog
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
.PARAMETER TaskBar
Si cette option est renseignée, le raccourci sera également épinglé sur la barre des tâches.
.PARAMETER Params
Cette option permet de rajouter des paramètres spécifiques après le fichier appelé
.PARAMETER Icon
Cette option permet de rajouter la référence de l'icône si nécessaire
.PARAMETER Dest
Emplacement du raccourci (par défaut sur le bureau)
.EXAMPLE
new-ib1Shortcut -URL 'https://www.ib-formation.fr'
Crée un raccourci sur le bureau qui sera nommé en fonction du titre du site web
#>
PARAM(
[string]$File='',
[uri]$URL='',
[string]$title='',
[switch]$TaskBar=$false,
[string]$Params='',
[string]$icon='',
[string]$dest='')
begin{get-ib1elevated $true}
process {
if ((($File -eq '') -and ($URL -eq '')) -or (($File -ne '') -and ($URL -ne ''))) {write-ib1log "Cette commande nécessite un et un seul paramètre '-File' ou '-URL'" -ErrorLog}
if ($URL -ne '') {
  if ($title -eq '') {
    write-ib1log "Recherche du titre du site Web pour nommer le raccourci" -DebugLog
    $title=((Invoke-WebRequest $URL).parsedHtML.getElementsByTagName('title')[0].text) -replace ':','-' -replace '\\','-'}
  $title=$title+'.url'
  $target=$URL.ToString()}  
else {
  if ($title -eq '') {
    write-ib1log "Récupération du nom du fichier pour nommer le raccourci" -DebugLog
    $title=([io.path]::GetFileNameWithoutExtension($File))}
  $title=$title+'.lnk'
  $target=$File}
$WScriptShell=new-object -ComObject WScript.Shell
if ($dest -eq '') {$dest=[Environment]::GetFolderPath('CommonDesktopDirectory')}
$shortcut=$WScriptShell.createShortCut("$dest\$title")
$shortcut.TargetPath=$target
if ($Params -ne '') {$shortcut.Arguments=$Params}
if ($icon -ne '') {$shortcut.IconLocation=$Icon}
write-ib1log "Création du raccourci '$title'." -DebugLog
$shortcut.save()
if ($TaskBar -and $URL -eq '') {
  #Ajout du raccourci à la barre des tâches
  new-ib1TaskBarShortcut -Shortcut "$dest\$title"}}}

function invoke-ib1Clean {
<#
.SYNOPSIS
Cette commande permet de lancer le nettoyage de toutes les machines du réseau local
.PARAMETER Delay
Ancienneté (en jours, 7 par défaut) maximum des éléments qui seront supprimés lors du nettoyage
.PARAMETER SubNet
Ce paramètre permet de spécifier (sous la forme X.Y.Z) le sous-réseau sur lequel lancer le nettoyage.
Par défaut, le sous-réseau local connecté à la machine est utilisé.
.PARAMETER GetCred
Ce switch permet de demander le nom et mot de passe de l'utilisateur à utiliser pour la connexion WinRM et le nettoyage
S'il est omis, les identifiants de l'utilisateur connecté localement seront utilisés.
.EXAMPLE
invoke-ib1Clean
Supprime les élents plus anciens que 7 jours des machines du réseau local.
#>
[CmdletBinding(DefaultParameterSetName='delay')]
param(
[int]$Delay=7,
[string]$SubNet,
[switch]$GetCred)
begin{get-ib1elevated $true}
process {
#$subNet=get-ib1Subnet -subnet $SubNet
if ($GetCred) {
  $cred=Get-Credential -Message "Merci de saisir le nom et mot de passe du compte administrateur WinRM à utiliser pour éxecuter le nettoyage"
  if (-not $cred) {write-ib1log "Arrêt suite à interruption utilisateur lors de la saisie du Nom/Mot de passe" -warningLog
    break}}
$computers=get-ib1NetComputers $SubNet
$saveTrustedHosts=set-ib1WinRM
$command='$userDir=(get-item $env:USERPROFILE).parent.FullName;$dirsToClean=@("Desktop","Documents","Downloads","AppData\Local\google\Chrome\User Data\Default");$userSubDirs=Get-ChildItem $userDir;foreach ($userSubDir in $userSubDirs) {foreach ($dirToClean in $dirsToClean) {Get-ChildItem -recurse "$userDir\$userSubDir\$dirToClean"|where lastWriteTime -GE (get-date).AddDays(-'+$Delay+')|remove-item -recurse -force}};runDll32.exe inetCpl.cpl,ClearMyTracksByProcess 255;Remove-Item -Path ''C:\$Recycle.Bin'' -Recurse -Force'
foreach ($computer in $computers.Keys) {
  $commandNoError=$true
  try {
    if ($GetCred) {$commandOut=(invoke-command -ComputerName $computer -ScriptBlock ([scriptBlock]::create($command)) -Credential $cred -ErrorAction Stop)}
    else {$commandOut=(invoke-command -ComputerName $computer -ScriptBlock ([scriptBlock]::create($command)) -ErrorAction Stop)}}
  catch {
   $commandNoError=$false
   if ($_.Exception.message -ilike '*Access is denied*' -or $_.Exception.message -ilike '*Accès refusé*') {write-ib1log "[$computer] Accès refusé." -colorLog Red}
   else {
     write-ib1log "[$computer] Erreur: $($_.Exception.message)" -colorLog Red
     $_.Exception.message}}
  if ($commandNoError) {
    write-ib1log "[$computer] Machine nettoyée." -colorLog Green}}
Set-Item WSMan:\localhost\Client\TrustedHosts -value $saveTrustedHosts -Force}}

function invoke-ib1Rearm {
<#
.SYNOPSIS
Cette commande permet de lancer le réarmement Windows de toutes les machines du réseau local
.PARAMETER SubNet
Ce paramètre permet de spécifier (sous la forme X.Y.Z) le sous-réseau sur lequel lancer le nettoyage.
Par défaut, le sous-réseau local connecté à la machine est utilisé.
.PARAMETER GetCred
Ce switch permet de demander le nom et mot de passe de l'utilisateur à utiliser pour la connexion WinRM et le nettoyage
S'il est omis, les identifiants de l'utilisateur connecté localement seront utilisés.
.EXAMPLE
invoke-ib1Rearm
Réarme le système Windows des machines du réseau local, suivi d'un redémarage.
#>
param(
[string]$SubNet,
[switch]$GetCred)
begin{get-ib1elevated $true}
process {
if ($GetCred) {
  $cred=Get-Credential -Message "Merci de saisir le nom et mot de passe du compte administrateur WinRM à utiliser pour éxecuter le réarmement"
  if (-not $cred) {write-ib1log "Arrêt suite à interruption utilisateur lors de la saisie du Nom/Mot de passe" -warningLog
    break}}
$computers=get-ib1NetComputers $SubNet -Nolocal $true
$saveTrustedHosts=set-ib1WinRM
$command="$env:windir\system32\slmgr.vbs -rearm"
foreach ($computer in $computers.Keys) {
  $commandNoError=$true
  try {
    if ($GetCred) {$commandOut=(invoke-command -ComputerName $computer -ScriptBlock ([scriptBlock]::create($command)) -Credential $cred -ErrorAction Stop)}
    else {$commandOut=(invoke-command -ComputerName $computer -ScriptBlock ([scriptBlock]::create($command)) -ErrorAction Stop)}}
  catch {
   $commandNoError=$false
   if ($_.Exception.message -ilike '*Access is denied*' -or $_.Exception.message -ilike '*Accès refusé*') {write-ib1log "[$computer] Accès refusé." -colorLog Red}
   else {
     write-ib1log "[$computer] Erreur: $($_.Exception.message)" -colorLog Red
     $_.Exception.message}}
  if ($commandNoError) {
    if ($GetCred) {invoke-command -ComputerName $computer -ScriptBlock ([scriptBlock]::create('restart-computer -force')) -Credential $cred}
    else {invoke-command -ComputerName $computer -ScriptBlock ([scriptBlock]::create('restart-computer -force'))}
    write-ib1log "[$computer] Machine réarmée, redémarrage en cours." -colorLog Green}}
if ($subnet) {
  invoke-command -ScriptBlock ([scriptBlock]::create($command))
  write-ib1log "Machine locale réarmée, pensez à la redémarrer..." -warningLog}
Set-Item WSMan:\localhost\Client\TrustedHosts -value $saveTrustedHosts -Force}}

function invoke-ib1netCommand {
<#
.SYNOPSIS
Cette commande permet de lancer une commande/un programme sur toutes les machines du réseau local
.PARAMETER Command
Syntaxe complète de la commande à lancer
.PARAMETER NoLocal
Ce switch permet de ne pas lancer la commande cible sur la machine locale.
.PARAMETER SubNet
Ce paramètre permet de spécifier (sous la forme X.Y.Z) le sous-réseau sur lequel lancer la commande.
Par défaut, le sous-réseau local connecté à la machine est utilisé.
.PARAMETER GetCred
Ce switch permet de demander le nom et mot de passe de l'utilisateur à utiliser pour la connexion WinRM et la commande
S'il est omis, les identifiants de l'utilisateur connecté localement seront utilisés.
.EXAMPLE
invoke-ib1netCommand -NoLocal -Command 'stop-computer -force'
Eteind toutes les machines du réseau local dont l'accès est permis.
#>
[CmdletBinding(DefaultParameterSetName='Command')]
param(
[parameter(Mandatory=$true,ValueFromPipeLine=$true,HelpMessage="Commande à lancer sur les machines accessibles sur le réseau local.")]
[string]$Command,
[switch]$NoLocal,
[string]$SubNet,
[switch]$GetCred)
begin{get-ib1elevated $true}
process {
if ($GetCred) {
  $cred=Get-Credential -Message "Merci de saisir le nom et mot de passe du compte administrateur WinRM à utiliser pour éxecuter la commande '$Command'"
  if (-not $cred) {
    write-ib1log "Arrêt suite à interruption utilisateur lors de la saisie du Nom/Mot de passe" -warningLog
    break}}
$computers=get-ib1NetComputers $SubNet -Nolocal $NoLocal
$saveTrustedHosts=set-ib1WinRM
foreach ($computer in $computers.Keys) {
  $commandNoError=$true
  try {
    if ($GetCred) {$commandOut=(invoke-command -ComputerName $computer -ScriptBlock ([scriptBlock]::create($command)) -Credential $cred -ErrorAction Stop)}
    else {$commandOut=(invoke-command -ComputerName $computer -ScriptBlock ([scriptBlock]::create($command)) -ErrorAction Stop)}}
  catch {
   $commandNoError=$false
   if ($_.Exception.message -ilike '*Access is denied*' -or $_.Exception.message -ilike '*Accès refusé*') {write-ib1log "[$computer] Accès refusé." -colorLog Red}
   else {
     write-ib1log "[$computer] Erreur: $($_.Exception.message)" -colorLog Red
     $_.Exception.message}}
  if ($commandNoError) {
    if ($commandOut) {
      write-ib1log "[$computer] Résultat de la commande:`n$commandOut" -colorLog Green
      $commandOut}
    else {write-ib1log "[$computer] Commande executée." -colorLog Green}}}
Set-Item WSMan:\localhost\Client\TrustedHosts -value $saveTrustedHosts -Force}}
  
function complete-ib1Setup{
<#
.SYNOPSIS
Cette commande permet de finaliser/réparer l'installation de la machine hôte ib
#>
get-ib1elevated $true
write-ib1log "Désactivation de l'UAC" -DebugLog
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name “ConsentPromptBehaviorAdmin” -Value “0”
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name “PromptOnSecureDesktop” -Value “0”
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA -PropertyType DWord -Value 0 -Force -ErrorAction SilentlyContinue|out-null
write-ib1log "Passage du clavier en Français sur environement en-US" -DebugLog
$langList=New-WinUserLanguageList en-US
$langList[0].inputMethodTips.clear()
$langList[0].inputmethodTips.add('0409:0000040c')
Set-WinUserLanguageList $langList -Force
write-ib1log -progressTitleLog "Mise en place des options nécessaires pour WinRM" "Passage des réseaux en privé."
Get-NetConnectionProfile|where {$_.NetworkCategory -notlike '*Domain*'}|Set-NetConnectionProfile -NetworkCategory Private
Set-ItemProperty –Path HKLM:\System\CurrentControlSet\Control\Lsa –Name ForceGuest –Value 0 -Force
write-ib1log -progressTitleLog "Mise en place des otpion nécessaires pour WinRM" "Activation de PSRemoting."
Enable-PSRemoting -Force -SkipNetworkProfileCheck |out-null
write-ib1log -progressTitleLog "Mise en place des otpion nécessaires pour WinRM"
if ((Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online).state -notlike 'enabled') {
  write-ib1log 'Installation de Hyper-V' -DebugLog
  Enable-WindowsOptionalFeature -Online -FeatureName:Microsoft-Hyper-V-All -NoRestart -WarningAction SilentlyContinue|out-null
  write-ib1log "Merci de redémarrer la machine et de relancer la commande après redémarrage pour finaliser la confirguration!" -warningLog
  break}
else {
  if ((get-VMHost).EnableEnhancedSessionMode) {
    write-ib1log "Désactivation de la stratégie de session avançée d'Hyper-V." -DebugLog
    Set-VMHost -EnableEnhancedSessionMode $false}}
write-ib1log 'Création de la tâche de lancement de ibInit' -DebugLog
if (Get-ScheduledTask -TaskName 'Lancement ibInit' -ErrorAction 0) {
  write-ib1log "Supression de l'ancienne tâche ibInit" -DebugLog
  Get-ScheduledTask -TaskName 'Lancement ibInit'|unregister-scheduledTask -confirm:0}
$moduleVersion=(get-Module -ListAvailable -Name ib1|sort-object|select-object -last 1).version.tostring()
write-ib1log "Création de la tâche de mise à jour du module et de lancement de ibInit.ps1" -DebugLog
$PSTask1=New-ScheduledTaskAction -Execute 'powershell.exe' -argument '-noprofile -windowStyle Hidden -command "& set-executionpolicy bypass -force; $secondsToWait=10; While (($secondsToWait -gt 0) -and (-not(test-NetConnection))) {$secondsToWait--;start-sleep 1}; if (get-module -ListAvailable -name ib1) {update-module ib1 -force} else {install-module ib1 -force};Get-NetConnectionProfile|Set-NetConnectionProfile -NetworkCategory Private"'
$PSTask2= New-ScheduledTaskAction -Execute 'powershell.exe' -argument ('-noprofile -windowStyle Hidden -command "'+"& $env:ProgramFiles\windowspowershell\Modules\ib1\$moduleVersion\ibInit.ps1"+'"')
$PSTaskUpdate1=New-ScheduledTaskAction -Execute 'powershell.exe' -argument '-noprofile -windowStyle Hidden -command "& {Get-Service *wuauserv*|stop-service -passthru|set-service -StartupType disabled -Status Stopped}"'
$PSTaskUpdate2=New-ScheduledTaskAction -Execute 'powershell.exe' -argument '-noprofile -windowStyle Hidden -command "& {Get-Service *BITS*|stop-service -passthru|set-service -StartupType disabled -Status Stopped}"'
$PSTaskUpdate3=New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-noprofile -windowStyle Hidden -command "& {Get-Service *dosvc*|stop-service -passthru|set-service -StartupType disabled -Status Stopped}"'
$trigger=New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -Action $PSTask1,$PSTask2,$PSTaskUpdate1,$PSTaskUpdate2,$PSTaskUpdate3 -AsJob -TaskName 'Lancement ibInit' -Description "Lancement de l'initialisation ib" -Trigger $trigger -user 'NT AUTHORITY\SYSTEM' -RunLevel Highest|out-null
write-ib1log 'Création des raccourcis sur le bureau' -DebugLog
new-ib1Shortcut -URL 'https://eval.ib-formation.com/avis' -title 'Mi-parcours'
new-ib1Shortcut -URL 'https://eval.ib-formation.com' -title 'Evaluations'
new-ib1Shortcut -URL 'https://docs.google.com/forms/d/e/1FAIpQLSfH3FiI3_0Gdqx7sIDtdYyjJqFHHgZa2p75m8zev7bk2sT2eA/viewform?c=0&w=1' -title 'Evaluation du distanciel'
new-ib1Shortcut -File "$env:AppDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows Powershell.lnk" -TaskBar
$ShortcutShell=New-Object -ComObject WScript.Shell
$formateurShortcut=$true
Get-ChildItem -Recurse ([Environment]::GetFolderPath('CommonDesktopDirectory')),$env:USERPROFILE\desktop -include *.lnk|foreach-object {if ($ShortcutShell.CreateShortcut($_).targetpath -like "\\$trainerComputerName\partage") {$formateurShortcut=$false}}
if ($formateurShortcut) { new-ib1Shortcut -File "\\$trainerComputerName\partage" -title 'Partage Formateur'}
new-ib1Shortcut -File '%windir%\System32\mmc.exe' -Params '%windir%\System32\virtmgmt.msc' -title 'Hyper-V Manager' -icon '%ProgramFiles%\Hyper-V\SnapInAbout.dll,0' -TaskBar
new-ib1Shortcut -File '%SystemRoot%\System32\shutdown.exe' -Params '-s -t 0' -title 'Eteindre' -icon '%SystemRoot%\system32\SHELL32.dll,27'
if (!(Get-SmbShare partage -ErrorAction SilentlyContinue)) {
  write-ib1log 'Création du partage pour le poste Formateur.' -DebugLog
  md C:\partage|out-null
  New-SmbShare partage -Path c:\partage -ChangeAccess everyone|out-null}
write-ib1log 'Activation de la connexion et des règles firewall pour RDP' -DebugLog
set-itemProperty -Path 'HKLM:\System\CurrentControlSet\Control\terminal Server' -name 'fDenyTSConnections' -Value 0
Enable-netFireWallRule -DisplayGroup 'Remote Desktop' -erroraction SilentlyContinue|out-null
Enable-netFirewallRule -DisplayGroup 'File and Printer Sharing' -erroraction SilentlyContinue|out-null
Enable-netFirewallRule -DisplayGroup "Partage de fichiers et d'imprimantes" -erroraction SilentlyContinue|out-null
Enable-netFirewallRule -DisplayGroup 'Bureau à distance' -erroraction SilentlyContinue|out-null
set-itemProperty -path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value 0
write-ib1log 'Changement du mot de passe utilisateur' -DebugLog
([adsi]'WinNT://./ib').SetPassword('Pa55w.rd')
write-ib1log 'Désactivation des mises à jour automatiques' -DebugLog
@('wuauserv','BITS')|foreach {Get-Service *$_*|stop-service; Get-Service *$_*|set-service -StartupType disabled -Status Stopped}
write-ib1log "Configuration des options d'alimentation" -DebugLog
powercfg /hibernate off
powercfg /SETACTIVE SCHEME_BALANCED
powercfg /SETDCVALUEINDEX SCHEME_BALANCED SUB_SLEEP STANDBYIDLE 0|Out-Null
powercfg /SETACVALUEINDEX SCHEME_BALANCED SUB_SLEEP STANDBYIDLE 0|Out-Null
powercfg /SETDCVALUEINDEX SCHEME_BALANCED SUB_VIDEO VIDEOIDLE 0|Out-Null
powercfg /SETACVALUEINDEX SCHEME_BALANCED SUB_VIDEO VIDEOIDLE 0|Out-Null
powercfg /SETACVALUEINDEX SCHEME_BALANCED SUB_BUTTONS PBUTTONACTION 3|Out-Null
write-ib1log "Désactivation des notifications système" -DebugLog
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type DWord -Value 0
$ibpptUrl="https://raw.githubusercontent.com/renaudwangler/ib/master/extra/$ibppt"
if (-not(Get-Childitem -Path ([Environment]::GetFolderPath('CommonDesktopDirectory')+"\$ibppt") -ErrorAction SilentlyContinue)) {
  write-ib1log "Copie de la présentation ib sur le bureau depuis github." -DebugLog
  invoke-webRequest -uri $ibpptUrl -OutFile ([Environment]::GetFolderPath('CommonDesktopDirectory')+"\$ibppt")}
elseif ((Get-Childitem -Path ([Environment]::GetFolderPath('CommonDesktopDirectory')+"\$ibppt")).length -ne  (Invoke-WebRequest -uri $ibpptUrl -Method head -UseBasicParsing).headers.'content-length') {
  write-ib1log "Présentation ib à priori pas à jour: Copie de la présentation ib sur le bureau depuis github." -DebugLog
  Remove-Item -Path ([Environment]::GetFolderPath('CommonDesktopDirectory')+"\$ibppt") -Force -ErrorAction SilentlyContinue
  invoke-webRequest -uri $ibpptUrl -OutFile ([Environment]::GetFolderPath('CommonDesktopDirectory')+"\$ibppt")}
write-ib1log 'Installation de la dernière version de Chrome' -DebugLog
install-ib1Chrome
write-ib1log 'Installation de Adobe Acrobat Reader DC' -DebugLog
if (-not($adobereaderPath=(Get-ChildItem -Path 'c:\' -Filter *AcroRd?2.exe -Recurse -ErrorAction SilentlyContinue).FullName)) {
  $destination = "$env:TEMP\adobeDC.exe"
  Invoke-WebRequest $adobeReaderUrl -OutFile $destination
  Start-Process -FilePath $destination -ArgumentList "/sPB /rs"
  Start-Sleep -s 60
  rm -Force $destination}
write-ib1log 'Installation de Adobe Acrobat Reader DC' -DebugLog
  $destination="c:\TeamViewerQS.exe"
if (-not(test-path $destination)) {
  write-ib1log 'Installation du client QuickSupport de TeamViewer' -DebugLog
  Invoke-WebRequest $remoteControlUrl -OutFile $destination}
write-ib1log 'Création de la commande "C:\hypervisor.cmd".' -DebugLog
set-content -Path 'c:\hypervisor.cmd' -Value 'bcdedit /set hypervisorlaunchtype auto'
write-ib1log 'récupération du fichier xml pour le Sysprep' -DebugLog
Invoke-WebRequest -Uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/windows10ib.xml -OutFile "$env:windir\Windows10ib.xml"
write-ib1log 'Création de la commande Sysprep.' -DebugLog
Set-Content -Path "$env:windir\sysprep.cmd" -Value 'c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /shutdown /unattend:c:\windows\windows10ib.xml'
write-ib1log 'Mise en place du fond d''écran ib' -DebugLog
invoke-webRequest -uri https://raw.githubusercontent.com/renaudwangler/ib/master/extra/IBDesktop.png -OutFile "$env:windir\IBDesktop.png"
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name wallpaper -Value "$env:windir\IBDesktop.png"
write-ib1log "Suppression de l'invite de nouveau réseau" -DebugLog
New-Item -Path HKLM:\SYSTEM\CurrentControlSet\Control\Network -Name newNetworkWindowOff|Out-Null
write-ib1log "Nettoyage des applications du Store empèchant la commande Sysprep." -DebugLog
Remove-AppxPackage -Package 'Microsoft.LanguageExperiencePacken-US_18362.4.5.0_neutral__8wekyb3d8bbwe' -AllUsers
Remove-AppxPackage -Package 'Microsoft.LanguageExperiencePacken-GB_18362.6.15.0_neutral__8wekyb3d8bbwe' -AllUsers
Restart-Computer -Force}

function set-ib1VMExternalMac{
<#
.SYNOPSIS
Cette commande permet de changer les adresses MAC des cartes réseau des VM relié a un switch externe
Le dernier octet de l'adresse MAC fixé sera celui de l'adresse IP de la machine physique
L'avnt dernier octet de l'adresse MAC fixé sera un incrément pour chaque carte/VM, commençant à 0.
[Attention] : nécessite un seul switch externe.
[Attention] : ne traite pas les VMs allumées
#>
begin {get-ib1elevated $true}
process {
$extSwitch=(Get-VMSwitch|where switchtype -like '*external').Name
$vmNics=get-vm|Get-VMNetworkAdapter|where SwitchName -eq $extSwitch
$localIp=Get-NetIPAddress -AddressFamily IPv4|where InterfaceAlias -like "*$extSwitch*"
if ($localIP.count -and $localIp.count -ne 1) {
write-ib1log "Problème avec récupération de l'adresse IP de la carte réseau." -warningLog
return}
else {
  $nicCount=0  
  foreach ($vmnic in $vmNics) {
    if ((get-vm -Name $vmnic.vmName).state -notlike 'off') { write-ib1log "- La VM '$($vmnic.VMName)' n'est pas éteinte et ne sera pas traitée..." -warningLog}
    else {
    $newMac=([string]$vmnic.MacAddress.substring(0,8))+('{0:x2}' -f $nicCount)+'{0:x2}' -f [int]$localIp.IPAddress.split('.')[3]
    write-ib1log "- Traitement de la carte '$($vmnic.Name)' de la VM '$($vmnic.VMName)' (changement de l'adresse Mac de '$($vmnic.MacAddress)' vers '$newMac')." -DebugLog
    Set-VMNetworkAdapter -VMNetworkAdapter $vmnic -StaticMacAddress $newMac
    set-ib1VMNotes $vmnic.VMName -TextNotes "Changement de l'adresse Mac de '$($vmnic.MacAddress)' vers '$newMac'."
    $nicCount ++}}}}}

function new-ib1Nat{
<#
.SYNOPSIS
Cette commande permet de créer/paramètrer le réseau NAT d'un hyper-v 2016/windows 10
.PARAMETER Name
Nom du switch virtuel utilisé. si non spécifié, un switch virtuel nommé 'ibNat' sera créé.
Si un vSwitch existant est mentionné, il sera relié au nat, si un vSwitch portant ce nom existe déja il sera lié au réseau Nat.
.PARAMETER GatewayIP
Adresse IP de la passerelle par défaut (pour le switch virtuel NAT). Valeur par défaut : 172.16.0.1
.PARAMETER GatewaySubnet
Adresse de sous-réseau pour le sous-réseau local du NAT. Valeur par défaut : 172.16.0.0/24
.PARAMETER GatewayMask
Longeur du masque de sous-réseau de la passerelle pour le NAT. valeur par défaut : 24
#>
param(
[string]$Name='ibNat',
[string]$GatewayIP='172.16.0.1',
[string]$GatewaySubnet='172.16.0.0',
[string]$GatewayMask=24)
begin {get-ib1elevated $true}
process {
if ((get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online).state -eq 'enabled') {
  if (Get-HNSNetwork|Where-Object id -eq $defaultSwitchId) {
    write-ib1log -progressTitleLog "Paramètrage de Hyper-V" 'Suppression du réseau virtuel nat par défaut'
    Get-HNSNetwork|Where-Object id -eq $defaultSwitchId|Remove-HNSNetwork}
  if (get-VMSwitch|where-object {$_.name -like "*$Name*"}) {
    write-ib1log -progressTitleLog "Paramètrage de Hyper-V" "Récupération du vSwitch '$Name'"
    $ibNat=get-VMSwitch|where-object {$_.name -like $name}
    if ($ibNat.SwitchType -inotlike 'internal') {
      write-ib1log -progressTitleLog "Paramètrage de Hyper-V" "Passage du Switch '$($ibNat.Name)' en Interne."
      Set-VMSwitch -VMSwitch $ibNat -SwitchType Internal}}
  else {
    write-ib1log -progressTitleLog "Paramètrage de Hyper-V" "Création du vSwitch '$Name'"
    $ibNat=New-VMSwitch -SwitchName $Name -switchType Internal|out-null
    $ibNat=get-VMSwitch|where-object {$_.name -like "*$name*"}}
  write-ib1log -progressTitleLog "Paramètrage de Hyper-V" "Configuration du vSwitch '$($ibNat.name)'"
  $ibNatAdapter=(get-NetAdapter|where-object {$_.name -ilike "*($($ibNat.name))*"}).ifIndex
  remove-NetIpAddress -IPAddress $GatewayIP -confirm:0 -ErrorAction 0
  remove-NetNat -confirm:0 -ErrorAction 0
  Start-Sleep 10
  new-netIPAddress -IPAddress $GatewayIP -PrefixLength $GatewayMask -InterfaceIndex $ibNatAdapter|out-null
  new-NetNat -name $ibNat.name -InternalIPInterfaceAddressPrefix "$GatewaySubnet/$GatewayMask"|out-null
  write-ib1log -progressTitleLog "Paramètrage de Hyper-V"}
else {write-ib1log "La fonctionnalité Hyper-V n'est pas installée, merci de vérifier !" -ErrorLog}}}

function install-ib1Chrome {
<#
.SYNOPSIS
Cette commande permet d'installer la dernière version du navigateur Chrome de Google.
.PARAMETER Force
Lance l'installation même si une version de Chrome est déja présente.
#>
PARAM(
[switch]$Force=$false)
begin{get-ib1elevated $true}
process {
if ((-not (Get-WmiObject -Class win32_product|where name -like '*chrome*')) -or $Force) {
  $ChromeDL="https://dl.google.com/tag/s/appguid={8A69D345-D564-463C-AFF1-A69D9E530F96}&iid={00000000-0000-0000-0000-000000000000}&lang=en&browser=3&usagestats=0&appname=Google%2520Chrome&needsadmin=prefers/edgedl/chrome/install/GoogleChromeStandaloneEnterprise.msi"
  (new-object System.Net.WebClient).DownloadFile($chromeDL,"$env:TEMP\Chrome.msi")
  & "$env:TEMP\Chrome.msi"}}}

function stop-ib1ClassRoom {
<#
.SYNOPSIS
Cette commande permet d'arrêter toutes les machines du réseau local, en terminant par la machine sur laquelle est lançée la commande
.PARAMETER Subnet
Adresse de sous-réseau (si absent, le réseau local sera utilisé)
Nota: Si ce parmaètre est renseigné, la machine locale ne sera pas stoppée en fin d'action.
.PARAMETER GetCred
Si ce switch n'est pas spécifié, l'identité de l'utilisateur actuellement connecté sera utilisé pour stopper les machines.
#>
param(
[string]$Subnet,
[switch]$GetCred)
begin {get-ib1elevated $true}
process {
if ($Subnet) {
  if ($GetCred) {invoke-ib1NetCommand -Command 'stop-Computer -Force' -SubNet $Subnet -GetCred}
  else {invoke-ib1NetCommand 'Stop-Computer -Force' -SubNet $Subnet}}
else {
  if ($GetCred) {invoke-ib1NetCommand -Command 'stop-Computer -Force' -NoLocal -GetCred}
  else {invoke-ib1NetCommand 'Stop-Computer -Force' -NoLocal}
  write-ib1log "Arrêt de la machine locale." -DebugLog
  Stop-Computer -Force}}}

function invoke-ib1TechnicalSupport {
<#
.SYNOPSIS
Cette commande permet d'utiliser des fonctionnalités du repositery Git de l'équipe tehcnique
.PARAMETER Command
Nom de la commande à lancer présente dans le fichier command.md du repo STC
.PARAMETER File
Nom du fichier à copier sur le bureau présent dans le repo STC
.PARAMETER GetCred
Ce switch permet de demander le nom et mot de passe de l'utilisateur à utiliser pour lancer les commandes et script. S'il est omis, l'utilisateur actuellement connecté sera utilisé.
.EXAMPLE
invoke-ib1TechnicalSupport -Command sysprep
Va lancer la commande "sysprep" présente dans le fichier 'commands.ps1' du repo Git du service technique
#>
[CmdletBinding(DefaultParameterSetName='Command')]
param([string]$Command,[string]$File,[string]$Teampassword,[switch]$GetCred)
begin{get-ib1elevated $true}
process {
$stcCommands=read-ib1CourseFile -readUrl https://raw.githubusercontent.com/$TechnicalSupportGit/master/commandes.md -newLine "`n"
if ($Command -eq '' -and $File -eq '') {
  $objPick=foreach ($stcCommand in ($stcCommands|Get-Member -MemberType NoteProperty)) {New-Object psobject -Property @{'Quelle commande lancer'=$stcCommand.Name}}
  $input=$objPick|Out-GridView -Title "ib - Service technique Client" -PassThru
  $Command=$input.'Quelle commande lancer'}
if ($Command -ne '' -and -not $stcCommands.$Command) {write-ib1log "Le paramètre -command ne peut avoir que l'une des valeurs suivantes: $(($stcCommands|Get-Member -MemberType NoteProperty).name -join ', '). Merci de vérifier!" -ErrorLog}
elseif ($Command -ne '') {
  $Command=$stcCommands.$Command
  if ($Command.Contains('[**password**]')) {
    write-ib1log 'La commande appelée necessite un mot de passe, saisie.' -DebugLog
    $commandPass=Read-Host -Prompt 'Mot de passe à utiliser pour la commande appelée'
    $Command=$Command.Replace('[**password**]',$commandPass)}
  if ($GetCred) {
    $cred=Get-Credential -Message "Merci de saisir le nom et mot de passe du compte administrateur WinRM à utiliser pour éxecuter la commande '$Command'"
    if (-not $cred) {
      write-ib1log "Arrêt suite à interruption utilisateur lors de la saisie du Nom/Mot de passe" -warningLog
      break}}
  write-ib1log "Lancement de la commande '$Command'" -DebugLog
  invoke-expression $Command}
  if ($Command -eq '' -or $File -ne '') {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $STCFiles=Invoke-RestMethod -Headers @{Accept='application/vnd.github.v3.full+json'} -uri "https://api.github.com/repos/$TechnicalSupportGit/contents/data" -UseBasicParsing
    if ($File -ne '') {$SelectedFiles=@{name=$File}}
    else {$SelectedFiles=$STCFiles|Select-Object -Property name,size|sort-object -Property name| Out-GridView -Title 'ib - STC - Fichier(s) à copier sur le bureau.' -OutputMode Multiple}
    $STCFiles|ForEach-Object {if ($SelectedFiles.name -contains $_.name) {
      (new-object System.Net.WebClient).DownloadFile($_.download_url,"$($env:PUBLIC)\Desktop\$($_.name)")}}
  }}}
  

#######################
#  Gestion du module  #
#######################
Set-Alias ibReset reset-ib1VM
Set-Alias ibSetup install-ib1Course
Set-Alias set-ib1VhdBoot mount-ib1VhdBoot
Set-Alias get-ib1Git get-ib1repo
set-Alias stc invoke-ib1TechnicalSupport
Set-Alias ibStop stop-ib1ClassRoom
Export-moduleMember -Function install-ib1Chrome,complete-ib1Setup,invoke-ib1NetCommand,new-ib1Shortcut,Reset-ib1VM,Mount-ib1VhdBoot,Remove-ib1VhdBoot,Switch-ib1VMFr,Test-ib1VMNet,Connect-ib1VMNet,Set-ib1TSSecondScreen,Import-ib1TrustedCertificate, Set-ib1VMCheckpointType, Copy-ib1VM, repair-ib1VMNetwork, start-ib1SavedVMs, get-ib1log, get-ib1version, stop-ib1ClassRoom, new-ib1Nat, invoke-ib1Clean, invoke-ib1Rearm, get-ib1Repo, set-ib1VMExternalMac, install-ib1course, set-ib1ChromeLang,set-ib1VMCusto, new-ib1TaskBarShortcut,invoke-ib1TechnicalSupport
Export-ModuleMember -Alias set-ib1VhdBoot,ibreset,complete-ib1Setup,get-ib1Git,ibSetup,stc,ibStop