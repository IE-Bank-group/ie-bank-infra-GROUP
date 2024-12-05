param appServiceAppName string
param location string = resourceGroup().location
// param appServicePlanId string
param sku string 

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
  location: location
  properties: {
    allowConfigFileUpdates: false
  }
  sku: {
    name: sku
    tier: 'Standard'
  }
}






output appServiceAppHostName string = appServiceApp.properties.defaultHostname
//need two more outputs - endpoint & resource name
