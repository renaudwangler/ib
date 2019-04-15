#########################################
# Script lançé à l'import du module ib1 #
#########################################
#Création du journal d'évènements ib1
if (!(Get-EventLog -List|where log -eq ib1 -ErrorAction SilentlyContinue)) {
  New-EventLog -LogName ib1 -Source powerShellib1|Out-Null
  Limit-EventLog -LogName ib1 -OverflowAction OverwriteAsNeeded -MaximumSize 64KB}

$vmCourse=@{
'20411D-LON-DC1'='m20411d';
'20740C-LON-DC1'='m20740c';
'20741B-LON-DC1'='m20741b';
'20741B-LON-DC1-B'='m20741b';
'20742B-LON-DC1'='m20742b';
'20740C-LON-DC1-B'='m20740c';
'20740C-LON-DC1-C'='m20740c';}
if ($env:ibCourse -eq $null) {
  if ($vms=get-vm -ErrorAction SilentlyContinue) {(Compare-Object -ReferenceObject $($vmCourse.Keys) -DifferenceObject $vms.VMName -ExcludeDifferent -IncludeEqual).inputObject|ForEach-Object{if ($_){$ibCourse=$vmCourse.$_}}}
  if ($ibCourse -ne $null) {
    [System.Environment]::SetEnvironmentVariable('ibCourse',$ibCourse,[System.EnvironmentVariableTarget]::Machine)
    $env:ibCourse=$ibCourse
    Write-EventLog -LogName ib1 -Source powerShellib1 -Message "Import du module : Inscription de l'identité du stage '$ibCourse' dans la variable système 'ibCourse' suite à découverte de VM." -EntryType Information -EventId 3}}
if ($env:ibBoot -eq $null) {
  if ((Get-Disk|Where-Object IsBoot).Model -like 'Virtual Disk*') {$ibBoot='VHD'} else {$ibBoot='HDD'}
  [System.Environment]::SetEnvironmentVariable('ibBoot',$ibBoot,[System.EnvironmentVariableTarget]::Machine)
  $env:ibBoot=$ibBoot
  Write-EventLog -LogName ib1 -Source powerShellib1 -Message "Import du module : Inscription du mode de démarrage '$ibBoot' dans la variable système 'ibBoot'." -EntryType Information -EventId 3}
Write-Warning "Les commandes du module 'ib1' ne sont pas prévues pour être utilisées en dehors de notre environnement de formation..."