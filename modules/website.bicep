param location string = resourceGroup().location
param webLocation string
@allowed([
  'dev'
  'uat'
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
// param postgresSQLAdminServerPrincipalName string
// param postgresSQLAdminServicePrincipalObjectId string 

param appInsightsName string 

param keyVaultResourceId string 

param logAnalyticsWorkspaceId string 

param dockerRegistryImageName string
param dockerRegistryImageTag string = 'latest'





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
    keyVaultResourceId: keyVaultResourceId
    environmentType: environmentType
  }
}


resource keyVaultReference 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: last(split(keyVaultResourceId, '/'))
}




module appServicePlan './app-service-plan.bicep' = {
  name: 'aspName-${userAlias}-${environmentType}'
  params: {
    appServicePlanName: appServicePlanName
    location: location
    appServicePlanSkuName: appServicePlanSkuName
    // logAnalyticsWorkSpaceId: logAnalyticsWorkspaceId
  }
}


//FRONTEND
module appServiceApp './fe-app-service.bicep' = {
  name: 'as-appName-${userAlias}-${environmentType}'
  params: {
    appServiceAppName: appServiceAppName
    // location: location
    webLocation: webLocation
    // appServicePlanId: appServicePlan.outputs.planId
    // appInsightsConnectionString: appInsights.outputs.appInsightsConnectionString
    // appInsightsInstrumentationKey: appInsights.outputs.appInsightsInstrumentationKey
    sku: sku
  }

}



//BACKEND
module appServiceAPIApp './be-app-service.bicep'= {
  name: 'as-APIAppName-${userAlias}-${environmentType}'
  params: {
    appServiceAPIAppName: appServiceAPIAppName
    location: location
    environmentType: environmentType
    containerRegistryName: containerRegistryName
    appServicePlanId: appServicePlan.outputs.planId
    // appInsightsConnectionString: appInsights.outputs.appInsightsConnectionString
    // appInsightsInstrumentationKey: appInsights.outputs.appInsightsInstrumentationKey
    dockerRegistryServerPassword: keyVaultReference.getSecret(keyVaultSecretNameAdminPassword0)
    dockerRegistryServerUsername: keyVaultReference.getSecret(keyVaultSecretNameAdminUsername)
    dockerRegistryImageName: dockerRegistryImageName
    dockerRegistryImageTag: dockerRegistryImageTag
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
  name: 'app-db-${userAlias}-${environmentType}'
  params: {
    location: location
    postgresSQLDatabaseName: postgresSQLDatabaseName
    postgresSQLServerName: postgresSQLServerName
    postgresSQLAdminServerPrincipalName: appServiceAPIAppName
    postgresSQLAdminServicePrincipalObjectId: appServiceAPIApp.outputs.systemAssignedIdentityPrincipalId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    userAlias:userAlias
    environmentType: environmentType
  }

}  

// need static web app url, endpoints, resource name 
output appServiceAppHostName string = appServiceApp.outputs.appServiceAppHostName
output appServiceAppEndpoint string = appServiceApp.outputs.appServiceAppEndpoint
output appServiceAppResourceName string = appServiceApp.outputs.appServiceAppResourceName
