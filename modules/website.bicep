param appServicePlanName string 
param appServiceAppName string 
param appServiceAPIAppName string 
param appServiceAPIDBHostFLASK_APP string 
param appServiceAPIEnvVarENV string 
param appServiceAPIDBHostFLASK_DEBUG string 
param appServiceAPIEnvVarDBHOST string 
param appServiceAPIEnvVarDBNAME string 
param appServiceAPIDBHostDBUSER string
@secure()
param appServiceAPIEnvVarDBPASS string 

param containerRegistryName string 
param dockerRegistryImageName string 
param dockerRegistryImageTag string 

param appInsightsInstrumentationKey string
param appInsightsConnectionString string

param postgresSQLServerName string
param postgresSQLDatabaseName string
param logAnalyticsWorkspaceId string

param keyVaultResourceId string
param keyVaultSecretNameAdminUsername string 
param keyVaultSecretNameAdminPassword0 string 
param keyVaultSecretNameAdminPassword1 string 

param location string = resourceGroup().location
@allowed([
  'dev'
  'uat'
  'prod'
])
param environmentType string

var appServicePlanSkuName = (environmentType == 'prod') ? 'B1' : 'B1'




module appServicePlan './apps/app-service-plan.bicep' = {
  name: 'appServicePlan'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    // environmentType: environmentType
    skuName: appServicePlanSkuName
  }
}



resource keyVaultReference 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: last(split(keyVaultResourceId, '/'))
}



module containerRegistry './container-registry.bicep' = {
  name: 'containerRegistry'
  params: {
    location: location
    // environmentType: environmentType
    registryName: containerRegistryName
    keyVaultResourceId: keyVaultResourceId
    keyVaultSecretNameAdminUsername: keyVaultSecretNameAdminUsername
    keyVaultSecretNameAdminPassword0: keyVaultSecretNameAdminPassword0
    keyVaultSecretNameAdminPassword1: keyVaultSecretNameAdminPassword1
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

module applicationInsights './application-insights.bicep' = {
  name: 'applicationInsights'
  params: {
    location: location
    appInsightsName: appServiceAppName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId 
  }
}


module backend './apps/backend-app-service.bicep' = {
  name: 'backend'
  params: {
    location: location
    environmentType: environmentType
    appServiceAPIAppName: appServiceAPIAppName
    appServicePlanId: appServicePlan.outputs.planId
    containerRegistryName: containerRegistryName
    dockerRegistryUserName: keyVaultReference.getSecret(keyVaultSecretNameAdminUsername)
    dockerRegistryPassword: keyVaultReference.getSecret(keyVaultSecretNameAdminPassword0)

    dockerRegistryImageName: dockerRegistryImageName
    dockerRegistryImageTag: dockerRegistryImageTag

    appSettings: [
      {
      name: 'ENV'
      value: appServiceAPIEnvVarENV
      }
      {
        name: 'DBHOST'
        value: appServiceAPIEnvVarDBHOST
      }
      {
        name: 'DBNAME'
        value: appServiceAPIEnvVarDBNAME
      }
      {
        name: 'DBPASS'
        value: appServiceAPIEnvVarDBPASS
      }
      {
        name: 'DBUSER'
        value: appServiceAPIDBHostDBUSER
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
      {
      //   name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
      //   value: appInsightsInstrumentationKey
      // }
      // {
      //   name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
      //   value: appInsightsConnectionString
      }
    ]
  }
  dependsOn: [
    appServicePlan
    keyVaultReference
    containerRegistry
    applicationInsights
  ]
}



module frontendApp './apps/frontend-app-service.bicep' = {
  name: 'frontendAppService'
  params: {
    appServiceAppName: appServiceAppName
    appServicePlanId: appServicePlan.outputs.planId
    appInsightsInstrumentationKey: appInsightsInstrumentationKey
    appInsightsConnectionString: appInsightsConnectionString
    environmentType: environmentType
    location: location
  }
}


module appDatabase './database.bicep' = {
  name: 'applicationDatabase'
  params: {
    environmentType: environmentType
    location: location
    postgresSQLServerName: postgresSQLServerName
    postgresSQLDatabaseName: postgresSQLDatabaseName
    postgreSQLAdminServicePrincipalObjectId: backend.outputs.systemAssignedIdentityPrincipalId
    postgreSQLAdminServicePrincipalName: appServiceAPIAppName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}




output appServiceAppHostName string = frontendApp.outputs.serviceAppHostName

