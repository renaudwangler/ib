function Get-ibWebCache {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$SourceUrl,[Parameter(Mandatory)][string]$DestinationFolder)
    $FileName = ($SourceUrl.TrimEnd('/') -split '/')[-1]
    if (-not $FileName) {$FileName = "index"}
    if (-not (Test-Path $DestinationFolder)) { New-Item -ItemType Directory -Path $DestinationFolder | Out-Null }
    $DestinationFile = Join-Path $DestinationFolder "$FileName.html"
    if (Test-Path $DestinationFile) {
        Write-Debug "Cache : $DestinationFile"
        return $DestinationFile}
    Write-Host "Téléchargement : $SourceUrl"
    Invoke-WebRequest -Uri $SourceUrl -OutFile $DestinationFile
    return $DestinationFile}

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
    $LearningPathFolder = Join-Path $CacheFolder "learning-paths"
    $ModulesFolder = Join-Path $CacheFolder "modules"
    $CourseUrl = "https://learn.microsoft.com/en-us/training/courses/$CourseCode"
    $CourseFile = Get-ibWebCache -SourceUrl $CourseUrl -DestinationFolder $CacheFolder
    $CourseContent = Get-Content $CourseFile -Raw
    #Analyse de l'accueil pour trouver les Learning Path
    $Matches = [regex]::Matches($CourseContent, '<meta[^>]*name="learn_item"[^>]*content="([^"]+)"')
    Write-Host "$($Matches.Count) LP trouvées"
    $LearningPaths = @()
    foreach ($Match in $Matches) {
        $Content = $Match.Groups[1].Value
        if ($Content -notlike 'learn.wwl.*') {continue}
        $Slug = $Content -replace '^learn\.wwl\.', ''
        if ($Slug -notin $LearningPaths) {$LearningPaths += $Slug}}
    foreach ($LearningPath in $LearningPaths) {
        $LpUrl = "https://learn.microsoft.com/en-us/training/paths/$LearningPath/"
        $LpFile = Get-ibWebCache -SourceUrl $LpUrl -DestinationFolder $LearningPathFolder
        $LpContent = Get-Content $LpFile -Raw
        #Analyse du Learning Path pour trouver les modules
        $ModuleMatches = [regex]::Matches($LpContent,'href="\.\./\.\./modules/([^/]+)/"')
        write-host "$($ModuleMatches.count) modules trouvés"
        foreach ($Match in $ModuleMatches) {
            $Slug = $Match.Groups[1].Value
            $ModuleUrl = "https://learn.microsoft.com/en-us/training/modules/$Slug/"
            $ModuleFile = Get-ibWebCache -SourceUrl $ModuleUrl -DestinationFolder $ModulesFolder}}
    python -m pip install --upgrade --quiet pip
    python -m pip install --quiet -r ( Join-Path $PSScriptRoot '..\requirements.txt' )
    $PythonScript = Join-Path $PSScriptRoot "..\Private\export-course.py"
    $Python = Get-Command python -ErrorAction Stop
    & $Python.Source $PythonScript $CourseCode $ExportProfile }
