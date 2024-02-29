# azure cli

az login

az account show

az account list

az account set --subscription d3a6d337-5d00-48be-8db0-271e755b197b

# create resource group
az group create --location westeurope --name rg-bicepcourse

# deploy bicep template to resource group
az deployment group create `
    --subscription "Demo" `
    --resource-group rg-bicepcourse `
    --name deployment `
    --mode Incremental `
    --template-file main.bicep `
    --parameters .\main-params.bicepparam


# deploy bicep template to subscription

az deployment sub create `
    --name deployment `
    --location westeurope `
    --template-file main.bicep `
    --parameters .\main-params.bicepparam

 # delete resource group   
az group delete --name RG-DynamicsFO-Dev
