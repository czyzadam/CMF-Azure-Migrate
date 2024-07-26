# Azure Migrate Automation

This repository contains PowerShell scripts and utilities for automating various tasks related to Azure migration using Azure Resource Manager (ARM) templates.

## Scripts

### AzureMigrateAutomation.ps1
- Description: This script is used to create Azure migrate resources using ARM templates.

### MigrationReport.ps1
- Description: This script exports Azure Migrate replication reports to a storage account.

## Utilities

### azmigrate\assessment-utility
- Description: Utility to create bulk assessments for all discovered servers.

### azmigrate\dependencies-at-scale
- Description: Utility to turn on dependency mapping for all discovered servers.

### azmigrate\migrate-at-scale-with-site-recovery
- Description: Utility to replicate and migrate servers from a CSV file. Please note that it does not work with Hyper-V due to unrecognized processor server.

## Usage
- Each script and utility contains its own usage instructions and prerequisites. Please refer to the individual script or utility for detailed information on how to use them.

## Contributions
- Contributions and improvements are welcome. If you find any issues or have suggestions for enhancements, feel free to open an issue or submit a pull request.

## License
