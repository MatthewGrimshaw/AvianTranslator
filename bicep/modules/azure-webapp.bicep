param webAppName string
param appInsightsName string
param sku string
param linuxFxVersion string
param location string
// param repositoryUrl string
// param branch string
param tags object
param appServicePlanName string
param diagnosticSettingsName string

@description('Type of app you are deploying. This field is for legacy reasons and will not impact the type of App Insights resource you deploy.')
param type string

@description('Source of Azure Resource Manager deployment')
param requestSource string

@description('Log Analytics workspace ID to associate with your Application Insights resource.')
param workspaceResourceId string


resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'other'
  properties: {
    Application_Type: type
    Flow_Type: 'Bluefield'
    Request_Source: requestSource
    WorkspaceResourceId: workspaceResourceId
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  properties: {
    reserved: true
  }
  sku: {
    name: sku
    capacity: 2
  }
  kind: 'linux'
}

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: webAppName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    clientAffinityEnabled: false
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
      alwaysOn: true
      http20Enabled: true
      netFrameworkVersion: 'v6.0'
      healthCheckPath: '/swagger/index.html'
      appSettings:[
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~2'
        }
      ]
    }
  }
}

/*
resource srcControls 'Microsoft.Web/sites/sourcecontrols@2021-01-01' = {
  parent: appService
  name: 'web'
  properties: {
    repoUrl: repositoryUrl
    branch: branch
    isManualIntegration: true
  }
}
*/

resource slots 'Microsoft.Web/sites/slots@2022-03-01' = {
  parent: appService
  name: 'staging'
  location: location
  kind: 'app'
  tags: tags
  properties:{
    serverFarmId: appServicePlan.id
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: appService
  properties: {
    logs: [
      {
        category: 'HTTP logs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'App Service Console Logs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'App Service Application Logs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'Access Audit Logs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'IPSecurity Audit logs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'App Service Platform logs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
    workspaceId:  workspaceResourceId
  }
}
