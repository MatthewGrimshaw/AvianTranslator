targetScope = 'subscription'

param resourceGroupName string
param location string
param tags object

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

output id string = resourceGroup.id
