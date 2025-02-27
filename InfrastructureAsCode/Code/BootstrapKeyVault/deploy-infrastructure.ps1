
$location = 'westeurope'

az login

az account set --subscription "b7a2a1ac-43d8-496f-94d6-bd9e16397733"

az deployment sub create `
--location $location `
--template-file ".\bootstrap.bicep"  `
--parameters .\bootstrap-params.bicepparam


