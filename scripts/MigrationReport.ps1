$vaultName = "CMF-Customer-01-MigrateVault-1994913701"  
$vaultRG = "CMF-Customer-01"
$sas_token="https://cmfmigratereporting.blob.core.windows.net/reports?sp=racwdl&st=2024-07-25T13:47:30Z&se=2024-07-25T21:47:30Z&spr=https&sv=2022-11-02&sr=c&sig=akvSnPacq8X3tqksrd99b4UlCKdy%2BI1ajPMGZH8bIik%3D”
$account_name = "cmfmigratereporting"
$context = New-AzStorageContext -StorageAccountName $account_name 
$containerName = "reports"
$report = "MigrationReport.html"
$file =  'C:\4.Projects\GitHub\CMF_AzureMigrate_ARM\MigrationReport.html'
$file2 =  'C:\4.Projects\GitHub\CMF_AzureMigrate_ARM\MigrationReport.csv'


$vault = Get-AzRecoveryServicesVault -Name $vaultName -ResourceGroupName $vaultRG
Set-AzRecoveryServicesAsrVaultContext -Vault $vault
$jobs = Get-AzRecoveryServicesAsrJob | Select TargetObjectName, DisplayName, State, StateDescription, StartTime, EndTime, TargetObjectType | Where-Object { $_.TargetObjectType -like "ProtectionEntity" }
$jobs |  Export-Csv -Path $file2 -NoTypeInformation
# Generate HTML table with colored rows based on the "State" column
$htmlTable = "<table><tr><th>Target Object Name</th><th>Display Name</th><th>State</th><th>State Description</th><th>Start Time</th><th>End Time</th></tr>"
foreach ($job in $jobs) {
    $rowColor = "white"  # Default color
    switch ($job.State) {
        "Succeeded" { $rowColor = "lightgreen" }
        "Failed" { $rowColor = "lightcoral" }
        "Running" { $rowColor = "lightyellow" }
    }
    $htmlTable += "<tr style='background-color:$rowColor'><td>$($job.TargetObjectName)</td><td>$($job.DisplayName)</td><td>$($job.State)</td><td>$($job.StateDescription)</td><td>$($job.StartTime)</td><td>$($job.EndTime)</td></tr>"
}
$htmlTable += "</table>"

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
    <a href="https://cmfmigratereporting.blob.core.windows.net/reports/MigrationReport.csv" download>Download Migration Report csv</a>
    $htmlTable
</body>
</html>
"@

# Save the HTML content to a file
$htmlContent | Set-Content -Path "MigrationReport.html" -Encoding UTF8

azcopy copy $file $sas_token --recursive
azcopy copy $file2 $sas_token --recursive

#https://cmfmigratereporting.blob.core.windows.net/reports/MigrationReport.html
#https://cmfmigratereporting.blob.core.windows.net/reports/MigrationReport.csv