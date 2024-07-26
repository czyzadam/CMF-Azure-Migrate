Import-Module .\AzMig_Dependencies.psm1

Get-AzMigDiscoveredVMwareVMs -ResourceGroupName "CMF-Customer-01" -ProjectName "CMF-Customer-01" -OutputCsvFile "CMF-Customer-01_VMs.csv"

Set-AzMigDependencyMappingAgentless -InputCsvFile .\CMF-Customer-01_VMs.csv -Enable