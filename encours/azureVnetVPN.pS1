function New-SSCert {
[OutputType('[System.Security.Cryptography.X509Certificates.X509Certificate2]')]
param ([string]$Name)
$AlgID=New-Object -ComObject X509Enrollment.CObjectId
$AlgID.InitializeFromValue(([Security.Cryptography.Oid]'RSA').Value)
$SigOID=New-Object -ComObject X509Enrollment.CObjectId
$SigOID.InitializeFromValue(([Security.Cryptography.Oid]'SHA256').Value)
$ExtensionsToAdd = @()
$SubjectDN1=New-Object -ComObject X509Enrollment.CX500DistinguishedName
$SubjectDN1.Encode("cn=$($Name)Root",0x0)
$SubjectDN2=New-Object -ComObject X509Enrollment.CX500DistinguishedName
$SubjectDN2.Encode("cn=$Name",0x0)

[Security.Cryptography.X509Certificates.X509KeyUsageFlags]$KeyUsage1='KeyCertSign'
$KU = New-Object -ComObject X509Enrollment.CX509ExtensionKeyUsage
$KU.InitializeEncode([int]$KeyUsage1)
$KU.Critical=$true
$PrivateKey1=New-Object -ComObject X509Enrollment.CX509PrivateKey -Property @{ProviderName='Microsoft Enhanced Cryptographic Provider v1.0';Algorithm=$AlgID;KeySpec=1;Length=2048;MachineContext=$false;ExportPolicy=1};$PrivateKey1.Create()
$PrivateKey2=New-Object -ComObject X509Enrollment.CX509PrivateKey -Property @{ProviderName='Microsoft Enhanced Cryptographic Provider v1.0';Algorithm=$AlgID;KeySpec=1;Length=2048;MachineContext=$false;ExportPolicy=1};$PrivateKey2.Create()
$Cert1=New-Object -ComObject X509Enrollment.CX509CertificateRequestCertificate
$Cert1.InitializeFromPrivateKey(0x1,$PrivateKey1,'')
$Cert1.Subject=$SubjectDN1
$Cert1.Issuer=$Cert1.Subject
$Cert1.NotBefore=[DateTime]::Now.AddDays(-1)
$Cert1.NotAfter=[DateTime]::Now.AddDays(96)
$Cert1.X509Extensions.Add($KU)
$Cert1.SignatureInformation.HashAlgorithm=$SigOID
$Cert1.Encode()
$Request1=New-Object -ComObject X509Enrollment.CX509enrollment
$Request1.InitializeFromRequest($Cert1)
$Request1.CertificateFriendlyName="$($Name)Root"
$endCert1=$Request1.CreateRequest(0x1)
$Request1.InstallResponse(0x2,$endCert1,0x1,"")

$Cert2=New-Object -ComObject X509Enrollment.CX509CertificateRequestCertificate
$Cert2.InitializeFromPrivateKey(0x1,$PrivateKey2,"")
$Cert2.Subject=$SubjectDN2
$Cert2.Issuer=$SubjectDN1
$Cert2.NotBefore=[DateTime]::Now.AddDays(-1)
$Cert2.NotAfter=[DateTime]::Now.AddDays(90)
$SigOID2=New-Object -ComObject X509Enrollment.CObjectId
$SigOID2.InitializeFromValue(([Security.Cryptography.Oid]'SHA256').Value)

$Cert2.SignatureInformation.HashAlgorithm=$SigOID2
$Cert2.Encode()

$Request2=New-Object -ComObject X509Enrollment.CX509enrollment
$Request2.InitializeFromRequest($Cert2)
$Request2.CertificateFriendlyName=$Name
$endCert2=$Request2.CreateRequest(0x1)
$Request2.InstallResponse(0x2,$endCert2,0x1,"")


[Byte[]]$CertBytes1=[Convert]::FromBase64String($endCert1)
[Byte[]]$CertBytes2=[Convert]::FromBase64String($endCert2)
$newCertThumb=(New-Object Security.Cryptography.X509Certificates.X509Certificate2 @(,$CertBytes1)).Thumbprint
$rootCert=Get-ChildItem Cert:\CurrentUser\My\$newCertThumb
return $rootCert}

if ((Get-Module azurerm -ListAvailable).count -eq 0) {Install-Module azurerm -Force}
if ((Get-Module azuread -ListAvailable).count -eq 0) {Install-Module azuread -Force}
while (!(Get-AzureRmContext)) {Login-AzureRmAccount|Out-Null}
#connect-AzureAD|Out-Null

$prefix=''
while ($prefix -eq '') {$prefix=read-host -Prompt 'Nom du ressource group à instancier'}

if (!(Get-AzureRmResourceGroup $prefix -ErrorAction SilentlyContinue)) {
  $locations=(get-AzureRmResourceProvider -ProviderNamespace microsoft.network|where {$_.ResourceTypes.resourceTypeName -like 'virtualnetworkgateways'}).Locations
  $locations|ForEach-Object {"[$([array]::indexof($locations,$_))] $_"}
  $location=$locations.Count+1
  while ($location -gt $locations.count-1) {$location=Read-Host -Prompt 'Merci de sélectionner la région de déploiement parmi celles disponibles ci-dessus'}
  $location=$locations[$location]
  echo "Création du Resource Group '$prefix'."
  New-AzureRmResourceGroup -Name $prefix -Location $location|Out-Null}
else {$location=(Get-AzureRmResourceGroup -Name $prefix).location}

if (!(Get-AzureRmVirtualNetwork -Name $prefix -ResourceGroupName $prefix -ErrorAction SilentlyContinue)) {
  $subnetConfig=New-AzureRmVirtualNetworkSubnetConfig -name 'subnet1' -AddressPrefix 10.0.0.0/24
  $gwSubnetConfig=New-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -AddressPrefix 10.0.1.0/24
  echo "Création du Vnet '$prefix'."
  $vnet=New-AzureRmVirtualNetwork -name $prefix -ResourceGroupName $prefix -AddressPrefix 10.0.0.0/16 -Subnet $subnetConfig,$gwSubnetConfig -Location $location}

if (!(Get-AzureRmVirtualNetworkGateway -Name "$prefix-gw" -ResourceGroupName $prefix -ErrorAction SilentlyContinue)) {
  $gwSubnetConfig=Get-AzureRmVirtualNetworkSubnetConfig -Name GatewaySubnet -VirtualNetwork $vnet
  echo "Création de l'adresse IP publique '$prefix-gwIP'"
  $gwpubIp=New-AzureRmPublicIpAddress -Name "$prefix-gwIP" -ResourceGroupName $prefix -Location $location -AllocationMethod Dynamic
  $gwIPConfig=New-AzureRmVirtualNetworkGatewayIpConfig -Name "$prefix-gwipconfig" -SubnetId $gwSubnetConfig.id -PublicIpAddressId $gwpubIp.id
  echo "Création de la Passerelle VPN '$prefix-gw'"
  $gw=New-AzureRmVirtualNetworkGateway -Name "$prefix-gw" -ResourceGroupName $prefix -Location $location -IpConfigurations $gwIPConfig -GatewayType vpn -VpnType RouteBased -GatewaySku Standard}

  echo '- témoin 3 -'

while ((Get-AzureRmVirtualNetworkGateway -Name "$prefix-gw" -ResourceGroupName $prefix).provisioningState -notlike 'succeeded') {
  echo 'Attente de fin de création de la passerelle...'
  Start-Sleep 60}
if ([System.Environment]::OSVersion.Version.Major -lt 10) { $rootCert=New-SSCert -name $prefix }
else { $rootCert=New-SelfSignedCertificate -KeySpec KeyExchange -KeyUsage CertSign -Subject 'CN=VPNRootCA' -KeyExportPolicy Exportable -CertStoreLocation Cert:\CurrentUser\My -FriendlyName VPNRoot}
$gw=Get-AzureRmVirtualNetworkGateway -Name aadds-gw -ResourceGroupName aadds
$certData=[convert]::ToBase64String($rootCert.RawData)
$certRoot=New-AzureRmVpnClientRootCertificate -Name VPNRootCA -PublicCertData $certData
Set-AzureRmVirtualNetworkGateway -VirtualNetworkGateway $gw -VpnClientAddressPool '10.1.0.0/24' -VpnClientRootCertificates $certRoot|out-null
if ([System.Environment]::OSVersion.Version.Major -ge 10) {
  #Création du certificat client sur poste Windows 10 et plus récent
   New-SelfSignedCertificate -KeySpec KeyExchange -Subject 'cn=VPNClient' -KeyExportPolicy Exportable -CertStoreLocation Cert:\CurrentUser\My -FriendlyName VPNClient -NotAfter (get-date).AddMonths(96) -Signer $rootCert}

 echo '- témoin 9 -'

if (Get-AzureRmVpnClientConfiguration -Name $gw.Name -ResourceGroupName $prefix) {
  $vpnClient=Get-AzureRmVpnClientConfiguration -Name $gw.Name -ResourceGroupName $prefix}
else { $vpnclient=New-AzureRmVpnClientConfiguration -Name $gw.name -ResourceGroupName $prefix -AuthenticationMethod eaptls}

if (![System.IO.File]::Exists($env:TEMP+'\'+$prefix+'.xml')) {
$destZip=$env:TEMP+'\'+$prefix+'.zip'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
echo "Récupération du fichier dans '$destZip'."
Start-BitsTransfer -Source $vpnClient.VpnProfileSASUrl -Destination $destZip
Add-Type -AssemblyName System.IO.Compression.FileSystem
New-Item -Path $env:TEMP\$prefix -ItemType Directory -Force|Out-Null
$zip=[IO.Compression.ZipFile]::OpenRead($destZip)
$zip.Entries|ForEach-Object {
  if($_.name -like '*.xml') {[IO.Compression.ZipFileExtensions]::ExtractToFile($_,$env:TEMP+'\'+$prefix+'.xml')
  }}
$zip.dispose()
Remove-Item -Path $destZip -Force}

if (!(Get-VpnConnection -Name $prefix -AllUserConnection -ErrorAction SilentlyContinue)) {
  $vpnSettings=([xml](get-content $env:TEMP\$prefix.xml)).vpnprofile
  Add-VpnConnection -Name $prefix -ServerAddress $vpnSettings.VpnServer -TunnelType ikev2 -AuthenticationMethod MachineCertificate -AllUserConnection
  #Add-VpnConnection -Name $prefix -ServerAddress $vpnSettings.VpnServer -TunnelType sstp -AuthenticationMethod MachineCertificate -AllUserConnection
  }
