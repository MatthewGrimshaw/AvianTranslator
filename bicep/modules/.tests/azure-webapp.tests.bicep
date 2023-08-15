@description('Configures the location to deploy the Azure resources.')
param location string = resourceGroup().location

// Test with only required parameters
module test_required_params '../azure-webapp.bicep' = {
  name: 'test_required_params'
  params: {
    webAppName: 'mywebapp'
    appInsightsName: 'myAppInsights'
    location: location
    sku: 'S1'
    linuxFxVersion: 'node|14-lts'
    appServicePlanName: 'AppServicePlan-AvianTranslator'
    requestSource: 'web'
    workspaceResourceId: 'longComplicatedString'
    type: 'web'
    diagnosticSettingsName: 'diagnosticSettingsName'
    workspaceId: 'bigLongString'

    tags:{
      env: 'prod'
      }
    }
 }
