param postgresSQLServerName string
param postgresSQLDatabaseName string
param postgreSQLAdminServicePrincipalObjectId string
param postgreSQLAdminServicePrincipalName string
param logAnalyticsWorkspaceId string

param location string = resourceGroup().location
@allowed([
  'dev'
  'uat'
  'prod'
])
param environmentType string = 'dev'      //should i change this ti nonprod/prod


module postgresSQLServer './db/postgres-server.bicep' = {
  name: 'postgresSQLServer'
  params: {
    location: location
    environmentType: environmentType
    postgresSQLServerName: postgresSQLServerName
    postgresSQLAdminServerPrincipalName: postgreSQLAdminServicePrincipalName
    postgresSQLAdminServerPrincipalObjectId: postgreSQLAdminServicePrincipalObjectId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}


module postgresSQLDatabase './db/postgres-db.bicep' = {
  name: 'postgresSQLDatabase'
  params: {
    postgresSQLServerName: postgresSQLServer.outputs.postgresSQLServerName
    postgresSQLDatabaseName: postgresSQLDatabaseName
  }
  dependsOn: [
    postgresSQLServer
  ]
}


output postgresSQLServerName string = postgresSQLServer.outputs.postgresSQLServerName
