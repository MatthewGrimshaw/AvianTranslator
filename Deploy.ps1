az group create --name birderApp --location westEurope
az deployment group create --resource-group birderApp --template-file .\bicep\modules\AzuireSqlServer.bicep --parameters .\paramaters.bicep.json



## test web app
az group create --name "myWebApp" --location "westeurope"
az deployment group create --resource-group "myWebApp" --template-file .\bicep\modules\azure-webapp.bicep