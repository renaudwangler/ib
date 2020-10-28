
1. Microsoft 365 admin center
1. Show All/Azure Active Directory
1. Azure Active Directory
1. Company Branding
1. Default
1. Sign-in page text : "bienvenue dans l'entreprise connectée"
1. Square logo image

1. Microsoft 365 admin center
1. Show All/Endpoint Manager
1. Devices
1. Windows
1. Windows Enrollment
1. Automatic Enrollment
1. MDM User scope : All

1. Powershell/Run as Administrator
1. Install-script Get-WindowsAutoPilotInfo
1. Get-WindowsAutoPilotInfo.ps1 -outputFile $env:USERPROFILE\Documents\myVMautopilot.csv

1. Microsoft 365 admin center
1. Show All/Endpoint Manager
1. Devices
1. Windows
1. Windows Enrollment
1. Devices
1. Import
1. Choisir fichier myVMAutopilot.csv

1. Microsoft 365 admin center
1. Show All/Endpoint Manager
1. Devices
1. Windows
1. Windows enrollment
1. Deployment Profile
1. Create Profile
1. Name : MyDeplomentProfile
1. Next
1. Deployment mode : User-Driven
1. Join to Azure AD as : Azure AD Joined
1. Allow White Glove OOBE : Yes
1. Apply Device name template : Yes
1. Enter a name : ib-%RAND:4%
1. Next
1. Assign to : All Devices
1. Next + Create

1. Powershell/Run as Administrator
1. & "$env:SystemRoot\system32\sysprep\sysprep" /reboot /oobe /generalyze
1. ooohhhhh
