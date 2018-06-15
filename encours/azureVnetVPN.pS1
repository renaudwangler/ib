$location='westeurope'
if ((Get-Module azurerm -ListAvailable).count -eq 0) {Install-Module azurerm -Force}
if ((Get-Module azuread -ListAvailable).count -eq 0) {Install-Module azuread -Force}
while (!(Get-AzureRmContext)) { Login-AzureRmAccount}
connect-AzureAD

if (!(Get-AzureRmResourceGroup aadds -ErrorAction SilentlyContinue)) {
  echo "Création du Resource Group 'aadds'."
  New-AzureRmResourceGroup -Name aadds -Location $location}
if (!(Get-AzureRmVirtualNetwork -Name aadds -ResourceGroupName aadds -ErrorAction SilentlyContinue)) {
  $subnetConfig=New-AzureRmVirtualNetworkSubnetConfig -name 'subnet1' -AddressPrefix 10.0.0.0/24
  $gwSubnetConfig=New-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -AddressPrefix 10.0.1.0/24
  echo "Création du Vnet 'aadds'."
  $vnet=New-AzureRmVirtualNetwork -name aadds -ResourceGroupName aadds -AddressPrefix 10.0.0.0/16 -Subnet $subnetConfig,$gwSubnetConfig -Location $location}


if (!(Get-AzureRmVirtualNetworkGateway -Name aadds-gw -ResourceGroupName aadds)) {
  $gwSubnetConfig=Get-AzureRmVirtualNetworkSubnetConfig -Name GatewaySubnet -VirtualNetwork $vnet
  echo "Création de l'adresse IP publique 'aadds-gwIP'"
  $gwpubIp=New-AzureRmPublicIpAddress -Name aadds-gwIP -ResourceGroupName aadds -Location $location -AllocationMethod Dynamic
  $gwIPConfig=New-AzureRmVirtualNetworkGatewayIpConfig -Name aadds-gwipconfig -SubnetId $gwSubnetConfig.id -PublicIpAddressId $gwpubIp.id
  echo 'Création de la Passerelle VPN aadds-gw'
  $gw=New-AzureRmVirtualNetworkGateway -Name aadds-gw -ResourceGroupName aadds -Location $location -IpConfigurations $gwIPConfig -GatewayType vpn -VpnType RouteBased -GatewaySku Standard}
while ((Get-AzureRmVirtualNetworkGateway -Name aadds-gw -ResourceGroupName aadds).provisioningState -notlike 'succeeded') {
  echo 'Attente de fin de création de la passerelle...'
  echo (Get-AzureRmVirtualNetworkGateway -Name aadds-gw -ResourceGroupName aadds).provisioningState
  Start-Sleep 30}

 $rootCert=New-SelfSignedCertificate -KeySpec KeyExchange -KeyUsage CertSign -Subject 'CN=VPNRootCA' -KeyExportPolicy Exportable -CertStoreLocation Cert:\CurrentUser\My -FriendlyName VPNRoot
 $gw=Get-AzureRmVirtualNetworkGateway -Name aadds-gw -ResourceGroupName aadds
 $certRoot=New-AzureRmVpnClientRootCertificate -Name VPNRootCA -PublicCertData ([convert]::ToBase64String($rootCert.RawData))
 Set-AzureRmVirtualNetworkGateway -VirtualNetworkGateway $gw -VpnClientAddressPool '10.1.0.0/24' -VpnClientRootCertificates $certRoot
 New-SelfSignedCertificate -KeySpec KeyExchange -Subject 'cn=VPNClient' -KeyExportPolicy Exportable -CertStoreLocation Cert:\CurrentUser\My -FriendlyName VPNClient -NotAfter (get-date).AddMonths(96) -Signer $rootCert

 Get-AzureRmVpnClientConfiguration -ResourceGroupName aadds -Name aadds-gw
#Add-VpnConnection -Name renaudVPN -ServerAddress '[récupéré dans le zip]' -TunnelType sstp -AuthenticationMethod eap -AllUserConnection $true -EncryptionLevel Optional
