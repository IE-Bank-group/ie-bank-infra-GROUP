param appServicePlanName string 
param appServicePlanSkuName string = (environmentType == 'prod') ? 'B1' : 'B1'
param location string = resourceGroup().location
@allowed([
  'nonprod'
  'prod' 
])
param environmentType string 
param appServiceAppName string
param appServiceAPIAppName string 

param appServiceAPIDBHostDBUSER string 
param appServiceAPIDBHostFLASK_APP string 
param appServiceAPIDBHostFLASK_DEBUG string 
param appServiceAPIEnvVarDBHOST string 
param appServiceAPIEnvVarDBNAME string 
param appServiceAPIEnvVarDBPASS string
param appServiceAPIEnvVarENV string


module appServicePlan './app-service-plan.bicep' = {
  name: appServicePlanName
  params: {
    appServicePlanName: appServicePlanName
    location: location
    appServicePlanSkuName: appServicePlanSkuName
    environmentType: environmentType
  }
}


//FRONTEND
module appServiceApp './fe-app-service.bicep' = {
  name: appServiceAppName
  params: {
    appServiceAppName: appServiceAppName
    location: location
    appServicePlanId: appServicePlan.outputs.planId
  }

}


//BACKEND
module appServiceAPIApp './be-app-service.bicep'= {
  name: appServiceAPIAppName
  params: {
    appServiceAPIAppName: appServiceAPIAppName
    location: location
    appServicePlanId: appServicePlan.outputs.planId
    appSettings: [
      {
        name: 'ENV'
        value: appServiceAPIEnvVarENV
      }
      {
        name: 'DBNAME'
        value: appServiceAPIEnvVarDBNAME
      }
      {
        name: 'DBHOST'
        value: appServiceAPIEnvVarDBHOST
      }
      {
        name: 'DBUSER'
        value: appServiceAPIDBHostDBUSER
      }
      {
        name: 'DBPASS'
        value: appServiceAPIEnvVarDBPASS
      }
      {
        name: 'FLASK_APP'
        value: appServiceAPIDBHostFLASK_APP
      }
      {
        name: 'FLASK_DEBUG'
        value: appServiceAPIDBHostFLASK_DEBUG
      }
      {
        name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
        value: 'true'
      }
    ]
  }
}


// need static web app url, endpoints, resource name 
output appServiceAppHostName string = appServiceApp.outputs.appServiceAppHostName
// output appServiceAppEndpoint string = appServiceApp.outputs.appServiceAppHostName
