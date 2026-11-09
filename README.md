# better-powershell

A lightweight PowerShell 7 profile that gives a zsh-like experience (autosuggestions, menu completion, history substring search) inside the terminal you already use. No custom terminal emulator, prompt framework, or extra binaries are required.

## Features

- **Autosuggestions as you type**: a dropdown of suggestions taken from your history *and* from tab completion (folders, files, commands, parameters), similar to `zsh-autosuggestions`.
- **zsh-style Tab menu**: `Tab` opens a navigable grid of completions instead of cycling through them one by one.
- **History substring search**: `↑` / `↓` only walk through commands that start with what you have already typed.
- **SSH host completion**: `ssh`, `scp` and `sftp` complete `Host` entries from `~/.ssh/config`, including files pulled in with `Include`. `scp` hosts get a trailing `:`.
- **Git completion**: branches, remotes and subcommands via [posh-git](https://github.com/dahlbyk/posh-git), lazy-loaded on the first `git <Tab>` to keep startup fast.
- **Fast startup**: the profile adds roughly 50–150 ms to PowerShell's startup time.
- **Safe for scripts**: PSReadLine options are applied only in an interactive console, so non-interactive runs and redirected output never error.

## Key bindings

| Key | Action |
| --- | --- |
| `→` | Accept the whole suggestion (at end of line) |
| `Ctrl+→` | Accept the next word of the suggestion |
| `F2` | Toggle suggestions between list view and inline view |
| `Tab` | Open the completion menu |
| `Ctrl+Space` | Open the completion menu (PSReadLine default) |
| `↑` / `↓` | Search history for commands starting with the current input |

## Requirements

- Windows with [PowerShell 7.2+](https://github.com/PowerShell/PowerShell) (`pwsh`)
- PowerShell Gallery modules, installed automatically by `install.ps1`:
  - [CompletionPredictor](https://github.com/PowerShell/CompletionPredictor): completion-based suggestions
  - [posh-git](https://github.com/dahlbyk/posh-git): git tab completion

## Repository layout

```
.
├── configs/
│   └── Microsoft.PowerShell_profile.ps1   # the PowerShell 7 profile
├── install.ps1                            # installer: modules + profile (with backup)
├── INSTALL.md                             # installation, uninstall and troubleshooting
└── README.md
```

## Quick start

```powershell
git clone https://github.com/<your-user>/better-powershell.git
cd better-powershell
pwsh -ExecutionPolicy Bypass -File .\install.ps1
```

Then open a new PowerShell 7 window. See [INSTALL.md](INSTALL.md) for manual installation and troubleshooting.
