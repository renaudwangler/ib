﻿# Manifeste de module pour le module « ib2 »
# Généré par : Renaud
# Généré le : 19/07/2024

@{

RootModule = 'ib2.psm1'
ModuleVersion = '2.11.6'
GUID = '8afa264f-71b6-4f7c-b16b-36463742660c'
Author = 'Renaud WANGLER'
CompanyName = 'ib'
Copyright = '(c) 2024 ib. Tous droits réservés.'
Description = 'Simplification des actions en salle de formation'
PowerShellVersion = '5.0'
ScriptsToProcess = @('.\moduleImport.ps1')
FunctionsToExport = @(
'get-ibComputers',
'invoke-ibNetCommand',
'invoke-ibMute',
'stop-ibNet',
'new-ibTeamsShortcut',
'get-ibComputerInfo',
'optimize-ibComputer',
'get-ibPassword',
'wait-ibNetwork',
'write-ibLog',
'get-ibLog')
CmdletsToExport = @()
VariablesToExport = '*'
AliasesToExport = @('oic','optib')
FileList = @('svcl.exe')
PrivateData = @{
    PSData = @{
         Tags = @()
         LicenseUri = 'https://www.powershellgallery.com/policies/Terms'
         ProjectUri = 'https://github.com/renaudwangler/ib'
         # URL vers une icône représentant ce module.
         # IconUri = ''
    }}}