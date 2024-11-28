@allowed([
  'dev'
  'uat'
  'prod'
])
param environmentType string
param location string = resourceGroup().location
param postgresSQLServerName string = 'ie-bank-db-server-dev'
param postgresSQLAdminServerPrincipalName string
param postgresSQLAdminServerPrincipalObjectId string
param logAnalyticsWorkspaceId string 

var skuName = environmentType == 'prod' ? 'Standard_B1ms' : (environmentType == 'uat' ? 'Standard_B1ms' : 'Standard_B1ms')
var backupRetentionDays = environmentType == 'prod' ? 7 : (environmentType == 'uat' ? 3 : 3)


resource postgresSQLServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: postgresSQLServerName
  location: location
  sku: {
    name: skuName
    tier: 'Burstable'
    }
  properties: {
    administratorLogin: 'iebankdbadmin'
    administratorLoginPassword: 'IE.Bank.DB.Admin.Pa$$'    //appServiceAPIEnvVarDBPASS  
    version: '15'
    createMode: 'Default'
    authConfig: {activeDirectoryAuth: 'Enabled', passwordAuth: 'Enabled', tenantId: subscription().tenantId }
    storage: {
      storageSizeGB: 32
    }
    backup: {
      backupRetentionDays: backupRetentionDays
      // geoRedundantBackup: environmentType == 'prod' ? 'Enabled' : 'Disabled'
      geoRedundantBackup: 'Disabled'
    }
    highAvailability:{
      mode: 'Disabled'
      standbyAvailabilityZone: ''
    }
  }


  resource serverFirewallRules 'firewallRules@2022-12-01' = {
  name: 'AllowAllAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}


  resource postgresSQLAdmins 'administrators@2022-12-01' = {
    name: postgresSQLAdminServerPrincipalObjectId
    properties: {
      principalName: postgresSQLAdminServerPrincipalName
      principalType: 'ServicePrincipal'
      tenantId: subscription().tenantId
    }
    dependsOn: [
      serverFirewallRules
    ]
  }
}



resource postgresSQLDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'PostGresSQLServerDiagnostics'
  scope: postgresSQLServer
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'PostgreSQLLogs'
        enabled: true
      }
      {
        category: 'PostgreSQLFlexSessions'
        enabled: true
      }
      {
        category: 'PostgreSQLFlexQueryStoreRuntime'
        enabled: true
      }
      {
        category: 'PostgreSQLFlexTableStats'
        enabled: true
      }
      {
        category: 'PostgreSQLFlexQueryStoreWaitStats'
        enabled: true
      }
      {
        category: 'PostgreSQLFlexDatabaseXacts'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}


output postgresSQLServerName string = postgresSQLServer.name
output resourceOutput object = postgresSQLServer
