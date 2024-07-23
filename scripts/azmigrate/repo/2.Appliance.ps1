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

$parameterobject = @{ }
$armparamobject.parameters.keys | ForEach-Object { $parameterobject[$_] = $armparamobject.parameters[$_]['value'] }

#$Deploy_AzureMigrate = 
New-AzResourceGroupDeployment -ResourceGroupName $resourcegroupname -Name "$($DeploymentName)-appliance" -TemplateFile $armtemplate.FullName -TemplateParameterObject $parameterobject

