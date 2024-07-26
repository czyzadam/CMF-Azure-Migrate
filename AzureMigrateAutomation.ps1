
#######################################################################################################################################
#get-AzContext -ListAvailable | Remove-AzContext
#connect-AzAccount

#region variables
param (
    [string]$location,
    [string]$resourcegroupname,
    [string]$migrationprojectname
)


#$location = "francecentral"
#$resourcegroupname = "Customera5-01"
#$migrationprojectname = "Customera5-01"

#CMF
#$subscriptionid = "9d09cff7-2d88-4196-a17c-a0881d1b4f64" #cmf-azure-dev
$subscriptionid = "0cda6999-8d6c-4882-91a5-de0db2c74586" #cmf-azure-dev2
$tenantid = "6a90c62c-5f34-42e8-9b92-9cf3594106fd"
#$tenantid = "b7dd1ca6-8890-4eec-b441-890719cd4915"

#ATM
#$subscriptionid = "4bfade5e-64eb-4d29-ba2e-933a6612bd5c"
#$tenantid = "6a74e396-c946-4654-ab7eget-5f120bdac760"

$AzureMigrateApplianceName = $migrationprojectname + "-app"
$DeploymentName = "Deploy-" + $migrationprojectname

# Object ID of the service principal you want to give access to Azure Keyvault
#$Objectid = "330e881b-46cb-40b4-a713-8c6056e23e4e" # CMF
$Objectid = "1477a0aa-6af3-48d9-8ec4-2716eca4f85b" # ATM

function Remove-SpecialCharacters {
    param(
        [string]$inputString
    )
    $cleanString = $inputString -replace '[^\w\s]',''
    return $cleanString
}

#######################################################################################################################################
#Step 1 : ARM Deployment => Azure Migrate Project and Solutions

$armtemplate = Join-Path "." -ChildPath "arm" -AdditionalChildPath "azmigrate", "MigrationProject", "azuredeploy.json" | Get-Item
$armtemplateparameter = Join-Path "." -ChildPath "arm" -AdditionalChildPath "azmigrate", "MigrationProject", "azuredeploy.parameters.json" | Get-Item

$armparamobject = Get-Content $armtemplateparameter.FullName | ConvertFrom-Json -AsHashtable
$armparamobject.parameters.AzMigrateProjectName.value = $migrationprojectname
$armparamobject.parameters.Location.value = $location

$parameterobject = @{ }
$armparamobject.parameters.keys | ForEach-Object { $parameterobject[$_] = $armparamobject.parameters[$_]['value'] }

#$SetTenant = Set-AzContext -Tenant $tenantid
#$SetSubscription = Set-AzContext -Subscription $subscriptionid
#set-AzContext -Subscription $subscriptionid
New-AzResourceGroup  -Name $resourcegroupname -Location $location

#$Deploy_AzureMigrateMigration = 
New-AzResourceGroupDeployment -ResourceGroupName $resourcegroupname -Name "$($DeploymentName)" -TemplateFile $armtemplate.FullName -TemplateParameterObject $parameterobject

#######################################################################################################################################
#Step 2 : ARM Deployment => Migration Appliance

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
$armparamobject.parameters.StorageAccountName.value = (Remove-SpecialCharacters -inputString $migrationprojectname).ToLower()

$parameterobject = @{ }
$armparamobject.parameters.keys | ForEach-Object { $parameterobject[$_] = $armparamobject.parameters[$_]['value'] }

#$Deploy_AzureMigrate = 
New-AzResourceGroupDeployment -ResourceGroupName $resourcegroupname -Name "$($DeploymentName)-appliance" -TemplateFile $armtemplate.FullName -TemplateParameterObject $parameterobject

#######################################################################################################################################
#Step 3 : Connect Migration Appliance with Migration Project
 
$AssessmentProjectResourceID = Get-AzResource -Name "$($AzureMigrateApplianceName)-project"
$RsvResourceID = Get-AzResource -Name "$($migrationprojectname)-rsv"
$SiteID = Get-AzResource -Name "$($AzureMigrateApplianceName)-site"
$MasterSiteID = Get-AzResource -Name "$($migrationprojectname)-mastersite"
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
 
#$Deploy_AzureMigrate = 
New-AzResourceGroupDeployment -ResourceGroupName $resourcegroupname -Name "$($DeploymentName)-applianceconnect" -TemplateFile $armtemplate.FullName -TemplateParameterObject $parameterobject
 
Write-Host $objectid 