# Contexte

Nous avons construit un module Powershell learnExport exposant une unique commande : Export-ibCourse
Cette commande s'appuie actuellement sur un moteur Python (export-course.py) qui :

- récupère le contenu Microsoft Learn ;
- télécharge les images ;
- récupère et enrichit les Knowledge Checks ;
- construit le Markdown ;
- génère l'EPUB ;
- génère le PDF.

L'outil est fonctionnel et répond au besoin initial :

- sauvegarde hors ligne des cours Learn ;
- lecture sur liseuse (EPUB) ;
- impression et annotation (PDF) ;
- conservation d'une copie pérenne du contenu.

# Objectif réel

L'objectif n'est pas pédagogique.
L'objectif est de réduire progressivement la dépendance au Python, car :

- le mainteneur du projet maîtrise bien PowerShell ;
- le mainteneur du projet maîtrise peu Python ;
- la maintenance future sera plus facile si la majorité du code est en PowerShell.

La migration doit cependant :

- conserver un outil fonctionnel à chaque étape ;
- éviter les réécritures massives ;
- ne pas dégrader la fiabilité du scraping Learn.

# Principe général

Ne pas chercher à tout réécrire immédiatement.

Approche retenue :

Migration incrémentale ==> Conserver un noyau Python fonctionnel ==> Déplacer progressivement les responsabilités vers PowerShell

# Priorités de migration
## V1 - Déplacer les responsabilités système

Objectif : PowerShell orchestre et Python convertit Learn en Markdown

Migrer vers PowerShell :

- génération EPUB ;
- génération PDF ;
- création des dossiers ;
- gestion des chemins ;
- gestion des paramètres ;
- orchestration générale.

Python conserve :

- récupération Learn ;
- images ;
- Knowledge Checks ;
- génération Markdown.

## V2 - Migrer les Knowledge Checks
Migrer vers PowerShell : get_knowledge_check() et knowledge_check_to_markdown()
Remplacements : requests.get() ==> Invoke-RestMethod et yaml.safe_load() ==> ConvertFrom-Yaml
Résultat :

- suppression de la dépendance Python YAML ;
- logique plus lisible pour le mainteneur.

## V3 - Migrer la gestion des images
Migrer : download_image() et process_images() vers Invoke-WebRequest
Objectif :

- centraliser les téléchargements dans PowerShell ;
- réduire fortement l'utilisation de requests.

## V4 - Migrer les téléchargements HTML
Migrer : get_html() ==> Invoke-WebRequest
Le Python ne recevrait plus forcément des URLs mais directement du contenu HTML préparé par PowerShell.

## V5 - Réévaluer le noyau restant
À ce stade il devrait principalement rester : BeautifulSoup et Construction du Markdown
Deux options possibles :
### Conserver ce noyau Python.
Avantages :

- peu de code à maintenir ;
- BeautifulSoup reste très efficace.

### Migration complète vers PowerShell.
Cette étape ne sera décidée qu'après les V1 à V4.

# État actuel de la stratégie

## V1
EPUB/PDF
Dossiers
Paramètres
 
## V2
Knowledge Checks
 
## V3
Images
 
## V4
Téléchargements HTML
 
## V5
BeautifulSoup et/ou maintien du noyau Python