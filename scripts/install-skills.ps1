[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string[]]$Names = @(
        'frontend-design',
        'lanhu-design-build',
        'lean-code-edits',
        'precision-frontend-engineering'
    ),
    [string]$Destination,
    [switch]$Replace
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$packageRoot = Split-Path -Parent $PSScriptRoot
$sourceRoot = Join-Path $packageRoot 'skills'
$allowedNames = @(
    'frontend-design',
    'lanhu-design-build',
    'lean-code-edits',
    'precision-frontend-engineering'
)

if ([string]::IsNullOrWhiteSpace($Destination)) {
    $codexRoot = if (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
        $env:CODEX_HOME
    } else {
        Join-Path ([Environment]::GetFolderPath('UserProfile')) '.codex'
    }
    $Destination = Join-Path $codexRoot 'skills'
}

$destinationPath = [IO.Path]::GetFullPath($Destination)

foreach ($name in $Names) {
    if ($name -notin $allowedNames) {
        throw "Unknown skill '$name'. Allowed values: $($allowedNames -join ', ')"
    }
}

if (-not (Test-Path -LiteralPath $destinationPath)) {
    if ($PSCmdlet.ShouldProcess($destinationPath, 'Create skills destination')) {
        New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
    }
}

$installed = [Collections.Generic.List[string]]::new()
$backups = [Collections.Generic.List[string]]::new()

foreach ($name in $Names) {
    $source = Join-Path $sourceRoot $name
    $sourceEntry = Join-Path $source 'SKILL.md'
    $target = Join-Path $destinationPath $name
    $staging = Join-Path $destinationPath ".$name.install-$([guid]::NewGuid().ToString('N'))"
    $backup = $null

    if (-not (Test-Path -LiteralPath $sourceEntry -PathType Leaf)) {
        throw "Skill entrypoint not found: $sourceEntry"
    }

    if ((Test-Path -LiteralPath $target) -and -not $Replace) {
        throw "Skill already exists: $target. Re-run with -Replace to create a backup and install the team copy."
    }

    if (-not $PSCmdlet.ShouldProcess($target, "Install skill '$name'")) {
        continue
    }

    try {
        Copy-Item -LiteralPath $source -Destination $staging -Recurse
        if (-not (Test-Path -LiteralPath (Join-Path $staging 'SKILL.md') -PathType Leaf)) {
            throw "Staged skill is missing SKILL.md: $staging"
        }

        if (Test-Path -LiteralPath $target) {
            $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
            $backup = "$target.backup-$stamp"
            if (Test-Path -LiteralPath $backup) {
                $backup = "$backup-$([guid]::NewGuid().ToString('N').Substring(0, 8))"
            }
            Move-Item -LiteralPath $target -Destination $backup
            $backups.Add($backup)
        }

        Move-Item -LiteralPath $staging -Destination $target
        $installed.Add($target)
    } catch {
        if (Test-Path -LiteralPath $staging) {
            Remove-Item -LiteralPath $staging -Recurse -Force
        }
        if ($backup -and (Test-Path -LiteralPath $backup) -and -not (Test-Path -LiteralPath $target)) {
            Move-Item -LiteralPath $backup -Destination $target
        }
        throw
    }
}

Write-Host "Installed $($installed.Count) skill(s) into: $destinationPath"
foreach ($path in $installed) {
    Write-Host "  + $path"
}
foreach ($path in $backups) {
    if (Test-Path -LiteralPath $path) {
        Write-Host "  backup: $path"
    }
}

Write-Host 'Restart or refresh the client so it can discover the installed skills.'
