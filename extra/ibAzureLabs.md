# Mise en place d'un environnement d'ateliers *ib* sur un compte Azure

## Objectifs
Le présent document explique comment mettre en place quelques resources dans un compte Azure (*Azure Pass Sponsorship* par exemple).  
Ces procédures pourront, par exemple, être utilisées en début de formation si vous ne souhaitez/pouvez pas faire de connexion RDP sur les VMs Azure depuis votre réseau.  
La **Procédure 1** comprend aussi la création d'un *Strorage Account* pour y lier votre *Cloud Shell* et vous éviter de devoir le supprimer/recréer à chaque atelier.  

---
**Nota :** L'objectif de ce document n'est pas pédagogique. Si vous êtes dans le contexte d'une formation de découverte d'Azure, ne cherchez pas à comprendre les étapes utilisées ici mais plutôt à les réaliser (avec l'aide éventuelle de votre formateur/trice si nécessaire).  

---
Voici les tâches que nous vous proposons de réaliser:
 - [Passer son compte Azure en anglais.](https:#proc%C3%A9dure-0-passer-son-compte-azure-en-anglais)
 - [Créer des resources dans Azure.](https:#proc%C3%A9dure-1-cr%C3%A9er-des-resources-dans-azure)
 - [Initialiser le Cloud Shell.](https:#proc%C3%A9dure-2--initialiser-le-cloud-shell)
 - [Permettre l'accès Bastion à une VM.](https:#proc%C3%A9dure-3--permettre-lacc%C3%A8s-bastion-%C3%A0-une-vm)
## Procédure 0: Passer son compte Azure en anglais
Tous les labs officiels fournis par Microsoft le sont en langue anglaise.  
Il sera donc plu efficace d'avoir votre portail Azure dans cette même langue anglaise. Ce ne sera pas le cas si vous avez activé votre compte de test depuis un navigateur Internet configuré en Français. Voici donc les quelques étapes pour changer la langue de votre portail Azure :  
1. Cliquez sur l'icône des paramètres en haut à droite du portail Azure.  
![paramètres Azure](images/azureSettings.png)  
3. Dans la page **Paramètres du portail** Sélectionnez l'affichage des **langues + région** en sélectionnant cet onglet (dans la liste à gauche)
4. Dans la page **Paramètres du portail|Langue + région**, sélectionnez **English** dans le menu **Langue**
5. Cliquez sur **Appliquer** puis sur **OK** dans la fenêtre de confirmation qui indique que le portail sera rechargé.
6. Vous pouvez fermer la page des paramètres.
## Procédure 1: Créer des resources dans Azure
1. Cliquez (préférez ouvrir dans un autre onglet pour ne pas quitter le présent document) sur le bouton suivant afin d'initialiser le déploiement des resources dans Azure :  
[![Deployer Dans Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Frenaudwangler%2Fib%2Fmaster%2Fextra%2FibAzureLabEnvironment.json)

1. Ce bouton, ouvre votre portail Azure.  
Si vous n'étiez pas encore connecté à votre compte Azure dans le navigateur Internet, procédez à la connexion.
1. Saisissez les informations suivantes dans la page **Custom Deployment** :  
   - **Subscription** : Selectionnez votre abonnement Azure
   - **Resource group** : Cliquer sur **Create new** puis choisissez un nom (*ibLabs* par exemple) et cliquez sur **OK**
   - **Region** : Choisissez **(Europe) West Europe** ou tout autre région désignée par votre formateur/trice
   - **Storage Account Name** : Tapez un nom mondialement unique **composé de minuscules et de chiffres uniquement**.
1. Cliquez sur **review + Create**
1. Si la validation échoue, retournez sur l'onglet **Basics** pour corriger votre saisie, sinon cliquez sur **Create**
1. Attendez que le déploiment soit terminé avant de passer à l'étape suivante  
---
**Nota :** Le déploiemet va prendre quelques minutes.  
Le plus simple est de rester sur la page **Template overview** jusqu'à ce que le bouton **Go to resoruce group** aparaisse.

---
## Procédure 2 : Initialiser le Cloud Shell
1. Dans votre protail Azure, cliquer sur l'icône du **Cloud Shell** dans la barre des icônes en haut à droite.  
![Lancer le Cloud Shell](images/cloudShell0.png)  
1. Au premier lancement du *Cloud Shell*, il faudra lier le *Storage Account* qui a été créé dans la procédure précédente. Pour ce faire, commencez par cliquer sur **Show Advanced Settings**  
![Show Advanced Settings](images/cloudShell1.png)  
1. Remplissez les **Advanced Settings** avec les valeurs suivantes :   
![Advanced Settings values](images/cloudShell2.png)
   - **Subscription** : Selectionnez votre abonnement Azure,
   - **Region** : Selectionnez **West Europe** ou tout autre région désignée par votre formateur/trice,
   - **Resource group** : Cliquez sur **Use existing** et choisissez le *Resource group* créé dans la procédure 1 précédente,
   - **Storage account** : Cliquez sur **Use existing** et choisissez le *Storage Account* créé par la procédure 1 précédente,
   - **File share** : Cliquez sur **Use existing** et saisissez la valeur "**cloudshell**".
1. Cliquez sur **Attach storage**. logiquement, votre première session de *Cloud Shell* se lance.
---
**Nota :** Votre *Cloud Shell* est donc associé à un *Storage Account* qui se trouve dans votre *Resource group*. Ainsi, à la fin de chaque atelier, pour faire le ménage, vous pourrez supprimer tous les **autres** *Resource groups* et conserver celui créé par la procédure 1 précédente.

---
## Procédure 3 : Permettre l'accès *Bastion* à une VM  
Si vous ne pouvez-souhaitez pas accèder aux VMs Azure directement en RDP ou SSH depuis votre réseau, vous pouvez utiliser la procédure suivante pour vous connecter à l'interface d'une VM Azure directement dans votre navigateur.  

---
**Nota :** Azure Bastion est un service facturé par Microsoft. Si vous ne souhaitez pas l'utiliser dans vos labs, nous vous conseillons de supprimer la resource **ibLabBastion** qui a été créée par la procédure 1 précedente (la facturation des resource réseau associées est nulle/négligeable).

---
1. Commencez par accèder au **Resource Group** créé par la procédure 1 précédente.
1. Dans la liste des resources (moitié droite de l'écran), cliquez sur le *Virtual Network* **ibLabVnet**
1. Dans la page **ibLabVnet** Sélectionnez l'affichage des **Properties** en sélectionnant cet onglet (sous **Settings** dans la liste à gauche)
1. Dans la page **ibLabVnet|Properties**, copiez la valeur **Resource ID**, vous en aurez besoin dans un instant.  
![vnet Properties](images/ibLabvNet.png)  
1. Accédez à la VM à laquelle vous souhaitez vous connecter
1. Dans la page de la VM, sélectionnez l'affichage **Networking**, en selectionnant cet onglet (sous **Settings** dans la liste à gauche)
1. Cliquez sur le nom du *Virtual Network* de votre machine virtuelle pour ouvrir celui-ci.  
![VM Networking](images/testVMNetworking.png)  
1. Dans la page de votre *Virtual Network*, Sélectionnez l'affichage des **Peerings** en sélectionnant cet onglet (sous **Settings** dans la liste à gauche)
1. Dans la page **Peerings** de votre machine virtuelle, cliquez sur **+ Add** pour ajouter un nouveau *peering*.  
![Add peering](images/addPeering.png)  
1. Dans la page **Add peering**, saisissez les informations suivantes :
![New peering value](images/peeringById.png)  
   - Laissez chaque bouton radio à sa valeur par défaut.
   - **This virtual network/Peering link name** : Saisissez un nom unique représentatif (ex : *test-vnet_to_ibLabvNet*)
   - **Remote virtual network/Peering link name** : Saisissez un nom unique représentatif (ex : *ibLabvNet_to_test-vnet*)
   - **I know my resource ID** : Cochez la case
   - **Resource ID** : Coller l'identifiant du vNet copié au point X précédent.
 1. Cliquez sur **Add**
 1. Restez sur la page **Peerings**, patientez et utilisez le bouton **Refresh** jusqu'à ce que le **Peering status** soit passé en **Connected**
 1. Retournez à l'affichage de votre machine virtuelle (peut se faire en cliquant sur son nom dans les objets **Home > VM > vNet** au dessus du titre de page **Peerings**).
 2. Dans la page de la VM, sélectionnez l'affichage **Overview**, en selectionnant cet onglet (Le premier dans la liste à gauche)
 3. Cliquez sur le menu **Connect/Bastion**  
![Connect/Bastion](images/BastionConnect.png)  
 5. Dans la page **bastion** de votre machine virtuelle, vous devriez pouvoir saisir votre **username** et **Password** de connexion... ***et VOILA!***
---
**Nota** : Si ce n'est pas le cas mais que la création d'un *bastion* vous est proposée à la place, patientez et rafraichissez la page jusque voir apparâitre la mention "*using Bastion: **ibLabBastion**, Provisioning State: **Succeeded**".

**Nota 2** : Cette *Procédure 3** sera à répéter pour tout nouveau *Virtual Netork* hébergeant une machine virtuelle à laquelle vous souhaiteriez vous connecter...

---
