@description('The environment type')
@allowed([
  'dev'
  'uat'
  'prod'
])
param environmentType string = 'dev'

@description('The Azure location where resources will be deployed')
param location string = resourceGroup().location

// App Service Parameters
@minLength(3)
@maxLength(24)
param appServiceWebsiteBEName string
@description('The app settings for the App Service website backend')
param appServiceWebsiteBeAppSettings array = []

// Container Registry Parameters
@description('The name of the container registry')
param containerRegistryName string
@description('The name of the default Docker image in the container registry')
param dockerRegistryImageName string
@description('The default version of the Docker image in the container registry')
param dockerRegistryImageVersion string = 'latest'

// Key Vault Parameters
@description('The name of the Key Vault')
param keyVaultName string
@description('The role assignments for the Key Vault')
param keyVaultRoleAssignments array = []

// Log Analytics Parameters
@description('Name of the Log Analytics workspace')
param logAnalyticsWorkspaceName string
@description('SKU for the Log Analytics workspace')
param logAnalyticsSkuName string
@description('Retention period for data in Log Analytics workspace')
param logAnalyticsRetentionDays int

// Application Insights Parameters
@description('The Application Insights name')
param appInsightsName string
@description('The Application Insights application type')
param appInsightsType string
@description('The retention period for Application Insights data in days')
param appInsightsRetentionDays int

// Derived Variables
var acrUsernameSecretName = 'acr-username'
var acrPassword0SecretName = 'acr-password0'
var acrPassword1SecretName = 'acr-password1'

// Resources
resource keyVaultReference 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// App Service Backend Module
module appServiceWebsiteBE 'modules/apps/backend-app-service.bicep' = {
  name: 'appServiceBE-${environmentType}'
  params: {
    name: appServiceWebsiteBEName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    appCommandLine: ''
    appSettings: appServiceWebsiteBeAppSettings
    dockerRegistryName: containerRegistryName
    dockerRegistryServerUserName: keyVaultReference.getSecret(acrUsernameSecretName)
    dockerRegistryServerPassword: keyVaultReference.getSecret(acrPassword0SecretName)
    dockerRegistryImageName: dockerRegistryImageName
    dockerRegistryImageVersion: dockerRegistryImageVersion
  }
  dependsOn: [
    appServicePlan
    containerRegistry
    keyVaultReference
  ]
}

// App Service Plan Module
module appServicePlan 'modules/apps/app-service-plan.bicep' = {
  name: 'appServicePlan-${environmentType}'
  params: {
    location: location
    environmentType: environmentType
    appServicePlanName: appServiceWebsiteBEName
  }
}

// Container Registry Module
module containerRegistry 'modules/container-registry.bicep' = {
  name: 'containerRegistry-${environmentType}'
  params: {
    name: containerRegistryName
    location: location
    keyVaultResourceId: keyVaultReference.id
    keyVaultSecretNameAdminUsername: acrUsernameSecretName
    keyVaultSecretNameAdminPassword0: acrPassword0SecretName
    keyVaultSecretNameAdminPassword1: acrPassword1SecretName
    workspaceResourceId: logAnalytics.outputs.workspaceId
  }
  dependsOn: [
    keyVaultReference
  ]
}

// Log Analytics Module
module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'logAnalytics-${environmentType}'
  params: {
    location: location
    workspaceName: logAnalyticsWorkspaceName
    skuName: logAnalyticsSkuName
    dataRetention: logAnalyticsRetentionDays
  }
}

// Key Vault Module
module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVault-${environmentType}'
  params: {
    keyVaultName: keyVaultName
    location: location
    roleAssignments: keyVaultRoleAssignments
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
  }
  dependsOn: [
    logAnalytics
  ]
}

// Application Insights Module
module appInsights 'modules/application-insights.bicep' = {
  name: 'appInsights-${environmentType}'
  params: {
    appInsightsName: appInsightsName
    location: location
    workspaceResourceId: logAnalytics.outputs.workspaceId
    applicationType: appInsightsType
    retentionInDays: appInsightsRetentionDays
  }
  dependsOn: [
    logAnalytics
  ]
}

// Outputs
output appServiceAppHostName string = appServiceWebsiteBE.outputs.appServiceAppHostName
output appInsightsInstrumentationKey string = appInsights.outputs.appInsightsInstrumentationKey
output appInsightsConnectionString string = appInsights.outputs.appInsightsConnectionString
output logAnalyticsWorkspaceId string = logAnalytics.outputs.workspaceId
output logAnalyticsWorkspaceName string = logAnalytics.outputs.workspaceName

