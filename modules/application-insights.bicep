param appInsightsName string
param location string
param logAnalyticsWorkspaceId string
param keyVaultResourceId string 
// @allowed([
//   'web'
//   'other'
// ])

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}



resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = if (!empty(keyVaultResourceId)) {
  name: last(split(keyVaultResourceId, '/')) 
}

// create a secret to store the container registry admin username
resource instrumentationKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'instrumentationKey' 
  parent: adminCredentialsKeyVault
  properties: {
    value: appInsights.properties.InstrumentationKey
  }
}

// create a secret to store the container registry admin password 0
resource connectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' =  {
  name: 'connectionString'
  parent: adminCredentialsKeyVault
  properties: {
    value: appInsights.properties.ConnectionString
  }
}




// output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
// output appInsightsConnectionString string = appInsights.properties.ConnectionString
