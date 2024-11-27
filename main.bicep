@description('The environment type')
@allowed([
  'dev'
  'uat'
  'prod'
])
param environmentType string = 'dev'

param location string = resourceGroup().location
// var postgresSku = environmentType == 'prod' ? 'GP_B2ms' : (environmentType == 'uat' ? 'Standard_B1ms' : 'Standard_B1ms')

// PostgreSQL Parameters
// @secure()
// param postgresAdminPassword string //= keyVault.getSecret('postgres-admin-password')

@minLength(3)
@maxLength(24)
param postgresSQLServerName string 
@minLength(3)
@maxLength(24)
param postgresSQLDatabaseName string 

// param postgresSQLAdminServerPrincipalName string
// param postgresSQLAdminServerPrincipalObjectId string

// App Service Parameters

@minLength(3)
@maxLength(24)
param appServicePlanName string 
@minLength(3)
@maxLength(24)
param appServiceAppName string 
@minLength(3)
@maxLength(24)
param appServiceAPIAppName string 

//environment variables
param appServiceAPIDBHostFLASK_APP string 
param appServiceAPIEnvVarENV string 
param appServiceAPIDBHostFLASK_DEBUG string 
param appServiceAPIEnvVarDBHOST string 
param appServiceAPIEnvVarDBNAME string 
param appServiceAPIDBHostDBUSER string 
@secure()
param appServiceAPIEnvVarDBPASS string 

// Container Registry Parameters
param containerRegistryName string 

param dockerRegistryImageName string 
param dockerRegistryImageTag string 
// param dockerRegistryUserName string 
// param dockerRegistryPassword string 


// Application Insights and Log Analytics Parameters
param appInsightsName string 
param logAnalyticsWorkspaceName string 
var logAnalyticsWorkspaceId = resourceId('Microsoft.OperationalInsights/workspaces', logAnalyticsWorkspaceName)


// Key Vault Parameters
param keyVaultName string 
param keyVaultRoleAssignments array = []
param keyVaultSecretNameAdminUsername string 
param keyVaultSecretNameAdminPassword0 string 
param keyVaultSecretNameAdminPassword1 string 



//MODULE REFERENCES


module logAnalytics 'modules/log-analytics.bicep' = {
    name: 'logAnalytics-${environmentType}'
    params: {
        location: location
        workspaceName: logAnalyticsWorkspaceName
    }
}


module appInsights 'modules/application-insights.bicep' = {
    name: 'appInsights-${environmentType}'
    params: {
        appInsightsName: appInsightsName
        location: location
        logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    }
    dependsOn: [
      logAnalytics
  ]
}


module keyVault 'modules/key-vault.bicep' = {
    name: 'keyVault-${environmentType}'
    params: {
        keyVaultName: keyVaultName
        location: location
        // environmentType: environmentType
        // enableVaultForDeployment: true
        roleAssignments: keyVaultRoleAssignments
        logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    }
}



module appService 'modules/website.bicep' = {
  name: 'appService'
  params: {
    location: location
    environmentType: environmentType
    appServiceAppName: appServiceAppName
    appServiceAPIAppName: appServiceAPIAppName
    appServicePlanName: appServicePlanName
    appServiceAPIEnvVarENV: appServiceAPIEnvVarENV
    appServiceAPIDBHostDBUSER: appServiceAPIDBHostDBUSER
    appServiceAPIDBHostFLASK_APP: appServiceAPIDBHostFLASK_APP
    appServiceAPIDBHostFLASK_DEBUG: appServiceAPIDBHostFLASK_DEBUG
    appServiceAPIEnvVarDBHOST: appServiceAPIEnvVarDBHOST
    appServiceAPIEnvVarDBNAME: appServiceAPIEnvVarDBNAME
    appServiceAPIEnvVarDBPASS: appServiceAPIEnvVarDBPASS
    appInsightsInstrumentationKey: appInsights.outputs.appInsightsInstrumentationKey // implicit dependency
    appInsightsConnectionString: appInsights.outputs.appInsightsConnectionString
    keyVaultResourceId: keyVault.outputs.keyVaultResourceId 
    keyVaultSecretNameAdminUsername: keyVaultSecretNameAdminUsername
    keyVaultSecretNameAdminPassword0: keyVaultSecretNameAdminPassword0
    keyVaultSecretNameAdminPassword1: keyVaultSecretNameAdminPassword1
    postgresSQLServerName: postgresSQLServerName
    postgresSQLDatabaseName: postgresSQLDatabaseName
    dockerRegistryImageName: dockerRegistryImageName
    dockerRegistryImageTag: dockerRegistryImageTag
    containerRegistryName: containerRegistryName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
  dependsOn: [
    appInsights
  ]
}


// module postgresSQLDatabase 'modules/postgres.bicep' = {
//   name: 'postgres-${environmentType}'
//   params: {
//     postgresSQLServerName: postgreSQLServerName
//     postgresSQLDatabaseName: postgreSQLDatabaseName
//     // adminPassword: postgresAdminPassword
//     location: location
//     environmentType: environmentType
//     logsAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
//     storageSizeGB: storageSizeGB
//     appServiceAPIEnvVarDBPASS: appServiceAPIEnvVarDBPASS
//   }
//   dependsOn: [
//     keyVault
//   ]
// }


// module containerRegistry 'modules/container-registry.bicep' = {
//     name: 'containerRegistry-${environmentType}'
//     params: {
//         registryName: containerRegistryName
//         location: location
//         environmentType: environmentType
//         keyVaultResourceId: keyVault.outputs.keyVaultResourceId
//         keyVaultSecretNameAdminUsername: keyVaultSecretNameAdminUsername
//         keyVaultSecretNameAdminPassword0: keyVaultSecretNameAdminPassword0
//         keyVaultSecretNameAdminPassword1: keyVaultSecretNameAdminPassword1
//         logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
//     }
//     dependsOn: [
//       keyVault
//       logAnalytics
//   ]
// }



output appServiceAppHostName string = appService.outputs.appServiceAppHostName
output appInsightsInstrumentationKey string = appInsights.outputs.appInsightsInstrumentationKey
output appInsightsConnectionString string = appInsights.outputs.appInsightsConnectionString 
output logAnalyticsWorkspaceId string = logAnalytics.outputs.workspaceId
output logAnalyticsWorkspaceName string = logAnalytics.outputs.logAnalyticsWorkspaceName
// output postgresConnectionString string = '${postgreSQLServerName}.postgres.database.azure.com'



