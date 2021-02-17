$cred=Get-Credential
#Installation de la target iSCSI sur sea-adm et de ses 3 disques
Add-WindowsFeature FS-iSCSITarget-Server
New-IscsiServerTarget iSCSI-23 -InitiatorIds "IQN:iqn.1991-05.com.microsoft:sea-svr2.contoso.com","IQN:iqn.1991-05.com.microsoft:sea-svr3.contoso.com"
for ($i=1;$i -le 3;$i++) {
  New-IscsiVirtualDisk c:\storage\disk$i.vhdx -size 10GB
  Add-IscsiVirtualDiskTargetMapping iSCSI-23 c:\storage\disk$i.vhdx}

#Connexion des disques sur les serveurs sea-svr2 et sea-svr3  
$servers=@('sea-svr2','sea-svr3')
$servers|ForEach-Object {
  Invoke-Command -ComputerName $_ -Credential $cred -ScriptBlock {
  Start-Service msiscsi
  Set-Service msiscsi -StartupType Automatic
  New-IscsiTargetPortal -TargetPortalAddress sea-adm1.contoso.com
  Connect-IscsiTarget -NodeAddress iqn.1991-05.com.microsoft:sea-adm1-iSCSI-23-target}}

#Initialisation des disques montés sur le premier serveur
Invoke-Command -ComputerName $servers[0] -Credential $cred -ScriptBlock {
  $disks=(Get-Disk|where OperationalStatus -like Offline)
  $disks|ForEach-Object {
    Initialize-Disk -Number $_.Number -PartitionStyle MBR
    $part=New-Partition -DiskNumber $_.Number -Size 5gb -AssignDriveLetter
    $part
    Format-Volume -DriveLetter $part.driveletter -FileSystem NTFS}}

#Installation de la fonctionnalité Failover cluster et de ses outils de gestion
@('sea-adm1','sea-svr2','sea-svr3')|ForEach-Object {Install-WindowsFeature -Name Failover-clustering -IncludeManagementTools -ComputerName $_ }
@('sea-svr2','sea-svr3')|ForEach-Object {Restart-Computer -ComputerName $_}
Restart-Computer