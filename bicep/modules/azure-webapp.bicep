param webAppName string
param sku string
param linuxFxVersion string
param location string
// param repositoryUrl string
// param branch string
param tags object
var appServicePlanName = toLower('AppServicePlan-${webAppName}')
var webSiteName = toLower('wapp-${webAppName}')

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  properties: {
    reserved: true
  }
  sku: {
    name: sku
    capacity: 1
  }
  kind: 'linux'
}

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: webSiteName
  location: location
  tags: tags
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
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
