# Lab: Mise en œuvre Azure File Sync

**Scenario**
Dans cet atelier, nous allons tester la synchronisation de fichiers entre un serveur SMB Windows Server "classique" et un partage de fichiers "*Azure File Share*".  

Voici les étapes incluses dans cet atelier :
 - Créer une machine virtuelle
 - Créer un *Azure File Share*
 - Créer un partage SMB dans le serveur Windows
 - Créer une instance de service *Azure File Sync*
 - Lier le partage SMB avec le service *Azure File Sync*
 - Mettre en place la réplication de fichiers
 - Vérifier la synchronisation
---
## Etape 1 : Créer une machine virtuelle
Vous allez commencer par créer une machine virtuelle qui sera votre serveur de fichiers Windows.  
> **Nota :** Vous allez utiliser une machine virtuelle dans Azure pour simuler un serveur de fichier SMB on premises.
1. Connectez-vous au portail Azure (http://portal.azure.com) et cliquez sur **+ Create a resource**
1. Dans la fenêtre **Create a resource**, sélectionnez **Compute** puis cliquez sur **Create** sous **Virtual Machine**.
1. Dans la fenêtre **Create a virtual machine**, Utilisez les paramètres suivants dans l'onglet **Basics** (laissez les paramètres non mentionnés à leur valeur par défaut):  
    - **Resource Group:** cliquez **Create new**, utilisez **demoRG** comme nom et cliquez sur **OK**.
    - **Virtual machine name:** **demoFiler**
    - **Region :** **East US** (ou toute autre région conseillée par votre formateur/trice)
    - **Image :** Windows Server 2022 Datacenter: Azure Edition - Gen2
    - **Size :** **Standard_DS1_v2**
    - **Administrator account - Username :** type **Student**
    - **Administrator account - Password :** type **Pa55w.rd1234**
1. Basculez sur l'onglet **Networking**, Utilisez les paramètres suivants (laissez les paramètres non mentionnés à leur valeur par défaut):  
    - **Virtual network :** Cliquez sur **Create new** et utilisez les valeurs suivantes avant de cliquer sur **OK** :
      - **Name** : **demoVnet**
      - **Subnet name** : remplacez **default** par **10.0.0**
    - **Delete public IP and NIC when VM is deleted :** Cochez la case.
1. Cliquez sur **Review + create** puis, une fois que le message *Validation passed* est apparu, cliquez sur **Create**.
> **Nota :** Vous n'avez pas besoin d'attendre que le déploiement soit terminé pour passer à l'étape suivante.
## Etape 2 : Créer un *Azure File Share*
Vous allez maintenant créer un partage de fichier SMB natif hébergé dans Azure.
1. Connectez-vous au portail Azure (http://portal.azure.com) et cliquez sur **+ Create a resource**
1. Dans la fenêtre **Create a resource**, sélectionnez **Storage** puis cliquez sur **Create** sous **Storage Account**.
1. Dans la fenêtre **Create a storage account**, Utilisez les paramètres suivants dans l'onglet **Basics** (laissez les paramètres non mentionnés à leur valeur par défaut):  
    - **Resource Group :** Sélectionnez **demoRG**
    - **Storage account name :** Tapez un nom mondialement unique et composé uniquement de minuscules et de chiffres.
    - **Region :** **East US** (ou toute autre région conseillée par votre formateur/trice)
    - **Redundancy :** Selectionnez **Locally-redundant storage (LRS)**
1. Cliquez sur **Review + create** puis, une fois que le message *Validation passed* est apparu, cliquez sur **Create**.
1. Attendez que le *storage account* soit créé, puis cliquez sur le bouton **Go to resource**.
1. Dans la page de configuration de votre *Storage Account*, dans le menu à gauche, sélectionnez **File shares** dans la section **Data storage**
1. Cliquez sur le bouton **+ File share**.
1. Dans la fenêtre **New file share**, saisissez les informations suivantes avant de cliquer sur **Create**
    - **Name :** tapez **syncedshare**
    - **Tier :** sélectionnez **Hot**
1. Cliquez sur **Create**
## Etape 3 : Créer un partage SMB dans le serveur Windows
Vous allez désormais vous connecter à distance sur votre serveur Windows pour y installer le service SMB, créer un partage et y déposer un fichier témoin.  
1. Retournez à la **Home** page du portail Azure et cliquez sur **Resource groups**
1. Cliquez sur le *resource group* **demoRG** pour l'ouvrir.
1. Cliquez sur la *Virtual machine* **demoFiler** pour l'ouvrir
1. dans la fenêtre **demoFiler**, dans la barre d'outils supérieure, cliquez sur **Connect / RDP**
    > **Nota :** Si vous avez des problèmes avec la connexion RDP, vous pouvez passer par la mise en place d'un *bastion* (rapprochez-vous de votre formateur/trice si nécessaire pour obtenir de l'aide).  
1. Dans la fenêtre **demoFiler \| Connect**, cliquez sur **Download RDP File** 
1. Utilisez le fichier **demoFiler.rdp** que vous venez de télécharger pour vous connecter avec les identifiants suivants :
    - Nom d'utilisateur : **Student**
    - Mot de passe : **Pa55w.rd1234**
1. Une fois la session ouverte, attendez, si nécessaire, qu'elle s'initialise correctement.
1. Dans la session distante, si le panneau **Networks** s'affiche, cliquez sur **yes**.
1. Dans la fenêtre **Server Manager > Dashboard**, cliquez sur **File and Storage Services** dans le menu de gauche.
1. Dans la fenêtre **Server Manager > File and Storage Services**, cliquez sur **Volumes** dans le menu de gauche.
1. Dans la fenêtre **Server Manager > File and Storage Services > Volumes**, cliquez sur le lien **Start the Add Roles and Features Wizard** dans la tuile **Shares**
1. Dans la fenêtre **Add Roles and Features Wizard** qui s'est ouverte, cliquez deux fois sur **Next >** puis sur **Install**
1. Attendez que l'installation se termine avant de cliquer sur **Close**
1. De retour dans la fenêtre **Server Manager > File and Storage Services > Volumes**, cliquez sur **TASKS / New Share...** à droite de la tuile **Shares**.
1. Dans la fenêtre **New Share Wizard**, vérifiez que **SMB Share - Quick** soit sélectionné avant de cliquer deux fois sur **Next >**.
1. Dans la page **Specify share name**, tapez **localshare** dans le champ **Share Name** puis cliquez trois fois sur **next >** avant de cliquer sur **Create**.
1. une fois le partage créé, cliquez sur **Close**.
1. A droite du bouton **Démarrer**, saisissez **C:\Shares\localshare** et appuyez sur **[Entrée]**
1. Créez (ou copiez) n'importe quel fichier dans le dossier qui s'est ouvert.
    > **Nota :** Le fichier plaçé dans le partage va nous servir de témoin pour vérifier s'il a été synchronisé dans le *Azure File Share*.
## Etape 4 : Créer une instance de service *Azure File Sync*
Vous allez ici créer une instance de service *Azure File Sync* dans Azure. Ce service est celui qui sera chargé de la communication entre votre serveur SMB et le partage dans le cloud Azure.  
1. Dans la session distante RDP, En passant par le menu **Démarrer**, lancez **Microsoft Edge**
1. Connectez-vous au portail Azure (http://portal.azure.com) et cliquez sur **+ Create a resource** 
1. Dans la fenêtre **Create a resource**, saisissez **Azure File Sync** dans le champ **Search services and marketplace** puis cliquez sur l'entrée **Azure File Sync** qui s'affiche en dessous de ce champ.
1. Dans la fenêtre **Azure File Sync**, cliquez sur **Create**.
1. Dans la fenêtre **Deploy Azure File Sync**, Utilisez les paramètres suivants dans l'onglet **Basics** (laissez les paramètres non mentionnés à leur valeur par défaut):  
    - **Resource Group :** Sélectionnez **demoRG**
    - **Storage sync service name :** **demoSyncXXXX** (en utilisant une chaine unique à la place de **XXXX**)
    - **Region :** **East US** (ou toute autre région conseillée par votre formateur/trice)
1. Cliquez sur **Review + create** puis cliquez sur **Create**.
1. Cliquez sur le bouton **Go to resource**
1. Cliquez sur **+ Sync group** et saisissez les paramètres suivants dans l'onglet **Basics** (laissez les paramètres non mentionnés à leur valeur par défaut):  
    - **Sync group name :** Tapez **demoSync**
    - **Storage Account :** Cliquez sur **Select storage account** pour sélectionner le *storage account* créé à l'étape 2
    - **Azure File Share :** Sélectionnez **syncedshare**
1. Cliquez sur **Create**
## Etape 5 : Lier le partage SMB avec le service *Azure File Sync*
Vous allez maintenant installe un agent sur votre serveur de fichiers, qui sera connecté avec le service *Azure File Sync* afin de réaliser la synchronisation des fichiers locaux.  
1. Dans la session distante RDP, si nécessaire, ouvrez dans Edge le *Storage Sync Service* créé à l'étape précédente.
1. Dans le menu de gauche, cliquez sur **Registered servers** dans la section **Sync**
1. Dans l'encadré **To register your server**, cliquez sur le lien **Azure File Sync agent** pour en ouvrir la page de téléchargement.
1. Dans la page **Download azure File Sync Agent**, cliquez sur le bouton **Download**
1. Cochez la case **StorageSyncAgent_WS2022.msi** puis cliquez sur **Next**
1. Dans la notification de téléchargement de Edge, cliquez sur **Open File** en dessous du nom de fichier *StorageSyncAgent_WS2022.msi*
1. Dans la page **Welcome to the storage Sync Agent Setup Wizard** qui s'ouvre, cliquez cinq fois sur **Next** puis sur **Install**
1. Cliquez sur **Finish**, cela va lancer la fenêtre de configuration de l'agent.
1. Si une fenêtre **Update** apparaît, cliquez sur **OK**
1. Dans la page **Sign in and register this server**, sélectionnez **AzureCloud** (ne cochez pas **I am signing in as a Cloud Solution Provider**) et cliquez sur **Sign in**
    > **Nota :** Si vous recevez des invites *Internet Explorer* concernant la sécurité, autorisez les domaines **https://*.microsoftonline.com**, **https://*.msauth.net** et **https://*.msftauth.net**. Une fois cela fait, si le login échoue, recliquez sur **Sign in** pour réessayer...
1. Dans la page **Choose a Storage Sync Service**, utilisez les informations suivantes :
    - **Azure Subscription :** Sélectionnez l'abonnement Azure utilisé pour cet atelier
    - **Resource Group :** **demoRG**
    - **Storage Sync Service :** **demoSyncXXXX** (le service créé à l'étape précédente).
1. Cliquez sur **Register**
1. Cliquez sur **Close**
## Etape 6 : Mettre en place la réplication de fichiers
Tout est prêt : vous pouvez désormais indiquer au service *Azure File Sync* qu'il doit répliquer les fichiers entre votre serveur et le partage Azure.  
1. Dans la session distante RDP, si nécessaire, ouvrez dans Edge le *Storage Sync Service* créé à l'étape précédente.
1. Dans le menu de gauche, cliquez sur **Sync groups** dans la section **Sync**
2. Cliquez sur le groupe **demoSync** pour l'ouvrir.
3. Dans la page **DemoSync**, vérifiez que le **Provisioning State** est correct en face de **syncedshare**
4. Dans le bandeau d'outil en haut de page, cliquez sur **Add server endpoint**
5. Dans la page **Add server endpoint**, utilisez les informations suivantes (laissez les paramètres non mentionnés à leur valeur par défaut):
    - **Registered Server :** sélectionnez **demoFiler**
    - **path :** Saisissez C:\Shares\localshare**
1. Cliquez sur **Create**
2. De retour sur la page **demoSync**, attendez (vous pouvez utiliser le bouton **Refresh**) que l'état de santé **health** passe à **ok** (coche verte) pour le serveur **demoFiler**
## Etape 7 : Vérifier la synchronisation
Cette dernière étape, après avoir un peu attendu que le processus de synchronisation s'active, va vous permettre de vérifier que votre fichier témoin a bien été synchronisé dans le partage Azure.  
1. Fermez la session distante RDP et retournez sur le navigateur utilisé initialement pour travailler sur le portail Azure.
1. Ouvrez la page **Home** dans le portail Azure et cliquez sur **Resource groups**
1. Cliquez sur **demoRG** pour ouvrir le *resource group*
1. Dans la liste des ressources, cliquez sur le *storage account* créé à l'étape 2
1. Dans le menu à gauche, cliquez sur **File shares** dans la section **Data storage**
1. Cliquez sur le partage **syncedshare** pour l'ouvrir
1. Vous devriez y retrouver le document déposé dans le serveur à l'étape 3 précédente....

## Résultat
Vous avez mis en place la synchronisation des fichiers contenus entre un serveur SMB Windows et un partage de fichier dans Azure.  
Pour rappel, vous pourriez également lier plusieurs partages de plusieurs serveurs SMB pour en synchroniser le contenu sur plusieurs de vos sites.

## Nettoyage
Une fois cet atelier terminé, nous vous conseillons de supprimer le *resource group* **demoRG** afin d'éviter toute facturation inutile sur votre compte Azure.  
> **Nota :** Pour supprimer le *storage sync service*, il pourra être nécessaire de l'ouvrir dans le portail puis :
>   - Cliquer sur **registered servers** dans la section **sync**
>   - Cliquer sur les points de suspension (...) en fin de la ligne **demoFiler** et sélectionner **Unregister server**
>   - Taper le nom **demoFiler** dans le champ de confirmation et cliquer sur **Unregister**
>   - Cliquer sur **Sync group** dans la section **sync**
>   - Ouvrir le *sync group* **demoSync**
>   - Cliquer sur les points de suspension (...) en fin de la ligne **syncedshare**, sélectionner **Delete** et valider par **OK**
>   - Cliquer sur **Delete sync group** dans la barre de menu en haut de la page **demoSyncXXXX** et cliquers sur **OK** pour confirmer
