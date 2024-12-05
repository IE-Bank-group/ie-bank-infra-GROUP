param appServiceAPIAppName string 
param location string = resourceGroup().location
param appServicePlanId string
param appCommandLine string = ''

param appServiceAPIDBHostDBUSER string 
param appServiceAPIDBHostFLASK_APP string 
param appServiceAPIDBHostFLASK_DEBUG string 
param appServiceAPIEnvVarDBHOST string 
param appServiceAPIEnvVarDBNAME string 
param appServiceAPIEnvVarDBPASS string
param appServiceAPIEnvVarENV string


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
      appCommandLine: appCommandLine
    }
  }
}




output appServiceAppAPIHostName string = appServiceAPIApp.properties.defaultHostName       //do we need this same outpt from both FE & BE
output systemAssignedIdentityPrincipalId string = appServiceAPIApp.identity.principalId    //unsure where this is used


