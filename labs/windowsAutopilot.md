# Lab ++ Mise en place d'un test Windows AutoPilot
## Scénario d'atelier
Dans cet atelier, il vous est proposé de tester de manière la plus simple et rapide possible la fonctionnalité **Windows Autopilot** Afin de constater la jonction et la customisation automatique d'un poste Windows 10 dans un tenant Microsoft 365.
# Prérequis
Il vous faut une machine (physique ou virtuelle) Windows 10 à jour dont la configuration sera perdue à l'issue du test et un tenant Microsoft 365 de test avec un compte **Global Administrator** dessus.
# Objectifs
Dans cet atelier, vous allez:
+ Tâche 1: Configurer La customisation d'interface de l'Azure AD aux couleurs de l'entreprise
+ Tâche 2: Activer la prise en charge d'Autopilot pour votre tenant 365.
+ Tâche 3: Récupérer les informations de la machine de test.
+ Tâche 4: Inscrire la machine de test dans le programme Autopilot.
+ Tâche 5: Créer un profil de déploiement basique.
+ Tâche 6: Tester le déploiement Autopilot de la machine.
# Instructions
## Tâche 1: Configurer l'interface de l'entreprise dans Azure AD.
Cette tâche n'est pas directement liée à l'activation de la fonction Windows Autopilot sur un tenant 365, mais celle-ci échouera si la customisation d'interface de l'entreprise n'a pas été faite.
>En plus de votre tenant de test, il vous faudra pour réaliser cette tâche une image représentant le logo de l'entreprise virtuelle. Vous pouvez utiliser toute image de votre choix ou [télécharger le logo ib ici](https://www.ib-formation.fr/Portals/0/logo_ib.png) par exemple.
1. Connectez-vous au [Microsoft 365 admin center](https://admin.microsoft.com) en utilisant le compte *Global Administrator* de votre tenant de test.
1. Dans le menu de navigation à gauche, cliquer sur "**... Show all**" puis, dans la section "**Admin centers**" sur "**Azure Active Directory**".
1. Dans le "**Azure Active Directory admin center**", cliquez sur "**Azure Active Directory**" dans le menu de navigation à gauche.
1. Cliquez sur "**Company Branding**" dans la section "**Manage**" du menu de navigation de la fenêtre "**Overview**".
1. Cliquez sur "**Configure**" dans la barre d'outil de la page "**Company Branding**".
>Si une configuration est déjà présente, cliquez sur son titre ("**Default**" par exemple) afin d'afficher la fenêtre "**Edit company branding**".
6. Utilisez les valeurs suivantes pour la customisation, laissez les autres valeurs non renseignées ou par défaut:
  - "**Sign-in page text**" : "```Bienvenue dans l'enterprise connectée...```"
  - "**Square logo image**" : Utiliser l'image récupérée précédemment.
7. Cliquez sur "**Save**" 
## Tâche 2: Activer la prise en charge d'Autopilot pour le tenant
1. Connectez-vous au [Microsoft 365 admin center](https://admin.microsoft.com) en utilisant le compte *Global Administrator* de votre tenant de test.
1. Dans le menu de navigation à gauche, cliquer sur "**... Show all**" puis, dans la section "**Admin centers**" sur "**Endpoint Manager**".
1. Dans le "**Microsoft Endpoint Manager admin center**", cliquez sur "**Devices**" dans le menu de navigation à gauche.
1. Dans la fenêtre "**Devices | Overview**", dans la section "**By platform**" du menu de navigation, cliquez sur "**Windows**".
1. Dans la fenêtre "**Windows | Windows Devices**", cliquez sur "**Windows Enrollment**" dans le menu de navigation.
1. Dans la fenêtre "**Windows | Windows Enrollment**", cliquez sur la tuile "**Automatic Enrollment**".
1. Dans la fenêtre "**Configure**" qui s'ouvre, passez le paramètre "**MDM user scope**" sur ```All``` avant de cliquer sur "**Save**"
## Tâche 3: Récupérer les informations de la machine de test
1. Commencez par vous connecter sur la machine (physique ou virtuelle) qui servira de test à la fonction Autopilot avec un compte ayant les privilèges administratif en local.
1. Faites un *clic-droit* sur le bouton Start et cliquez sur "**Windows Powershell (Admin)**".
>Si une fenêtre *User Account Control* apparait, cliquez sur "**Yes**".
3. Dans la fenêtre "**Administrator: Windows PowerShell**", tapez la commande suivante :
```
Install-script Get-WindowsAutoPilotInfo
```
1. A chaque demande de confirmation, saisir ```Y``` (ou ```O``` sur un Windows Français) et *Entrée*.
3. Dans la fenêtre "**Administrator: Windows PowerShell**", tapez la commande suivante :
```
Get-WindowsAutoPilotInfo.ps1 -outputFile $env:USERPROFILE\Documents\myVMautopilot.csv
```
## Tâche 4: Inscrire la machine de test dans le programme Autopilot
1. Connectez-vous au [Microsoft 365 admin center](https://admin.microsoft.com) en utilisant le compte *Global Administrator* de votre tenant de test.
1. Dans le menu de navigation à gauche, cliquer sur "**... Show all**" puis, dans la section "**Admin centers**" sur "**Endpoint Manager**".
1. Dans le "**Microsoft Endpoint Manager admin center**", cliquez sur "**Devices**" dans le menu de navigation à gauche.
1. Dans la fenêtre "**Devices | Overview**", dans la section "**By platform**" du menu de navigation, cliquez sur "**Windows**".
1. Dans la fenêtre "**Windows | Windows Devices**", cliquez sur "**Windows Enrollment**" dans le menu de navigation.
1. Dans la fenêtre "**Windows | Windows enrollment**", cliquez sur la tuile "**Devices**" de la section "**Windows Autopilot Deployment Program**".
1. Dans la fenêtre "**Windows Autopilot devices**" cliquez sur "**Import**" dans la barre d'outils.
1. Dans la fenêtre "**Add Windows Autopilot devices**", cliquez sur le bouton de parcours pour aller chercher le fichier ```Documents\myVMautopilot.csv``` et cliquez sur "**Open**".
1. Dans la fenêtre "**Add Windows Autopilot devices**", un message devrait vous indiquer que votre fichier contient une ligne d'entrée correctement formattée : cliquez sur "**Import**"
>Il faudra s'assurer que l'import a bien eu lieu (notification en ce sens, avant de passer au test de la tâche 6, mais vous pouvez continuer avec la tâche 5 suivante en attendant).
## Tâche 5: Créer un profil de déploiement basique
1. Connectez-vous au [Microsoft 365 admin center](https://admin.microsoft.com) en utilisant le compte *Global Administrator* de votre tenant de test.
1. Dans le menu de navigation à gauche, cliquer sur "**... Show all**" puis, dans la section "**Admin centers**" sur "**Endpoint Manager**".
1. Dans le "**Microsoft Endpoint Manager admin center**", cliquez sur "**Devices**" dans le menu de navigation à gauche.
1. Dans la fenêtre "**Devices | Overview**", dans la section "**By platform**" du menu de navigation, cliquez sur "**Windows**".
1. Dans la fenêtre "**Windows | Windows Devices**", cliquez sur "**Windows Enrollment**" dans le menu de navigation.
1. Dans la fenêtre "**Windows | Windows enrollment**", cliquez sur la tuile "**Deployment Profiles**" de la section "**Windows Autopilot Deployment Program**".
1. Dans la fenêtre "**Windows Autopilot deployment profiles**", cliquez sur le bouton "**+ Create profile**".
1. Dans la fenêtre "**Create profile**", dans l'onglet "**Basics**", saisissez ```Mon Profil de déploiement``` pour le "**Name**" avant de cliquer sur "**Next**"
1. Dans l'onglet "**Out-of-box experience (OOBE)**", saisissez les informations suivantes avant de cliquer sur "**Next**" (laissez les autres valeurs par défaut) :
  - "**Deployment mode**" : ```User-Driven```
  - "**Join to Azure AD as**" : ```Azure AD Joined```
  - "**Allow White Glove OOBE**" : ```Yes```
  - "**Apply Device name template**" : ```Yes```
  - "**Enter a name**" : ```ib-%RAND:4%```
10. Dans l'onglet "**Assignments**", selectionnez ```All devices``` pour le champ "**Assign to**" avant de cliquer sur "**Next**"
1. Dans la fenêtre "**Create profile**", cliquez sur le bouton "**Create**"
## Tâche 6: Tester le déploiement Autopilot de la machine.
1. Si vous avez fermé l'invite Powershell administrative, faties un *clic-droit* sur le bouton Start et cliquer sur "**Windows Powershell (Admin)**".
>Si une fenêtre *User Account Control* apparait, cliquez sur "**Yes**".
2. Dans la fenêtre "**Administrator: Windows PowerShell**", tapez la commande suivante : 
```psh
& "$env:SystemRoot\system32\sysprep\sysprep" /reboot /oobe /generalize
```
>Il est possible d'omettre le paramètre ```/generalize``` pour que le redémarrage soit plus rapide !
3. une fenêtre "**Sysprep is working**" va apparaître, puis le poste Windows redémarre et vous allez pouvoir procéder à sa mise en service connectée...
