
// Param & variables for Synapse Workspace

@description('The name of the application')
@minLength(3)
param appName string

@description('The environment for deployment')
@minLength(3)
param environment string

@description('Location for the resources')
param location string

@description('Name of the Synapse Workspace Admin')
param adminUsername string 

@secure()
@description('Password for Synapse Workspace Admin')
param adminPassword string 


@description('URL of ADLS')
param adlsAccountUrl string

@description('ID of ADLS')
param adlsId string

@description('The Entra Object Id of the user that should be Workspace Admin')
param synapseWsAdminId string

@description('The primary container, if nothing is defined this container is used')
param adlsFileSystemContainerName string

//Param Big Data Pool

@description('Azure Synapse Apache Spark runtime')
param sparkVersion string

@description('The number of nodes in the Big Data pool')
param nodeCount int

@description('The level of compute power that each node in the Big Data pool has')
@allowed([
  'Large'
  'Medium'
  'Small'
  'XLarge'
])
param nodeSize string


@description('The kind of nodes that the Big Data pool provides')
@allowed([
'HardwareAcceleratedFPGA'
'HardwareAcceleratedGPU'
'MemoryOptimized'
])
param nodeSizeFamily string

@description('Number of minutes of idle time before the Big Data pool is automatically paused')
param delayInMinutes int

@description('Determines whether a Big Data pool is to be deployed')
param bigDataPoolDeployment bool

// Var Synapse Workspace

var synapseWorkspaceName = toLower('sws-${appName}-${environment}')
var managedResourceGroupName = toLower('rg-${appName}-mng-${environment}')

// Var Big Data Pool

var bigDataPool = 'SparkPool'

var bigDataPoolName = '${bigDataPool}${environment}'

var minNodeCount = 3

var maxNodeCount = nodeCount


// Resource Synapse Workspace 

resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseWorkspaceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    azureADOnlyAuthentication: false
    trustedServiceBypassEnabled: false
     managedResourceGroupName: managedResourceGroupName
     publicNetworkAccess: 'Enabled'
     cspWorkspaceAdminProperties: {
      initialWorkspaceAdminObjectId: synapseWsAdminId
    }

   defaultDataLakeStorage:  {
     accountUrl: adlsAccountUrl
     filesystem: adlsFileSystemContainerName
     createManagedPrivateEndpoint: false
     resourceId: adlsId
     }
     sqlAdministratorLogin: adminUsername
      sqlAdministratorLoginPassword: adminPassword
  }

 
}


// Resource Firewall rules, if not deployed serverless SQL pool does not work, change IP adresses afterwards

resource workspaces_name_allowAll 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = {
  parent: synapseWorkspace
  name: 'allowAll'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}



// Resource Big Data Pool with conditional deployment 

resource sparkPool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = if (bigDataPoolDeployment == true) {
  name: bigDataPoolName
  location: location
  parent: synapseWorkspace
  properties: {
    sparkVersion: sparkVersion
    nodeCount: nodeCount
    nodeSize: nodeSize
    nodeSizeFamily: nodeSizeFamily
    autoScale: {
      enabled: true
      minNodeCount: minNodeCount
      maxNodeCount: maxNodeCount
    }
    autoPause: {
      enabled: true
      delayInMinutes: delayInMinutes 
    }
    isComputeIsolationEnabled: false
    sessionLevelPackagesEnabled: false
    cacheSize: 0
    dynamicExecutorAllocation: {
      enabled: false
    }
    isAutotuneEnabled: false
    provisioningState: 'Succeeded'
  }
}





resource AutoResolveIntegrationRuntime 'Microsoft.Synapse/workspaces/integrationruntimes@2021-06-01' = {
  parent: synapseWorkspace
  name: 'AutoResolveIntegrationRuntime'
  properties: {
    type: 'Managed'
    typeProperties: {
      computeProperties: {
        location: 'AutoResolve'
      }
    }
  }
}




//outputs for further consumption in other modules 

output synapseWorkspaceId string = synapseWorkspace.id
output synapseWorkspaceManagedIdentityId string = synapseWorkspace.identity.principalId
