targetScope = 'subscription'

@description('The name of the function app that you wish to create.')
@maxLength(15)
param appName string = 'd365fo'

@description('The location of the resource group')
param location string = 'westeurope'


var appNameFormatted = toLower(appName)
var locationFormatted = length(location) > 7 ? substring(location,0,7) : location 

resource resourceGroupShared 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${appNameFormatted}-shared-${locationFormatted}'
  location: location
}


module keyvault 'modules/keyvault.bicep' = {
  scope: resourceGroupShared
  name: 'mod-bootkv-${appNameFormatted}-${location}'
  params: {
    appName: appName
    location: location

  }
}



