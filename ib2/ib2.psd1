#
# Manifeste de module pour le module "PSGet_ib2"
#
# Généré par : Wangler
#
# Généré le : 06/07/2023
#

@{

# Module de script ou fichier de module binaire associé à ce manifeste
RootModule = 'ib2.psm1'

# Numéro de version de ce module.
ModuleVersion = '0.1'

# éditions PS prises en charge
# CompatiblePSEditions = @()

GUID = '710f9ad8-405c-421d-ab45-d97f9974da59'
Author = 'Wangler'
CompanyName = 'ib'
Copyright = '(c) 2023 ib. Tous droits réservés.'
Description = 'Simplification des actions en salle de formation'
PowerShellVersion = '5.0'
FunctionsToExport = 'get-ibComputers'
CmdletsToExport = @()
AliasesToExport = 'ibComputers'
FileList = ''

# Données privées à transmettre au module spécifié dans RootModule/ModuleToProcess.
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
        ReleaseNotes = '0.1'
    }
 }
}

