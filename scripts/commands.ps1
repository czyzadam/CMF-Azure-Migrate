./AzureMigrateAutomation.ps1 -location "francecentral" -resourcegroupname "CMF-Customer2-01" -migrationprojectname "CMF-Customer2-01"


$vaultName = "CMF-Customer-01-MigrateVault-1994913701"  
$vaultRG = "CMF-Customer-01"

$vault = Get-AzRecoveryServicesVault -Name $vaultName -ResourceGroupName $vaultRG
Set-AzRecoveryServicesAsrVaultContext -Vault $vault
Get-AzRecoveryServicesAsrJob -TargetObjectId $vault