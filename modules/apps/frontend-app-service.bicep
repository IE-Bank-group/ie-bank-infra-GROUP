param appServiceAppName string
param appServicePlanId string
param location string
param appInsightsInstrumentationKey string 
param appInsightsConnectionString string

@allowed([
  'dev'
  'uat'
  'prod'
])
param environmentType string

var frontendConfig = {
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
var alwaysOnSetting = frontendConfig[environmentType].alwaysOn



resource frontendServiceApp 'Microsoft.Web/sites@2021-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'NODE|18-lts' 
      alwaysOn: alwaysOnSetting   
      ftpsState: 'FtpsOnly'
      appCommandLine: 'pm2 serve /home/site/wwroot --spa --no-daemon'
      appSettings: [{
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: appInsightsInstrumentationKey
        }
        {
        name:'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: appInsightsConnectionString
        }
      ]
    }  
  }
}

output serviceAppHostName string = frontendServiceApp.properties.defaultHostName
