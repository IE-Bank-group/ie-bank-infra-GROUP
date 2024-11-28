param workspaceName string
param location string = resourceGroup().location

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {   //-08-01   ?
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018' 
    }
    retentionInDays: 30 
  }
}

output workspaceId string = logAnalyticsWorkspace.id
// output workspaceKey string = listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name
