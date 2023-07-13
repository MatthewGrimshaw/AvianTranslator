@description('Configures the location to deploy the Azure resources.')
param location string = resourceGroup().location

// Test with only required parameters
module test_required_params '../azure-sqlserver.bicep' = {
  name: 'test_required_params'
  params: {
    logAnalyticsWorkspaceName: 'mgmtworkspace'
    logAnalyticsResourceGroup: 'management'
    azureSqlName: 'sqlserver'
    location: location
    aadUsername: 'username@email.com'
    aadSid: 'longsid'
    databaseName: 'testdb'
    sqlDiagnosticSettingsName: 'sqlDiagnosticSettingsName'
    tags:{
      env: 'prod'
      }
    }
 }
