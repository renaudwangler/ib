#########################################
# Script lançé à l'import du module ib #
#########################################
Write-Warning "Les commandes du module 'ib' ne sont pas prévues pour être utilisées en dehors de notre environnement de formation..."
#Correction de la publication de module sur Powershell Gallery depuis Windows non US (utile au 25/07/2023)
$Profilepowershellget = "$env:userprofile\AppData\Local\Microsoft\Windows\PowerShell\PowerShellGet\"
if(-Not(Test-Path $Profilepowershellget)){New-Item $Profilepowershellget -ItemType Directory}
$Url = 'https://dist.nuget.org/win-x86-commandline/v5.1.0/nuget.exe'
$OutputFile =  "$Profilepowershellget\nuget.exe"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($Url, $OutputFile)
Unblock-File $OutputFile 