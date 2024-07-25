#Load SharePoint CSOM Assemblies
#Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
#Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
  
#Variables for Processing
$WebUrl = "https://atos365.sharepoint.com/:f:/r/sites/AtosNewOfferings/Shared%20Documents/Microsoft/Membership%20-%20Advanced%20Specialization%20and%20Solution%20Partners%20+%20Azure%20MSP/Advanced%20Specializations%20-%20checklists%20and%20documentations/Azure/Infra%20and%20Database%20Migration%20to%20Azure/Checklist%20and%20Evidence%20collection?csf=1&web=1&e=fALrgX"
$LibraryName ="Digital Business Platforms"
$SourceFile='C:\4.Projects\GitHub\CMF_AzureMigrate_ARM\MigrationReport.html'
$AdminName ="adam.czyz@atos.net"
#$AdminPassword ="password goes here"
  
#Setup Credentials to connect
$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($AdminName,(ConvertTo-SecureString $AdminPassword -AsPlainText -Force))
  
#Set up the context
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($WebUrl)
$Context.Credentials = $Credentials
 
#Get the Library
$Library =  $Context.Web.Lists.GetByTitle($LibraryName)
 
#Get the file from disk
$FileStream = ([System.IO.FileInfo] (Get-Item $SourceFile)).OpenRead()
#Get File Name from source file path
$SourceFileName = Split-path $SourceFile -leaf
   
#sharepoint online upload file powershell
$FileCreationInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation
$FileCreationInfo.Overwrite = $true
$FileCreationInfo.ContentStream = $FileStream
$FileCreationInfo.URL = $SourceFileName
$FileUploaded = $Library.RootFolder.Files.Add($FileCreationInfo)
  
#powershell upload single file to sharepoint online
$Context.Load($FileUploaded)
$Context.ExecuteQuery()
 
#Close file stream
$FileStream.Close()
  
write-host "File has been uploaded!"


#Read more: https://www.sharepointdiary.com/2016/06/upload-files-to-sharepoint-online-using-powershell.html#ixzz8h0CB7EmY

https://atos365.sharepoint.com/:f:/r/sites/AtosNewOfferings/Shared%20Documents/Microsoft/Membership%20-%20Advanced%20Specialization%20and%20Solution%20Partners%20+%20Azure%20MSP/Advanced%20Specializations%20-%20checklists%20and%20documentations/Azure/Infra%20and%20Database%20Migration%20to%20Azure/Checklist%20and%20Evidence%20collection?csf=1&web=1&e=fALrgX