#URL du fichier json reference ib partage sur OneDrive
$computersInfoUrl = 'https://ibgroupecegos-my.sharepoint.com/:u:/g/personal/distanciel_ib_cegos_fr/EZu4bAqgln5PlEwkMPtryEcB8UL-RJvUxig2GfHESWQjeQ?e=UMd3jn'

function optimize-ibStudentComputer {
  <#
  .DESCRIPTION
  Cette commande est faite pour etre lancee au demarrage de la machine de formation et optimiser son fonctionnement pour la formation en cours.
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
  Cette commande recupere les informations techniques/d'installation depuis le fichier de reference ib (sur oneDrive).
  #>
  if (!$script:ibComputersInfo) {
    wait-ibNetwork
    if (!($script:ibComputersInfo = ((invoke-WebRequest -Uri "$computersInfoUrl&download=1" -UseBasicParsing).content|ConvertFrom-Json))) { write-error -message 'Impossible de recuperer les informations des machines ib depuis le partage oneDrive'}}}
function get-ibComputerInfo {
  <#
  .DESCRIPTION
  Cette commande recupere les informations techniques/d'installation sur la machine en cours depuis la reference ib.
  #> 
  if (!$script:ibComputersInfo) { get-ibComputersInfo }
  $serialNumber = (Get-CimInstance Win32_BIOS).SerialNumber
  if ($script:ibComputerInfo = $script:ibComputersInfo.($serialNumber)) {
    Write-Host "Machine trouvee en salle '$($script:ibComputerInfo.salle)'" -ForegroundColor green }
else { Write-error "Numero de serie '$serialNumber' introuvable dans le fichier de references."}}

function new-ibTeamsShortcut {
  <#
  .DESCRIPTION
  Cette commande Installe le nouveau client Teams et pose un raccourci pour la reunion sur le bureau le cas echeant.
  .PARAMETER meetingUrl
  Si ce parametre est renseigne, un raccourci sera pose sur le bureau (de tous les utilisateurs de la machine) qui pointera sur l'adresse fournie et s'appelera 'Reunion Teams'.
  #> 
  param( $meetingUrl = 'noUrl')
  # URL vers Teamsbootstrapper.exe depuis https://learn.microsoft.com/en-us/microsoftteams/new-teams-bulk-install-client
  $DownloadExeURL='https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409'
  $WebClient=New-Object -TypeName System.Net.WebClient
  $WebClient.DownloadFile($DownloadExeURL,(Join-Path -Path $env:TEMP -ChildPath 'Teamsbootstrapper.exe'))
  $WebClient.Dispose()
  & "$($Env:TEMP)\Teamsbootstrapper.exe" -p >> $null
  # Création du raccourci sur le bureau
  if ($meetingUrl -ne 'noUrl') {New-Item -Path "$env:PUBLIC\Desktop" -Name 'Réunion Teams.url' -ItemType File -Value "[InternetShortcut]`nURL=$meetingUrl" -Force}}

function set-ibRemoteManagement {
  <#
  .DESCRIPTION
  Cette commande verifie et/ou met en place la configuration necessaire pour utiliser le service WinRM en local.
  #> 
  Get-NetConnectionProfile|where {$_.NetworkCategory -notlike '*Domain*'}|Set-NetConnectionProfile -NetworkCategory Private
  enable-PSRemoting -Force|out-null
  try {$saveTrustedHosts=(Get-Item WSMan:\localhost\Client\TrustedHosts).value}
  catch {$savedTrustedHosts=''}
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
    [IPAddress]$broadcast = (0..3 | %{$LowerBytes[$_] + ($maskbytes[(3-$_)] -bxor 255)}) -join '.'
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
  Cette commande renvoit un tableau contenant les adresses IP de toutes les machines du sous-reseau de la machine depusis laquelle elle est lancee.
  #>      

  #prerequis
  if (!(Get-Command Start-ThreadJob)) {
    Install-Module -Name ThreadJob -Force -scope allUsers
    import-module -Name ThreadJob}
  #Recuperation des informations sur le subnet
  $netIPConfig = get-NetIPConfiguration|Where-Object {$_.netAdapter.status -like 'up' -and $_.InterfaceDescription -notlike '*VirtualBox*' -and $_.InterfaceDescription -notlike '*vmware*' -and $_.InterfaceDescription -notlike '*virtual*'}
  $netIpAddress = $netIPConfig|Get-NetIPAddress -AddressFamily ipv4
  $localIp = $netIpAddress.IPAddress
  [System.Collections.ArrayList]$ipList = (get-ibSubNet -ip $netIpAddress.IPAddress -MaskBits $netIpAddress.PrefixLength)
  #Enlever le routeur de la liste !
  $ipList.Remove([ipaddress]($netIPConfig.ipv4defaultGateway.nextHop))
  #lancement des pings des machines en parallele
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
    Write-Progress -Activity "Attente des resultats" -Status "Adresse $($pingJob.name)." -PercentComplete (($ipLoop/$ipLength)*100)
    $pingResult = Receive-Job $pingJob -Wait -AutoRemoveJob
    #Enlever l'adresse de la liste si pas de reponse au ping
    if (!$pingResult) {$ipList.Remove($pingJob.name)}}
    Write-Progress -Activity "Attente des resultats" -Completed
  return($ipList)}

function invoke-ibNetCommand {
<#
.DESCRIPTION
Cette commande permet de lancer une commande sur toutes les machines accessibles sur le subnet.
.PARAMETER Command
Syntaxe complète de la commande à lancer (chaine de caracteres)
.PARAMETER getCred
Ce switch permet de demander le nom et mot de passe de l'utilisateur à utiliser sur les machines distantes.
S'il est omis, l'utilisateur actuellement connecte sera utilise.
.EXAMPLE
invoke-ibNetCommand -Command {$env:computername}
Va se connecter à chaque mahcine du reseau pour recuperer son nom d'ordinateur et l'afficher
#>    
    param([parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage='Commande à lancer sur toutes les machines du sous-réseau')][string]$command,
    [switch]$getCred)
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
  Cette commande permet de desactiver le son sur toutes les machines accessibles sur le subnet (dans la salle).
  Pour ce faire, elle tuilise, un freeware (svcl.exe https://www.nirsoft.net/utils/sound_volume_command_line.html) qui sera uploade dans le répertoire temporaire de chaque machine.
  Ne fonctionnera, à priori, que si un utilisateur est deja connecte sur la machine...
  .PARAMETER GetCred
  Ce switch permet de demander le nom et mot de passe de l'utilisateur à utiliser sur les machines distantes. S'il est omis, l'utilisateur actuellement connecte sera utilisé.
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
                invoke-command -session $session -scriptBlock {cd $using:remoteTemp;.\svcl.exe /mute (.\svcl.exe /scomma|ConvertFrom-Csv|where Default -eq render).name}
                Write-Host "[$computer] OK" -ForegroundColor Green}
            }
        catch {
            if ($_.Exception.message -ilike '*Access is denied*' -or $_.Exception.message -like '*Accès refusé*') { Write-Host "[$computer] Accès refusé." -ForegroundColor Red}
            else { Write-Host "[$computer] Erreur: $($_.Exception.message)" -ForegroundColor Red }}}
    Set-Item WSMan:\localhost\Client\TrustedHosts -value $savedTrustedHosts -Force}

function stop-ibNet {
<#
.DESCRIPTION
Cette commande permet d'arreter toutes les machines du reseau local, en terminant par la machine sur laquelle est lançee la commande
.PARAMETER GetCred
Si ce switch n'est pas specifie, l'identite de l'utilisateur actuellement connecte sera utilisee pour stopper les machines.
#>
param(
[string]$Subnet,
[switch]$GetCred)
if ($GetCred) {invoke-ibNetCommand -Command 'stop-Computer -Force' -GetCred}
else {invoke-ibNetCommand 'Stop-Computer -Force'}
  Stop-Computer -Force}  

#######################
#  Gestion du module  #
#######################
Export-moduleMember -Function invoke-ibMute,get-ibComputers,invoke-ibNetCommand,stop-ibNet,new-ibTeamsShortcut,get-ibComputerInfo,optimize-ibStudentComputer