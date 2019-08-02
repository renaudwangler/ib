#
# Manifeste de module pour le module « PSGet_ib1 »
#
# Généré par : Wangler
#
# Généré le : 02/08/2019
#

@{

# Module de script ou fichier de module binaire associé à ce manifeste
RootModule = 'ib1.psm1'

# Numéro de version de ce module.
ModuleVersion = '2.5.20'

# Éditions PS prises en charge
# CompatiblePSEditions = @()

# ID utilisé pour identifier de manière unique ce module
GUID = '369b9a24-09ce-4df3-840f-80315b499bd4'

# Auteur de ce module
Author = 'Wangler'

# Société ou fournisseur de ce module
CompanyName = 'ib'

# Déclaration de copyright pour ce module
Copyright = '(c) 2018 ib. Tous droits réservés.'

# Description de la fonctionnalité fournie par ce module
Description = 'Simplification des installations'

# Version minimale du moteur Windows PowerShell requise par ce module
PowerShellVersion = '5.0'

# Nom de l'hôte Windows PowerShell requis par ce module
# PowerShellHostName = ''

# Version minimale de l'hôte Windows PowerShell requise par ce module
# PowerShellHostVersion = ''

# Version minimale du Microsoft .NET Framework requise par ce module. Cette configuration requise est valide uniquement pour PowerShell Desktop Edition.
# DotNetFrameworkVersion = ''

# Version minimale de l’environnement CLR (Common Language Runtime) requise par ce module. Cette configuration requise est valide uniquement pour PowerShell Desktop Edition.
# CLRVersion = ''

# Architecture de processeur (None, X86, Amd64) requise par ce module
# ProcessorArchitecture = ''

# Modules qui doivent être importés dans l'environnement global préalablement à l'importation de ce module
# RequiredModules = @()

# Assemblys qui doivent être chargés préalablement à l'importation de ce module
# RequiredAssemblies = @()

# Fichiers de script (.ps1) exécutés dans l’environnement de l’appelant préalablement à l’importation de ce module
ScriptsToProcess = '.\moduleImport.ps1'

# Fichiers de types (.ps1xml) à charger lors de l'importation de ce module
# TypesToProcess = @()

# Fichiers de format (.ps1xml) à charger lors de l'importation de ce module
# FormatsToProcess = @()

# Modules à importer en tant que modules imbriqués du module spécifié dans RootModule/ModuleToProcess
# NestedModules = @()

# Fonctions à exporter à partir de ce module. Pour de meilleures performances, n’utilisez pas de caractères génériques et ne supprimez pas l’entrée. Utilisez un tableau vide si vous n’avez aucune fonction à exporter.
FunctionsToExport = 'install-ib1Chrome', 'complete-ib1Setup', 'invoke-ib1NetCommand', 
               'new-ib1Shortcut', 'reset-ib1VM', 'mount-ib1VhdBoot', 
               'remove-ib1VhdBoot', 'switch-ib1VMFr', 'test-ib1VMNet', 
               'connect-ib1VMNet', 'set-ib1TSSecondScreen', 
               'import-ib1TrustedCertificate', 'set-ib1VMCheckpointType', 
               'repair-ib1VMNetwork', 'Copy-ib1VM', 'start-ib1SavedVMs', 'get-ib1Log', 
               'get-ib1Version', 'stop-ib1ClassRoom', 'new-ib1Nat', 'invoke-ib1Clean', 
               'invoke-ib1Rearm', 'get-ib1Repo', 'set-ib1VMExternalMac', 
               'install-ib1Course', 'set-ib1ChromeLang', 'set-ib1VMCusto', 
               'invoke-ib1TechnicalSupport'

# Applets de commande à exporter à partir de ce module. Pour de meilleures performances, n’utilisez pas de caractères génériques et ne supprimez pas l’entrée. Utilisez un tableau vide si vous n’avez aucune applet de commande à exporter.
CmdletsToExport = @()

# Variables à exporter à partir de ce module
# VariablesToExport = @()

# Alias à exporter à partir de ce module. Pour de meilleures performances, n’utilisez pas de caractères génériques et ne supprimez pas l’entrée. Utilisez un tableau vide si vous n’avez aucun alias à exporter.
AliasesToExport = 'set-ib1VhdBoot', 'ibreset', 'get-ib1Git', 'ibSetup', 'stc', 'ibStop'

# Ressources DSC à exporter depuis ce module
# DscResourcesToExport = @()

# Liste de tous les modules empaquetés avec ce module
# ModuleList = @()

# Liste de tous les fichiers empaquetés avec ce module
FileList = 'ibInit.ps1'

# Données privées à transmettre au module spécifié dans RootModule/ModuleToProcess. Cela peut également inclure une table de hachage PSData avec des métadonnées de modules supplémentaires utilisées par PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'ib'

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/renaudwangler/ib'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/renaudwangler/ib'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = '2.3.2'

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

 } # End of PrivateData hashtable

# URI HelpInfo de ce module
# HelpInfoURI = ''

# Le préfixe par défaut des commandes a été exporté à partir de ce module. Remplacez le préfixe par défaut à l’aide d’Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

