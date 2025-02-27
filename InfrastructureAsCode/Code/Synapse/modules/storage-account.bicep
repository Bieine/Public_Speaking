
// Param & variables for Storage Account 

@description('The name of the application')
@minLength(3)
param appName string

@description('The environment for deployment')
@minLength(3)
param environment string

@description('Location for the resources')
param location string

@description('Name of the SKU')
@allowed([
  'Standard_GRS'
  'Standard_LRS'
  'Standard_ZRS'
])
param storageAccountSku string = 'Standard_ZRS'

@description('Minimum Tls Version')
@allowed([
  'TLS1_0'
  'TLS1_1'
  'TLS1_2'
])
param tlsVersion string = 'TLS1_2'


@description('Names of the containers to deploy')
param containerNames array = ['bronze-layer'
'silver-layer'
'gold-layer']



var storageAccountName = 'sa${appName}${environment}'


// Storage Account with HnS (Data Lake)

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSku
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: tlsVersion
    supportsHttpsTrafficOnly: true
    isHnsEnabled: true
    accessTier: 'Hot'
    publicNetworkAccess: 'Enabled'
    allowBlobPublicAccess: false
  }
}


// Blob Services are deployed here to later on deploy container(s) within storage account

resource blobservices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
}


// Containers are deployed through iteration

resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [ for containerName in containerNames: {
  name: containerName
  parent: blobservices
  properties: {
    publicAccess: 'None'
  }
}]


//outputs for further consumption in other modules 

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output fileSystemContainerName string = containers[0].name
output adlsUrl string = storageAccount.properties.primaryEndpoints.dfs

