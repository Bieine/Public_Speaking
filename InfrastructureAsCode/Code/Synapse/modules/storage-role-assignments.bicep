
// Param & variables for Role assignment

@description('Name of the storage account for role assignments')
param storageAccountName string

@description('ID of the AD group or ID of single user for role assignment')
param adGroupIds array

// Role Definition 

// Role definition Ids to be found here: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles

resource role_StorageBlobDataContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing =  {
  name: storageAccountName
}

/* note - this module should assign one role assignment 
 role assignment name has to be unique therefore function guid() is used, which is deterministic
*/

resource storageAccountRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for identity in adGroupIds :  {
  name: guid(identity, storageAccount.id, subscription().id)
  scope: storageAccount
  properties: {
    roleDefinitionId: role_StorageBlobDataContributor.id
    principalId: identity
  }
}]
