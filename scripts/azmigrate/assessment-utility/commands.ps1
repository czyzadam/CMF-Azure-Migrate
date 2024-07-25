#Import-Module .\AzureMigrateAssessmentCreationUtility.psm1

#Query the name of your Azure Migrate project
#Get-AzureMigrateAssessmentProject -subscriptionId $subscriptionId -resourceGroupName $resourceGroupName

# Declare variables
$subscriptionId = "0cda6999-8d6c-4882-91a5-de0db2c74586"
$resourceGroupName = "CMF-Customer-01"
$assessmentProjectName = "CMF-Customer-01-app-project"
$discoverySource = "Appliance"

New-AssessmentCreation -subscriptionId $subscriptionID -resourceGroupName $resourceGroupName -assessmentProjectName $assessmentProjectName -discoverySource "Appliance"

#New-AssessmentCreation -subscriptionId "0cda6999-8d6c-4882-91a5-de0db2c74586" -resourceGroupName "CMF-Customer-01" -assessmentProjectName "CMF-Customer-01-app-project" -discoverySource "Appliance"

#Get-AccessToken