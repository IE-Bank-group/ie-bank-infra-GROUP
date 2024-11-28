param appServicePlanName string
param location string = resourceGroup().location
// @allowed([
//   'dev'
//   'uat'
//   'prod'
// ])
// param environmentType string

// var environmentConfig = {
//   dev: {
//     sku: 'F1'
//     capacity: 1
//   }
//   uat: {
//     sku: 'F1'
//     capacity: 1
//   }
//   prod: {
//     sku: 'B1'
//     capacity: 2
//   }
// }
// var skuName = environmentConfig[environmentType].sku
// var capacity = environmentConfig[environmentType].capacity

@allowed([
  'B1'
  'F1'
])
param skuName string

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
  }
  kind: 'linux'
  properties: {
    reserved: true     // for a linux-based AS
  }
}

output planId string = appServicePlan.id
