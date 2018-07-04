if ((Get-Module azurerm -ListAvailable).count -eq 0) {Install-Module azurerm -Force}
if ((Get-Module azuread -ListAvailable).count -eq 0) {Install-Module azuread -Force}
while (!(Get-AzureRmContext)) {Login-AzureRmAccount|Out-Null}

$prefix=''
while ($prefix -eq '') {$prefix=read-host -Prompt 'Nom du ressource group à instancier'}

if (!(Get-AzureRmResourceGroup $prefix -ErrorAction SilentlyContinue)) {
  $locations=(get-AzureRmResourceProvider -ProviderNamespace microsoft.network|where {$_.ResourceTypes.resourceTypeName -like 'virtualnetworkgateways'}).Locations
  $locations|ForEach-Object {"[$([array]::indexof($locations,$_))] $_"}
  $location=$locations.Count+1
  while ($location -gt (($locations.count)-1)) {[int32]$location=Read-Host -Prompt 'Merci de sélectionner la région de déploiement parmi celles disponibles ci-dessus';$location}
  [string]$location=$locations[$location]
  echo "Création du Resource Group '$prefix'."
  New-AzureRmResourceGroup -Name $prefix -Location $location|Out-Null}
else {$location=(Get-AzureRmResourceGroup -Name $prefix).location}

#Création du Vnet et de la passerelle
if (!(Get-AzureRmVirtualNetwork -Name $prefix -ResourceGroupName $prefix -ErrorAction SilentlyContinue)) {
  $subnetConfig=New-AzureRmVirtualNetworkSubnetConfig -name 'subnet1' -AddressPrefix 10.0.0.0/24
  $gwSubnetConfig=New-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -AddressPrefix 10.0.1.0/24
  echo "Création du Vnet '$prefix'."
  $vnet=New-AzureRmVirtualNetwork -name $prefix -ResourceGroupName $prefix -AddressPrefix 10.0.0.0/16 -Subnet $subnetConfig,$gwSubnetConfig -Location $location}
  else {$vnet=Get-AzureRmVirtualNetwork -Name $prefix -ResourceGroupName $prefix}
if (!(Get-AzureRmVirtualNetworkGateway -Name "$prefix-gw" -ResourceGroupName $prefix -ErrorAction SilentlyContinue)) {
  $gwSubnetConfig=Get-AzureRmVirtualNetworkSubnetConfig -Name GatewaySubnet -VirtualNetwork $vnet
  echo "Création de l'adresse IP publique '$prefix-gwIP'"
  $gwpubIp=New-AzureRmPublicIpAddress -Name "$prefix-gwIP" -ResourceGroupName $prefix -Location $location -AllocationMethod Dynamic
  $gwIPConfig=New-AzureRmVirtualNetworkGatewayIpConfig -Name "$prefix-gwipconfig" -SubnetId $gwSubnetConfig.id -PublicIpAddressId $gwpubIp.id
  echo "Création de la Passerelle VPN '$prefix-gw'"
  $gw=New-AzureRmVirtualNetworkGateway -Name "$prefix-gw" -ResourceGroupName $prefix -Location $location -IpConfigurations $gwIPConfig -GatewayType vpn -VpnType RouteBased -GatewaySku Standard -VpnClientAddressPool '10.1.0.0/24' -AsJob}

#Création de l'AADDS
$addsAppid='2565bd9d-da50-47d4-8b85-4c97f669dc36'
if (!(Get-AzureRmADServicePrincipal|where applicationId -like $addsAppid)) {New-AzureRmADServicePrincipal -ApplicationId $addsAppid}
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.AAD|Out-Null
if (!(Get-AzureRmResource|where resourceId -like "/subscriptions/$((Get-AzureRmSubscription).Id)/resourceGroups/$prefix/providers/Microsoft.AAD/DomainServices/*")) {
  echo "Mise en place du domaine géré (AADDS) nommé '$prefix.ad'."
  $addsDomain=New-AzureRmResource -ResourceId "/subscriptions/$((Get-AzureRmSubscription).Id)/resourceGroups/$prefix/providers/Microsoft.AAD/DomainServices/$prefix" -Location $location -Properties @{"DomainName"="$prefix.ad"; "SubnetId"="/subscriptions/$((Get-AzureRmSubscription).Id)/resourceGroups/$prefix/providers/Microsoft.Network/virtualNetworks/$prefix/subnets/subnet1"} -ApiVersion 2017-06-01 -Force}
else {echo "Le domaine ADDS se créé se nomme '$prefix.ad'."}  

while (!(Get-AzureRmLoadBalancer -ResourceGroupName $prefix) -or (Get-AzureRmNetworkInterface -ResourceGroupName $prefix).count -ne 2 -or ((Get-AzureRmVirtualNetworkGateway -Name "$prefix-gw" -ResourceGroupName $prefix).provisioningState -notlike 'succeeded')) {
  echo 'Attente de fin des opérations de création...'
  Start-Sleep 60}
echo "Mise en place/vérification des serveurs DNS du vNet '$($vnet.Name)'."
$vnetDns=(Get-AzureRmNetworkInterface -ResourceGroupName $prefix).IpConfigurations.privateIPAddress
$vnet.DhcpOptions.DnsServers = $vnetDns
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet|Out-Null

#Gestion des groupes et utilisateurs nécessaires.
$domainName=(Get-AzureRmEnrollmentAccount).principalName.split('@')[1]
if (Get-AzureRmADUser|where displayName -like $prefix-admin) {
  $adminUser=Get-AzureRmADUser|where displayName -like $prefix-admin}
else {
  echo "Création du compte utilisateur '$prefix-admin@$domainName'."
  $adminUser=New-AzureRmADUser -DisplayName $prefix-admin -UserPrincipalName $prefix-admin@$domainName -Password (Read-Host -Prompt "Mot de passe pour le compte '$prefix-admin'" -AsSecureString) -MailNickname $prefix-admin}
echo "Connectez-vous avec le compte '$prefix-admin@$domainName' !"
if (Get-AzureRmADGroup|where displayName -like 'AAD DC Administrators' -erroraction silentlyContinue) {
  $adminGroup=Get-AzureRmADGroup|where displayName -like 'AAD DC Administrators'}
else {
  echo "Création du groupe 'AAD DC Administrators'."
  $adminGroup=New-AzureRmADGroup -DisplayName 'AAD DC Administrators' -MailNickname AADDCAdministrators}
  #Add-AzureRmADGroupMember -MemberObjectId $adminUser.Id -TargetGroupObjectId $adminGroup.id

#Création des clients VPN
if ([System.Environment]::OSVersion.Version.Major -lt 10) {echo 'Pas de gestion prévue des certificats pour version inférieure à Windows 10, Windows Server 2016...'}
else {
  if (Get-ChildItem -Path Cert:\LocalMachine\my|where subject -like "*$($prefix)VPNRootCA") {$rootCert=Get-ChildItem -Path Cert:\LocalMachine\my|where subject -like "*$($prefix)VPNRootCA"}
  else {
    echo "Création du certificat racine '$($prefix)VPNRootCA."
    $rootCert=New-SelfSignedCertificate -KeySpec KeyExchange -KeyUsage CertSign -Subject "CN=$($prefix)VPNRootCA" -KeyExportPolicy Exportable -CertStoreLocation Cert:\LocalMachine\My -FriendlyName VPNRoot}
  $gw=Get-AzureRmVirtualNetworkGateway -Name aadds-gw -ResourceGroupName aadds
  $certData=[convert]::ToBase64String($rootCert.RawData)
  $certData > $env:TEMP\$($prefix)Root.cer
  Import-Certificate -CertStoreLocation Cert:\LocalMachine\AuthRoot -FilePath $env:TEMP\$($prefix)Root.cer -ErrorAction SilentlyContinue|Out-Null
  Import-Certificate -CertStoreLocation Cert:\CurrentUser\AuthRoot -FilePath $env:TEMP\$($prefix)Root.cer -ErrorAction SilentlyContinue|Out-Null
  $certRoots=Get-AzureRmVpnClientRootCertificate -VirtualNetworkGatewayName $gw.Name -ResourceGroupName $prefix
  if (!($certRoots|where PublicCertData -EQ $certData)) {
    echo "Ajout du certificat Racine comme confiance pour les clients de la passerelle du vNet '$prefix'."
    if ($certRoots.count -eq 0) {$certRootsSuff=''} else {$certRootsSuff='-'+$certRoots.count}
    Add-AzureRmVpnClientRootCertificate -VpnClientRootCertificateName $prefix-VPNRootCA$certRootsSuff -VirtualNetworkGatewayName $gw.Name -ResourceGroupName $prefix -PublicCertData $certData|Out-Null}
  echo 'Création des certificats clients utilisateur et machine et création de la connexion VPN.'
  New-SelfSignedCertificate -Type Custom -DnsName vpnClient -KeySpec Signature -Subject 'cn=vpnClient' -KeyExportPolicy Exportable -HashAlgorithm sha256 -KeyLength 2048 -CertStoreLocation Cert:\CurrentUser\my -Signer $rootCert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")|out-null
  New-SelfSignedCertificate -Type Custom -DnsName vpnClient -KeySpec Signature -Subject 'cn=vpnClient' -KeyExportPolicy Exportable -HashAlgorithm sha256 -KeyLength 2048 -CertStoreLocation Cert:\LocalMachine\My -Signer $rootCert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")|out-null
  if (Get-AzureRmVpnClientConfiguration -Name $gw.Name -ResourceGroupName $prefix -ErrorAction SilentlyContinue) {
    $vpnClient=Get-AzureRmVpnClientConfiguration -Name $gw.Name -ResourceGroupName $prefix}
  else { $vpnclient=New-AzureRmVpnClientConfiguration -Name $gw.name -ResourceGroupName $prefix -AuthenticationMethod eaptls}
  if (![System.IO.File]::Exists($env:TEMP+'\'+$prefix+'.xml')) {
  $destZip=$env:TEMP+'\'+$prefix+'.zip'
  Invoke-WebRequest -Uri $vpnClient.VpnProfileSASUrl -OutFile $destZip
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $zip=[IO.Compression.ZipFile]::OpenRead($destZip)
  $zip.Entries|ForEach-Object {if($_.name -like '*.xml') {[IO.Compression.ZipFileExtensions]::ExtractToFile($_,$env:TEMP+'\'+$prefix+'.xml')}}
  $zip.dispose()
  Remove-Item -Path $destZip -Force}
  $vpnSettings=([xml](get-content $env:TEMP\$prefix.xml)).vpnprofile
  Remove-Item -Path $env:TEMP\$prefix.xml -Force
  if (Get-VpnConnection -Name $prefix-ike -AllUserConnection -ErrorAction SilentlyContinue) {Remove-VpnConnection -AllUserConnection -Name $prefix-ike -Force}
  Add-VpnConnection -Name $prefix-ike -ServerAddress $vpnSettings.VpnServer -TunnelType ikev2 -AuthenticationMethod MachineCertificate -AllUserConnection -DnsSuffix "$prefix.ad" -SplitTunneling
  if (Get-VpnConnection -Name $prefix-sstp -AllUserConnection -ErrorAction SilentlyContinue) {Remove-VpnConnection -AllUserConnection -Name $prefix-sstp -Force}
  $eapConf=New-EapConfiguration -Tls -UserCertificate
  Add-VpnConnection -Name $prefix-sstp -ServerAddress $vpnSettings.VpnServer -AllUserConnection -TunnelType sstp -AuthenticationMethod Eap -EapConfigXmlStream $eapConf.EapConfigXmlStream -DnsSuffix "$prefix.ad" -SplitTunneling}


$rasphone=Get-Content -Path $env:ProgramData\microsoft\network\connections\pbk\rasphone.pbk
$rasphoneNew=@()
$foundVPN=$false
foreach ($rasphoneline in $rasphone) {
  if ($rasphoneline -like "*$prefix-*") {$foundVPN=$true}
  if ($rasphoneline -like "*ipdnsAddress=*") {$rasphoneLine="IpDnsAddress=$($vnetDns[0])"}
  if ($rasphoneline -like "*ipdns2Address=*") {$rasphoneLine="IpDns2Address=$($vnetDns[1])"}
  if ($rasphoneline -like "*IpNameAssign=*") {
    $rasphoneLine='IpNameAssign=2'
    $foundVPN=$false}
 $rasphoneNew+=$rasphoneline}
 Set-Content -Path $env:ProgramData\microsoft\network\connections\pbk\rasphone.pbk -Value $rasphoneNew

#if (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name disableCAD -ErrorAction SilentlyContinue) {SET-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\windows NT\CurrentVersion\Winlogon' -Name DisableCAD -Value 0}
#else { New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\windows NT\CurrentVersion\Winlogon' -Name DisableCAD -PropertyType DWORD -Value 0}
