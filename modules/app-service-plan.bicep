param appServicePlanName string 
@allowed([
  'B1'
  'F1'
])
param appServicePlanSkuName string 
param location string = resourceGroup().location



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


output planId string = appServicePlan.id
