using '' /*TODO: Provide a path to a bicep template*/

param azureSqlName = 'aviantranslatorsql.'

param aadUsername = ? /*KeyVault references are not supported in Bicep Parameters files*/

param aadSid = ? /*KeyVault references are not supported in Bicep Parameters files*/

param sqlDiagnosticSettingsName = 'sqlDiagnosticSettings'

param logAnlayticsWorkspaceName = 'mgmtworkspace'

param logAnalayticsResourceGroup = 'management'

param databaseName = 'aviantranslatordb'

param tags = {
  env: 'prod'
}