param AzMigrateProjectName string = 'Customer2a'
param location string = resourceGroup().location


var ServerMigrationSolutionName = '${AzMigrateProjectName}/Servers-Migration-ServerMigration'
var ServerAssessmentSolutionName = '${AzMigrateProjectName}/Servers-Assessment-ServerAssessment'
var ServerDiscoverySolutionName = '${AzMigrateProjectName}/Servers-Discovery-ServerDiscovery'

resource AzMigrateProject 'Microsoft.Migrate/migrateProjects@2018-09-01-preview' = {
  name: AzMigrateProjectName
  location: location
  properties: {
    registeredTools: []
  }
}

resource ServerAssessmentSolution 'Microsoft.Migrate/migrateProjects/solutions@2018-09-01-preview' = {
  name: ServerAssessmentSolutionName
  properties: {
    tool: 'ServerAssessment'
    purpose: 'Assessment'
    goal: 'Servers'
    status: 'Active'
  }
  dependsOn: [
    AzMigrateProject
  ]
}

resource ServerDiscoverySolution 'Microsoft.Migrate/migrateProjects/solutions@2018-09-01-preview' = {
  name: ServerDiscoverySolutionName
  properties: {
    tool: 'ServerDiscovery'
    purpose: 'Discovery'
    goal: 'Servers'
    status: 'Inactive'
  }
  dependsOn: [
    AzMigrateProject
  ]
}

resource ServerMigrationSolution 'Microsoft.Migrate/migrateProjects/solutions@2018-09-01-preview' = {
  name: ServerMigrationSolutionName
  properties: {
    tool: 'ServerMigration'
    purpose: 'Migration'
    goal: 'Servers'
    status: 'Active'
  }
  dependsOn: [
    AzMigrateProject
  ]
}
