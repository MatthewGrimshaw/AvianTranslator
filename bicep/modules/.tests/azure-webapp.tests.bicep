@description('Configures the location to deploy the Azure resources.')
param location string = resourceGroup().location

// Test with only required parameters
module test_required_params '../azure-webapp.bicep' = {
  name: 'test_required_params'
  params: {
    webAppName: 'mywebapp'
    location: location
    sku: 'F1'
    linuxFxVersion: 'node|14-lts'
    tags:{
      env: 'prod'
      }
    }
 }
