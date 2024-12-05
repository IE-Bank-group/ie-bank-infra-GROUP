param appServiceAppName string
param location string = resourceGroup().location
param appServicePlanId string

//NEEDS APPINSIGHTS CONNECTIONS 



resource appServiceApp 'Microsoft.Web/sites@2021-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      ftpsState: 'FtpsOnly'
      linuxFxVersion: 'NODE|18-lts' 
      alwaysOn: false   
      appCommandLine: 'pm2 serve /home/site/wwroot --spa --no-daemon'
      appSettings: []
    }  
  }
}


output appServiceAppHostName string = appServiceApp.properties.defaultHostName
