<#
.SYNOPSIS
  Installs agent-kit's global subagents and skills into your user profile.

.DESCRIPTION
  Copies:
    global/agents/*.md   -> ~/.cursor/agents/
    global/skills/*      -> ~/.cursor/skills/
    template/            -> ~/.cursor/skills/bootstrap-repo/template/
  With -Claude, also copies agents and skills into ~/.claude/ for Claude Code.
  Re-run after pulling kit updates. Existing files with the same name are overwritten.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts/install.ps1
  powershell -ExecutionPolicy Bypass -File scripts/install.ps1 -Claude
#>
param([switch]$Claude)

$ErrorActionPreference = 'Stop'
$kit = Split-Path -Parent $PSScriptRoot

function Install-To([string]$root) {
    $agents = Join-Path $root 'agents'
    $skills = Join-Path $root 'skills'
    New-Item -ItemType Directory -Force $agents, $skills | Out-Null

    Copy-Item (Join-Path $kit 'global/agents/*.md') $agents -Force
    Get-ChildItem (Join-Path $kit 'global/skills') -Directory | ForEach-Object {
        Copy-Item $_.FullName $skills -Recurse -Force
    }

    $tpl = Join-Path $skills 'bootstrap-repo/template'
    if (Test-Path $tpl) { Remove-Item $tpl -Recurse -Force }
    Copy-Item (Join-Path $kit 'template') $tpl -Recurse -Force

    Write-Host "Installed into $root"
    Get-ChildItem $agents -Filter *.md | ForEach-Object { Write-Host "  agent: $($_.BaseName)" }
    Get-ChildItem $skills -Directory | ForEach-Object { Write-Host "  skill: $($_.Name)" }
}

Install-To (Join-Path $HOME '.cursor')
if ($Claude) { Install-To (Join-Path $HOME '.claude') }

Write-Host ""
Write-Host "Last step (manual): paste global/USER-RULES.md into Cursor Settings -> Rules -> User Rules."
Write-Host "Then restart Cursor so it picks up the new agents and skills."
