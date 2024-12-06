param name string
param location string = resourceGroup().location
param keyVaultResourceId string
param keyVaultSecretNameAdminUsername string
param keyVaultSecretNameAdminPassword0 string
param keyVaultSecretNameAdminPassword1 string
param logAnalyticsWorkspaceId string
param ContainerRegistryDiagnostics string ='myDiagnosticSetting'


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
  name: ContainerRegistryDiagnostics
  scope: containerRegistry
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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



resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = if (!empty(keyVaultResourceId)) {
  name: last(split((empty(keyVaultResourceId) ? keyVaultResourceId : 'dummyVault'), '/')) 
  //scope: resourceGroup(split((empty(keyVaultResourceId) ? keyVaultResourceId : '//'), '/')[2], split((empty(keyVaultResourceId) ? keyVaultResourceId : '//')))
}

// create a secret to store the container registry admin username
resource secretAdminUserName 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!(empty(keyVaultSecretNameAdminUsername))) {
  name:keyVaultSecretNameAdminUsername 
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().username
  }
}

// create a secret to store the container registry admin password 0
resource secretAdminUserPassword0 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!(empty(keyVaultSecretNameAdminPassword0))) {
  name: keyVaultSecretNameAdminPassword0
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[0].value
  }
}

// create a secret to store the container registry admin password 1
resource secretAdminUserPassword1 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!(empty(keyVaultSecretNameAdminPassword1))) {
  name: keyVaultSecretNameAdminPassword1
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[1].value
  }
}









// output containerRegistryAdminUserName string = containerRegistry.listCredentials().username
// output containerRegistryAdminPassword0 string = containerRegistry.listCredentials().passwords[0].value
// output containerRegistryAdminPassword1 string = containerRegistry.listCredentials().passwords[1].value

//disable-next-line outputs-should-not-contain-secrets
// output containerRegistryUserName string = containerRegistry.listCredentials().username
// //disable-next-line outputs-should-not-contain-secrets
// output containerRegistryPassword0 string = containerRegistry.listCredentials().passwords[0].value
// //disable-next-line outputs-should-not-contain-secrets
// output containerRegistryPassword1 string = containerRegistry.listCredentials().passwords[1].value
