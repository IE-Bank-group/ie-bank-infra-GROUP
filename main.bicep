@description('The environment type')
@allowed([
  'dev'
  'uat'
  'prod'
])
param environmentType string = 'dev'

param location string = resourceGroup().location

// App Service Parameters
@minLength(3)
@maxLength(24)
param appServiceWebsiteBEName string
@description('The app settings for the App Service website for the backend')
param appServiceWebsiteBeAppSettings array = []

// Container Registry Parameters
@description('The name of the container registry')
param containerRegistryName string
@description('The name of the default Docker image in the container registry')
param dockerRegistryImageName string
@description('The default version Docker image in the container registry')
param dockerRegistryImageVersion string = 'latest'

// Key Vault Parameters
@description('The name of the Key Vault')
param keyVaultName string
@description('The role assignments for the Key Vault')
param keyVaultRoleAssignments array = []

// Derived Variables
var acrUsernameSecretName = 'acr-username'
var acrPassword0SecretName = 'acr-password0'
var acrPassword1SecretName = 'acr-password1'

// Resources
resource keyVaultReference 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

module appServiceWebsiteBE 'modules/apps/backend-app-service.bicep' = {
  name: 'appfe-${userAlias}'
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

// Other Modules
module appServicePlan 'modules/apps/app-service-plan.bicep' = {
  name: 'appServicePlan-${environmentType}'
  params: {
    location: location
    environmentType: environmentType
    appServicePlanName: appServicePlan
  }
}

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

module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'logAnalytics-${environmentType}'
  params: {
    location: location
    workspaceName: logAnalyticsWorkspaceName
  }
}

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

module appInsights 'modules/application-insights.bicep' = {
  name: 'appInsights-${environmentType}'
  params: {
    appInsightsName: appInsightsName
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
  }
  dependsOn: [
    logAnalytics
  ]
}

// Outputs
output appServiceAppHostName string = backendAPIApp.outputs.appServiceAppHostName
output appInsightsInstrumentationKey string = appInsights.outputs.appInsightsInstrumentationKey
output appInsightsConnectionString string = appInsights.outputs.appInsightsConnectionString
output logAnalyticsWorkspaceId string = logAnalytics.outputs.workspaceId
output logAnalyticsWorkspaceName string = logAnalytics.outputs.workspaceName
