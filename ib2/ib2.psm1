function get-subNet {
    #retourne un tableau des addresses IP du sous-réseau correspondant à l'adresse fournie, mais excluant celle-ci
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
    #lancement des pings des machines
    [System.Collections.ArrayList]$pingJobs=@()
    ForEach ($ip in $ipList) {
    $pingJobs.add((Test-Connection -ComputerName $ip -count 1 -buffersize 8 -asJob))|Out-Null}
    foreach ($pingJob in $pingJobs) {
        if ($pingJob.state -notlike '*completed*') {Wait-Job $pingJob|out-null}
        $pingResult = Receive-Job $pingJob -Wait -AutoRemoveJob
        if ($pingResult.statusCode -ne 0) {$ipList.Remove($pingResult.address)}}
    return($ipList)}
