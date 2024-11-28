@allowed([
  'nonprod'
  'prod'
])
param environmentType string

param location string = resourceGroup().location
param appServiceAppName string
param appServiceAPIAppName string 
param appServicePlanName string 
param appServiceAPIDBHostDBUSER string 
param appServiceAPIDBHostFLASK_APP string 
param appServiceAPIDBHostFLASK_DEBUG string 
param appServiceAPIEnvVarDBHOST string 
param appServiceAPIEnvVarDBNAME string 
param appServiceAPIEnvVarDBPASS string
param appServiceAPIEnvVarENV string

var appServicePlanSkuName = (environmentType == 'prod') ? 'B1' : 'B1'




resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
  }
  kind: 'linux'
  properties: {
    reserved: true     // for a linux-based AS
  }
}




// FRONTEND APP SERVICE APP 
resource appServiceApp 'Microsoft.Web/sites@2021-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
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



// BACKEND APP SERVICE APP
resource appServiceAPIApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAPIAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      ftpsState: 'FtpsOnly'
      linuxFxVersion: 'PYTHON|3.11'
      alwaysOn: false
      appSettings: [
        {
          name: 'ENV'
          value: appServiceAPIEnvVarENV
        }
        {
          name: 'DBNAME'
          value: appServiceAPIEnvVarDBNAME
        }
        {
          name: 'DBHOST'
          value: appServiceAPIEnvVarDBHOST
        }
        {
          name: 'DBUSER'
          value: appServiceAPIDBHostDBUSER
        }
        {
          name: 'DBPASS'
          value: appServiceAPIEnvVarDBPASS
        }
        {
          name: 'FLASK_APP'
          value: appServiceAPIDBHostFLASK_APP
        }
        {
          name: 'FLASK_DEBUG'
          value: appServiceAPIDBHostFLASK_DEBUG
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
      ]
    }
  }
}






output appServiceAppHostName string = appServiceApp.properties.defaultHostName
