function Get-ibWebCache {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$SourceUrl, [Parameter(Mandatory)][string]$DestinationFolder, [string]$Extension = "html")
    $Uri = [uri]$SourceUrl
    $FileName = ($Uri.AbsolutePath.TrimEnd('/') -split '/')[-1]
    if (-not (Test-Path $DestinationFolder)) {New-Item -ItemType Directory -Path $DestinationFolder | Out-Null}
    if ($FileName.EndsWith(".$Extension")) {$DestinationFile = Join-Path $DestinationFolder $FileName}
    else {$DestinationFile = Join-Path $DestinationFolder "$FileName.$Extension"}
    if (-not (Test-Path $DestinationFile)) {
        Write-Debug "Téléchargement de '$SourceUrl'"
        Invoke-WebRequest -Uri $SourceUrl -OutFile $DestinationFile}
    return $DestinationFile}

function Convert-ibKnowledgeCheckToMarkdown {
    [CmdletBinding()]param([Parameter(Mandatory)]$KnowledgeCheckFile)
    $KnowledgeCheck = Get-Content $KnowledgeCheckFile -Raw | ConvertFrom-Yaml
    $Markdown = @('## Module assessment','')
    $QuestionIndex = 1
    foreach ($Question in $KnowledgeCheck.quiz.questions) {
        $Markdown += "### Question $QuestionIndex",'',$Question.content,''
        foreach ($Choice in $Question.choices) {
            if ($Choice.isCorrect) {
                $Markdown += "- **$($Choice.content)**"
                if ($Choice.explanation) {$Markdown += "  - *$($Choice.explanation)*"}}
            else { $Markdown += "- $($Choice.content)" }}
        $Markdown += ''
        $QuestionIndex++}
    return ($Markdown -join "`r`n")}

function get-ibGlobalCache {
[CmdletBinding()]param([Parameter(Mandatory)][string]$CourseCode,[Parameter(Mandatory)][string]$CacheFolder)
    $learnPath = 'https://learn.microsoft.com/en-us/training'
    $KnowledgeCheckRepos = @('learn','learn-m365-pr')
    $KnownFiles = [System.Collections.Generic.HashSet[string]]::new()
    $LearningPathFolder = Join-Path $CacheFolder $CourseCode
    $ImagesFolder = Join-Path $LearningPathFolder "images"
    $CourseUrl = "$learnPath/courses/$CourseCode"
    $CourseFile = Get-ibWebCache -SourceUrl $CourseUrl -DestinationFolder $CacheFolder
    $CourseContent = Get-Content $CourseFile -Raw
    #Analyse de l'accueil pour trouver les Learning Path
    $LPMatches = [regex]::Matches($CourseContent, '<meta[^>]*name="learn_item"[^>]*content="([^"]+)"')
    $lpStructure = @()
    foreach ($LPMatch in $LPMatches)  {
        $Content = $LPMatch.Groups[1].Value
        if ($Content -notlike 'learn.wwl.*') {continue}
        $LpUrl = "$learnPath/paths/$($Content -replace '^learn\.wwl\.', '')/"
        $LpFile = Get-ibWebCache -SourceUrl $LpUrl -DestinationFolder $LearningPathFolder
        if (-not $KnownFiles.Add($LPFile)) {continue}
        $LpContent = Get-Content $LpFile -Raw
        if ($LpContent -match 'property="og:title"[^\>]*content="([^"]+)"') {
            $LpTitle = $Matches[1] -replace '\s*-\s*Training$'}
        #Analyse du Learning Path pour trouver les modules
        $ModuleMatches = [regex]::Matches($LpContent,'href="\.\./\.\./modules/([^/]+)/"')
        $ModuleStructure = @()
        foreach ($ModuleMatch in $ModuleMatches) {
            $ModuleUrl = "$learnPath/modules/$($ModuleMatch.Groups[1].Value)/"
            $ModuleFolder = join-path $LearningPathFolder ([System.IO.Path]::GetFileNameWithoutExtension($lpFile))
            $ModuleFile = Get-ibWebCache -SourceUrl $ModuleUrl -DestinationFolder $ModuleFolder
            if (-not $KnownFiles.Add($ModuleFile)) {continue}
            $ModuleContent = Get-Content $ModuleFile -Raw
            if ($ModuleContent -match 'property="og:title"[^\>]*content="([^"]+)"') {
            $ModuleTitle = $Matches[1] -replace '\s*-\s*Training$'}
            #Récupération des informations pour les urls
            if ($ModuleContent -match 'name="source_path"[^"]*content="([^"]+)"') {$SourcePath = $Matches[1]}
            #Analyse du module pour trouver les unités
            $UnitStructure = @()
            $UnitLines = $ModuleContent -split "`n" | Where-Object { $_ -like '*unit-title*' }
            $firstUnit = $true
            foreach ($Line in $UnitLines) {
                if ($Line -match 'href="([^"]+)"') {
                    $UnitUrl = "$ModuleUrl$($Matches[1])?accept=text/markdown"
                    $UnitsFolder = Join-Path $ModuleFolder ([System.IO.Path]::GetFileNameWithoutExtension($ModuleFile))
                    $UnitFile = Get-ibWebCache -SourceUrl $UnitUrl -DestinationFolder $UnitsFolder -Extension "md"
                    if (-not $KnownFiles.Add($UnitFile)) {continue}
                    $UnitContent = Get-Content $UnitFile -Raw
                    #Suppression du FrontMatter YAML
                    $IsKnowledgeCheck = $false
                    $KnowledgeCheckYaml = $null
                    if ($UnitContent -match '(?s)^---\s*\r?\n.*?\r?\n---\s*\r?\n') {
                        $UnitContent = "`r`n`r`n" + $UnitContent.Substring($Matches[0].Length)
                        $UnitYaml = $Matches[0]
                        # Détection Knowledge Check
                        if ($UnitYaml -match 'module_assessment:\s*true') {
                            if ($UnitYaml -match 'source_path:\s*(.+)') {
                                $SourcePath = $Matches[1].Trim()
                                $KnowledgeCheckYaml = $null
                                foreach ($KnowledgeCheckRepo in $KnowledgeCheckRepos) {
                                    $KnowledgeCheckYamlUrl = "https://raw.githubusercontent.com/MicrosoftDocs/$KnowledgeCheckRepo/main/$SourcePath"
                                    try {
                                        $KnowledgeCheckYaml = Get-ibWebCache -SourceUrl $KnowledgeCheckYamlUrl -DestinationFolder $UnitsFolder -Extension 'yml'
                                        $UnitContent = Convert-ibKnowledgeCheckToMarkdown -KnowledgeCheckFile $KnowledgeCheckYaml
                                        $IsKnowledgeCheck = $true
                                        break}
                                    catch {}}
                            if (-not $KnowledgeCheckYaml) {Write-Warning "Knowledge Check introuvable : $SourcePath"}}}}
                    if (-not $FirstUnit) {$UnitContent = "`r`n`r`n\newpage`r`n`r`n" + $UnitContent}
                    $FirstUnit = $false
                    $UnitTitle = ($UnitContent -split "`n" | Where-Object { $_ -like '## *' } | Select-Object -First 1)
                    $UnitTitle = $UnitTitle -replace '^##\s+', ''
                    #Récupération éventuelle des images de l'unité
                    $ImageMatches = [regex]::Matches($UnitContent, '\(([^)]*/media/[^)]+)\)')
                    foreach ($ImageMatch in $ImageMatches) {
                        $OriginalImagePath = $ImageMatch.Groups[1].Value
                        $ImageFile = (Split-Path $OriginalImagePath -Leaf) -replace '#.*$'
                        $RawUrl = "https://learn.microsoft.com/en-us/training/" + ($OriginalImagePath -replace '^\.\./\.\./','' -replace '#.*$','')
                        $Extension = [System.IO.Path]::GetExtension($ImageFile).TrimStart('.')
                        $LocalImageFile = Get-ibWebCache -SourceUrl $RawUrl -DestinationFolder $ImagesFolder -Extension $Extension
                        $UnitContent = $UnitContent.Replace($OriginalImagePath, $LocalImageFile)
                        }
                    Set-Content -Path $UnitFile -Value $UnitContent -Encoding UTF8 -Force
                    $UnitStructure += @{Title = $UnitTitle; File = $UnitFile; IsKnowledgeCheck = $IsKnowledgeCheck;}}}
            $ModuleStructure += @{File = $ModuleFile;Title = $ModuleTitle; Units = $UnitStructure}}
        $lpStructure += @{File = $LpFile;Title = $LpTitle ;Modules = $ModuleStructure}}
    $courseStructure = @{Course = $CourseCode; LearningPaths = $lpStructure}
    $courseStructure | ConvertTo-Json -Depth 6 | out-File "$LearningPathFolder\structure.json" -Encoding utf8} 

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
    Install-Module powershell-yaml -Scope CurrentUser
    Import-Module powershell-yaml
    $CacheFolder = Join-Path (Get-Location) "cache"
    get-ibGlobalCache -CourseCode $courseCode -CacheFolder $CacheFolder


    python -m pip install --upgrade --quiet pip
    python -m pip install --quiet -r ( Join-Path $PSScriptRoot '..\requirements.txt' )
    $PythonScript = Join-Path $PSScriptRoot "..\Private\export-course.py"
    $Python = Get-Command python -ErrorAction Stop
    & $Python.Source $PythonScript $CourseCode $ExportProfile }
