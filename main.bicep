@description('The environment type')
@allowed([
  'dev'
  'uat'
  'prod'
])
param environmentType string 
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
param keyVaultSecretNameAdminUsername string
param keyVaultSecretNameAdminPassword0 string
param keyVaultSecretNameAdminPassword1 string
@secure()
param deploymentToken string

// param appSettings array 
param dockerRegistryImageName string
param dockerRegistryImageTag string = 'latest'
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
// param postgresSQLAdminServerPrincipalName string
// param postgresSQLAdminServicePrincipalObjectId string 

var logAnalyticsWorkspaceId = logAnalytics.outputs.logAnalyticsWorkspaceId
var keyVaultResourceId = keyVault.outputs.keyVaultResourceId
// param keyVaultResourceId string = resourceId('Microsoft.KeyVault/vaults', keyVaultName)

param logicAppName string 
param slackUrl string 

 



module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'law-${userAlias}-${environmentType}'
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    location: location
  }
}


module keyVault 'modules/key-vault.bicep' = {
  name: 'kv-${userAlias}-${environmentType}'
  params: {
    location: location
    roleAssignments: keyVaultRoleAssignments
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    }
}



module appService 'modules/website.bicep' = {
  name: 'as-${userAlias}-${environmentType}'
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
    keyVaultResourceId: keyVaultResourceId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    keyVaultSecretNameAdminUsername: keyVaultSecretNameAdminUsername
    keyVaultSecretNameAdminPassword0: keyVaultSecretNameAdminPassword0
    keyVaultSecretNameAdminPassword1: keyVaultSecretNameAdminPassword1
    dockerRegistryImageName: dockerRegistryImageName
    dockerRegistryImageTag: dockerRegistryImageTag
    slackUrl: slackUrl
    deploymentToken : deploymentToken 
    // postgresSQLAdminServerPrincipalName: postgresSQLAdminServerPrincipalName
    // postgresSQLAdminServicePrincipalObjectId: postgresSQLAdminServicePrincipalObjectId
  }
}



module logicAppModule 'modules/logic-app.bicep' = {
  name: 'logicAppDeployment'
  params: {
    logicAppName: logicAppName
    slackWebhookUrl: slackUrl
  }
}





output appServiceAppHostName string = appService.outputs.appServiceAppHostName
output appServiceAppEndpoint string = appService.outputs.appServiceAppEndpoint
output appServiceAppResourceName string = appService.outputs.appServiceAppResourceName
// output appInsightsInstrumentationKey string = appInsights.outputs.appInsightsInstrumentationKey
// output appInsightsConnectionString string = appInsights.outputs.appInsightsConnectionString
output logAnalyticsWorkspaceId string = logAnalytics.outputs.logAnalyticsWorkspaceId
output logAnalyticsWorkspaceName string = logAnalytics.outputs.logAnalyticsWorkspaceName

