if ((Get-ItemProperty -Path 'HKCU:\Control Panel\Cursors' -name 'Arrow').Arrow.split('\')[-1] -like 'aero_arrow.cur') {
  $cursors=@{'git'=$true;'directory'="$env:SystemRoot";'Arrow'='HLCursor';'Hand'='HLLink';'IBeam'='HLText'}}
else {$cursors= @{'git'=$false;'directory'="$env:SystemRoot\cursors";'Arrow'='aero_arrow';'Hand'='aero_link';'IBeam'=''}}
$cursors.Keys | foreach {if ($_ -notlike 'directory' -and $_ -notlike 'git') {
  $cursorFile="$($cursors['directory'])\$($cursors[$_]).cur"
  if ($cursors['git']) {if (!(Test-Path $cursorFile)) {Invoke-WebRequest -Uri "https://github.com/renaudwangler/ib/raw/master/extra/$($cursors[$_]).cur" -OutFile $cursorFile}}
  if ($cursors[$_] -like '') {Set-ItemProperty -Path 'HKCU:\Control Panel\Cursors' -Name $_ -Value ''} else {Set-ItemProperty -Path 'HKCU:\Control Panel\Cursors' -Name $_ -Value $cursorFile}}}
#Rafraichissement des curseurs en "live"
$CSharpSig = @’
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
public static extern bool SystemParametersInfo(uint uiAction,uint uiParam,uint pvParam,uint fWinIni);
‘@
$CursorRefresh = Add-Type -MemberDefinition $CSharpSig -Name WinAPICall -Namespace SystemParamInfo –PassThru
$CursorRefresh::SystemParametersInfo(0x0057,0,$null,0)>$null