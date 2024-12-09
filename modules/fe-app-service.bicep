param appServiceAppName string
// param location string = resourceGroup().location
// param appServicePlanId string
param sku string 
param webLocation string 
// param appInsightsConnectionString string 
// param appInsightsInstrumentationKey string 


param keyVaultResourceId string

param keyVaultSecretName string

//NEEDS APPINSIGHTS CONNECTIONS 


//CONVERT THIS INTO STATIC WEB APP
// resource appServiceApp 'Microsoft.Web/sites@2021-03-01' = {
//   name: appServiceAppName
//   location: location
//   properties: {
//     serverFarmId: appServicePlanId
//     httpsOnly: true
//     siteConfig: {
//       ftpsState: 'FtpsOnly'
//       linuxFxVersion: 'NODE|18-lts' 
//       alwaysOn: false   
//       appCommandLine: 'pm2 serve /home/site/wwroot --spa --no-daemon'
//       appSettings: []
//     }  
//   }
//   // sku: {
//   //   name: sku
//   //   tier: 'Standard'
//   //   }
// }


//converted to static web app
resource appServiceApp 'Microsoft.Web/staticSites@2024-04-01' = {
  name: appServiceAppName
  location: webLocation
  properties: {
    allowConfigFileUpdates: false
  }
  sku: {
    name: sku
    tier: 'Standard'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: last(split(keyVaultResourceId, '/'))
}

resource deploymentTokenSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: keyVaultSecretName
  parent: keyVault
  properties: {
    value: staticSite.listSecrets().properties.apiKey
  }
}




output appServiceAppHostName string = appServiceApp.properties.defaultHostname
//need two more outputs - endpoint & resource name
output appServiceAppEndpoint string = appServiceApp.properties.contentDistributionEndpoint
output appServiceAppResourceName string = appServiceApp.name
