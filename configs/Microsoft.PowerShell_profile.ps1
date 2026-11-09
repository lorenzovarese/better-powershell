# PowerShell 7 profile

# --- PSReadLine: only in an interactive console (skipped when output is redirected) ---
if ($Host.Name -eq 'ConsoleHost' -and -not [Console]::IsOutputRedirected -and (Get-Module PSReadLine)) {
    # Suggestions (history + tab-completion based)
    try {
        Import-Module CompletionPredictor -ErrorAction Stop
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    } catch {
        Set-PSReadLineOption -PredictionSource History
    }
    Set-PSReadLineOption -PredictionViewStyle ListView   # F2 toggles inline/list
    Set-PSReadLineOption -ShowToolTips
    Set-PSReadLineOption -HistoryNoDuplicates

    # zsh-style key bindings
    Set-PSReadLineKeyHandler -Key Tab             -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow         -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow       -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
}

# --- git completion: posh-git is lazy-loaded on the first `git <Tab>` (saves ~450ms at startup) ---
Register-ArgumentCompleter -Native -CommandName git -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    Import-Module posh-git -ErrorAction SilentlyContinue   # replaces this stub with posh-git's own completer
    if (Get-Command Expand-GitCommand -ErrorAction SilentlyContinue) {
        $padLength = $cursorPosition - $commandAst.Extent.StartOffset
        $text = $commandAst.ToString().PadRight($padLength, ' ').Substring(0, $padLength)
        Expand-GitCommand $text
    }
}

# --- ssh / scp / sftp: complete Host names from ~/.ssh/config (follows Include) ---
function Get-SshConfigHosts {
    param([string]$Path = (Join-Path $HOME '.ssh\config'), [int]$Depth = 0)
    if ($Depth -gt 5) { return }
    foreach ($file in (Resolve-Path $Path -ErrorAction SilentlyContinue)) {
        foreach ($line in Get-Content $file.Path) {
            if ($line -match '^\s*Include\s+(.+)$') {
                foreach ($inc in ($Matches[1] -split '\s+')) {
                    $inc = $inc -replace '^~', $HOME
                    if (-not [System.IO.Path]::IsPathRooted($inc)) { $inc = Join-Path $HOME ".ssh\$inc" }
                    Get-SshConfigHosts -Path $inc -Depth ($Depth + 1)
                }
            } elseif ($line -match '^\s*Host\s+(.+)$') {
                $Matches[1] -split '\s+' | Where-Object { $_ -and $_ -notmatch '[*?!]' }
            }
        }
    }
}

Register-ArgumentCompleter -Native -CommandName ssh, scp, sftp -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    $suffix = if ($commandAst.CommandElements[0].Value -match 'scp') { ':' } else { '' }
    Get-SshConfigHosts | Sort-Object -Unique | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new("$_$suffix", $_, 'ParameterValue', $_)
    }
}
