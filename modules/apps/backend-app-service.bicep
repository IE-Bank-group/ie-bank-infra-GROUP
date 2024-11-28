param appServiceAPIAppName string
param appServicePlanId string
param location string = resourceGroup().location
param containerRegistryName string
param dockerRegistryImageName string
param dockerRegistryImageTag string = 'latest'

@secure()
param dockerRegistryUserName string
@secure()
param dockerRegistryPassword string

param appSettings array = []
param appCommandLine string = ''

@allowed([
  'dev'
  'uat'
  'prod'
])
param environmentType string 

var backendConfig = {
  dev: {
    alwaysOn: false
  }
  uat: {
    alwaysOn: false
  }
  prod: {
    alwaysOn: true
  }
}
var alwaysOnSetting = backendConfig[environmentType].alwaysOn

var dockerAppSettings = [
  { name: 'DOCKER_REGISTRY_SERVER_URL', value: 'https://${containerRegistryName}.azurecr.io'}
  { name: 'DOCKER_REGISTRY_SERVER_USERNAME', value: dockerRegistryUserName }
  { name: 'DOCKER_REGISTRY_SERVER_PASSWORD', value: dockerRegistryPassword }
]



resource backendAPIApp 'Microsoft.Web/sites@2021-02-01' = {
  name: appServiceAPIAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${dockerRegistryImageName}:${dockerRegistryImageTag}'
      alwaysOn: alwaysOnSetting
      ftpsState: 'FtpsOnly'
      appSettings: union(appSettings, dockerAppSettings)
      appCommandLine: appCommandLine
    }
  }
}


output systemAssignedIdentityPrincipalId string = backendAPIApp.identity.principalId
output appServiceAppHostName string = backendAPIApp.properties.defaultHostName
// output dockerImage string = '${containerRegistryName}.azurecr.io/${dockerRegistryImageName}:${dockerRegistryImageTag}'

