param appInsightsName string
param location string
param logAnalyticsWorkspaceId string
param keyVaultResourceId string 
param environmentType string
param slackUrl string  


resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}


resource logicAppActionGroup 'Microsoft.Insights/actionGroups@2022-06-01' = {
  name: 'slack-notifications'
  location: 'global'
  properties: {
    groupShortName: 'SlackAlert'
    enabled: true
    webhookReceivers: [
      {
        name: 'slackWebhook'
        serviceUri: slackUrl
        useCommonAlertSchema: true
      }
    ]
  }
}




resource pageLoadTimeAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'page-load-alert'
  location: 'global'
  properties: {
    description: 'Alert if page load time > 5 sec.'
    severity: 4
    enabled: true
    scopes: [
      appInsights.id
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'pageLoadTime'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'browserTimings/totalDuration'
          operator: 'GreaterThan'
          threshold: 5000
          timeAggregation: 'Average'
        }
      ]
    }
    autoMitigate: true
    actions: [
      {
        actionGroupId: logicAppActionGroup.id
        webHookProperties: {
          customMessage: 'Page load time > 5 seconds. Check issue immediately.'
        }
      }
    ]
  }
}




resource loginSLOAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'login-slo-alert'
  location: 'global'
  properties: {
    description: 'Alert if login response time > 5 sec.'
    severity: 2
    enabled: true
    scopes: [
      appInsights.id
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'LoginResponseTime'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'requests/duration'
          operator: 'GreaterThan'
          threshold: 5000
          timeAggregation: 'Average'
        }
      ]
    }
    autoMitigate: true
    actions: [
      {
        actionGroupId: logicAppActionGroup.id
        webHookProperties: {
          customMessage: 'Login response time > 5 sec. Immediate attention required.'
        }
      }
    ]
  }
}






resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = if (!empty(keyVaultResourceId)) {
  name: last(split(keyVaultResourceId, '/')) 
}

resource instrumentationKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'instrumentationKey' 
  parent: adminCredentialsKeyVault
  properties: {
    value: appInsights.properties.InstrumentationKey
  }
}

resource connectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' =  {
  name: 'connectionString'
  parent: adminCredentialsKeyVault
  properties: {
    value: appInsights.properties.ConnectionString
  }
}


module workbook 'workbook.bicep' = {
  name: 'workbook-${environmentType}'
  params: {
    location: location
    appInsightsResourceId: appInsights.id 
  }
}







// output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
// output appInsightsConnectionString string = appInsights.properties.ConnectionString
