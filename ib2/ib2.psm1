#URL du fichier json reference ib partage sur OneDrive
$computersInfoUrl = 'https://ibgroupecegos-my.sharepoint.com/:u:/g/personal/distanciel_ib_cegos_fr/EZu4bAqgln5PlEwkMPtryEcB8UL-RJvUxig2GfHESWQjeQ?e=UMd3jn'

function optimize-ibStudentComputer {
  <#
  .DESCRIPTION
  Cette commande est faite pour etre lancée au démarrage de la machine de formation et optimiser son fonctionnement pour la formation en cours.
  #>
  get-ibComputerInfo -force
  if ($global:ibComputerInfo) {
    if ($global:ibComputerInfo.teamsMeeting -ne $null) {new-ibTeamsShortcut -meetingUrl $global:ibComputerInfo.teamsMeeting}
    else {new-ibTeamsShortcut}
    if ($global:ibComputerInfo.share -ne $null) {New-Item -Path "$env:PUBLIC\Desktop" -Name 'Partage de la salle.url' -ItemType File -Value "[InternetShortcut]`nURL=$($global:ibComputerInfo.share)" -Force|out-null}
  }}

function wait-ibNetwork {
  do { $netTest = Test-NetConnection -InformationLevel Quiet }
  until ($netTest) }

function get-ibComputersInfo {
  <#
  .DESCRIPTION
  Cette commande récupère les informations techniques/d'installation depuis le fichier de réference ib (sur oneDrive).
  .PARAMETER force
  Si ce paramètre n'est pas mentionné, la machine pourra conserver les informations déjà récupérées depuis le réseau
  #>
  param ([switch]$force)
  if (!$global:ibComputersInfo -or $force) {
    wait-ibNetwork
    if (!($global:ibComputersInfo = ((invoke-WebRequest -Uri "$computersInfoUrl&download=1" -UseBasicParsing).content|ConvertFrom-Json))) { write-error -message 'Impossible de récuperer les informations des machines ib depuis le partage oneDrive'}}}
function get-ibComputerInfo {
  <#
  .DESCRIPTION
  Cette commande récupere les informations techniques/d'installation sur la machine en cours depuis la réference ib.
  .PARAMETER force
  Si ce paramètre n'est pas mentionné, la machine pourra conserver les informations déjà recupérées depuis le réseau
  #>
  param ([switch]$force)
  if (!$global:ibComputersInfo -or $force) { get-ibComputersInfo -force}
  $ibComputersInfo = $global:ibComputersInfo
  $serialNumber = (Get-CimInstance Win32_BIOS).SerialNumber
  if ($ibComputerInfo -eq $ibComputersInfo.($serialNumber)) {
    Write-Debug "Machine trouvée"
    if ($ibComputerInfo.session -ne $null) {
      if ($ibComputersInfo.Sessions.($ibComputerInfo.session) -ne $null) {
        if ($ibComputersInfo.Sessions.($ibComputerInfo.session).salle -ne $null -and $ibComputersInfo.Salles.($ibComputersInfo.Sessions.($ibComputerInfo.session).salle).share -ne $null) { $ibComputersInfo.Sessions.($ibComputerInfo.session)|Add-Member -NotePropertyName share -NotePropertyValue $ibComputersInfo.Salles.($ibComputersInfo.Sessions.($ibComputerInfo.session).salle).share }}
        if ($ibComputersInfo.Sessions.($ibComputerInfo.session).teamsMeeting -ne $null) {$ibComputerInfo|Add-Member -NotePropertyName teamsMeeting -NotePropertyValue $ibComputersInfo.Sessions.($ibComputerInfo.session).teamsMeeting}
        if ($ibComputersInfo.Sessions.($ibComputerInfo.session).share -ne $null) {$ibComputerInfo|Add-Member -NotePropertyName share -NotePropertyValue $ibComputersInfo.Sessions.($ibComputerInfo.session).share}}}
    if ($ibComputerInfo.salle -ne $null) {
      if ($ibComputersInfo.Salles.($ibComputerInfo.salle) -ne $null) {
        if ($ibComputersInfo.Salles.($ibComputerInfo.Salle).teamsMeeting -ne $null) {$ibComputerInfo|Add-Member -NotePropertyName teamsMeeting -NotePropertyValue $ibComputersInfo.Salles.($ibComputerInfo.salle).teamsMeeting}
        if ($ibComputersInfo.Salles.($ibComputerInfo.Salle).share -ne $null) {$ibComputerInfo|Add-Member -NotePropertyName share -NotePropertyValue $ibComputersInfo.Salles.($ibComputerInfo.salle).share}}}
    $global:ibComputerInfo = $ibComputerInfo}
else { Write-error "Numero de serie '$serialNumber' introuvable dans le fichier de references."}}

function new-ibTeamsShortcut {
  <#
  .DESCRIPTION
  Cette commande Installe le nouveau client Teams et pose un raccourci pour la réunion sur le bureau le cas échéant.
  .PARAMETER meetingUrl
  Si ce paramètre est renseigné, un raccourci sera posé sur le bureau (de tous les utilisateurs de la machine) qui pointera sur l'adresse fournie et s'appelera 'Réunion Teams'.
  #>
  param( $meetingUrl = 'noUrl')
  # URL vers Teamsbootstrapper.exe depuis https://learn.microsoft.com/en-us/microsoftteams/new-teams-bulk-install-client
  $DownloadExeURL='https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409'
  $WebClient=New-Object -TypeName System.Net.WebClient
  $WebClient.DownloadFile($DownloadExeURL,(Join-Path -Path $env:TEMP -ChildPath 'Teamsbootstrapper.exe'))
  $WebClient.Dispose()
  & "$($Env:TEMP)\Teamsbootstrapper.exe" -p >> $null
  # Création du raccourci sur le bureau
  if ($meetingUrl -ne 'noUrl') {New-Item -Path "$env:PUBLIC\Desktop" -Name 'Réunion Teams.url' -ItemType File -Value "[InternetShortcut]`nURL=$meetingUrl" -Force|out-null}}

function set-ibRemoteManagement {
  <#
  .DESCRIPTION
  Cette commande vérifie et/ou met en place la configuration nécessaire pour utiliser le service WinRM en local.
  #>
  Get-NetConnectionProfile|where-object {$_.NetworkCategory -notlike '*Domain*'}|Set-NetConnectionProfile -NetworkCategory Private
  enable-PSRemoting -Force|out-null
  try {$saveTrustedHosts=(Get-Item WSMan:\localhost\Client\TrustedHosts).value}
  catch {$saveTrustedHosts=''}
  Set-Item WSMan:\localhost\Client\TrustedHosts -value * -Force
  Set-ItemProperty -Path HKLM:\System\CurrentControlSet\Control\Lsa –Name ForceGuest –Value 0 -Force
  return $saveTrustedHosts }

function get-ibSubNet {
    #retourne un tableau des addresses IP du sous-réseau correspondant à l'adresse fournie (mais excluant celle-ci)
    param (
        [ipaddress]$ip,
        [ValidateRange(1,31)][int]$MaskBits)
    $mask = ([Math]::Pow(2,$MaskBits)-1)*[Math]::Pow(2,(32-$MaskBits))
    $maskbytes = [BitConverter]::GetBytes([UInt32] $mask)
    $DottedMask = [IPAddress]((3..0 | ForEach-Object { [String] $maskbytes[$_] }) -join '.')
    [ipaddress]$subnetId = $ip.Address -band $DottedMask.Address
    $LowerBytes = [BitConverter]::GetBytes([UInt32] $subnetId.Address)
    [IPAddress]$broadcast = (0..3 | ForEach-object{$LowerBytes[$_] + ($maskbytes[(3-$_)] -bxor 255)}) -join '.'
    $subList = @()
    $current=$subnetId
    do {
        $curBytes = [BitConverter]::GetBytes([UInt32] $current.Address)
        [Array]::Reverse($curBytes)
        $nextBytes = [BitConverter]::GetBytes([UInt32]([bitconverter]::ToUInt32($curBytes,0) +1))
        [Array]::Reverse($nextBytes)
        $current = [ipaddress]$nextBytes
        if (($current -ne $broadcast) -and ($current -ne $ip)) { $subList+=$current.IPAddressToString }}  while ($current -ne $broadcast)
    return ($subList)}

function get-ibComputers {
  <#
  .DESCRIPTION
  Cette commande renvoit un tableau contenant les adresses IP de toutes les machines du sous-réseau de la machine depuis laquelle elle est lancée.
  #>

  #prérequis
  if (!(Get-Command Start-ThreadJob)) {
    Install-Module -Name ThreadJob -Force -scope allUsers
    import-module -Name ThreadJob}
  #Récuperation des informations sur le subnet
  $netIPConfig = get-NetIPConfiguration|Where-Object {$_.netAdapter.status -like 'up' -and $_.InterfaceDescription -notlike '*VirtualBox*' -and $_.InterfaceDescription -notlike '*vmware*' -and $_.InterfaceDescription -notlike '*virtual*'}
  $netIpAddress = $netIPConfig|Get-NetIPAddress -AddressFamily ipv4
  [System.Collections.ArrayList]$ipList = (get-ibSubNet -ip $netIpAddress.IPAddress -MaskBits $netIpAddress.PrefixLength)
  #Enlever le routeur de la liste !
  $ipList.Remove([ipaddress]($netIPConfig.ipv4defaultGateway.nextHop))
  #lancement des pings des machines en parallèle
  $ipLoop = 0
  $ipLength = $ipList.Count
  ForEach ($ip in $ipList) {
    $ipLoop ++
    Write-Progress -Activity "Tentatives de connexion" -Status "Machine $ip." -PercentComplete (($ipLoop/$ipLength)*100)
    Start-ThreadJob -ScriptBlock {Test-Connection -ComputerName $using:ip -count 1 -buffersize 8 -Quiet} -ThrottleLimit 50 -Name $ip|Out-Null }
    Write-Progress -Activity "Tentatives de connexion" -Completed
  $ipLoop = 0
  $pingJobs = Get-Job
  $ipLength = $pingJobs.count
  foreach ($pingJob in $pingJobs) {
    $ipLoop ++
    Write-Progress -Activity "Attente des résultats" -Status "Adresse $($pingJob.name)." -PercentComplete (($ipLoop/$ipLength)*100)
    $pingResult = Receive-Job $pingJob -Wait -AutoRemoveJob
    #Enlever l'adresse de la liste si pas de réponse au ping
    if (!$pingResult) {$ipList.Remove($pingJob.name)}}
    Write-Progress -Activity "Attente des résultats" -Completed
  return($ipList)}

function invoke-ibNetCommand {
<#
.DESCRIPTION
Cette commande permet de lancer une commande sur toutes les machines accessibles sur le subnet.
.PARAMETER Command
Syntaxe complète de la commande à lancer (dans une chaine de caracteres)
.PARAMETER getCred
Ce switch permet de demander le nom et mot de passe de l'utilisateur à utiliser sur les machines distantes.
S'il est omis, l'utilisateur actuellement connecté sera utilisé.
.EXAMPLE
invoke-ibNetCommand -Command {$env:computername}
Va se connecter à chaque machine du réseau pour récupérer son nom d'ordinateur et l'afficher
#>
    param([parameter(Mandatory=$true,HelpMessage='Commande à lancer sur toutes les machines du sous-réseau')][string]$command,[switch]$getCred)
    if ($getCred) {
        $cred=Get-Credential -Message "Merci de saisir le nom et mot de passe du compte administrateur WinRM à utiliser pour éxecuter la commande '$Command'"
        if (-not $cred) {
            Write-Error "Arrêt suite à interruption utilisateur lors de la saisie du Nom/Mot de passe"
            break}}
    $savedTrustedHosts = set-ibRemoteManagement
    foreach ($computer in get-ibComputers) {
        try {
            if ($getCred) {$commandOutput=(invoke-command -ComputerName $computer -ScriptBlock ([scriptBlock]::create($command)) -Credential $cred -ErrorAction Stop)}
            else {$commandOutput=(invoke-command -ComputerName $computer -ScriptBlock ([scriptBlock]::create($command)) -ErrorAction Stop)}
            if ($commandOutput) {
                Write-Host "[$computer] Résultat de la commande:" -ForegroundColor Green
                Write-host $commandOutput -ForegroundColor Gray }
            else { Write-Host "[$computer] Commande executée." -ForegroundColor Green}}
        catch {
            if ($_.Exception.message -ilike '*Access is denied*' -or $_.Exception.message -like '*Accès refusé*') { Write-Host "[$computer] Accès refusé." -ForegroundColor Red}
            else { Write-Host "[$computer] Erreur: $($_.Exception.message)" -ForegroundColor Red }}}
    Set-Item WSMan:\localhost\Client\TrustedHosts -value $savedTrustedHosts -Force}

function invoke-ibMute {
  <#
  .DESCRIPTION
  Cette commande permet de désactiver le son sur toutes les machines accessibles sur le subnet (dans la salle).
  Pour ce faire, elle utilise, un freeware (svcl.exe https://www.nirsoft.net/utils/sound_volume_command_line.html) qui sera uploadé dans le répertoire temporaire de chaque machine.
  Ne fonctionnera, à priori, que si un utilisateur est deja connecté sur la machine...
  .PARAMETER GetCred
  Ce switch permet de demander le nom et mot de passe de l'utilisateur à utiliser sur les machines distantes. S'il est omis, l'utilisateur actuellement connecté sera utilisé.
  #>
    param([switch]$getCred)
    if ($getCred) {
        $cred=Get-Credential -Message 'Merci de saisir le nom et mot de passe du compte administrateur WinRM à utiliser pour couper le son'
        if (-not $cred) {
            Write-Error "Arrêt suite à interruption utilisateur lors de la saisie du Nom/Mot de passe"
            break}}
    $savedTrustedHosts = set-ibRemoteManagement
    $svclFile = (get-module -listAvailable ib2).path
    $svclFile = $svclFile.substring(0,$svclFile.LastIndexOf('\')) + '\svcl.exe'
    foreach ($computer in get-ibComputers) {
        try {
            if ($getCred) {$session = New-PSSession -ComputerName $computer -Credential $cred -errorAction Stop}
            else {$session = New-PSSession -ComputerName $computer -errorAction Stop}
            if ($session) {
                $remoteTemp = (Invoke-Command -Session $session -ScriptBlock {$env:Temp})
                Copy-Item $svclFile -Destination "$remoteTemp\svcl.exe" -ToSession $session
                invoke-command -session $session -scriptBlock {set-location $using:remoteTemp;.\svcl.exe /mute (.\svcl.exe /scomma|ConvertFrom-Csv|where-object Default -eq render).name}
                Write-Host "[$computer] OK" -ForegroundColor Green}
            }
        catch {
            if ($_.Exception.message -ilike '*Access is denied*' -or $_.Exception.message -like '*Accès refusé*') { Write-Host "[$computer] Accès refusé." -ForegroundColor Red}
            else { Write-Host "[$computer] Erreur: $($_.Exception.message)" -ForegroundColor Red }}}
    Set-Item WSMan:\localhost\Client\TrustedHosts -value $savedTrustedHosts -Force}

function stop-ibNet {
<#
.DESCRIPTION
Cette commande permet d'arrêter toutes les machines du réseau local, en terminant par la machine sur laquelle est lançée la commande
.PARAMETER GetCred
Si ce switch n'est pas spécifié, l'identité de l'utilisateur actuellement connecté sera utilisée pour stopper les machines.
#>
param(
[switch]$GetCred)
if ($GetCred) {invoke-ibNetCommand -Command 'stop-Computer -Force' -GetCred}
else {invoke-ibNetCommand 'Stop-Computer -Force'}
  Stop-Computer -Force}

#######################
#  Gestion du module  #
#######################
Export-moduleMember -Function invoke-ibMute,get-ibComputers,invoke-ibNetCommand,stop-ibNet,new-ibTeamsShortcut,get-ibComputerInfo,optimize-ibStudentComputer