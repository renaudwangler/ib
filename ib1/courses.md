#[Attention] les commentaires dans ce fichier ne doivent pas comporter d'espace après le #
# m20411d
La machine "**MSL-TMG1**" partagera un accès Internet sur le vSwitch "*Private Network*" si elle est démarrée.

# m20742b
## Atelier 12
Afin de donner accès Internet aux machines virtuelles, il faudra s'assurer de démarrer la machine "**MT17B-WS2016-NAT**".
Il pourra s'avérer pertinent de vérifier que cette machine possède une carte réseau branchée sur le switch "*Internal Network*" et une autre sur le switch "*External Network*".
Le switch "*External Network*" doit être banché sur la carte réseau physique donnant accès à Internet depuis le "Virtual Switch Manager".
La commande ```set-ib1VMExternalMac``` corrigera la configuration sur un hôte Hyper-V en Windows 10.

# m20741b
## Atelier 10
Afin de réaliser l'atelier, il faudra lancer la commande suivante, pour redémarrer sur le disque VHD:
```mount-ib1VhdBoot -VHDfile "C:\Program Files\Microsoft Learning\Base\20741B-LON-HOST1.vhd" -restart```

**Attention:** La réalisation de cet atelier nécessite qu'au moins une carte réseau ethernet soit branchée (le wifi seul ne suffit pas).

Une fois la machine redémarrée sur lon-host1, lancer la commande ```ibSetup```
Cette commande (dont l'execution est un peu longue) va préparer l'atelier en
 - Réarmant les machines (reboot du host nécessaire ensuite)
 - Corrigeant la configuration réseau
 - Affectant la configuration IP pertinente au vSwitch "Private Network"
 - Créant une copie de chaque machine virtuelle
 - Corrigeant la configuration IP des machines virtuelles copiées

**Attention:** A l'issue de cette commande, ce sont les machines virtuelles suffixées "**-ib**" qui seront à utiliser pendant l'atelier.

# m20740c
## Atelier 5
Afin de réaliser l'atelier, il faudra lancer la commande suivante pour redémarrer sur le disque VHD:
```mount-ib1VhdBoot -VHDfile "C:\Program Files\Microsoft Learning\Base\20740C-LON-HOST1.vhd" -restart```

**Attention:** La réalisation de cet atelier nécessite qu'au moins une carte réseau ethernet soit branchée (le wifi seul ne suffit pas).

Une fois la machine redémarrée sur lon-host1, **avant la tâche 2 de l'exercice 4** lancer la commande ```ibSetup```
Cette commande (dont l'execution est un peu longue) va préparer l'atelier en
 - Réarmant les machines,
 - Passant le clavier en Français,
 - Créant une copie de chaque machine virtuelle,
 - Corrigeant la configuration IP des machines virtuelles copiées.

**Attention 1:** A l'issue de cette commande, ce sont les machines virtuelles suffixées "**-ib**" qui seront à utiliser pendant l'atelier.
**Attention 2:** Pour compléter la mise en place, il faudra se connecter sur la machine "NAT-ib", lancer l'outil "Routing and Remote Access", ouvrir "IPv4" et, ajouter les deux cartes avec leur rôle respectif sur le "NAT".
## Atelier 9
Afin de réaliser l'atelier, il faudra lancer la commande suivante pour redémarrer sur le disque VHD:
```mount-ib1VhdBoot -VHDfile "C:\Program Files\Microsoft Learning\Base\20740C-LON-HOST2.vhd" -restart```

**Attention:** La réalisation de cet atelier nécessite qu'au moins une carte réseau ethernet soit branchée (le wifi seul ne suffit pas).

Une fois la machine redémarrée sur lon-host1, **après le point 6 de la tâche 1 de l'exercice 1** lancer la commande ```ibSetup ##course##```
Cette commande (dont l'execution est un peu longue) va préparer l'atelier en
 - Réarmant les machines,
 - Passant le clavier en Français,
 - Créant une copie de chaque machine virtuelle,
 - Corrigeant la configuration IP des machines virtuelles copiées.

**Attention:** A l'issue de cette commande, ce sont les machines virtuelles suffixées "**-ib**" qui seront à utiliser pendant l'atelier.

# goDeploy
Un raccourci "**Ateliers en ligne**" a été placé sur le bureau qui renvoie vers l'environement d'ateliers en ligne "goDeploy"

# msms100
Un dossier "**Ateliers MSMS100**" a été placé sur le bureau qui contient :
 - Un lien vers l'environement d'ateliers en ligne "goDeploy"
 - Un lien vers le portail principal d'Office 365
 - Un lien vers le portail d'administration de Microsoft 365

# msms101
Un dossier "**Ateliers MSMS101**" a été placé sur le bureau qui contient :
 - Un lien vers l'environement d'ateliers en ligne "goDeploy"
 - Un lien vers le portail principal d'Office 365
 - Un lien vers le portail d'administration de Microsoft 365

# msms200
Un dossier "**Ateliers MSMS200**" a été placé sur le bureau qui contient :
 - Un lien vers l'environement d'ateliers en ligne "goDeploy"
 - Un lien vers le portail principal d'Office 365
 - Un lien vers le portail d'administration de Microsoft 365

# msms300
Un dossier "**Ateliers MSMS300**" a été placé sur le bureau qui contient :
 - Un lien vers l'environement d'ateliers en ligne "goDeploy"
 - Un lien vers le portail principal d'Office 365
 - Un lien vers le portail d'administration de Microsoft 365

# msms500
Un dossier "**Ateliers MSMS500**" a été placé sur le bureau qui contient :
 - Un lien vers l'environement d'ateliers en ligne "goDeploy"
 - Un lien vers le portail principal d'Office 365
 - Un lien vers le portail d'administration de Microsoft 365

# m10979
Un raccourci "**Ateliers stage m10979**" a été placé sur le bureau vers les instructions d'ateliers.

# msaz900
Un dossier "**Manipulations MSAZ900**" a été placé sur le bureau qui contient :
 - Un lien vers la création de compte Azure gratuit
 - Un lien vers la création de Pass Azure (nommé " Azure - Validation pass")
 - Un lien vers le portail Azure
 - Un lien vers le Cloud Shell Azure

Le module **AZ** a été installé dans le Powershell de la machine (ainsi que le Framework .Net 4.8).

# msaz103
Un dossier "**Ateliers MSAZ103**" a été placé sur le bureau qui contient :
 - Les fichiers nécessaires pour réaliser les ateliers (nommés AZ-100.x / AZ-101.x)
 - Un lien vers la création de Pass Azure (nommé " Azure - Validation pass")
 - Un lien vers le portail Azure
 - Un lien vers le Cloud Shell Azure
 - Un lien vers les instructions en ligne pour les divers ateliers.
 Le module **AZ** a été installé dans le Powershell de la machine (ainsi que le Framework .Net 4.8).

# msaz300
Un dossier "**Ateliers MSAZ300**" a été placé sur le bureau qui contient :
 - Les fichiers nécessaires pour réaliser les ateliers
 - Un lien vers la création de Pass Azure (nommé " Azure - Validation pass")
 - Un lien vers le portail Azure
 - Un lien vers le Cloud Shell Azure
 - Un lien vers les instructions en ligne pour les divers ateliers.
 Le module **AZ** a été installé dans le Powershell de la machine (ainsi que le Framework .Net 4.8).

# msaz301
Un dossier "**Ateliers MSAZ301**" a été placé sur le bureau qui contient :
 - Les fichiers nécessaires pour réaliser les ateliers
 - Un lien vers la création de Pass Azure (nommé " Azure - Validation pass")
 - Un lien vers le portail Azure
 - Un lien vers le Cloud Shell Azure
 - Un lien vers les instructions en ligne pour les divers ateliers.
 Le module **AZ** a été installé dans le Powershell de la machine (ainsi que le Framework .Net 4.8).
 L'éditeur Visual Studio Code a été installé dans sa dernière version.

# intro
<!DOCTYPE html><html><head><title>##course##</title><style>body {padding:10px;color:gray;font-family:tahoma;}h1,h2{color:#EA690B;text-decoration:underline;margin:0em;}h2{margin-top:1em;margin-bottom:0.5em;}li{list-style:none;}li::before{color:#EA690B;content:"\2022";font-size:1em;padding-right:0.7em;}code{border:solid 1px darkgrey;padding:3px;margin:2px;margin-bottom:0px;background-color:lightgrey;display:inline-block;color:black;}strong {font-weight:bold;color:black;}hr {margin:2em;}</style></head><body><h1>Bienvenue !</h1>
Voici quelques petits conseils afin d'améliorer le déroulement du stage ##course##.

Le module powershell **ib1** a été installé sur la machine et contient des commandes qui peuvent automatiser et faciliter certaines actions pendant la formation.
Ainsi, à titre d'exemple, la commande ```reset-ib1VM``` lancera la rétablissement successif de toutes les machines virtuelles trouvées sur l'hyperviseur local.
*(Toutes les commandes du module sont documentées mais ne sont pas supportées en dehors de notre environnement d'atelier.)*
# outro
Le service technique ***ib*** est à votre disposition pour tout assistance pendant la durée de la formation.
</body></html>

# Fin