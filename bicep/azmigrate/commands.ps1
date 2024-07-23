New-AzResourceGroup -Name Bicep4 -location swedencentral
New-AzResourceGroupDeployment -TemplateFile project.bicep -ResourceGroup Bicep4
New-AzResourceGroupDeployment -TemplateFile appliance.bicep -ResourceGroup Bicep4