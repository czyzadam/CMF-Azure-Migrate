param project string = 'Customer2a'
param location string = resourceGroup().location

param AccessPolicyObjectID string = '1477a0aa-6af3-48d9-8ec4-2716eca4f85b'

var ApplianceName = '${project}-app'
var keyvaultn = '${project}-kv'
var keyvauluri = 'https://${keyvaultn}.vault.azure.net'
var sqlsiten = '${ApplianceName}-mastersite/${project}-sqlsites'

var ServerMigrationSolutionName = '${project}/Servers-Migration-ServerMigration'
var ServerAssessmentSolutionName = '${project}/Servers-Assessment-ServerAssessment'
var ServerDiscoverySolutionName = '${project}/Servers-Discovery-ServerDiscovery'

resource AzMigrateProject 'Microsoft.Migrate/migrateProjects@2023-01-01' existing = {
  name: project
}

resource keyv 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyvaultn
  location: location
  tags: {
    'Migrate Project': project
  }
   properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enabledForDeployment: true
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    publicNetworkAccess: 'Enabled'
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: AccessPolicyObjectID
        permissions: {
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
          certificates: [
            'all'
          ]
          storage: [
            'all'
          ]
        }
      }
    ]
  }
  dependsOn: []
}

resource AzMigrateProjectApplianceName_site 'Microsoft.OffAzure/hypervSites@2023-06-06' = {
  name: ApplianceName
  location: location
  tags: {
    'Migrate Project': project
  }
  properties: {
    agentDetails: {
      keyVaultId: keyv.id
      keyVaultUri: keyvauluri
    }
    applianceName: ApplianceName
    discoverySolutionId: '${AzMigrateProject.id}/Servers-Discovery-ServerDiscovery'

   }
}

resource AzMigrateProjectApplianceName_project 'Microsoft.Migrate/assessmentProjects@2023-04-01-preview' = {
  name: '${ApplianceName}-project'
  location: location
  tags: {
    'Migrate Project': project
  }
  
  properties: {
    projectStatus: 'Active'
    publicNetworkAccess: 'Enabled'
    assessmentSolutionId: '${AzMigrateProject.id}/Solutions/Servers-Assessment-ServerAssessment'
  }
  dependsOn: []
}

resource AzMigrateProjectApplianceName_mastersite 'Microsoft.OffAzure/masterSites@2020-07-07' = {
  name: '${ApplianceName}-mastersite'
  location: location
  properties: {
    sites: [
      AzMigrateProjectApplianceName_site.id
    ]
    allowMultipleSites: true
    publicNetworkAccess: 'Enabled'
  }
}

resource sqlsitename 'Microsoft.OffAzure/masterSites/sqlSites@2023-06-06' = {
  name: sqlsiten
  properties: {
     siteAppliancePropertiesCollection: [
      {
        agentDetails: {
          keyVaultId: keyv.id
          keyVaultUri: keyvauluri
        }
        applianceName: ApplianceName
      }
    ]
  }
  dependsOn: [
    AzMigrateProjectApplianceName_mastersite
  ]
}
resource AzMigrateProjectApplianceName_rsv 'Microsoft.RecoveryServices/vaults@2024-04-30-preview' = {
  name: '${ApplianceName}-rsv'
  location: location
  tags: {
    'Migrate Project': project
  }
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {
  publicNetworkAccess: 'Enabled'
  }
  dependsOn: []
}

resource ServerAssessmentSolution 'Microsoft.Migrate/MigrateProjects/Solutions@2018-09-01-preview' = {
  name: ServerAssessmentSolutionName
  properties: {
    tool: 'ServerAssessment'
    purpose: 'Assessment'
    goal: 'Servers'
    status: 'Active'
    details: {
      groupCount: 0
      assessmentCount: 0
      extendedDetails: {
        projectId: AzMigrateProject.id
      }
    }
  }
}
  resource ServerDiscoverySolution 'Microsoft.Migrate/MigrateProjects/Solutions@2018-09-01-preview' = {
    name: ServerDiscoverySolutionName
    properties: {
      tool: 'ServerDiscovery'
      purpose: 'Discovery'
      goal: 'Servers'
      status: 'Inactive'
      details: {
        groupCount: 0
        assessmentCount: 0
        extendedDetails: {
          
          masterSiteId: AzMigrateProjectApplianceName_mastersite.id
          supportedScenarioSites: '{"SqlSites":"${AzMigrateProjectApplianceName_mastersite.id}/SqlSites/${sqlsiten}"}'
          keyVaultId: keyv.id
          keyVaultUrl: 'https://${keyvaultn}.vault.azure.net'
          applianceNameToSiteIdMapV3: '[{"${ApplianceName}":{"ApplianceName":"${ApplianceName}","SiteId":"${AzMigrateProjectApplianceName_site.id}","AppDetails":{"TenantID":"","AppName":"","AppID":"","ObjectID":""},"KeyVaultId":"${keyv.id}","KeyVaultUrl":"https://${keyvaultn}.vault.azure.net","CertificateContents":{"${keyv.name}agentauthcert":""}}}]'
        }
      }
    }
  }

