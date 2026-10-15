function Get-ibWebCache {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$SourceUrl, [Parameter(Mandatory)][string]$DestinationFolder, [string]$Extension = "html")
    $Uri = [uri]$SourceUrl
    $FileName = ($Uri.AbsolutePath.TrimEnd('/') -split '/')[-1]
    if (-not (Test-Path $DestinationFolder)) {New-Item -ItemType Directory -Path $DestinationFolder | Out-Null}
    $DestinationFile = Join-Path $DestinationFolder "$FileName.$Extension"
    if (-not (Test-Path $DestinationFile)) {
        Write-Debug "Téléchargement de '$SourceUrl'"
        Invoke-WebRequest -Uri $SourceUrl -OutFile $DestinationFile}
    return $DestinationFile}
function get-ibGlobalCache {
[CmdletBinding()]param([Parameter(Mandatory)][string]$CourseCode,[Parameter(Mandatory)][string]$CacheFolder)
    $KnownFiles = [System.Collections.Generic.HashSet[string]]::new()
    $LearningPathFolder = Join-Path $CacheFolder $CourseCode
    $CourseUrl = "https://learn.microsoft.com/en-us/training/courses/$CourseCode"
    $CourseFile = Get-ibWebCache -SourceUrl $CourseUrl -DestinationFolder $CacheFolder
    $CourseContent = Get-Content $CourseFile -Raw
    #Analyse de l'accueil pour trouver les Learning Path
    $LPMatches = [regex]::Matches($CourseContent, '<meta[^>]*name="learn_item"[^>]*content="([^"]+)"')
    $lpStructure = @()
    foreach ($LPMatch in $LPMatches) {
        $Content = $LPMatch.Groups[1].Value
        if ($Content -notlike 'learn.wwl.*') {continue}
        $LpUrl = "https://learn.microsoft.com/en-us/training/paths/$($Content -replace '^learn\.wwl\.', '')/"
        $LpFile = Get-ibWebCache -SourceUrl $LpUrl -DestinationFolder $LearningPathFolder
        if (-not $KnownFiles.Add($LPFile)) {continue}
        $LpContent = Get-Content $LpFile -Raw
        if ($LpContent -match 'property="og:title"[^\>]*content="([^"]+)"') {
            $LpTitle = $Matches[1] -replace '\s*-\s*Training$'}
        #Analyse du Learning Path pour trouver les modules
        $ModuleMatches = [regex]::Matches($LpContent,'href="\.\./\.\./modules/([^/]+)/"')
        $ModuleStructure = @()
        foreach ($ModuleMatch in $ModuleMatches) {
            $ModuleUrl = "https://learn.microsoft.com/en-us/training/modules/$($ModuleMatch.Groups[1].Value)/"
            $ModuleFolder = join-path $LearningPathFolder ([System.IO.Path]::GetFileNameWithoutExtension($lpFile))
            $ModuleFile = Get-ibWebCache -SourceUrl $ModuleUrl -DestinationFolder $ModuleFolder
            if (-not $KnownFiles.Add($ModuleFile)) {continue}
            $ModuleContent = Get-Content $ModuleFile -Raw
            #Analyse du module pour trouver les unités
            $UnitStructure = @()
            $UnitLines = $ModuleContent -split "`n" | Where-Object { $_ -like '*unit-title*' }
            foreach ($Line in $UnitLines) {
                if ($Line -match 'href="([^"]+)"') {
                  $UnitUrl = "$ModuleUrl$($Matches[1])?accept=text/markdown"
                  $UnitsFolder = Join-Path $ModuleFolder ([System.IO.Path]::GetFileNameWithoutExtension($ModuleFile))
                  $UnitFile = Get-ibWebCache -SourceUrl $UnitUrl -DestinationFolder $UnitsFolder -Extension "md"
                  if (-not $KnownFiles.Add($UnitFile)) {continue}
                  $UnitStructure += $UnitFile }}
            $ModuleStructure += @{File = $ModuleFile;Units = $UnitStructure}}
        $lpStructure += @{File = $LpFile;Title = $LpTitle ;Modules = $ModuleStructure}}
    $courseStructure = @{Course = $CourseCode; LearningPaths = $lpStructure}
    $courseStructure | ConvertTo-Json -Depth 5 | out-File "$LearningPathFolder\structure.json" -Encoding utf8} 

function Export-ibCourse {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$CourseCode,
        [ValidateSet('Lecture', 'Complet')][string]$ExportProfile = 'Lecture')
    if (-not (Get-Command pandoc -ErrorAction SilentlyContinue)) {
        Write-Warning "Pandoc introuvable : installation"
        winget install --id JohnMacFarlane.Pandoc --accept-package-agreements --accept-source-agreements -e }
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        Write-Warning "Python introuvable : installation"
        winget install --id Python.Python.3.13 --accept-package-agreements --accept-source-agreements -e }
    $env:Path = [System.Environment]::GetEnvironmentVariable( "Path", "Machine" ) + ";" + [System.Environment]::GetEnvironmentVariable( "Path", "User")
    $CacheFolder = Join-Path (Get-Location) "cache"
    get-ibGlobalCache -CourseCode $courseCode -CacheFolder $CacheFolder


    python -m pip install --upgrade --quiet pip
    python -m pip install --quiet -r ( Join-Path $PSScriptRoot '..\requirements.txt' )
    $PythonScript = Join-Path $PSScriptRoot "..\Private\export-course.py"
    $Python = Get-Command python -ErrorAction Stop
    & $Python.Source $PythonScript $CourseCode $ExportProfile }