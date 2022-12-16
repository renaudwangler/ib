# Lab: Mise en place de la M.F.A avec une application Windows

**Scenario**
Dans cet atelier, vous allez utiliser une application sur un poste Windows 10/11 pour implémenter l'authentification multifactorielle. Cette mise en oeuvre pourrait, par exemple, être utilisée pour authentifier un utilisateur dans un environnement Azure-AD ou Microsoft 365.

Cet atelier inclut les tâches suivantes :
 - Activer la MFA pour un utilisateur
 - Désactiver la MFA pour un utilisateur

## Exercice 1 : Activer la MFA pour un utilisateur

### Tâche 1 : Installer une application du Store Microsoft sur Windows 10/11
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
1. Dans le champ **"Search apps, games, movies and more"**, taper **2fast**
1. Cliquer sur le lien **"2fast - Two factor authenticato[...]"**
1. Cliquer sur le bouton **Install**.
1. Attendre que l'application soit installée avant de poursuivre.
1. Sur le **Microsoft Store**, sur la page **"2 fast - Two factor[...]"**, cliquer sur le bouton **Open**
1. Sur la page **Welcome**, cliquer sur le bouton **Create new datafile**.
1. Dans la fenêtre **Create datafile**, cliquer sur le bouton **Choose local path**.
1. Dans la fenêtre **Select Folder**, choisir n'importe quel dossier dans lequel vous souhaitez que l'application stocke sa configuration (par exemple le dossier **Documents**) et cliquer sur le bouton **Select Folder**
1. De retour sur la fenêtre **Create datafile**, saisir n'importe quelle valeur dans les champs **Filename** et **Password** avant de cliquer sur le bouton **Create datafile**.

### Tâche 2 : Activer la MFA pour un compte utilisateur
1. Lancer un navigateur Internet et se connecter au portail Azure ou 365 avec le compte Azure AD sur lequel l'activation de la MFA est souhaitée.
1. Sur la page du portail, cliquer sur l'information du compte (image/logo dans le coinb en haut à droite de la page) et cliquer sur le lien **View account**.

---
**Nota :** Un utilisateur peut accéder directement à sa page **My Account** en utilisant le lien suivant : **https://myaccount.microsoft.com**.

---
3. Cliquer sur le lien **Security info**.
1. Sur la page **Security info**, cliquer sur le bouton **+ Add method**.
1. Dans la fenêtre **Add a method**, selectionner **"Authenticator app"** et cliquer sur le bouton **Add**.
1. Dans la fenêtre **Microsoft Authenticator**, cliquer sur le lien **I want to use a different authenticator app**.
1. Dans la fenêtre **Auhtenticator app**, cliquer sur le bouton **Next**.
1. Sur la page **Scan QR code** page, cliquer sur le bouton **Can't scan image?**.
1. Copier le "Account name" dans le presse-papier.
1. Retourner sur la fenêtre de l'application **2fast**.
1. Sur la page **Accounts**, cliquer sur le bouton *Add* **+** en haut.
1. Sur la page **Input type**, cliquer sur le bouton **Manual key entry**.
1. Sur la page **Inputs**, choisir n'importe quel label et vérifier que la case **Manual key input** est bien cochée.
1. Coller le nom de compte dans le champ **Account name** (enlever tout caractère présent avant le véritable nom de connexion de l'utilisateur).
1. Retourner dans le navigateur Internet et copier la valeur de la **Secret key** dans le presse-papier.
1. Retourner dans la fenêtre de l'application **2fast** et coller la clef secrète dans le champ **Secret key**.
1. Cliquer sur le bouton **Create account**.
1. Copier le code à 6 chiffres affiché dans l'application **2fast**.
1. Retourner dans le navigateur Internet et cliquer sur le bouton **Next**.
1. Sur la page **Enter code**, coller le code à 6 chiffres et cliquer sur **next** (si le code/session est périmé, répéter les 2 étapes précédentes).

**Résultat** : Vous pouvez désormais utiliser l'application **2fast** pour générer des codes à 6 chiffres pour la connexion de l'utilisateur concerné.

## Exercice 2 : Désactiver la MFA pour l'utilisateur

### Tâche 1 : Supprimer le lien à l'application
1. Lancer un navigateur Internet et se connecter au portail Azure ou 365 avec le compte Azure AD sur lequel l'activation de la MFA est souhaitée.
1. Sur la page du portail, cliquer sur l'information du compte (image/logo dans le coinb en haut à droite de la page) et cliquer sur le lien **View account**.

---
**Nota :** Un utilisateur peut accéder directement à sa page **My Account** en utilisant le lien suivant : **https://myaccount.microsoft.com**.

---
3. Cliquer sur le lien **Security info**.
1. Si nécessaire, utiliser le code à 6 chiffres généré par l'application **2fast** pour valider la connexion MFA.
1. Sur la page **Security Info**, cliquer sur le lien **Delete** présent sur la ligne correspondant à **"Authenticator app"**
1. Confirmer ce choix en cliquant sur le bouton **Ok**.
---
**Nota :** Vu que nous sommes dans un environnement de test/atelier, il n'y a aucune raison pour aller nettoyer les informations que nous avions entrées dans l'application **2fast**...

---

**Résultat** : Vous avez supprimé les informations MFA du compte utilisateur.
