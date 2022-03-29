# Lab: Mise en oeuvre Azure File Sync

**Scenario**
Dans cet atelier, nous allons tester la synchronisation de fichiers entre un serveur SMB Windows Server "classique" et un partage de fichiers "*Azure File Share*".  
Voici les étapes incluses dans cet atelier:  
 - Créer un serveur de fichiers Windows
 - Create un *Azure File Share*
 - Mettre en oeuvre *Azure File Zync*
## Exercice 1: Provisionner l'environement d'atelier
Dans ce premier exercice, vous allez créer les éléments nécessaire pour tester la synchronisation de fichiers entre votre serveur et le partage Azure.  
> **Nota:** Vous allez utiliser une machine virtuelle dans Azure pour simuler un serveur de fichier SMB on premises.
### Etape 1: Créer une machine virtuelle
1. Connectez-vous au portail Azure (http://portal.azure.com) et cliquez sur **+ Create a resource**
1. Dans la fenêtre **Create a resource**, sélectionnez **Compute** puis cliquez sur **Create** sous **Virtual Machine**.
1. Dans la fenêtre **Create a virtual machine**, Utilisez les paramêtres suivants dans l'onglet **Basics** (laissez les paramêtres non mentionnés à leur valeur par défaut):  
    - **Resource Group:** cliquez **Create new**, utilisez **demoRG** comme nom et cliquez sur **OK**.
    - **Virtual machine name:** **demoFiler**
    - **Region:** **East US** (ou tout autre région conseillé par votre formateur/trice)
    - **Image:** Windows Server 2022 Datacenter: Azure Edition - Gen2
    - **Size:** **Standard_DS1_v2**
    - **Administrator account - Username:** type **Student**
    - **Administrator account - Password:** type **Pa55w.rd1234**
1. Basculez sur l'onglet **Networking**, Utilisez les paramêtres suivants (laissez les paramêtres non mentionnés à leur valeur par défaut):  
    - **Virtual network** : Cliquez sur **Create new** et utilisez les valeurs suivantes avant de cliquer sur **OK** :
      - **Name** : **demoVnet**
      - **Subnet name** : remplacez **default** par **10.0.0**
    - **Delete public IP and NIC when VM is deleted** : Cochez la case.
1. Cliquez sur **Review + create** puis, une fois que le message *Validation passed* est apparu, cliquez sur **Create**.
> **Nota:** Vous n'avez pas besoin d'attendre que le déploiement soit terminé pour passer à l'étape suivante.
### Etape 2: Créer un *Azure File Share*
1. Connectez-vous au portail Azure (http://portal.azure.com) et cliquez sur **+ Create a resource**
1. Dans la fenêtre **Create a resource**, sélectionnez **Storage** puis cliquez sur **Create** sous **Storage Account**.
1. Dans la fenêtre **Create a storage account**, Utilisez les paramêtres suivants dans l'onglet **Basics** (laissez les paramêtres non mentionnés à leur valeur par défaut):  
    - **Resource Group:** Sélectionnez **demoRG**
    - **Storage account name:** Tapez un nom mondialement unique et composé uniquement de minuscules et de chiffres.
    - **Region:** **East US** (ou tout autre région conseillé par votre formateur/trice)
    - **Redundancy:** Selectionnez **Locally-redundant storage (LRS)**
1. Cliquez sur **Review + create** puis, une fois que le message *Validation passed* est apparu, cliquez sur **Create**.
1. Attendez que le *storage account* soit créé, puis cliquez sur le bouton **Go to resource**.
1. Dans la page de configuration de votre *Storage Account*, dans le menu à gauche, sélectionnez **File shares** dans la section **Data storage**
1. Cliquez sur le bouton **+ File share**.
1. Dans la fenêtre **Ne file share**, saisissez les informations suivantes avant de cliquer sur **Create**
    - **Name** : tapez **syncedshare**
    - **Tier** : sélectionnez **Hot**
1. Cliquez sur **Create**
## Etape 3: Créer un partage SMB dans le serveur Windows
1. Retournez à la **Home** page du portail Azure et cliquez sur **Resource groups**
1. Cliquez sur le *resource group* **demoRG** pour l'ouvrir.
1. Cliquez sur la *Virtual machine* **demoFiler** pour l'ouvrir
1. dans la fenêtre **demoFiler**, dans la barre d'outil supérieure, cliquez sur **Connect/RDP**
    > **Nota:** Si vous avez des problèmes avec la connexion RDP, vous pouvez passer par la mise en place d'un *bastion* (rapprochez-vous de votre formateur/trice si nécessaire pour obtenir de l'aide).  
1. Dans la fenêtre **demoFiler|Connect**, cliquez sur **Download RDP File** 
1. Utilisez le fichier **demoFiler.rdp** que vous venez de télécharger pour vous connecter avec les identifiants suivants:
    - Nom d'utilisateur : **Student**
    - Mot de passe : **Pa55w.rd1234**
1. Une fois la session ouverte, attendez, si nécessaire, qu'elle s'initialise correctement.
1. Dans la session distante, si le panneau **Networks** s'affiche, cliquez sur **yes**.
1. Dans la fenêtre **Server Manager > Dashboard**, cliquez sur **File and Storage Services** dans le menu de gauche.
1. Dans la fenêtre **Server Manager > File and Storage Services**, cliquez sur **Volumes** dans le menu de gauche.
1. Dans la fenêtre **Server Manager > File and Storage Services > Volumes**, cliquez sur le lien **Start the Add Roles and Features Wizard** dans la tuile **Shares**
1. Dans la fenêtre **Add Roles and Features Wizard** qui s'est ouverte, cliquez deux fois sur **Next >** puis sur **Install**
1. Attendez que l'installation se termine avant de cliquer sur **Close**
1. De retour dans la fenêtre **Server Manager > File and Storage Services > Volumes**, cliquez sur **TASKS/New Share...** à droite de la tuile **Shares**.
1. Dans la fenêtre **New Share Wizard**, vérfiez que **SMB Share - Quick** soit sélectionné avant de cliquer deux fois sur **Next >**.
1. Dans la page **Specify share name**, tapez **localshare** dans le champ **Share Name** puis cliquez trois fois sur **next >** avant de cliquer sur **Create**.
1. une fois le partage créé, clqiuez sur **Close**.
1. A droite du bouton **Démarrer**, saisissez **C:\Shares\localshare** et appuyez sur **[Entrée]**
1. Créez (ou copiez) n'importe quel fichier dans le dossier qui s'est ouvert.
    > **Nota:** Le fichier plaçé dans le partage va nous servir de témoin pour vérifier s'il a été synchronisé dans le *Azure File Share*.

## Etape 4: Création d'un *Azure File Sync*
1. Dans la session distante RDP, En passant par le menu **Démarrer**, lançez **Microsoft Edge**
1. Connectez-vous au portail Azure (http://portal.azure.com) et cliquez sur **+ Create a resource** 
1. Dans la fenêtre **Create a resource**, saisissez **Azure File Sync** dans le champ **Search services and marketplace** puis cliquez sur l'entrée **Azure File Sync** qui s'affiche en dessous de ce champ.
1. Dans la fenêtre **Azure File Sync**, cliquez sur **Create**.
1. Dans la fenêtre **Deploy Azure File Sync**, Utilisez les paramêtres suivants dans l'onglet **Basics** (laissez les paramêtres non mentionnés à leur valeur par défaut):  
    - **Resource Group:** Sélectionnez **demoRG**
    - **Storage sync service name:** **demoSyncXXXX** (en utilisant une chaine unique à la place de **XXXX**)
    - **Region:** **East US** (ou tout autre région conseillé par votre formateur/trice)
1. Cliquez sur **Review + create** puis cliquez sur **Create**.
1. Cliquez sur le bouton **Go to resource**

**Results** : You have now connected to a file share from a VM without using any stored password/certificate
