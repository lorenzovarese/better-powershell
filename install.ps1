#Requires -Version 7.2
<#
.SYNOPSIS
    Installs the PowerShell 7 profile from configs/ and the modules it uses.
.DESCRIPTION
    - Installs CompletionPredictor and posh-git for the current user (unless -SkipModules).
    - Backs up any existing profile to <profile>.bak-<timestamp>.
    - Copies configs/Microsoft.PowerShell_profile.ps1 to your profile path and
      removes the "downloaded from the internet" mark so RemoteSigned allows it to run.
.EXAMPLE
    pwsh -ExecutionPolicy Bypass -File .\install.ps1
.EXAMPLE
    .\install.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    # Target profile file. Defaults to the current user's PowerShell 7 profile.
    [string]$ProfilePath = $PROFILE.CurrentUserCurrentHost,
    # Do not install modules from the PowerShell Gallery.
    [switch]$SkipModules
)

$ErrorActionPreference = 'Stop'
$source = Join-Path $PSScriptRoot 'configs\Microsoft.PowerShell_profile.ps1'
if (-not (Test-Path $source)) { throw "Profile not found: $source" }

# 1. Modules
if (-not $SkipModules) {
    foreach ($module in 'CompletionPredictor', 'posh-git') {
        if (Get-Module -ListAvailable -Name $module) {
            Write-Host "[ok]      $module already installed"
        } elseif ($PSCmdlet.ShouldProcess($module, 'Install-Module -Scope CurrentUser')) {
            Write-Host "[install] $module"
            Install-Module -Name $module -Scope CurrentUser -Force
        }
    }
}

# 2. Back up the existing profile
$profileDir = Split-Path -Parent $ProfilePath
if (-not (Test-Path $profileDir) -and $PSCmdlet.ShouldProcess($profileDir, 'Create directory')) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}
if (Test-Path $ProfilePath) {
    $backup = '{0}.bak-{1}' -f $ProfilePath, (Get-Date -Format 'yyyyMMdd-HHmmss')
    if ($PSCmdlet.ShouldProcess($ProfilePath, "Back up to $backup")) {
        Copy-Item -Path $ProfilePath -Destination $backup
        Write-Host "[backup]  $backup"
    }
}

# 3. Install the profile
if ($PSCmdlet.ShouldProcess($ProfilePath, 'Install profile')) {
    Copy-Item -Path $source -Destination $ProfilePath -Force
    Unblock-File -Path $ProfilePath
    Write-Host "[done]    Profile installed to $ProfilePath"
    Write-Host 'Open a new PowerShell 7 window (or run ". $PROFILE") to load it.'
}
