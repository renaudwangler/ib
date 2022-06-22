param location string = resourceGroup().location
param rgName string = resourceGroup().name
param storageName string

var ipNameSpace = '10.255.0.0'
var clientSubnet = '10.255.0.0'
var bastionSubnet = '10.255.255.0'
var cloudshellShare = 'cloudshell'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-08-01' = {
    name : '${rgName}Vnet'
    location : location
    properties: {
        addressSpace: { addressPrefixes: [ '${ipNameSpace}/16' ] }
        subnets : [
            { name: clientSubnet, properties: { addressPrefix: '${clientSubnet}/24' } }
            { name: 'AzureBastionSubnet', properties: { addressPrefix: '${bastionSubnet}/24' } }
        ]
    }
}
output virtualNetworkName string = virtualNetwork.name

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
    name: storageName
    location: location
    sku: { name: 'Standard_LRS' }
    kind: 'StorageV2'
    properties:{
        minimumTlsVersion: 'TLS1_2'
        allowBlobPublicAccess: false
        allowSharedKeyAccess: true
        networkAcls: {
            bypass:'AzureServices'
            defaultAction:'Allow'
        }
        accessTier:'Hot'
    }
}
output storageAccountName string = storageAccount.name

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2021-09-01' = {
    parent:storageAccount
    name: 'default'
}
resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' = {
    parent : fileService
    name : cloudshellShare
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = {
    name: '${rgName}Verrou'
    properties: {
        level:'CanNotDelete'
        notes: 'Ce groupe de ressources est vérouillé afin d\'éviter une suppression accidentelle.'

        }
}
