param appServicePlanName string 
param appServicePlanSkuName string = (environmentType == 'prod') ? 'B1' : 'B1'
param location string = resourceGroup().location
@allowed([
  'nonprod'
  'prod' 
])
param environmentType string 


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
