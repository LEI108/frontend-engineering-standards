[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rootPath = [IO.Path]::GetFullPath($Root)
$errors = [Collections.Generic.List[string]]::new()
$warnings = [Collections.Generic.List[string]]::new()

function Add-Error {
    param([string]$Message)
    $script:errors.Add($Message)
}

function Add-Warning {
    param([string]$Message)
    $script:warnings.Add($Message)
}

if (-not (Test-Path -LiteralPath $rootPath -PathType Container)) {
    throw "Package root not found: $rootPath"
}

$requiredFiles = @(
    'README.md',
    'CHANGELOG.md',
    'skills/manifest.yaml',
    'skills/INSTALL.md',
    'scripts/install-skills.ps1',
    'scripts/verify-package.ps1'
)

foreach ($relativePath in $requiredFiles) {
    $fullPath = Join-Path $rootPath $relativePath
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        Add-Error "Missing required file: $relativePath"
    }
}

$requiredDocumentCounts = @{
    standards = 3
    profiles = 2
    guides = 2
    integrations = 1
    templates = 4
}

foreach ($directoryName in $requiredDocumentCounts.Keys) {
    $directoryPath = Join-Path $rootPath $directoryName
    if (-not (Test-Path -LiteralPath $directoryPath -PathType Container)) {
        Add-Error "Missing required directory: $directoryName"
        continue
    }
    $documentCount = @(Get-ChildItem -LiteralPath $directoryPath -File -Filter '*.md').Count
    if ($documentCount -lt $requiredDocumentCounts[$directoryName]) {
        Add-Error "Directory '$directoryName' contains $documentCount Markdown file(s); expected at least $($requiredDocumentCounts[$directoryName])."
    }
}

$skillNames = @(
    'frontend-design',
    'lanhu-design-build',
    'lean-code-edits',
    'precision-frontend-engineering'
)
$frontmatterNames = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)

foreach ($skillName in $skillNames) {
    $entry = Join-Path $rootPath "skills/$skillName/SKILL.md"
    if (-not (Test-Path -LiteralPath $entry -PathType Leaf)) {
        Add-Error "Missing skill entrypoint: skills/$skillName/SKILL.md"
        continue
    }

    $content = Get-Content -LiteralPath $entry -Raw -Encoding utf8
    if ($content -notmatch '(?s)^---\s*\r?\n.*?\r?\n---') {
        Add-Error "Invalid or missing YAML frontmatter: skills/$skillName/SKILL.md"
        continue
    }

    $nameMatch = [regex]::Match($content, '(?m)^name:\s*([^\r\n]+)\s*$')
    $descriptionMatch = [regex]::Match($content, '(?m)^description:\s*([^\r\n]+)\s*$')
    if (-not $nameMatch.Success) {
        Add-Error "Missing frontmatter name: skills/$skillName/SKILL.md"
    } else {
        $declaredName = $nameMatch.Groups[1].Value.Trim()
        if ($declaredName -ne $skillName) {
            Add-Error "Skill folder/name mismatch: '$skillName' vs '$declaredName'"
        }
        if (-not $frontmatterNames.Add($declaredName)) {
            Add-Error "Duplicate skill name: $declaredName"
        }
    }
    if (-not $descriptionMatch.Success -or [string]::IsNullOrWhiteSpace($descriptionMatch.Groups[1].Value)) {
        Add-Error "Missing frontmatter description: skills/$skillName/SKILL.md"
    }
}

$markdownFiles = Get-ChildItem -LiteralPath $rootPath -Recurse -File -Filter '*.md'
$linkPattern = [regex]'\[[^\]]*\]\((?<target>[^)]+)\)'

foreach ($file in $markdownFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding utf8
    foreach ($match in $linkPattern.Matches($content)) {
        $target = $match.Groups['target'].Value.Trim()
        if ($target.StartsWith('<') -and $target.EndsWith('>')) {
            $target = $target.Substring(1, $target.Length - 2)
        }
        if ($target -match '^(https?:|mailto:|skill:|#)' -or $target -match '^<.*>$') {
            continue
        }

        $target = ($target -split '#', 2)[0]
        $target = ($target -split '\s+"', 2)[0]
        if ([string]::IsNullOrWhiteSpace($target)) {
            continue
        }

        try {
            $decodedTarget = [Uri]::UnescapeDataString($target)
            $resolved = [IO.Path]::GetFullPath((Join-Path $file.DirectoryName $decodedTarget))
            if (-not $resolved.StartsWith($rootPath + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
                $relativeSource = $file.FullName.Substring($rootPath.Length).TrimStart('\', '/')
                Add-Error "Markdown link escapes the package in $relativeSource -> $target"
                continue
            }
            if (-not (Test-Path -LiteralPath $resolved)) {
                $relativeSource = $file.FullName.Substring($rootPath.Length).TrimStart('\', '/')
                Add-Error "Broken Markdown link in $relativeSource -> $target"
            }
        } catch {
            $relativeSource = $file.FullName.Substring($rootPath.Length).TrimStart('\', '/')
            Add-Error "Invalid Markdown link in $relativeSource -> $target"
        }
    }
}

$textFiles = Get-ChildItem -LiteralPath $rootPath -Recurse -File | Where-Object {
    $_.Extension -in @('.md', '.yaml', '.yml')
}

foreach ($file in $textFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding utf8
    $relativeSource = $file.FullName.Substring($rootPath.Length).TrimStart('\', '/')
    if ($content -match '[A-Za-z]:\\') {
        Add-Error "Machine-specific Windows path found in $relativeSource"
    }
    if ($content -match '(^|[\s`(])/(Users|home)/[^\s`)]+') {
        Add-Error "Machine-specific Unix home path found in $relativeSource"
    }
    if ($content -match '-zhCN\.md') {
        Add-Error "Dangling legacy Chinese mirror reference found in $relativeSource"
    }
}

$sensitiveNames = @('.env', 'id_rsa', 'id_ed25519')
$allFiles = Get-ChildItem -LiteralPath $rootPath -Recurse -Force -File
foreach ($file in $allFiles) {
    if ($file.Name -in $sensitiveNames -or $file.Extension -in @('.pem', '.pfx', '.p12', '.key')) {
        $relativeSource = $file.FullName.Substring($rootPath.Length).TrimStart('\', '/')
        Add-Error "Potential secret file included: $relativeSource"
    }
}

$reparsePoints = Get-ChildItem -LiteralPath $rootPath -Recurse -Force | Where-Object {
    $_.Attributes -band [IO.FileAttributes]::ReparsePoint
}
foreach ($item in $reparsePoints) {
    $relativeSource = $item.FullName.Substring($rootPath.Length).TrimStart('\', '/')
    Add-Warning "Reparse point found; verify portability manually: $relativeSource"
}

$scriptNames = @('install-skills.ps1', 'verify-package.ps1')
foreach ($scriptName in $scriptNames) {
    $parseTokens = $null
    $parseErrors = $null
    [Management.Automation.Language.Parser]::ParseFile(
        (Join-Path $rootPath "scripts/$scriptName"),
        [ref]$parseTokens,
        [ref]$parseErrors
    ) | Out-Null
    foreach ($parseError in $parseErrors) {
        Add-Error "PowerShell syntax error in ${scriptName}: $($parseError.Message)"
    }
}

Write-Host "Checked package: $rootPath"
Write-Host "Markdown files: $($markdownFiles.Count)"
Write-Host "Skills: $($skillNames.Count)"

foreach ($warning in $warnings) {
    Write-Warning $warning
}

if ($errors.Count -gt 0) {
    foreach ($message in $errors) {
        Write-Error $message -ErrorAction Continue
    }
    throw "Package verification failed with $($errors.Count) error(s)."
}

Write-Host 'Package verification passed.'
