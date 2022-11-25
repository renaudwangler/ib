# Lab: Mise en place de la M.F.A avec une application Windows

**Scenario**
Dans cet atelier, vous allez utiliser une application sur un poste Windows 10/11 pour implémenter l'authentification multifactorielle. Cette mise en ouevre pourrait, par exemple, être utilisée pour authentifier un utilisateur dans un environnement Azure-AD ou Microsoft 365.

Cet atelier inclut les tâches suivantes:
This lab includes the following tasks:

 - Activer la MFA pour un utilisateur
 - Désactiver la MFA pour un utilisateur

## Exercice 1: Activer la MFA pour un utilisateur

### Tâche 1: Installer une appplication du Store Microsoft sur Windows 10/11
1. Sur une machine de test, il est conseillé de partir sur un *Microsoft store* vierge.
1. Cliquer sur le bouton **Démarrer** de Windows 10/11 et taper **Store**
1. Cliquer sur le raccourci **"Microsoft Store"**
---
**Nota :** Le service Windows Update doit être activé et démarré pour utiliser le *Microsoft Store*

---
4. Cliquer sur le bouton **Sign in** (en haut de l'application Microsoft Store, avec une image d'utilisateur) et cliquer sur **Sign in**
1. Saisir le nom de l'utilisateur à utiliser pour cet atelier (n'importe quel compte Microsoft fera l'affaire) et cliquer sur **Next**.
1. Saisir le mot de passe du compte saisi et cliquer sur **Sign in**.
1. Sur la fenêtre **"Use this account everywhere on your device"**, cliquer sur **Microsoft apps only**.
1. dans le champ^**"Search apps, games, movies and more"**, taper **2fast**
1. Cliquer sur le lien **"2fast - Two factor authenticato[...]"**
1. Cliquer sur le bouton **Install**.
1. Attendre que l'application soit installée avant de poursuivre.
1. sur le **Microsoft Store**, sur la page **"2 fast - Two factor[...]"**, cliquer sur le bouton **Open**
1. Sur la page **Welcome**, cliquer sur le bouton **Create new datafile**.
1. Dans la fenêtre **Create datafile**, cliquer sur le bouton **Choose local path**.
1. Dans la fenêtre **Select Folder**, choisir n'importe quel dossier dans lequel vous souhaitez que l'application stocke sa configuration (par exemple le dossier **Documents**) et cliquer sur le bouton **Select Folder**
1. De retour sur la fenêtre **Create datafile**, saisir n'importe quelle valeur dans les champs **Filename** et **Password** avant de cliquer sur le bouton **Create datafile**.

### Task 2: Enable MFA for a user account
1. Launch your favorite Internet browser and log into either 365 or Azure portal wiht the user account you want to enable MFA for
1. On the portal webpage, click on the account information (picture/logo in the top-right corner) and click on the **View account** link.
---
**Note :** The user may access directly the **My Account** webpage by going to the **https://myaccount.microsoft.com** url.

---
3. Click on the **Security info** link.
1. On the **Security info** page, click on the **+ Add method** button.
1. On the **Add a method** window, select **"Authenticator app"** and clcik on the **Add** button.
1. On the **Microsoft Authenticator** window, click on the **I want to use a different authenticator app** link.
1. On the **Auhtenticator app** window, click on the **Next** button.
1. On the **Scan QR code** page, click on the **Can't scan image?** button.
1. Copy the "Account name" value in your clipboard.
1. Switch back to the **2fast** app window.
1. On the **Accounts** page, click on the *Add* **+** button on top.
1. On the **Input type** page, click on the **Manual key entry** button.
1. On the **Inputs** page, choose any label and ensure the **Manual key input** checkbox is selected.
1. Paste the account name in the **Account name** field (remove any character before the real user logon name).
1. Switch back to your Internet browser and copy the **Secret key** value to your clipboard.
1. Switch back to the **2fast** app window and paste the secret key in the **Secret key** field.
1. Click on the **Create account** button.
1. Copy the 6 digits code showed in the **2fast** app.
1. Switch back to your Internet browser and click on the **Next** button.
1. On the **Enter code** page, paste the 6 digits code and click **Next** (if the code/session is out of date, repeat the 2 previous steps).

**Results** : You may now use the **2fast** app to generate 6 digit codes to login with the user you just setup.

## Exercise 2: Disable MFA for the user

### Task 1: Install a Windows 10/11 Store Application
1. Launch your favorite Internet browser and log into either 365 or Azure portal wiht the user account you want to enable MFA for
1. On the portal webpage, click on the account information (picture/logo in the top-right corner) and click on the **View account** link.
---
**Note :** The user may access directly the **My Account** webpage by going to the *https://myaccount.microsoft.com** url.

---
3. Click on the **Security info** link.
4. If needed use the 6 digits code from the **2fast** app to verify your MFA logon.
5. On the **Security info** page, click on the **Delete** link on the line matching the **"Authenticator app"**
6. Confirm your choice by clicking on the **Ok** button.
---
**Note :** Since we are on a test/lab environment, there is no readon to delete the account information in the **2fast** application...

---

**Results** : You have now removed the MFA information form the user account.
