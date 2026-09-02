# learnExport

**learnExport** est un module PowerShell permettant d'exporter des cours Microsoft Learn au format Markdown, EPUB et PDF.

L'objectif principal du projet est de faciliter la consultation hors ligne des contenus Learn et de fournir aux formateurs un support de lecture consolidé à partir d'un cursus Microsoft Learn.

## Fonctionnalités

- Export d'un cursus Microsoft Learn complet
- Génération d'un document Markdown consolidé
- Génération d'un fichier EPUB
- Génération d'un fichier PDF
- Téléchargement automatique des illustrations publiques
- Enrichissement des Knowledge Checks lorsque les sources sont accessibles
- Installation automatique des dépendances nécessaires

## Prérequis

Aucun prérequis particulier.

Lors de la première exécution, le module vérifie la présence des outils suivants et les installe automatiquement si nécessaire :

- Git
- Python 3
- Pandoc
- MiKTeX (XeLaTeX)
    - XeLaTeX va probablement demander de nombreuses confirmation lors de l'installation et la première utilisation.

## Installation

Depuis la PowerShell Gallery :

```powershell
Install-Module learnExport -Scope CurrentUser
```