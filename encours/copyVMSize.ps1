if (!(Get-Variable locationSizes -ErrorAction SilentlyContinue)) {
  Connect-AzureRmAccount
  $locationSizes=@{}
  foreach ($location in (Get-AzureRmLocation)) {
    Write-Progress -Activity "Retreiving available VM sizes by location for the '$((Get-AzureRmSubscription).Name)' subscription." -CurrentOperation $location.DisplayName
    if ($location.Providers -icontains 'Microsoft.compute') {
      $cpuLimit=(Get-AzureRmVMUsage -Location $location.Location|where {$_.name.value -like 'cores'}).Limit
      $vmSizes=(Get-AzureRmVMSize -Location $location.Location|where NumberOfCores -le $cpuLimit).Name
      $localSizes=(Get-AzureRmComputeResourceSku |where {$_.ResourceType -like 'virtualmachines' -and $_.Restrictions.reasoncode -notlike 'notavailableforsubscription' -and $_.LocationInfo.location -eq $location.Location -and $vmSizes -contains $_.Name}).Name
      if ($localSizes.Count -ne 0) {
        $locationSizes.$($location.DisplayName)=$localSizes
      }
    }
  }
  Write-Progress -Activity "Retreiving available VM sizes by location for the '$((Get-AzureRmSubscription).Name)' subscription." -Completed
}
Set-Clipboard (($locationSizes|Out-GridView -Title 'Vm Size by location' -PassThru).value|Out-GridView -title 'Choose VM size for clipboard' -PassThru)