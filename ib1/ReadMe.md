# Module powershell ib1

Pour installer, sur machine antérieure à Windows Server 2016/Windows 10,
télécharger et installer http://go.microsoft.com/fwlink/?LinkID=746217&clcid=0x409

Puis dans une commande powershell (En administrateur, avec executionPolicy en "ByPass") : ```install-module ib1 -force```

**Attention:** Pour que le changement de clavier fonctionne, il faudra installer la dernière version de DISM sur la machine hôte dans le répertoire par défaut (C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM)
*(Installation ici: https://msdn.microsoft.com/en-us/windows/hardware/dn913721(v=vs.8.5).aspx)*.

Commandes (et alias) contenues dans le module en version 2.1 (se référer à l'aide de chaque commande pour le détail des paramètres):
- Reset-ib1VM (ibReset)
- Mount-ib1VhdBoot
- Remove-ib1VhdBoot
- Switch-ib1VMFr
- Copy-ib1VM
- complete-ib1Install
- Set-ib1TSSecondScreen
- Import-ib1trustedCertificate
- Test-ib1VMNet
- Connect-ib1VMNet
- Set-ib1VMCheckpointType
- Repair-ib1VMNetwork
- Start-ib1SavedVMs
- New-ib1Shortcut
- invoke-ib1NetCommand
- new-ib1Nat
- invoke-ib1Clean
- invoke-ib1Rearm
- get-ib1Repo
- set-ib1VMExternalMac
- install-ib1Course (ibsetup)
- set-ib1ChromeLang
- set-ib1VMCusto
- invoke-ib1TechnicalSupport