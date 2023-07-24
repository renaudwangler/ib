function set-ibRemoteManagement {
  Write-Verbose "Vérification/mise en place de la configuration pour le WinRM local"
  Get-NetConnectionProfile|where {$_.NetworkCategory -notlike '*Domain*'}|Set-NetConnectionProfile -NetworkCategory Private
  $saveTrustedHosts=(Get-Item WSMan:\localhost\Client\TrustedHosts).value
  Set-Item WSMan:\localhost\Client\TrustedHosts -value * -Force
  Set-ItemProperty –Path HKLM:\System\CurrentControlSet\Control\Lsa –Name ForceGuest –Value 0 -Force
  Enable-PSRemoting -Force|Out-Null
  return $saveTrustedHosts}

function get-subNet {
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
    #Récupération des informations sur le subnet
    $netIPConfig = get-NetIPConfiguration|Where-Object {$_.netAdapter.status -like 'up' -and $_.InterfaceDescription -notlike '*VirtualBox*' -and $_.InterfaceDescription -notlike '*vmware*' -and $_.InterfaceDescription -notlike '*virtual*'}
    $netIpAddress = $netIPConfig|Get-NetIPAddress -AddressFamily ipv4
    $localIp = $netIpAddress.IPAddress
    [System.Collections.ArrayList]$ipList = (get-subNet -ip $netIpAddress.IPAddress -MaskBits $netIpAddress.PrefixLength)
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

function set-ibMute {
    param ([switch]$getCred)
    #Ne marche qu'en local...
    if ($getCred) {invoke-ibNetCommand -command '(new-object -com wscript.shell).sendKeys([char]175);(new-object -com wscript.shell).sendKeys([char]173)' -getCred}
    else { invoke-ibNetCommand -command '(new-object -com wscript.shell).sendKeys([char]175);(new-object -com wscript.shell).sendKeys([char]173)' }
    #En utilisant le soft "svcl" stocké dans le github
    $env:ProgramFiles\WindowsPowerShell\Modules\ib2\svcl.exe /unmute (C:\svcl.exe /scomma|ConvertFrom-Csv|where Default -eq render).name
    }
