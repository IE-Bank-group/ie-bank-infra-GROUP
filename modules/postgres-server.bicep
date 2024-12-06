param location string = resourceGroup().location
param postgresSQLServerName string = 'ie-bank-db-server'
// param logAnalyticsWorkspaceId string 
param postgresSQLAdminServerPrincipalName string
param postgresSQLAdminServicePrincipalObjectId string  


resource postgresSQLServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: postgresSQLServerName
  location: location
  sku: {
    name: 'Standard_B1ms'
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
      backupRetentionDays: 7
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


  resource postgresSQLAdministrators 'administrators@2022-12-01' = {
    name: postgresSQLAdminServicePrincipalObjectId
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






//NEEDS ADMINS, DIAGNOSTICS


output postgresSQLServerName string = postgresSQLServer.name
output resourceOutput object = postgresSQLServer
