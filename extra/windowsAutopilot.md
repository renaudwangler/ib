# Lab ++ Mise en place d'un test Windows AutoPilot
## Scénario d'atelier
Dans cet atelier, il vous est proposé de tester de manière la plus simple et rapide possible la fonctionnalité **Windows Autopilot** Afin de constater la jonction et la customisation automatique d'un poste Windows 10 dans un tenant Microsoft 365.
# Prérequis
Il vous faut une machine (physique ou virtuelle) Windows 10 à jour dont la configuration sera perdue à l'issue du test et un tenant Microsoft 365 de test avec un compte **Global Administrator** dessus.
# Objectifs
Dans cet atelier, vous allez:
+ Tâche 1: Configurer La customisation d'interface de l'Azure AD aux couleurs de l'entreprise
+ Tâche 2: Activer la prise en charge d'Autopilot pour votre tenant 365.
# Instructions
## Tâche 1: Configurer l'interface de l'entreprise dans Azure AD.
1. Microsoft 365 admin center
1. Show All/Azure Active Directory
1. Azure Active Directory
1. Company Branding
1. Default
1. Sign-in page text : "bienvenue dans l'entreprise connectée"
1. Square logo image
## Tâche 2: Activer la prise en charge d'Autopilot pour le tenant
1. Microsoft 365 admin center
1. Show All/Endpoint Manager
1. Devices
1. Windows
1. Windows Enrollment
1. Automatic Enrollment
1. MDM User scope : All
## Tâche 3: Récupérer les informations de la machine de test
1. Powershell/Run as Administrator
1. Install-script Get-WindowsAutoPilotInfo
1. Get-WindowsAutoPilotInfo.ps1 -outputFile $env:USERPROFILE\Documents\myVMautopilot.csv
## Tâche 4: Inscrire la machine de test dans le programme Autopilot
1. Microsoft 365 admin center
1. Show All/Endpoint Manager
1. Devices
1. Windows
1. Windows Enrollment
1. Devices
1. Import
1. Choisir fichier myVMAutopilot.csv
## Tâche 5: Créer un profil de déploiement basique
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
## Tâche 6: Testerle déploiement Autopilot de la machine.
1. Powershell/Run as Administrator
1. & "$env:SystemRoot\system32\sysprep\sysprep" /reboot /oobe /generalyze
1. ooohhhhh
