using './main.bicep'

// General param

param appName = 'dynamicsfodemo'

param location = 'westeurope'

param environments = ['dev', 'prod']

param containerNames = ['bronze-layer'
'silver-layer'
'gold-layer']



// Param Synapse Workspace

param synapseWorkspaceName = 'Synapse-Dynamics-FO'

// SQL Admin Synapse  
param adminUsername = 'synapsefoadmin'

// Id of Marisol, needs to be changed to user who will be Synapse Admin in Synapse under Access control 
param synapseWsAdminId = '082dd2fc-a19a-4534-85aa-cb14a8d15a2e'


// Param Spark Pool 
 
param nodeCount = 10

param nodeSize = 'Medium'

param nodeSizeFamily = 'MemoryOptimized'

param delayInMinutes = 15

param sparkVersion = '3.3'

param bigDataPoolDeployment = true

param userid = '5672477d-4ff7-497f-910f-2a4d616eec40'
