#region variables

$location = "polandcentral"
$resourcegroupname = "ARM-migration-lab"
$migrationprojectname = "ARM-Lab"
$subscriptionid = "4bfade5e-64eb-4d29-ba2e-933a6612bd5c"
$tenantid = "6a74e396-c946-4654-ab7e-5f120bdac760"

$AzureMigrateApplianceName = $migrationprojectname + "-app"
$DeploymentName = "Deploy-" + $migrationprojectname
# Object ID of the service principal you want to give access to Azure Keyvault
$Objectid = "1477a0aa-6af3-48d9-8ec4-2716eca4f85b"

#endregion

#region Step 1 : ARM Deployment => Azure Migrate Project and Solutions

$armtemplate = Join-Path "." -ChildPath "arm" -AdditionalChildPath "azmigrate", "MigrationProject", "azuredeploy.json" | Get-Item
$armtemplateparameter = Join-Path "." -ChildPath "arm" -AdditionalChildPath "azmigrate", "MigrationProject", "azuredeploy.parameters.json" | Get-Item

$armparamobject = Get-Content $armtemplateparameter.FullName | ConvertFrom-Json -AsHashtable
$armparamobject.parameters.AzMigrateProjectName.value = $migrationprojectname
$armparamobject.parameters.Location.value = $location
$parameterobject = @{ }
$armparamobject.parameters.keys | ForEach-Object { $parameterobject[$_] = $armparamobject.parameters[$_]['value'] }

$Deploy_ResourceGroup = New-AzResourceGroup  -Name $resourcegroupname -Location $location

$Deploy_AzureMigrateMigration = New-AzResourceGroupDeployment -ResourceGroupName $resourcegroupname -Name "$($DeploymentName)" -TemplateFile $armtemplate.FullName -TemplateParameterObject $parameterobject

#region Step 2 : ARM Deployment => Migration Appliance

$ResourceID = Get-AzResource -Name $migrationprojectname

$armtemplate = Join-Path "." -ChildPath "arm" -AdditionalChildPath "azmigrate", "MigrationAppliance", "azuredeploy.json" | Get-Item
$armtemplateparameter = Join-Path "." -ChildPath "arm" -AdditionalChildPath "azmigrate", "MigrationAppliance", "azuredeploy.parameters.json" | Get-Item

$armparamobject = Get-Content $armtemplateparameter.FullName | ConvertFrom-Json -AsHashtable
$armparamobject.parameters.AzMigrateProjectName.value = $migrationprojectname
$armparamobject.parameters.AzMigrateProjectResourceID.value = $ResourceID.ResourceId
$armparamobject.parameters.AzMigrateProjectApplianceName.value = $AzureMigrateApplianceName
$armparamobject.parameters.location.value = $location
$armparamobject.parameters.TenantID.value = $tenantid
$armparamobject.parameters.AccessPolicyObjectID.value = $Objectid

$parameterobject = @{ }
$armparamobject.parameters.keys | ForEach-Object { $parameterobject[$_] = $armparamobject.parameters[$_]['value'] }

$Deploy_AzureMigrate = New-AzResourceGroupDeployment -ResourceGroupName $resourcegroupname -Name "$($DeploymentName)-appliance" -TemplateFile $armtemplate.FullName -TemplateParameterObject $parameterobject
#endregion
#region Step 3 : Connect Migration Appliance with Migration Project
 
$AssessmentProjectResourceID = Get-AzResource -Name "$($AzureMigrateApplianceName)-project"
$RsvResourceID = Get-AzResource -Name "$($AzureMigrateApplianceName)-rsv"
$SiteID = Get-AzResource -Name "$($AzureMigrateApplianceName)-site"
$MasterSiteID = Get-AzResource -Name "$($AzureMigrateApplianceName)-mastersite"
$KeyVaultID = Get-AzResource -Name "$($migrationprojectname)-kv"
$objectid = "1477a0aa-6af3-48d9-8ec4-2716eca4f85b"
$ResourceID = Get-AzResource -Name $migrationprojectname
$SQLSiteName = "$($migrationprojectname)-mastersite/$($migrationprojectname)-sqlsites"
 
$armtemplate = Join-Path "." -ChildPath "arm" -AdditionalChildPath "azmigrate", "MigrationConnect", "azuredeploy.json" | Get-Item
$armtemplateparameter = Join-Path "." -ChildPath "arm" -AdditionalChildPath "azmigrate", "MigrationConnect", "azuredeploy.parameters.json" | Get-Item
 
$armparamobject = Get-Content $armtemplateparameter.FullName | ConvertFrom-Json -AsHashtable
$armparamobject.parameters.AzMigrateProjectName.value = $migrationprojectname
$armparamobject.parameters.Location.value = $location
$armparamobject.parameters.AzMigrateApplianceName.value = $AzureMigrateApplianceName
$armparamobject.parameters.KeyVaultName.value = $KeyVaultID.Name
$armparamobject.parameters.RecoveryVaultName.value = $RsvResourceID.Name
$armparamobject.parameters.Keyvault_ResourceID.value = $KeyVaultID.ResourceId
$armparamobject.parameters.SQLSiteName.value = $SQLSiteName
$armparamobject.parameters.MigrateProjects_ResourceID.value = $ResourceID.ResourceId
$armparamobject.parameters.HyperVSite_MigrateProjects_ResourceID.value =$SiteID.ResourceId
$armparamobject.parameters.assessmentprojects_MigrateProjects_ResourceID.value = $AssessmentProjectResourceID.ResourceId
$armparamobject.parameters.MasterSites_MigrateProjects_ResourceID.value = $MasterSiteID.ResourceId
$armparamobject.parameters.Recoveryvaults_ResourceID.value = $RsvResourceID.ResourceId
 
$parameterobject = @{ }
$armparamobject.parameters.keys | ForEach-Object { $parameterobject[$_] = $armparamobject.parameters[$_]['value'] }
 
$Deploy_AzureMigrate = New-AzResourceGroupDeployment -ResourceGroupName $resourcegroupname -Name "$($DeploymentName)-applianceconnect" -TemplateFile $armtemplate.FullName -TemplateParameterObject $parameterobject
 
#endregion