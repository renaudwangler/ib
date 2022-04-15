# Lab: Key Vault et Identité gérée

**Scenario**
Dans cet atelier, nous allons illustrer l'utilisation d'un *Key Vault* pour stocker un élément de sécurité (réprésenté ici par le mot de passe d'un *Azure File Share*).  
De plus l'accès au *Key Vault* se fera depuis une machine virtuelle en utilisant sa *System Assigned Managed Identity*.  
> **Nota :** Il serait bien plus simple de donner accès directement au storage account à l'identité de la VM. Le passage par le *Key Vault* dans cet atelier n'a qu'un objectif pédagogique.  
Voici les étapes incluses dans cet atelier :
 - Créer une machine virtuelle
 - Créer un *Azure File Share*
 - Créer un *Key Vault*
 - Ajouter un secret dans le *Key Vault*
 - Rendre le Key Vault accessible par la VM.
 - Vérification du fonctionnement
---
## Etape 1 : Créer une machine virtuelle
Vous allez commencer par lancer la création d'une machine virtuelle qui devra, par la suite, pouvoir accèder au *Storage Account*.  
1. Connectez-vous au portail Azure (http://portal.azure.com) et cliquez sur **+ Create a resource**
1. Dans la fenêtre **Create a resource**, sélectionnez **Compute** puis cliquez sur **Create** sous **Virtual Machine**.
1. Dans la fenêtre **Create a virtual machine**, Utilisez les paramètres suivants dans l'onglet **Basics** (laissez les paramètres non mentionnés à leur valeur par défaut):  
   - **Resource Group:** cliquez **Create new**, utilisez **demoRG** comme nom et cliquez sur **OK**.
   - **Virtual machine name:** **DemoVM**
   - **Region :** **East US** (ou toute autre région conseillée par votre formateur/trice)
   - **Image :** Windows Server 2022 Datacenter: Azure Edition - Gen2
   - **Size :** **Standard_DS1_v2**
   - **Administrator account - Username :** type **Student**
   - **Administrator account - Password :** type **Pa55w.rd1234**
1. Basculez sur l'onglet **Management**et activez **System Assigned managed identity** (laissez les paramètres non mentionnés à leur valeur par défaut)  
1. Cliquez sur **Review + create** puis, une fois que le message *Validation passed* est apparu, cliquez sur **Create**.
> **Nota :** Vous n'avez pas besoin d'attendre que le déploiement soit terminé pour passer à l'étape suivante.
## Etape 2 : Créer un *Azure File Share*
Vous allez maintenant créer un *File Share* dans un *Storage Account*, cible de notre test d'accès
1. Connectez-vous au portail Azure (http://portal.azure.com) et cliquez sur **+ Create a resource**
1. Dans la fenêtre **Create a resource**, sélectionnez **Storage** puis cliquez sur **Create** sous **Storage Account**.
1. Dans la fenêtre **Create a storage account**, Utilisez les paramètres suivants dans l'onglet **Basics** (laissez les paramètres non mentionnés à leur valeur par défaut):  
    - **Resource Group :** Sélectionnez **demoRG**
    - **Storage account name :** Tapez un nom mondialement unique et composé uniquement de minuscules et de chiffres.
    - **Region :** Sélectionnez la même région que pour la VM précédente.
    - **Redundancy :** Selectionnez **Locally-redundant storage (LRS)**
1. Cliquez sur **Review + create** puis, une fois que le message *Validation passed* est apparu, cliquez sur **Create**.
1. Attendez que le *storage account* soit créé, puis cliquez sur le bouton **Go to resource**.
1. Dans la page de configuration de votre *Storage Account*, dans le menu à gauche, sélectionnez **File shares** dans la section **Data storage**
1. Cliquez sur le bouton **+ File share**.
1. Dans la fenêtre **New file share**, saisissez les informations suivantes avant de cliquer sur **Create**
    - **Name :** tapez **demoshare**
    - **Tier :** sélectionnez **Hot**
1. Cliquez sur **Create**
1. Sur la page de votre *Storage Account*, cliquez sur **Settings/Acces Keys**
1. Cliquez sur le bouton **Show keys** et copiez la valeur du champ **Key1** (voius pouvez le faire en utilisant le bouton de copie à droite dudit champ).
## Etape 3: Créer un *Key vault*
Vous allez maintenant créer le *Key Vault* dans lequel vous stockerez ensuite le mot de passe de connexion au partage.
1. Connectez-vous au portail Azure (http://portal.azure.com) et cliquez sur **+ Create a resource**
1. Dans la fenêtre **Create a resource**, sélectionnez **Security** puis cliquez sur **Create** sous **Key Vault**.
1. Dans la fenêtre **Create a Key Vault**, Utilisez les paramètres suivants dans l'onglet **Basics** (laissez les paramètres non mentionnés à leur valeur par défaut):  
    - **Resource Group :** Sélectionnez **demoRG**
    - **Key vault name:** **demoKVXXX**, remplacez XXX avec une chaîne de caractères globalement unique.
    - **Region :** Sélectionnez la même région que pour la VM précédente.
    - **Purge protection:** **Disable purge protection**
1. Cliquez sur **Review + create** puis, une fois que le message *Validation passed* est apparu, cliquez sur **Create**.
1. Attendez que le *Key Vault* soit créé, puis cliquez sur le bouton **Go to resource**  
## Etape 4 : Ajouter un secret dans le *Key Vault*
Vous allez désormais placer le mot de passe de connexion au partage de fichiers dans le *Key Vault*.  
1. Sur la page de votre *Key Vault*, cliquez sur **Settings/Secrets**
1. Cliquez sur le bouton **+ Generate/import**
1. Utilisez les valeurs suivantes avant de cliquer sur le bouton **Create**  (laissez les paramètres non mentionnés à leur valeur par défaut)
    - **Upload options:** **Manual**
    - **Name:** **sakey**
    - **Value:** Collez la valeur de la clef que vous aviez copié à l'étape 2
## Etape 5 : Rendre le *Key Vault* accessible par la VM.
VOus allez maintenant permettre à la VM de récupérer les informations secretes dans le *Key Vault*, en vous appuyant sur le *RBAC* interne à ce dernier.
1. Dans la page de votre *Key Vault* , cliquez sur **Settings/Access policies**
1. Cliquez sur **+ Add Access Policy** et utilisez les valeurs suivantes avant de cliqure sur le bouton **Add** :
    - **Configure from template:** **Secret Management**
    - **Select principal:** Cliquez sur **None selected** et recherchez l'entrée **demoVM** pour la choisir avant de cliquer sur le bouton **Select**  
1. De retour sur la page **Access policies**, cliquez sur le bouton **Save**  
## Etape 6 : Vérification du fonctionnement
Pour finir, vous allez démontrer que le code tournant dans le contexte de la machine virtuelle peut récupérer des informations dans le *Key Vault* afin, dans notre exemple, d'accéder à un partage.
1. retournez sur la VM que vous avez déployé à l'étape 1 (vous pouvez, par exemple, cliquer sur l'entrée **demoVM** dans la liste **Recent resources** sur la page d'accueil du portail).
1. dans la fenêtre **demoVM**, dans la barre d'outils supérieure, cliquez sur **Connect/RDP**
    > **Nota :** Si vous avez des problèmes avec la connexion RDP, vous pouvez passer par la mise en place d'un *bastion* (rapprochez-vous de votre formateur/trice si nécessaire pour obtenir de l'aide).  
1. Dans la fenêtre **demoVM|Connect**, cliquez sur **Download RDP File** 
1. Utilisez le fichier **demoVM.rdp** que vous venez de télécharger pour vous connecter avec les identifiants suivants :
    - Nom d'utilisateur : **Student**
    - Mot de passe : **Pa55w.rd1234**
1. Une fois la session ouverte, attendez, si nécessaire, qu'elle s'initialise correctement.
1. Dans la session distante, si le panneau **Networks** s'affiche, cliquez sur **yes**.
1. Faites un clic-droit sur le menu Démarrer et selectionnez **Windows Powershell (admin)**
1. dans la fenêtre **Administrator: Windows Powershell** window, tapez la commande suivante et lancez la:
    ```powershell
    install-module az
    ```
1. Tapez **Y** et **Entrée** deux fois pour valider l'installation du module powershell pour Azure (cette installation prend quelques minutes).
1. A l'invite Powershell, utilisez la commande suivante pour vous connecter à lenvironnement Azure en utilisant la *System Assigned Managed Identity* :
    ```powershell
    connect-azAccount -Identity
    ```
    > **Nota ** Notez que vous n'utilisez ni mot de passe ni certificat pour vous connecter : le paramètre `-identity` se suffit à lui-même.
1. Utilisez les 2 commandes Powershell suivantes pour récupérer la clef depuis le *Key Vault* et vous connecter au *Azure FIle Shrare*:
    ```powershell
    $sakey=get-AzKeyVaultSecret -vaultName demoKVXXX -Name sakey -asplaintext
    $sakey
    net use z: \\demosaXXXXX.file.core.windows.net\demoshare /user:demosaXXXX $sakey
    ```
## Résultat
Vous avez pu connecter votre VM au *Azure File Share* sans besoin de gérer ni certificat ni mot de passe !
> **Nota :** La même opération est désormais faisable depuis une machine virtuelle/physique hors Azure car le service [Azure ARC](https://docs.microsoft.com/en-us/azure/azure-arc/servers/overview) intègre nativement la notion de *System Assigned Managed Identity*  
## Nettoyage
Une fois cet atelier terminé, nous vous conseillons de supprimer le *resource group* **demoRG** afin d'éviter toute facturation inutile sur votre compte Azure.  