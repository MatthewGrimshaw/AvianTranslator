az group create --name birderApp --location westEurope
az deployment group create --resource-group birderApp --template-file .\bicep\modules\AzuireSqlServer.bicep --parameters .\paramaters.bicep.json