function Export-ibCourse {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$CourseCode,
        [ValidateSet('Lecture', 'Complet')][string]$ExportProfile = 'Lecture')
    $tools = @{
        git = 'Git.Git'
        pandoc = 'JohnMacFarlane.Pandoc'
        xelatex = 'MiKTeX.MiKTeX'
        python = 'Python.Python.3.13'}
    foreach ($tool in $tools.getEnumerator()) {
        try { 
            & $tool.Key --version *> $null
            write-debug "$($tool.Key) Déjà installé."}
        catch {
            write-Warning "$($tool.Key) introuvable : Installation"
            if ($tool.Key -eq 'xelatex') { Write-Warning "Installation de Xelatex : tout accepter (y compris au premier lancement ensuite)..."}
            winget install --id $tool.Value --accept-package-agreements --accept-source-agreements -e }}
    python -m pip install --upgrade --quiet pip
    python -m pip install --quiet -r ( Join-Path $PSScriptRoot '..\requirements.txt' )
    $env:Path = [System.Environment]::GetEnvironmentVariable( "Path", "Machine" ) + ";" + [System.Environment]::GetEnvironmentVariable( "Path", "User")
    $PythonScript = Join-Path $PSScriptRoot "..\Private\export-course.py"
    $Python = Get-Command python -ErrorAction Stop
    & $Python.Source $PythonScript $CourseCode $ExportProfile }
