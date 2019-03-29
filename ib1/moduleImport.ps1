#########################################
# Script lançé à l'import du module ib1 #
#########################################
$vmCourse=@{
'20740C-LON-DC1'='m20740c';
'20741B-LON-DC1'='m20741b';
'20741B-LON-DC1-B'='m20741b';
'20742B-LON-DC1'='m20742b';
'20740C-LON-DC1-B'='m20740c';
'20740C-LON-DC1-C'='m20740c';
}
if ($env:ibCourse -eq $null) {
if ($vms=get-vm -ErrorAction SilentlyContinue) {(Compare-Object -ReferenceObject $($vmCourse.Keys) -DifferenceObject $vms.VMName -ExcludeDifferent -IncludeEqual).inputObject|ForEach-Object{if ($_){$ibCourse=$vmCourse.$_}}}
[System.Environment]::SetEnvironmentVariable('ibCourse',$ibCourse,[System.EnvironmentVariableTarget]::Machine)
$env:ibCourse=$ibCourse}
if ($env:ibBoot -eq $null) {
if ((Get-Disk|Where-Object IsBoot).Model -like 'Virtual Disk*') {$ibBoot='VHD'} else {$ibBoot='HDD'}
[System.Environment]::SetEnvironmentVariable('ibBoot',$ibBoot,[System.EnvironmentVariableTarget]::Machine)
$env:ibBoot=$ibBoot}
Write-Warning "Les commandes du module 'ib1' ne sont pas prévues pour être utilisées en dehors de notre environnement de formation..."