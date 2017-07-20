#
# Manifeste de module pour le module ��PSGet_ib1��
#
# G�n�r� par�: renaud.wangler
#
# G�n�r� le�: 19/07/2017
#

@{

# Module de script ou fichier de module binaire associ� � ce manifeste
RootModule = 'ib1.psm1'

# Num�ro de version de ce module.
ModuleVersion = '1.0.1.2'

# ID utilis� pour identifier de mani�re unique ce module
GUID = '369b9a24-09ce-4df3-840f-80315b499bd4'

# Auteur de ce module
Author = 'renaud.wangler'

# Soci�t� ou fournisseur de ce module
CompanyName = 'ib'

# D�claration de copyright pour ce module
Copyright = '(c) 2017 ib. Tous droits r�serv�s.'

# Description de la fonctionnalit� fournie par ce module
Description = 'Commandes pour installation et gestion des machines de stages ib.
Utiliser get-command -module ib1 pour la liste des commandes impl�ment�es.'

# Version minimale du moteur Windows PowerShell requise par ce module
PowerShellVersion = '3.0'

# Nom de l'h�te Windows PowerShell requis par ce module
# PowerShellHostName = ''

# Version minimale de l'h�te Windows PowerShell requise par ce module
# PowerShellHostVersion = ''

# Version minimale du Microsoft .NET Framework requise par ce module
# DotNetFrameworkVersion = ''

# Version minimale de l'environnement CLR (Common Language Runtime) requise par ce module
# CLRVersion = ''

# Architecture de processeur (None, X86, Amd64) requise par ce module
# ProcessorArchitecture = ''

# Modules qui doivent �tre import�s dans l'environnement global pr�alablement � l'importation de ce module
# RequiredModules = @()

# Assemblys qui doivent �tre charg�s pr�alablement � l'importation de ce module
# RequiredAssemblies = @()

# Fichiers de script (.ps1) ex�cut�s dans l�environnement de l�appelant pr�alablement � l�importation de ce module
# ScriptsToProcess = @()

# Fichiers de types (.ps1xml) � charger lors de l'importation de ce module
# TypesToProcess = @()

# Fichiers de format (.ps1xml) � charger lors de l'importation de ce module
# FormatsToProcess = @()

# Modules � importer en tant que modules imbriqu�s du module sp�cifi� dans RootModule/ModuleToProcess
# NestedModules = @()

# Fonctions � exporter � partir de ce module
FunctionsToExport = '*'

# Applets de commande � exporter � partir de ce module
# CmdletsToExport = @()

# Variables � exporter � partir de ce module
VariablesToExport = '*'

# Alias � exporter � partir de ce module
# AliasesToExport = @()

# Liste de tous les modules empaquet�s avec ce module
# ModuleList = @()

# Liste de tous les fichiers empaquet�s avec ce module
# FileList = @()

# Donn�es priv�es � transmettre au module sp�cifi� dans RootModule/ModuleToProcess
# PrivateData = ''
PrivateData = @{ 

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # External dependent modules of this module
        # ExternalModuleDependencies = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

# URI HelpInfo de ce module
# HelpInfoURI = ''

# Le pr�fixe par d�faut des commandes a �t� export� � partir de ce module. Remplacez le pr�fixe par d�faut � l�aide d�Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
