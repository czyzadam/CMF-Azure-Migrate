#Azure Project and resources 
Select-AzSubscription  -SubscriptionId '0cda6999-8d6c-4882-91a5-de0db2c74586'
./AzureMigrateAutomation.ps1 -location "francecentral" -resourcegroupname "Customer1-02" -migrationprojectname "Customer1-02"

#Assesment and group for all dicovered machines
#scripts\azmigrate\assessment-utility\

#Assesment and group for all dicovered machines
#scripts\azmigrate\dependencies-at-scale