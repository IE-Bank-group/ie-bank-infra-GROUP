param postgresSQLDatabaseName string = 'ie-bank-db'
param postgresSQLServerName string = 'ie-bank-db-server'
param location string = resourceGroup().location



module postgresSQLServer 'postgres-server.bicep' = {
  name: postgresSQLServerName
  params: {
    location: location
    postgresSQLServerName: postgresSQLServerName
  }
}


module postgresSQLDatabase 'postgres-db.bicep' = {
  name: postgresSQLDatabaseName
  params: {
    postgresSQLServerName: postgresSQLServer.outputs.postgresSQLServerName     //output of postgres-server.bicep
    postgresSQLDatabaseName: postgresSQLDatabaseName
  } 
  dependsOn: [
    postgresSQLServer
  ]

}



output postgresSQLServerName string = postgresSQLServer.outputs.postgresSQLServerName     //this is identical to output of postgres-server.bicep
