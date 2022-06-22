@description('Région de création des resources')
param location string = 'eastus'
@description('Nom du Resource Group')
param rgName string = 'iblabs'
@description('Nom du sotrage Account (chiffres et minuscules uniquement)')
param storageName string = 'iblabs${utcNow('yMMddHHmms')}'

targetScope = 'subscription'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = { name: rgName, location: location }

module resources 'ibAzureLabEnvironmentResources.bicep' = {
    name : 'resources'
    scope : resourceGroup
    params : {
        location: location
        rgName: rgName
        storageName: storageName
    }
}

