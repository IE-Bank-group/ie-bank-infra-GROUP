param appServiceAPIAppName string 
param location string = resourceGroup().location
param appServicePlanId string
param appSettings array = []


//NEEDS DOCKER CREDENTIALS  


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
      linuxFxVersion: 'PYTHON|3.11'
      alwaysOn: false
      appSettings: appSettings
      appCommandLine: ''
    }
  }
}




output appServiceAppAPIHostName string = appServiceAPIApp.properties.defaultHostName       //do we need this same outpt from both FE & BE
output systemAssignedIdentityPrincipalId string = appServiceAPIApp.identity.principalId    //unsure where this is used


