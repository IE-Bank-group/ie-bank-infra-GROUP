param location string = resourceGroup().location
param logicAppName string
param slackWebhookUrl string

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  properties: {
    state: 'Enabled'
    definition: json(loadTextContent('./logicAppWorkflow.json')) 
    parameters: {
      slackWebhookUrl: {
        value: slackWebhookUrl
      }
    }
  }
}
