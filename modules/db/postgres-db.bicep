param postgresSQLDatabaseName string  = 'ie-bank-db'
param postgresSQLServerName string

resource existPostgresSQLServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' existing = {
  name: postgresSQLServerName
}

resource postgresSQLDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = {
  name: postgresSQLDatabaseName
  parent: existPostgresSQLServer
  properties: {
    charset: 'UTF8'
    collation: 'en_US.UTF8'
  }
}


output postgresSQLDatabaseName string = postgresSQLDatabase.name
