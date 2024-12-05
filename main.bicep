@description('The environment type')
@allowed([
  'nonprod'
  'prod'
])
param environmentType string = 'nonprod'
param location string = resourceGroup().location
param userAlias string = 'apayne'

// param skuName string 
param appInsightsName string 
param logAnalyticsWorkspaceName string
// param logAnalyticsWorkspaceId string

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

param containerRegistryImageName string
param containerRegistryImageVersion string = 'latest'

param keyVaultName string = 'ie-bank-kv'

param keyVaultSecretNameACRUsername string = 'acr-username'
@sys.description('The name of the key vault secret for the ACR username')

param keyVaultSecretNameACRPassword1 string = 'acr-password1'
@sys.description('The name of the key vault secret for the first ACR password')

param keyVaultSecretNameACRPassword2 string = 'acr-password2'
@sys.description('The name of the key vault secret for the second ACR password')



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


// resource keyVaultReference 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
//   name: keyVaultName
// }


resource postgresSQLServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: postgresSQLServerName
  location: location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
    }
  properties: {
    administratorLogin: 'iebankdbadmin'
    administratorLoginPassword: 'IE.Bank.DB.Admin.Pa$$'    //appServiceAPIEnvVarDBPASS  
    version: '15'
    createMode: 'Default'
    // authConfig: {activeDirectoryAuth: 'Enabled', passwordAuth: 'Enabled', tenantId: subscription().tenantId }
    storage: {
      storageSizeGB: 32
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    highAvailability:{
      mode: 'Disabled'
      standbyAvailabilityZone: ''
    }
  }


    resource serverFirewallRules 'firewallRules@2022-12-01' = {
      name: 'AllowAllAzureServices'
      properties: {
        startIpAddress: '0.0.0.0'
        endIpAddress: '0.0.0.0'
      }
    }
  }


resource postgresSQLDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = {
  name: postgresSQLDatabaseName
  parent: postgresSQLServer
  properties: {
    charset: 'UTF8'
    collation: 'en_US.UTF8'
  }
}


module keyVault 'modules/key-vault.bicep' = {
  name: 'kv-${userAlias}-${environmentType}'
  params: {
    location: location
    keyVaultName: keyVaultName
    roleAssignments: keyVaultRoleAssignments
    }
}


module containerRegistry 'modules/container-registry.bicep' = {
  name: 'acr-${userAlias}-${environmentType}'
  params: {
    name: containerRegistryName
    location:location
    acrAdminUserEnabled: true
    adminCredentialsKeyVaultResourceId: resourceId('Microsoft.KeyVault/vaults', keyVaultName)
    adminCredentialsKeyVaultSecretUserName: keyVaultSecretNameACRUsername
    adminCredentialsKeyVaultSecretUserPassword1: keyVaultSecretNameACRPassword1
    adminCredentialsKeyVaultSecretUserPassword2: keyVaultSecretNameACRPassword2
  }
  dependsOn: [
    keyVault 
  ] 
}

resource keyVaultReference 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
  }

module appService 'modules/app-service.bicep' = {
  name: 'appService-${userAlias}-${environmentType}'
  params: {
    location: location
    appServiceAppName: appServiceAppName
    appServiceAPIAppName: appServiceAPIAppName
    appServicePlanName: appServicePlanName
    environmentType: environmentType
    appServiceAPIDBHostDBUSER: appServiceAPIDBHostDBUSER
    appServiceAPIDBHostFLASK_APP: appServiceAPIDBHostFLASK_APP
    appServiceAPIDBHostFLASK_DEBUG: appServiceAPIDBHostFLASK_DEBUG
    appServiceAPIEnvVarDBHOST: appServiceAPIEnvVarDBHOST
    appServiceAPIEnvVarDBNAME: appServiceAPIEnvVarDBNAME
    appServiceAPIEnvVarDBPASS: appServiceAPIEnvVarDBPASS
    appServiceAPIEnvVarENV: appServiceAPIEnvVarENV
    containerRegistryImageName: containerRegistryImageName
    containerRegistryImageVersion: containerRegistryImageVersion
    containerRegistryName: containerRegistryName
    keyVaultName: keyVaultName
    dummyOutput: containerRegistry.outputs.name
  }
  dependsOn: [
    containerRegistry
    postgresSQLDatabase
    keyVault
  ]
}



module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'logAnalytics-${userAlias}-${environmentType}'
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    location: location
  }
}


module appInsights 'modules/application-insights.bicep' = {
  name: 'appInsights-${userAlias}-${environmentType}'
  params: {
    location: location
    appInsightsName: appInsightsName
    // logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}




output appServiceAppHostName string = appService.outputs.appServiceAppHostName

// // Outputs
// output appServiceAppHostName string = appServiceWebsiteBE.outputs.appServiceAppHostName
// output appInsightsInstrumentationKey string = appInsights.outputs.appInsightsInstrumentationKey
// output appInsightsConnectionString string = appInsights.outputs.appInsightsConnectionString
// output logAnalyticsWorkspaceId string = logAnalytics.outputs.workspaceId
// output logAnalyticsWorkspaceName string = logAnalytics.outputs.logAnalyticsWorkspaceName

