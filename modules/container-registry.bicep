param name string
param location string = resourceGroup().location
param keyVaultResourceId string
param keyVaultSecretNameAdminUsername string
param keyVaultSecretNameAdminPassword0 string
param keyVaultSecretNameAdminPassword1 string
// param workspaceResourceId string

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



resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = if (!empty(keyVaultResourceId)) {
  name: last(split((!empty(keyVaultResourceId) ? keyVaultResourceId : 'dummyVault'), '/'))!
}

// create a secret to store the container registry admin username
resource secretAdminUserName 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!empty(keyVaultSecreNameAdminUsername)) {
  name: !empty(keyVaultSecreNameAdminUsername) ? keyVaultSecreNameAdminUsername : 'dummySecret'
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().username
}
}
// create a secret to store the container registry admin password 0
resource secretAdminUserPassword0 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!empty(keyVaultSecreNameAdminPassword0)) {
  name: !empty(keyVaultSecreNameAdminPassword0) ? keyVaultSecreNameAdminPassword0 : 'dummySecret'
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[0].value
}
}
// create a secret to store the container registry admin password 1
resource secretAdminUserPassword1 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!empty(keyVaultSecreNameAdminPassword1)) {
  name: !empty(keyVaultSecreNameAdminPassword1) ? keyVaultSecreNameAdminPassword1 : 'dummySecret'
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[1].value
}
}

output registryLoginServer string = containerRegistry.properties.loginServer
