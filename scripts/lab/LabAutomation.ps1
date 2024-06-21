# variables

$location = "francecentral"
$resourcegroupname = "CMF-MigrationDemo"
$LabVnetName = "CMF-MigrationVnet"
$addressPrefixes = "192.168.0.0/16"
$SubnetName = "HypervLab"
$SubnetPrefix = "192.168.0.0/24"

#CMF
#$subscriptionid = "9d09cff7-2d88-4196-a17c-a0881d1b4f64" #cmf-azure-dev
$subscriptionid = "0cda6999-8d6c-4882-91a5-de0db2c74586" #cmf-azure-dev2
$tenantid = "b7dd1ca6-8890-4eec-b441-890719cd4915"

#ATM
#$subscriptionid = "4bfade5e-64eb-4d29-ba2e-933a6612bd5c"
#$tenantid = "6a74e396-c946-4654-ab7e-5f120bdac760"

#Step 1 : VNET deployment

$armtemplate = Join-Path "." -ChildPath "arm" -AdditionalChildPath "lab", "vnet", "vnet.json" | Get-Item
$armtemplateparameter = Join-Path "." -ChildPath "arm" -AdditionalChildPath "lab", "vnet", "vnet.parameters.json" | Get-Item

$armparamobject = Get-Content $armtemplateparameter.FullName | ConvertFrom-Json -AsHashtable
$armparamobject.parameters.Location.value = $location
$armparamobject.parameters.LabVnetName.value = $LabVnetName
$armparamobject.parameters.addressPrefixes.value = $addressPrefixes
$armparamobject.parameters.SubnetPrefix.value = $SubnetPrefix
$armparamobject.parameters.SubnetName.value = $SubnetName

$parameterobject = @{ }
$armparamobject.parameters.keys | ForEach-Object { $parameterobject[$_] = $armparamobject.parameters[$_]['value'] }

$SetTenant = Set-AzContext -Tenant $tenantid
$SetSubscription = Set-AzContext -Subscription $subscriptionid

#$Deploy_ResourceGroup = New-AzResourceGroup  -Name $resourcegroupname -Location $location
#az account set --subscription $subscriptionid
#$SetSubscription = Set-AzContext -Subscription  "$subscriptionid"
$Deploy_AzureMigrateMigration = New-AzResourceGroupDeployment -ResourceGroupName $resourcegroupname -Name "$($LabVnetName)" -TemplateFile $armtemplate.FullName -TemplateParameterObject $parameterobject
