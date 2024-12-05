param name string
param location string = resourceGroup().location
// param keyVaultResourceId string
// param keyVaultSecretNameAdminUsername string
// param keyVaultSecretNameAdminPassword0 string
// param keyVaultSecretNameAdminPassword1 string
param logAnalyticsWorkspaceId string

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
  name: 'acr-diagnostics'
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
        category: 'ContainerRegistryLoginEvents' // Tracks login events
        enabled: true
      }
      {
        category: 'ContainerRegistryRepositoryEvents' // Tracks repository events (push, pull, delete)
        enabled: true
      }
    ]
  }
}



// resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = if (!empty(keyVaultResourceId)) {
//   name: last(split((empty(keyVaultResourceId) ? keyVaultResourceId : 'dummyVault'), '/')) 
//   //scope: resourceGroup(split((empty(keyVaultResourceId) ? keyVaultResourceId : '//'), '/')[2], split((empty(keyVaultResourceId) ? keyVaultResourceId : '//')))
// }

// // create a secret to store the container registry admin username
// resource secretAdminUserName 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!(empty(keyVaultSecretNameAdminUsername))) {
//   name: empty(keyVaultSecretNameAdminUsername) ? keyVaultSecretNameAdminUsername : 'dummySecret'
//   parent: adminCredentialsKeyVault
//   properties: {
//     value: containerRegistry.listCredentials().username
//   }
// }

// // create a secret to store the container registry admin password 0
// resource secretAdminUserPassword0 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!(empty(keyVaultSecretNameAdminPassword0))) {
//   name: empty(keyVaultSecretNameAdminPassword0) ? keyVaultSecretNameAdminPassword0 : 'dummySecret'
//   parent: adminCredentialsKeyVault
//   properties: {
//     value: containerRegistry.listCredentials().passwords[0].value
//   }
// }

// // create a secret to store the container registry admin password 1
// resource secretAdminUserPassword1 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!(empty(keyVaultSecretNameAdminPassword1))) {
//   name: empty(keyVaultSecretNameAdminPassword1) ? keyVaultSecretNameAdminPassword1 : 'dummySecret'
//   parent: adminCredentialsKeyVault
//   properties: {
//     value: containerRegistry.listCredentials().passwords[1].value
//   }
// }









// output containerRegistryUserName string = containerRegistry.listCredentials().username
// output containerRegistryPassword0 string = containerRegistry.listCredentials().passwords[0].value
// output containerRegistryPassword1 string = containerRegistry.listCredentials().passwords[1].value

//disable-next-line outputs-should-not-contain-secrets
// output containerRegistryUserName string = containerRegistry.listCredentials().username
// //disable-next-line outputs-should-not-contain-secrets
// output containerRegistryPassword0 string = containerRegistry.listCredentials().passwords[0].value
// //disable-next-line outputs-should-not-contain-secrets
// output containerRegistryPassword1 string = containerRegistry.listCredentials().passwords[1].value
