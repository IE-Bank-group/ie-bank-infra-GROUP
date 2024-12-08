param appServicePlanName string 
@allowed([
  'B1'
  'F1'
])
param appServicePlanSkuName string 
param location string = resourceGroup().location
param logAnalyticsWorkSpaceId string 



resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
  }
  kind: 'linux'
  properties: {
    reserved: true     // for a linux-based AS
  }
}


resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: appServicePlan.name
  scope: appServicePlan
  properties: {
  workspaceId: logAnalyticsWorkSpaceId
  logs: [
  {
  category: 'AllMetrics'
  enabled: true
  retentionPolicy: {
  days: 30
  enabled: true
  }
  }
  ]
  }
  }



output planId string = appServicePlan.id
