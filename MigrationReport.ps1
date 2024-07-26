$vaultName = "CMF-Customer-01-MigrateVault-1994913701"  
$vaultRG = "CMF-Customer-01"
$sas_token="https://cmfmigratereporting.blob.core.windows.net/reports?sp=racwdl&st=2024-07-26T06:17:29Z&se=2024-07-30T14:17:29Z&spr=https&sv=2022-11-02&sr=c&sig=qwrI1tP%2B8phnOFYalLCAROsJdZ7JU5DDnCpLyku4l%2F8%3D”
$account_name = "cmfmigratereporting"
$context = New-AzStorageContext -StorageAccountName $account_name 
$containerName = "reports"
$report = "MigrationReport.html"
$file =  'C:\4.Projects\GitHub\CMF_AzureMigrate_ARM\reports\MigrationReport.html'
$file2 =  'C:\4.Projects\GitHub\CMF_AzureMigrate_ARM\reports\MigrationReport.csv'

Select-AzSubscription  -SubscriptionId '0cda6999-8d6c-4882-91a5-de0db2c74586'
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
$htmlContent | Set-Content -Path $file  -Encoding UTF8

azcopy copy $file $sas_token --recursive
azcopy copy $file2 $sas_token --recursive

#https://cmfmigratereporting.blob.core.windows.net/reports/MigrationReport.html
#https://cmfmigratereporting.blob.core.windows.net/reports/MigrationReport.csv