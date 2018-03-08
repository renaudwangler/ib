**Version 1.4.1:**
-Remplacement des ">>$null" par des "|out-null"
-Suppression des valeurs "$false" par défaut pour les paramètres de type "switch"
-Remplacement du redémarrage de WinRm par "enable-psRemoting" en le changeant de place
-Changement de la commande "get-ib1NetComputers" pour simplifier avec tableau associatif
-Sauvegarde des "TrustedHosts" pour les remettre en place après action
-Passage des réseau de la machine en "Privé" à chaque redémarrage après la commande "complete-ib1Install"

**Version 1.4:**
- Moteur de log du module (commande interne "write-ib1Log").
- Nouvelle commande pour afficher le log "get-ib1Log"
- Changement général du paramètre "-vmName" pour accepter des fragements de noms de VMs.
- Changement de syntaxe de "switch-ib1vmFR" : remplacement du paramètre "-noCheckpoint" par le paramètre "-Checkpoint"
- Ajout des paramètres "-subnet", "-Gateway" et "-getCred" à la commande "invoke-ib1NetCommand"
- Optimisation radicale de la commande "invoke-ib1NetCommand" en passant par des jobs Powershell
- Nouvelle commande "get-ib1Version"
- Installation du module ib1 dans le VHD lors du "mount-ib1VHDBoot"
- Désactivation de la session étendue sur Hyper-V avec "complete-ib1Setup" (pb groupe RDP)
- Test de disponibilité de Powershell Direct dans la commande "repair-ib1VMNetwork"
- Commande "connect-ib1VMNet" marquée comme obsolète.
- Utilisation des Notes des VMs pour tracer les actions du module.
