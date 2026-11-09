# Installation guide

## 1. Install PowerShell 7

The profile targets PowerShell 7.2 or newer, not the built-in Windows PowerShell 5.1.

```powershell
winget install --id Microsoft.PowerShell --source winget
```

Open it by typing `pwsh`, from the Start menu ("PowerShell 7"), or set it as the default profile in Windows Terminal (Settings → Startup → Default profile).

## 2. Get the files

Clone the repository:

```powershell
git clone https://github.com/<your-user>/better-powershell.git
cd better-powershell
```

Or download the ZIP from GitHub (**Code → Download ZIP**), extract it, and `cd` into the extracted folder.

## 3a. Automatic install (recommended)

From the repository folder, in PowerShell 7:

```powershell
pwsh -ExecutionPolicy Bypass -File .\install.ps1
```

The script:

1. installs `CompletionPredictor` and `posh-git` for the current user (skip with `-SkipModules`);
2. backs up your existing profile to `<profile>.bak-<timestamp>`;
3. copies `configs\Microsoft.PowerShell_profile.ps1` to your profile path (`$PROFILE`) and unblocks it.

Preview without changing anything:

```powershell
pwsh -ExecutionPolicy Bypass -File .\install.ps1 -WhatIf
```

`-ExecutionPolicy Bypass` applies only to that one run. It is needed because files downloaded from the internet are blocked by the default `RemoteSigned` policy until they are unblocked.

## 3b. Manual install

```powershell
# Modules
Install-Module CompletionPredictor -Scope CurrentUser
Install-Module posh-git -Scope CurrentUser

# Back up the current profile, if any
if (Test-Path $PROFILE) { Copy-Item $PROFILE "$PROFILE.bak" }

# Install the profile
New-Item -ItemType Directory -Force (Split-Path $PROFILE) | Out-Null
Copy-Item .\configs\Microsoft.PowerShell_profile.ps1 $PROFILE -Force
Unblock-File $PROFILE
```

## 4. Load it

Open a new PowerShell 7 window, or reload in the current one:

```powershell
. $PROFILE
```

Check that it works:

- type `cd ` followed by a few letters of a folder name: suggestions appear in a list below the prompt;
- type `ssh ` and press `Tab`: hosts from `~/.ssh/config` are listed;
- type `git chec` and press `Tab`: it completes to `checkout`.

## Uninstall

```powershell
Remove-Item $PROFILE
# Restore a backup if you have one, e.g.:
# Rename-Item "$PROFILE.bak-20260101-120000" (Split-Path $PROFILE -Leaf)

# Optional: remove the modules
Uninstall-Module CompletionPredictor, posh-git
```

## Troubleshooting

**"Cannot load PSReadline module. Console is running without PSReadline."**
This usually appears in Windows PowerShell 5.1 when the execution policy is `Restricted`, which blocks the module's script files. Allow local scripts for your user (no admin needed):

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

PowerShell 7 already defaults to `RemoteSigned`.

**"…cannot be loaded because running scripts is disabled" or "…is not digitally signed"**
The profile file still carries the "downloaded from the internet" mark. Run `Unblock-File $PROFILE`.

**No suggestions appear**
Check `(Get-PSReadLineOption).PredictionSource`. It should be `HistoryAndPlugin`. If it is `History`, CompletionPredictor is not installed: run `Install-Module CompletionPredictor -Scope CurrentUser`. Suggestions need an interactive console that supports virtual terminal sequences (Windows Terminal, the default console host on Windows 10/11, the VS Code terminal).

**Git status is not shown in the prompt**
posh-git is lazy-loaded on the first `git <Tab>` to save about 450 ms at startup, so its prompt only appears after that. To load it at startup instead, replace the `Register-ArgumentCompleter -Native -CommandName git ...` block in the profile with:

```powershell
Import-Module posh-git
```

**Startup feels slow**
PowerShell prints `Loading personal and system profiles took …ms` when profiles take more than 500 ms. Measure with:

```powershell
Measure-Command { pwsh -NoProfile -Command exit }   # baseline
Measure-Command { pwsh -Command exit }              # with profile
```

**Clear the history used for suggestions**

```powershell
Clear-History
[Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()
Remove-Item (Get-PSReadLineOption).HistorySavePath
```
