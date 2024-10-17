function new-ibTeamsShortcut {
    #Installe le nouveau client Teams et pose un raccourci vers la réunion sur le bureau.
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
  Write-Verbose "Vérification/mise en place de la configuration pour le WinRM local"
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
.SYNOPSIS
Cette commande renvoit un tableau contenant les adresses IP de toutes les machines présentes sur le subnet (dans la salle).
#>      
    #Récupération des informations sur le subnet
    $netIPConfig = get-NetIPConfiguration|Where-Object {$_.netAdapter.status -like 'up' -and $_.InterfaceDescription -notlike '*VirtualBox*' -and $_.InterfaceDescription -notlike '*vmware*' -and $_.InterfaceDescription -notlike '*virtual*'}
    $netIpAddress = $netIPConfig|Get-NetIPAddress -AddressFamily ipv4
    $localIp = $netIpAddress.IPAddress
    [System.Collections.ArrayList]$ipList = (get-ibSubNet -ip $netIpAddress.IPAddress -MaskBits $netIpAddress.PrefixLength)
    #Enlever le routeur de la liste !
    $ipList.Remove([ipaddress]($netIPConfig.ipv4defaultGateway.nextHop))
    #lancement des pings des machines en parallèle
    [System.Collections.ArrayList]$pingJobs=@()
    ForEach ($ip in $ipList) {
        $pingJobs.add((Test-Connection -ComputerName $ip -count 1 -buffersize 8 -asJob))|Out-Null}
    foreach ($pingJob in $pingJobs) {
        if ($pingJob.state -notlike '*completed*') {Wait-Job $pingJob|out-null}
        $pingResult = Receive-Job $pingJob -Wait -AutoRemoveJob
        #Enlever l'adresse de la liste si pas de réponse au ping
        if ($pingResult.statusCode -ne 0) {$ipList.Remove($pingResult.address)}}
    return($ipList)}

function invoke-ibNetCommand {
<#
.SYNOPSIS
Cette commande permet de lancer une commande sur toutes les machines accessibles sur le subnet (dans la salle).
.PARAMETER Command
Syntaxe complète de la commande à lancer
.PARAMETER getCred
Ce switch permet de demander le nom et mot de passe de l'utilisateur à utiliser sur les machines distantes. S'il est omis, l'utilisateur actuellement connecté sera utilisé.
.EXAMPLE
invoke-ibNetCommand -Command {$env:computername}
Va se connecter à chaque mahcine du réseau (de la salle) pour récupérer son nom d'ordinateur et l'afficher
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
.SYNOPSIS
Cette commande permet de désactiver le son sur toutes les machines accessibles sur le subnet (dans la salle).
Pour ce faire, elle tuilise, un freeware (svcl.exe https://www.nirsoft.net/utils/sound_volume_command_line.html) qui sera uploadé dans le répertoire temporaire de chaque machine.
Ne fonctionnera, à priori, que si un utilisateur est déjà connecté sur la machine...
.PARAMETER GetCred
Ce switch permet de demander le nom et mot de passe de l'utilisateur à utiliser sur les machines distantes. S'il est omis, l'utilisateur actuellement connecté sera utilisé.
.EXAMPLE
invoke-ibMute
Va couper le son (mute) sur toutes les machines du subnet (de la salle)
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
.SYNOPSIS
Cette commande permet d'arrêter toutes les machines du réseau local (de la salle), en terminant par la machine sur laquelle est lançée la commande
.PARAMETER GetCred
Si ce switch n'est pas spécifié, l'identité de l'utilisateur actuellement connecté sera utilisé pour stopper les machines.
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
Export-moduleMember -Function invoke-ibMute,get-ibComputers,invoke-ibNetCommand,stop-ibNet,new-ibTeamsShortcut