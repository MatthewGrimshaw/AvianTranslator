param location string = resourceGroup().location
param azureSqlName string
@secure()
param aadUsername string
@secure()
param aadSid string
param databaseName string

resource azureSql 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: azureSqlName
  location: location
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

resource sqlserverName_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2014-04-01' = {
  name: 'AllowAllWindowsAzureIps'
  parent: azureSql
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}
