@description('The name of the function app that you wish to create')
@maxLength(15)
param appName string 

@description('The location of the resource group')
param location string 



var appNameFormatted = toLower(appName)
var locationFormatted = length(location) > 7 ? substring(location,0,7) : location 
var kvnameCandidate = 'kv-${appNameFormatted}-boot-${locationFormatted}'
var kvname = length(kvnameCandidate) > 24 ? substring(kvnameCandidate,0,24) : kvnameCandidate

resource bootStrapKeyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: kvname
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    enabledForTemplateDeployment: true
    enabledForDeployment: true
    enablePurgeProtection: true
    enableSoftDelete: true
  }
}




resource sqladmin_password_dev 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: 'sqlAdministratorLoginPassword-dev'
  parent: bootStrapKeyVault
  properties: {
    value: 'dummyvalue1'
    //contentType: 'dev, SPN1'
  }
}


resource sqladmin_password_prod 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: 'sqlAdministratorLoginPassword-prod'
  parent: bootStrapKeyVault
  properties: {
    value: 'dummyvalue1'
    //contentType: 'dev, SPN1'
  }
}


