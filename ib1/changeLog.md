**Version 2.5.8:**
 - Accompagnement Pédagogique et Technique des Stages accessible depuis https://renaudwangler.github.io/ib/
 - Corrections master0 + master1

**Version 2.5.4:**
 - Nouvelle commande **invoke-ib1TechnicalSupport** (allias *stc*)
 - Préparation du sysprep dans **ibSetup**
 - Correction chemin xml pour sysprep
 - Mise en place de l'action "shutdown" sur bouton power dans complete-ib1Setup

**Version 2.5:**
 - Suppression du dossier c:\dell de drivers dans les divers commandes
 - Préparation/correction de la procédure sysyprep
 - Préparation des DAPTS

**Version 2.4.3:**
 - Correction installation de Chrome
 - Modification accès au bureau public (suite à chanegment comportement dernière version de Windows 10)
 - Désactivation *complète* de l'UAC dans la commande "**complete-ib1setup**"

**Version 2.4.2:**
 - Correction du .psd (suppression allias complete-ib1Setup)
 - Passage du partage formateur en écriture
 
**Version 2.4.1:**
 - Correction de la commande new-ib1taskbarSHortcut
 - Suppression de l'alias historique "**complete-ib1Install**"

**Version 2.4:**
 - Première évolution de la commande complete-ib1Install pour nouveau master

**Version 2.3.4:**
 - Correction du readme.html pour stage m20740c
 - suppression de résidus de log en mode fichier
 - suppression de l'installation de la liseuse Skillpipe de la commande complete-ib1install

**Version 2.3.3:**
 - Ajout du stage msaz103
 - Ajout d'une option *-noCourse* à la commande *install-ib1course*

**Version 2.3.2:**
 - Ajout du passage du switch en "privé" si switch existant dans la commande "**connect-ib1VMNet**" pour éviter problème sur switch interne
 - Ajout du stage m20411d à la commande ibSetup
 - Correction de la détection des stages dans l'import du module

**Version 2.3.1:**
 - Passage du journal du module en log dans l'observateur d'évènements.
 - Nouvelle option '*-trainer*' dans la commande '**ibSetup**' pour ne pas copier les présentations Powerpoint si ce n'est pas utile

**Version 2.3:**
 - Nouvelle commande new-ib1TaskBarShortcut
 - Mise en silencieux (mute) du poste dans "ibSetup"
 - Amélioration de enable-ib1Office : lancement de Powerpoint une 1ère fois avant activation

**Version 2.2.3:**
 - Amélioration du raccourci "*Windows Powershell*" sur le bureau
 - Ajout de la supression de la mise en veille à chaque lancement de ibSetup

**Version 2.2.1:**
 - Correction mise en place du stage m20742
 - Changement de principe pour commande ib1Setup :
     possibilité de remplir le fichier courses.md *sans remplir* le fichier courses.ps1
 - Suppression du stage m20533

**Version 2.2:**
 - Utilisation de la déclaration du module pour lancer un script à l'import
 - Repèrage de certains stages MS depuis la présence de VMs spécifiques
 - Utilisation de variables système pour divers objectifs

**Version 2.1.1:**
 - Remplacement de "install-ib1Course" par son alias "ibSetup" dans l'aide de courses.md
 - correction de l'alias ibSetup

**Version 2.1:**
 - Sortie des éléments complémentaires (dossier "extra") du dossier du module.
 - Allias "ibsetup" pour la commande "install-ib1Course"
 - Correction message d'erreur sur attente de réseau IP d'une carte
 - Information de nécessité de branchement filaire pour les descriptifs des stages m20740c et m20741b

**Version 2.0.:**
 - Refonte du module avec utilisation de fichiers externes pour la customisation des stages

**Version 1.12.1:**
 - Ajout du stage m20741b à la commande install-ib1Course
 - Simplification=Suppression de la compatibilité de certaines commande avec Powershell 4.x devenue inutile

**Version 1.12:**
 - Modification de la version de la présentation stagiaires.

**Version 1.11.7:**
 - Ajout de la copie de la présentation ib dans install-ib1course

**Version 1.11.6:**
 - Correction de bugs

**Version 1.11.5:**
 - Création de la commande set-ib1VMCusto
 - Réaménagement de l'installation du stage m20740c avec la commande précédente

**Version 1.11.4:**
 - Aménagement de la fonction d'activation de Office
 - Aménagement de la fontion de changement de langue de Chrome
 - Gestion des VMs copiées pour les stage m20740c

**Version 1.11.3:**
 - Correction de bug sur install ms100

**Version 1.11.2:**
 - Ajout des installations des stages msaz900 et ms100

**Version 1.11.1:**
 - Correction nom de machine virtuelle pour installation des stages m10979 et m20533

**Version 1.11:**
 - Nouvelle commande set-ib1ChromeLang pour la langue dans le navigateur
 - Changement des installations des stages msaz100 et msaz101 avec nouveau format
 - activation de Office dans la commande install-ib1Course
 - Ajout du tour de table dans les intros des stages msaz100 et msaz101
 - Ajout de diapos sur "Azure Automation" en extra pour msaz100

**Version 1.10.2:**
 - Remplacement de l'option "-course" de la commande get-ib1repo par la nouvelle commande "install-ib1Course"
 - Amélioration du script d'installation des stages msaz100 et msaz101
 - Ajout de raccourcis vers les portails utiles pour les stages msaz100 et msaz101

**Version 1.10.1:**
 - refonte de la commande get-ib1Repo pour gérer diverses sortes d'actions lors de préparation des stages, prête pour les stages m20533, m10979, msAZ100 et msAZ101
 - Suppression de la création du réseau virtuel "ib1Nat" dans l'installation du master

**Version 1.9.1:**
 - Changement du téléchargement de get-ib1repo pour passer par DL web standard
 - Ajout de la création du raccourci web vers les instructions d'atelier dans get-ib1repo
 - Mise à jour du lecteur (E: vers F:) pour get-ib1repo -course m20533

**Version 1.9:**
 - Nouvelle commande set-ib1VMExternalMac
 - Ajout du vidage des corbeilles à la comande invoke-ib1clean

**Version 1.8.2:**
 - Suppression du message d'erreur sur dossier déja existant dans la commande "get-ib1repo"
 - Suppression du paramètre userPass dans la commande "repair-ib1VmNet"

**Version 1.8.1:**
 - Correction/modification de comportement de l'option -First de la commande start-ib1SavedVMs

**Version 1.8:**
 - Nouvelle commande get-ib1Repo pour télécharger localement le contenu d'un repo Git

**Version 1.7.3:**
 - La commande invoke-ib1Clean nettoie désormais l'hisorique/cache de Internet Explorer et Chrome

**Version 1.7.2:**
 - La commande complete-ib1Setup n'ajoute plus de raccourci vers \\pc-formateur\partage s'il existe déja !

**Version 1.7.1:**
 - Ajout du rearm de la machine locale pour la commande invoke-ib1rearm

**Version 1.7:**
 - Correction des commandes invoke-ib1NetCommand invoke-ib1Stop et invoke-ib1Clean
 - Nouvelle commande invoke-ib1Rearm pour réarmer les OS Windows d'une salle

**Version 1.6.2:**
 - Correction de la commande stop-ib1Classroom pour l'extinction de la machine locale en dernier.
 - Corrections de la commande new-ib1Nat pour tester nom exact du vSwitch (et pas un nom contenant le paramètre passé)

**Version 1.6.1:**
 - Correction de l'option -noLocal de la commande invoke-ib1NetCommand
 - Correction de la commande invoke-ib1Clean pour effectuer la suppression.

**Version 1.6:**
 - Ajout de la commande invoke-ib1Clean
 - Ajout de l'option -exactVMName pour les commandes set-ib1VMCheckpointType, reset-ib1VM, switch-ib1VMFr, copy-ib1VM, repair-ib1VMNetwork
 - Prise en compte du cas ou la carte réseau est branchée sur un vSwitch externe pour les commandes -invoke-ib1Command et invoke-ib1Clean

**Version 1.5.2:**
 - Correction installation lecteur Skillpipe
 - Correction commande 'new-ib1Nat' pour switch existant non interne.

**Version 1.5:**
 - Nouvelle commande 'new-ib1Nat' pour créer/configurer le réseau NAT

**Version 1.4.4:**
 - Correction du paramètre '-First' de la commande 'start-ib1SavedVMs' pour filtrer le cas de plusieurs VM aux noms correspondant.
 - Ajout de changement de registre pour la commande 'switch-ib1VMfr'.
 - Suppression de la déclaration des 'TrustedHosts' pour la commande 'complete-ib1Setup'
 - Désactivation des services BITS et DoSVC dans la commande 'complete-ib1Setup'

**Version 1.4.3:**
- Correction du chemin du module ib1 pour "mount-ib1VHDBoot"
- Ajout d'une clef de registre "Run" dans "mount-ib1VHDBoot"

**Version 1.4.2:**
- Nouvelle commande "stop-ib1ClassRoom" pour arrêter toutes les machines du réseau local.
- Correction de l'insertion du module ib1 dans le disque virtuelle lors de la commande "mount-ib1VHDBoot" pour compatibilité versions < w10/2016.
- Ajout de la version du module dans le log de lancement

**Version 1.4.1:**
- Remplacement des ">>$null" par des "|out-null"
- Suppression des valeurs "$false" par défaut pour les paramètres de type "switch"
- Remplacement du redémarrage de WinRm par "enable-psRemoting" en le changeant de place
- Changement de la commande "get-ib1NetComputers" pour simplifier avec tableau associatif
- Sauvegarde des "TrustedHosts" pour les remettre en place après action
- Passage des réseau de la machine en "Privé" à chaque redémarrage après la commande "complete-ib1Install"

**Version 1.4:**
- Moteur de log du module (commande interne "write-ib1Log").
- Nouvelle commande pour afficher le log "get-ib1Log"
- Changement général du paramètre "-vmName" pour accepter des fragements de noms de VMs.
- Changement de syntaxe de "switch-ib1vmFR" : remplacement du paramètre "-noCheckpoint" par le paramètre "-Checkpoint"
- Ajout des paramètres "-subnet", "-Gateway" et "-getCred" à la commande "invoke-ib1NetCommand"
- Optimisation radicale de la commande "invoke-ib1NetCommand" en passant par des jobs Powershell
- Nouvelle commande "get-ib1Version"
- Installation du module ib1 dans le VHD lors du "mount-ib1VHDBoot"
- Désactivation de la session étendue sur Hyper-V avec "complete-ib1Setup" (pb groupe RDP)
- Test de disponibilité de Powershell Direct dans la commande "repair-ib1VMNetwork"
- Commande "connect-ib1VMNet" marquée comme obsolète.
- Utilisation des Notes des VMs pour tracer les actions du module.
