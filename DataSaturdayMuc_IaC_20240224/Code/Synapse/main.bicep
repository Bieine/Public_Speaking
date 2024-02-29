targetScope = 'subscription'

//name of the app
param appName string

param location string

// Parameters Storage Account 


param environments array = ['dev','prod']

param containerNames array

// Parameters Synapse Workspace 

param synapseWorkspaceName string 

param adminUsername string 

param synapseWsAdminId string


// Parameters Synapse Spark Pool

param nodeCount int

param nodeSize string

param nodeSizeFamily string

param delayInMinutes int

param sparkVersion string

param bigDataPoolDeployment bool

param userid string

// Resource Group Deployment

var appNameFormatted = toLower(appName)
var locationFormatted = length(location) > 7 ? substring(location,0,7) : location 
var kvnameCandidate = 'kv-${appNameFormatted}-boot-${locationFormatted}'
var bootstrapkvname = length(kvnameCandidate) > 24 ? substring(kvnameCandidate,0,24) : kvnameCandidate

resource resourceGroup_Shared 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: 'rg-${appNameFormatted}-shared-${locationFormatted}'
 
}
 
resource keyVault_bootstrap 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  scope: resourceGroup_Shared
  name: bootstrapkvname
}


resource deploymentResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = [ for env in environments : {
  name: 'rg-${appName}-${env}'
  location: location
}]



// module name --> identifier of module
// name : name of module
module StorageAccount 'modules/storage-account.bicep' = [ for (env,index) in environments : {
  scope: deploymentResourceGroup[index]
  name: 'mod-${appName}-${env}'
  params: {
    appName: appName
    environment: env
    location: location
    containerNames: containerNames
  }
}]



module synapse 'modules/synapse-worksapce.bicep' = [ for (env,index) in environments : {
  scope: deploymentResourceGroup[index]
  name: synapseWorkspaceName
  params: {
    appName: appName
    environment: env
    location: location
    synapseWsAdminId: synapseWsAdminId     
    adlsFileSystemContainerName: StorageAccount[index].outputs.fileSystemContainerName
    adlsAccountUrl: StorageAccount[index].outputs.adlsUrl
    adlsId: StorageAccount[index].outputs.storageAccountId
    adminPassword: keyVault_bootstrap.getSecret('sqlAdministratorLoginPassword-${env}')
    adminUsername: adminUsername
    bigDataPoolDeployment: bigDataPoolDeployment
    delayInMinutes: delayInMinutes
    nodeCount: nodeCount
    nodeSize: nodeSize
    nodeSizeFamily: nodeSizeFamily
    sparkVersion: sparkVersion
 
  }
}]


module storageroleassignment 'modules/storage-role-assignments.bicep' = [ for (env,index) in environments : {
  scope: deploymentResourceGroup[index]
  name: 'role_StorageBlobDataContributor'
  params: {
    adGroupIds: [synapse[index].outputs.synapseWorkspaceManagedIdentityId, userid]
   storageAccountName: StorageAccount[index].outputs.storageAccountName
 
  }
}]
