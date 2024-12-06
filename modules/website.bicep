param location string = resourceGroup().location
param webLocation string
@allowed([
  'nonprod'
  'prod' 
])
param environmentType string 
param userAlias string 

param sku string 
param appServicePlanName string 
param appServicePlanSkuName string = (environmentType == 'prod') ? 'B1' : 'B1'
param appServiceAppName string
param appServiceAPIAppName string 

param appServiceAPIDBHostDBUSER string 
param appServiceAPIDBHostFLASK_APP string 
param appServiceAPIDBHostFLASK_DEBUG string 
param appServiceAPIEnvVarDBHOST string 
param appServiceAPIEnvVarDBNAME string 
param appServiceAPIEnvVarDBPASS string
param appServiceAPIEnvVarENV string

param containerRegistryName string
param keyVaultSecretNameAdminUsername string
param keyVaultSecretNameAdminPassword0 string
param keyVaultSecretNameAdminPassword1 string

param postgresSQLDatabaseName string
param postgresSQLServerName string 

param appInsightsName string 

param keyVaultResourceId string 

param logAnalyticsWorkspaceId string 





module containerRegistry './container-registry.bicep' = {
  name: 'acr-${userAlias}-${environmentType}'
  params: {
    name: containerRegistryName
    location:location
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    keyVaultResourceId: keyVaultResourceId
    keyVaultSecretNameAdminUsername: keyVaultSecretNameAdminUsername
    keyVaultSecretNameAdminPassword0: keyVaultSecretNameAdminPassword0
    keyVaultSecretNameAdminPassword1: keyVaultSecretNameAdminPassword1
  }
}


module appInsights './application-insights.bicep' = {
  name: 'appInsights-${userAlias}-${environmentType}'
  params: {
    location: location
    appInsightsName: appInsightsName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}


resource keyVaultReference 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: last(split(keyVaultResourceId, '/'))
}




module appServicePlan './app-service-plan.bicep' = {
  name: appServicePlanName
  params: {
    appServicePlanName: appServicePlanName
    location: location
    appServicePlanSkuName: appServicePlanSkuName
  }
}


//FRONTEND
module appServiceApp './fe-app-service.bicep' = {
  name: appServiceAppName
  params: {
    appServiceAppName: appServiceAppName
    // location: location
    webLocation: webLocation
    // appServicePlanId: appServicePlan.outputs.planId
    sku: sku
  }

}



//BACKEND
module appServiceAPIApp './be-app-service.bicep'= {
  name: appServiceAPIAppName
  params: {
    appServiceAPIAppName: appServiceAPIAppName
    location: location
    appServicePlanId: appServicePlan.outputs.planId
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
  dependsOn: [
    appInsights
    appServicePlan
    containerRegistry
    keyVaultReference
  ]
}




module appDatabase './database.bicep' = {
  name: 'appDatabase-${userAlias}-${environmentType}'
  params: {
    location: location
    postgresSQLDatabaseName: postgresSQLDatabaseName
    postgresSQLServerName: postgresSQLServerName
  }

}  

// need static web app url, endpoints, resource name 
output appServiceAppHostName string = appServiceApp.outputs.appServiceAppHostName
// output appServiceAppEndpoint string = appServiceApp.outputs.appServiceAppHostName
