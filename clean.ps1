#Nettoyage Chrome
$Items = 'Archived History','Cache\*','Cookies','History','Login Data','Top Sites','Visited Links','Web Data'
$Folder = "$($env:LOCALAPPDATA)\Google\Chrome\User Data\Default"
$Items | foreach-object {if (Test-Path "$Folder\$_") {Remove-Item "$Folder\$_" -recurse -confirm:$false}}
