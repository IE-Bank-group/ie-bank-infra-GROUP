@description('The environment type')
@allowed([
  'nonprod'
  'prod'
])
param environmentType string = 'nonprod'
param location string = resourceGroup().location
param webLocation string 
param userAlias string = 'apayne'

// param skuName string 
param appInsightsName string 
param logAnalyticsWorkspaceName string
// param logAnalyticsWorkspaceId string

param appServicePlanSkuName string 
param appServiceAPIEnvVarENV string
param appServiceAPIEnvVarDBHOST string
param appServiceAPIEnvVarDBNAME string
@secure()
param appServiceAPIEnvVarDBPASS string
param appServiceAPIDBHostDBUSER string
param appServiceAPIDBHostFLASK_APP string
param appServiceAPIDBHostFLASK_DEBUG string

param containerRegistryName string ='apayne-acr'

// param appSettings array 
// param dockerRegistryImageName string
// param dockerRegistryImageTag string = 'latest'
// param dockerRegistryUsername string 
// param dockerRegistryPassword string 


param keyVaultName string = 'ie-bank-kv'
param keyVaultRoleAssignments array 

// Derived Variables
// var acrUsernameSecretName = 'acr-username'
// var acrPassword0SecretName = 'acr-password0'
// var acrPassword1SecretName = 'acr-password1'

@minLength(3)
@maxLength(24)
param postgresSQLServerName string = 'ie-bank-db-server'
@minLength(3)
@maxLength(24)
param postgresSQLDatabaseName string = 'ie-bank-db'
@minLength(3)
@maxLength(24)
param appServicePlanName string = 'ie-bank-app-sp'
@minLength(3)
@maxLength(24)
param appServiceAppName string = 'ie-bank'
@minLength(3)
@maxLength(24)
param appServiceAPIAppName string = 'ie-bank-api'
param sku string 
var logAnalyticsWorkspaceId = logAnalytics.outputs.logAnalyticsWorkspaceId
// var keyVaultResourceId = keyVault.outputs.keyVaultResourceId



module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'logAnalytics-${userAlias}-${environmentType}'
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    location: location
  }
}


module appService 'modules/website.bicep' = {
  name: 'appService-${userAlias}-${environmentType}'
  params: {
    location: location
    webLocation: webLocation
    appServiceAppName: appServiceAppName
    appServiceAPIAppName: appServiceAPIAppName
    appServicePlanName: appServicePlanName
    appServicePlanSkuName: appServicePlanSkuName
    environmentType: environmentType
    appServiceAPIDBHostDBUSER: appServiceAPIDBHostDBUSER
    appServiceAPIDBHostFLASK_APP: appServiceAPIDBHostFLASK_APP
    appServiceAPIDBHostFLASK_DEBUG: appServiceAPIDBHostFLASK_DEBUG
    appServiceAPIEnvVarDBHOST: appServiceAPIEnvVarDBHOST
    appServiceAPIEnvVarDBNAME: appServiceAPIEnvVarDBNAME
    appServiceAPIEnvVarDBPASS: appServiceAPIEnvVarDBPASS
    appServiceAPIEnvVarENV: appServiceAPIEnvVarENV
    sku: sku
    containerRegistryName: containerRegistryName
    userAlias: userAlias
    postgresSQLDatabaseName: postgresSQLDatabaseName
    postgresSQLServerName: postgresSQLServerName
    appInsightsName: appInsightsName
    // keyVaultResourceId: keyVault.outputs.keyVaultResourceId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}


module keyVault 'modules/key-vault.bicep' = {
  name: 'kv-${userAlias}-${environmentType}'
  params: {
    location: location
    keyVaultName: keyVaultName
    roleAssignments: keyVaultRoleAssignments
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceName
    }
}







output appServiceAppHostName string = appService.outputs.appServiceAppHostName

// // Outputs
// output appServiceAppHostName string = appServiceWebsiteBE.outputs.appServiceAppHostName
// output appInsightsInstrumentationKey string = appInsights.outputs.appInsightsInstrumentationKey
// output appInsightsConnectionString string = appInsights.outputs.appInsightsConnectionString
// output logAnalyticsWorkspaceId string = logAnalytics.outputs.workspaceId
// output logAnalyticsWorkspaceName string = logAnalytics.outputs.logAnalyticsWorkspaceName

