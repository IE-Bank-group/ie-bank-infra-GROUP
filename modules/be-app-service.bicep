param appServiceAPIAppName string 
param location string = resourceGroup().location
param containerRegistryName string
param appServicePlanId string
param appSettings array = []
param appInsightsConnectionString string
param appInsightsInstrumentationKey string 
@secure()
param dockerRegistryServerUsername string
@secure()
param dockerRegistryServerPassword string
param dockerRegistryImageTag string
param dockerRegistryImageName string 

//NEEDS DOCKER CREDENTIALS 

var appInsightsSettings = [
  {name: 'APPINSIGHTS-INSTRUMENTATIONKEY', value: appInsightsInstrumentationKey}
  {name: 'APPINSIGHTS-CONNECTIONSTRING', value: appInsightsConnectionString}
]

var dockerAppSettings = [
  {name:'DOCKER_REGISTRY_SERVER_URL', value: 'https://${containerRegistryName}.azurecr.io'}
  { name: 'DOCKER_REGISTRY_SERVER_USERNAME', value: dockerRegistryServerUsername }
  { name: 'DOCKER_REGISTRY_SERVER_PASSWORD', value: dockerRegistryServerPassword }
]


var mergeAppSettings = concat (appSettings, appInsightsSettings, dockerAppSettings)

resource appServiceAPIApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAPIAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      ftpsState: 'FtpsOnly'
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${dockerRegistryImageName}:${dockerRegistryImageTag}'
      alwaysOn: false
      appSettings: mergeAppSettings
      appCommandLine: ''
    }
  }
}




output appServiceAppAPIHostName string = appServiceAPIApp.properties.defaultHostName       //do we need this same outpt from both FE & BE
output systemAssignedIdentityPrincipalId string = appServiceAPIApp.identity.principalId    //unsure where this is used


