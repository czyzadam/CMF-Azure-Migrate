
$vaultName = "CMF-Customer-01-MigrateVault-1994913701"  
$vaultRG = "CMF-Customer-01"

$vault = Get-AzRecoveryServicesVault -Name $vaultName -ResourceGroupName $vaultRG
Set-AzRecoveryServicesAsrVaultContext -Vault $vault
Get-AzRecoveryServicesAsrJob -TargetObjectId $vaultName

$Job = Get-AzRecoveryServicesAsrJob | Select TargetObjectName, DisplayName, State, StateDescription,StartTime,EndTime,TargetObjectType | Where-Object {$_.TargetObjectType -like "ProtectionEntity"}

$htmlTable = $Job |  ConvertTo-Html -Fragment

# HTML content to create a basic webpage with the table
$htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Azure Migrate Replication</title>
    <style>
        table {
            border-collapse: collapse;
            width: 100%;
        }
        th, td {
            border: 1px solid black;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <h1>Azure Migrate Replication</h1>
    $htmlTable
</body>
</html>
"@

# Save the HTML content to a file
$htmlContent | Set-Content -Path "MigrationReport.html" -Encoding UTF8

$sas_token="https://cmfmigratereporting.blob.core.windows.net/reports?sp=racwdl&st=2024-07-25T13:47:30Z&se=2024-07-25T21:47:30Z&spr=https&sv=2022-11-02&sr=c&sig=akvSnPacq8X3tqksrd99b4UlCKdy%2BI1ajPMGZH8bIik%3D”
$account_name = "cmfmigratereporting"
$context = New-AzStorageContext -StorageAccountName $account_name 
$containerName = "reports"
$report = "MigrationReport.html"
$file =  'C:\4.Projects\GitHub\CMF_AzureMigrate_ARM\MigrationReport.html'

azcopy copy $file $sas_token --recursive

#https://azuremigratereporting.blob.core.windows.net/migratereports/MigrationReport.html