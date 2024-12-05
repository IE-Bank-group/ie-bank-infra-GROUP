@description('Name of the Azure Container Registry')
param name string

@description('Location of the Azure Container Registry')
param location string = resourceGroup().location

@description('SKU for the Azure Container Registry')
param sku string = 'Standard'

@description('Key Vault Resource ID')
param keyVaultResourceId string

@description('Secret name for Admin Username in Key Vault')
param keyVaultSecretNameAdminUsername string

@description('Secret name for Admin Password 0 in Key Vault')
param keyVaultSecretNameAdminPassword0 string

@description('Secret name for Admin Password 1 in Key Vault')
param keyVaultSecretNameAdminPassword1 string

@description('Log Analytics Workspace Resource ID for diagnostic settings')
param workspaceResourceId string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: true
  }
}

resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = if (!empty(keyVaultResourceId)) {
  name: last(split((!empty(keyVaultResourceId) ? keyVaultResourceId : 'dummyVault'), '/'))!
}

// Create a secret in Key Vault for the Container Registry Admin Username
resource secretAdminUserName 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!empty(keyVaultSecretNameAdminUsername)) {
  name: keyVaultSecretNameAdminUsername
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().username
  }
}

// Create a secret in Key Vault for the Container Registry Admin Password 0
resource secretAdminUserPassword0 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!empty(keyVaultSecretNameAdminPassword0)) {
  name: keyVaultSecretNameAdminPassword0
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[0].value
  }
}

// Create a secret in Key Vault for the Container Registry Admin Password 1
resource secretAdminUserPassword1 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!empty(keyVaultSecretNameAdminPassword1)) {
  name: keyVaultSecretNameAdminPassword1
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[1].value
  }
}

resource acrDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'ContainerRegistryDiagnostic'
  scope: containerRegistry
  properties: {
    workspaceId: workspaceResourceId
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    logs: [
      {
        category: 'ContainerRegistryLoginEvents'
        enabled: true
      }
      {
        category: 'ContainerRegistryRepositoryEvents'
        enabled: true
      }
    ]
  }
}

output registryLoginServer string = containerRegistry.properties.loginServer


