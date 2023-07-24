@{

RootModule = 'ib2.psm1'
ModuleVersion = '0.2'
GUID = '710f9ad8-405c-421d-ab45-d97f9974da59'
Author = 'Wangler'
CompanyName = 'ib'
Copyright = '(c) 2023 ib. Tous droits rÃ©servÃ©s.'
Description = 'Simplification des actions en salle de formation'
PowerShellVersion = '5.0'
ScriptsToProcess = '.\moduleImport.ps1'
FunctionsToExport = 'get-ibComputers','invoke-ibNetCommand','set-ibMute'
CmdletsToExport = @()
AliasesToExport = 'ibComputers'
FileList = ''
PrivateData = @{
    PSData = @{
        Tags = 'ib'
        LicenseUri = 'https://github.com/renaudwangler/ib'
        ProjectUri = 'https://github.com/renaudwangler/ib'
        # IconUri = ''
        ReleaseNotes = '0.2'
    }
 }
}