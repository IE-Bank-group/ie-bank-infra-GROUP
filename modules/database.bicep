param postgresSQLDatabaseName string = 'ie-bank-db'
param postgresSQLServerName string = 'ie-bank-db-server'
param location string = resourceGroup().location
param postgresSQLAdminServerPrincipalName string
param postgresSQLAdminServicePrincipalObjectId string  
param logAnalyticsWorkspaceId string 
param userAlias string
param environmentType string




module postgresSQLServer 'postgres-server.bicep' = {
  name: 'postgres-server-${userAlias}-${environmentType}'
  params: {
    location: location
    postgresSQLServerName: postgresSQLServerName
    postgresSQLAdminServerPrincipalName: postgresSQLAdminServerPrincipalName
    postgresSQLAdminServicePrincipalObjectId: postgresSQLAdminServicePrincipalObjectId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}


module postgresSQLDatabase 'postgres-db.bicep' = {
  name: 'postgres-db-${userAlias}-${environmentType}'
  params: {
    postgresSQLServerName: postgresSQLServer.outputs.postgresSQLServerName     //output of postgres-server.bicep
    postgresSQLDatabaseName: postgresSQLDatabaseName
  } 
  dependsOn: [
    postgresSQLServer
  ]

}



output postgresSQLServerName string = postgresSQLServer.outputs.postgresSQLServerName     //this is identical to output of postgres-server.bicep
