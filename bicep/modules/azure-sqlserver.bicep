param location string = resourceGroup().location
param azureSqlName string
@secure()
param aadUsername string
@secure()
param aadSid string
param databaseName string
param tags object
param sqlDiagnosticSettingsName string
param logAnalyticsWorkspaceName string
param logAnalyticsResourceGroup string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(logAnalyticsResourceGroup)
}

resource azureSql 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: azureSqlName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: aadUsername
      principalType: 'User'
      sid: aadSid
      tenantId: tenant().tenantId
    }
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2020-08-01-preview' = {
  name: databaseName
  parent: azureSql
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 1073741824
  }
}

resource sqlserverName_AllowAMyIp 'Microsoft.Sql/servers/firewallRules@2014-04-01' = {
  name: 'AllowMyIp'
  parent: azureSql
  properties: {
    endIpAddress: '195.249.232.84'
    startIpAddress: '195.249.232.84'
  }
}


resource sqlatp 'Microsoft.Sql/servers/advancedThreatProtectionSettings@2022-05-01-preview' = {
  name: 'Default'
  parent: azureSql
  properties: {
    state: 'Enabled'
  }
}

resource assessment 'Microsoft.Sql/servers/sqlVulnerabilityAssessments@2022-05-01-preview' = {
  parent: azureSql
  name: 'Default'
  properties: {
    state: 'Enabled'
  }
}

resource defenderforcloud 'Microsoft.Sql/servers/securityAlertPolicies@2022-05-01-preview' = {
  name: 'Default'
  parent: azureSql
  properties: {
    emailAccountAdmins: true
    emailAddresses: [
      'string'
    ]
    state: 'Enabled'
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: sqlDatabase
  name: sqlDiagnosticSettingsName
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'SQLSecurityAuditEvents'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'DevOpsOperationsAudit'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

resource auditingSettings 'Microsoft.Sql/servers/auditingSettings@2021-11-01-preview' = {
  parent: azureSql
  name: 'default'
  properties: {
    state: 'Enabled'
    isAzureMonitorTargetEnabled: true
  }
}

resource devOpsAuditingSettings 'Microsoft.Sql/servers/devOpsAuditingSettings@2021-11-01-preview' = {
  parent: azureSql
  name: 'default'
  properties: {
    state: 'Enabled'
    isAzureMonitorTargetEnabled: true
  }
}
