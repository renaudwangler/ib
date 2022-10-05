# Lab: intégration de serveur avec Azure ARC

**Scenario**
Dans cet atelier, nous allons illustrer l'utilisation de l'*Azure Resource Control* pour gérer une machine Windows depuis l'environnement Azure.  
De plus l'accès aux resources Azure depuis la machine Windows se fera nativement gràce à une *Managed Identity*.  
  
Voici les étapes incluses dans cet atelier :
 - Créer une machine Windows
 - Créer un *blob* dans un *Storage Account*
 - Déconnecter la machine virtuelle de l'environnement Azure
 - Connecter la machine virtuelle à Azure ARC
 - Vérification du fonctionnement
---
## Etape 1 : Créer une machine Windows
Vous allez commencer par lancer la création d'une machine virtuelle Windows qui devra, par la suite, pouvoir accèder au *Storage Account*.  
> **Nota :** La machine créé ici simulera une machine Windows qui ne serait pas hébergée dans Azure
1. Connectez-vous au portail Azure (http://portal.azure.com) et cliquez sur **+ Create a resource**
1. Dans la fenêtre **Create a resource**, sélectionnez **Compute** puis cliquez sur **Create** sous **Virtual Machine**.
1. Dans la fenêtre **Create a virtual machine**, Utilisez les paramètres suivants dans l'onglet **Basics** (laissez les paramètres non mentionnés à leur valeur par défaut):  
   - **Resource Group:** cliquez **Create new**, utilisez **demoARC** comme nom et cliquez sur **OK**.
   - **Virtual machine name:** **ARC-VM**
   - **Region :** **East US** (ou toute autre région conseillée par votre formateur/trice)
   - **Image :** Windows Server 2022 Datacenter: Azure Edition - Gen2
   - **Size :** **Standard_DS1_v2**
   - **Administrator account - Username :** saisir **Student**
   - **Administrator account - Password :** saisir **Pa55w.rd1234**
1. Cliquez sur **Review + create** puis, une fois que le message *Validation passed* est apparu, cliquez sur **Create**.
> **Nota :** Vous n'avez pas besoin d'attendre que le déploiement de la machine virtuelle soit terminé pour passer à l'étape suivante.
## Etape 2 : Créer un *blob* dans un *Storage Account*
Vous allez maintenant télédéverser un fichier (*blob*) dans un *Storage Account*, ce sera la cible de notre test d'accès
1. Connectez-vous au portail Azure (http://portal.azure.com) et cliquez sur **+ Create a resource**
1. Dans la fenêtre **Create a resource**, sélectionnez **Storage** puis cliquez sur **Create** sous **Storage Account**.
1. Dans la fenêtre **Create a storage account**, Utilisez les paramètres suivants dans l'onglet **Basics** (laissez les paramètres non mentionnés à leur valeur par défaut):  
    - **Resource Group :** Sélectionnez **demoARC**
    - **Storage account name :** Tapez un nom mondialement unique et composé uniquement de minuscules et de chiffres.
    - **Region :** Sélectionnez la même région que pour la VM précédente.
    - **Redundancy :** Selectionnez **Locally-redundant storage (LRS)**
1. Cliquez sur **Review** puis, une fois que le message *Validation passed* est apparu, cliquez sur **Create**.
1. Attendez que le *storage account* soit créé, puis cliquez sur le bouton **Go to resource**.
1. Dans la page de configuration de votre *Storage Account*, dans le menu à gauche, sélectionnez **Containers** dans la section **Data storage**
1. Cliquez sur le bouton **+ Container**.
1. Dans la fenêtre **New container**, saisissez les informations suivantes avant de cliquer sur **Create**
    - **Name :** tapez **arc**
    - **Public access level :** sélectionnez **Private**
1. Cliquez sur **Create**
1. Sur la page des **Containers**, cliquez sur la ligne **arc** pour ouvrir votre conteneur
1. Sur la page **arc|Container**, cliquez sur **Upload**
1. Utilisez la page **Upload blob** pour déposer n'importe quel fichier (text, image...) dans le conteneur
1. Cliquez sur la case de fermeture **Close** pour fermer la page **Upload blob**
1. De retour sur la page **arc|Containers**, cliquez sur le nom du fichier télédéversé et utilisez le bouton **Copy to clipboard** pour copier l'url d'accès au fichier.
## Etape 3: Déconnecter la machine virtuelle de l'environnement Azure
Notre machine virtuelle simule une machine *on premises* et ne doit, à ce titre, pas être connectée avec l'environnement Azure
1. Connectez-vous au portail Azure (http://portal.azure.com) et cliquez sur **Home** puis sur **Resource groups**
1. Dans la page **Resource Groups**, cliquez sur le *resource group* **demoARC** pour l'ouvrir
1. Dans la page **demoARC**, cliquez sur votre machine virtuelle **ARC-VM** pour l'ouvrir
1. Dans la barre d'outils supérieure de la page **ARC-VM**, cliquez sur **Connect / RDP**
1. Dans la page **ARC-VM|Connect**, cliquez sur le bouton **Download RDP File**
1. Ouvrez le fichier *ARC-VM.rd* téléchargé depuis votre navigateur Internet et connectez-vous avec les informations suivantes :
    - Nom d'utilisateur : **Student**
    - Mot de passe : **Pa55w.rd1234**
1. Une fois la session ouverte, attendez, si nécessaire, qu'elle s'initialise correctement.
1. Dans la session distante, si le panneau **Networks** s'affiche, cliquez sur **yes**.
1. Dans le menu démarrer de la machine virtuelle, faites un clic-droit sur **Windows Powershell ISE** et choisissez **More/Run as administrator**
1. Dans **Windows Powershell ISE**, cliquez sur la petite flèche descendante à coté de la mention **Script** pour faire apparaître le panneau **Untitled.ps1**
1. Dans le panneau **Untitled.ps1**, saisissez les 3 lignes de code suivantes :
```powershell
    Set-Service WindowsAzureGuestAgent -StartupType Disabled -Verbose
    Stop-Service WindowsAzureGuestAgent -Force -Verbose
    New-NetFirewallRule -Name BlockAzureIMDS -DisplayName "Block access to Azure IMDS" -Enabled True -Profile Any -Direction Outbound -Action Block -RemoteAddress 169.254.169.254
```
1. Dans **Windows Powershell ISE**, cliquez sur la flèche verte **Run Script (F5)**.
> **Nota :** Vous pouvez vérifier si vous le souhaitez que, dans le portail azure, la machine virtuelle ne communique plus avec l'environnement Azure car un message apparait sur la resource VM dans le portail indiquant "****"

## Etape 4: Connecter la machine Windows à Azure
Vous allez maintenant vous connecter à la machine virtuelle pour y installer le nécessaire de connexion en gestion Azure.
1. Ouvrez le navigateur **Microsoft Edge** et initialisez le navigateur.
1. Dans **Microsoft Edge**, connectez-vous au portail Azure (http://portal.azure.com) avec votre compte d'administrateur
1. Dans le portail Azure, dans la barre de recherche, commencez à saisir **Azure Arc** et cliquez sur le service **Azure Arc**
1. Dans la page **Azure Arc**, dans la section **Infrastructure**, cliquez sur **Servers**
1. Dans la page **Azure Arc|Servers** cliquez sur **+ Add**
1. Dans la page **Add servers with Azure Arc**, cliquez sur le bouton **Generate script** sur la tuime **Add a single server**
1. Sur l'onglet **1. Prerequisites**, cliquez sur **Next**
1. Sur l'onglet **2. Resource details**, utilisez les informations suivantes avant de cliquer sur **Next** :
    - **Resource Group :** Sélectionnez **demoARC**
    - **Region :** Sélectionnez la même région que pour la VM précédente.
    - **Operating system :** Selectionnez **Windows**
    - **Connectivity method :** Sélectionnez **Public endpoint**
1. Sur l'onglet **3. tags**, cliquez sur **Next**
1. Sur l'onglet **Download and run script**, utilisez le bouton **Copy to clipboard** à coté du bouton **Download**
1. Dans le **Windows Powershell ISE** précédemment utilisé, dans le panneau **Untitled.ps1**, remplacez le contenu par le script copié au point précédent puis cliquez sur la flèche verte **Run Script (F5)**.
1. Dans la fenêtre de navigateur Internet qui s'ouvre, sélectionnez votre compte administrateur (qui ne sera pas un compte Microsoft...) pour valider la connexion à Azure (le message "**Authentication complete. You can return to the application. Feel free to close this browser tab.**" valide cette connexion)

## Etape 5: Vérification du fonctionnement
1. Retournez dans le navigateur Internet et, dans un nouvel onglet, saisissez l'url du Blob privé consignée précédemment
1. Logiquement, vous obtenez un message "ResourceNotFound" vous indiquant que vous n'avez pas accès au fichier (vous nêtes pas reconnu)

1. Dans l'onglet du portail Azure, cliquez sur **Home** puis sur votre **Resource groups**
1. Dans la page **Resource groups**, cliquez sur **demoARC**
1. Dans la page **demoARC|Resource group**, cliquez sur **Access Control (IAM)**
1. Dans la page **Access Control (IAM)**, cliquez sur **Add/Add role assignment**
1. Dans la page **Add role assignment**, Sélectionnez le rôle **Contributor**, et cliquez sur **Next**
1. Dans l'onglet **Members**, selectionnez **Managed Identity** et cliquez sur **+ Select members**
1. Dans la page **Select managed identities**, sous **Managed Identity**, sélectionnez **Server - Azure Arc**
1. Cliquez sur l'entrée **ARC-VM** pour la sélectionner et cliquez sur le bouton **Select**
1. De retour sur la page **Add role assignment**, cliquez sur le bouton **Review + assign**

## Résultat
Vous avez pu connecter votre session Powershell à Azure sans besoin de gérer ni certificat ni mot de passe !

## Nettoyage
Une fois cet atelier terminé, nous vous conseillons de supprimer le *resource group* **demoARC** afin d'éviter toute facturation inutile sur votre compte Azure.  