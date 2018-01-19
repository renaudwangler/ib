#
# Module manifest for module 'PSGet_ib1'
#
# Generated by: Wangler
#
# Generated on: 19/01/2018
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'ib1.psm1'

# Version number of this module.
ModuleVersion = '1.2.4'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '369b9a24-09ce-4df3-840f-80315b499bd4'

# Author of this module
Author = 'Wangler'

# Company or vendor of this module
CompanyName = 'ib'

# Copyright statement for this module
Copyright = '(c) 2017 ib. Tous droits r�serv�s.'

# Description of the functionality provided by this module
Description = 'Simplification des installations'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'complete-ib1Install', 'invoke-ib1NetCommand', 'new-ib1Shortcut', 
               'reset-ib1VM', 'mount-ib1VhdBoot', 'remove-ib1VhdBoot', 
               'switch-ib1VMFr', 'test-ib1VMNet', 'connect-ib1VMNet', 
               'set-ib1TSSecondScreen', 'import-ib1TrustedCertificate', 
               'set-ib1VMCheckpointType', 'repair-ib1VMNetwork', 'Copy-ib1VM', 
               'start-ib1SavedVMs'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
# VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = 'set-ib1VhdBoot', 'ibreset', 'complete-ib1Setup'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
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
        ReleaseNotes = '1.0.13'

        # External dependent modules of this module
        # ExternalModuleDependencies = ''

    } # End of PSData hashtable
    
 } # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

