param name string
param location string = resourceGroup().location
param keyVaultResourceId string
param keyVaultSecretNameAdminUsername string
param keyVaultSecretNameAdminPassword0 string
param keyVaultSecretNameAdminPassword1 string
param workspaceResourceId string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${name}-diag'
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
        categoryGroup: 'allLogs'
        enabled: true
      }
      {
        categoryGroup: 'audit'
        enabled: true
      }
    ]
  }
}


//TRINIS CODE 
// if a keyvault resource id is provided
resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = if (!empty(keyVaultResourceId)) {
  name: last(split((empty(keyVaultResourceId) ? keyVaultResourceId : 'dummyVault'), '/')) 
  //scope: resourceGroup(split((empty(keyVaultResourceId) ? keyVaultResourceId : '//'), '/')[2], split((empty(keyVaultResourceId) ? keyVaultResourceId : '//')))
}

// create a secret to store the container registry admin username
resource secretAdminUserName 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!(empty(keyVaultSecretNameAdminUsername))) {
  name: empty(keyVaultSecretNameAdminUsername) ? keyVaultSecretNameAdminUsername : 'dummySecret'
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().username
  }
}

// create a secret to store the container registry admin password 0
resource secretAdminUserPassword0 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!(empty(keyVaultSecretNameAdminPassword0))) {
  name: empty(keyVaultSecretNameAdminPassword0) ? keyVaultSecretNameAdminPassword0 : 'dummySecret'
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[0].value
  }
}

// create a secret to store the container registry admin password 1
resource secretAdminUserPassword1 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!(empty(keyVaultSecretNameAdminPassword1))) {
  name: empty(keyVaultSecretNameAdminPassword1) ? keyVaultSecretNameAdminPassword1 : 'dummySecret'
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[1].value
  }
}

output containerRegistryName string = containerRegistry.name
