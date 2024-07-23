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
