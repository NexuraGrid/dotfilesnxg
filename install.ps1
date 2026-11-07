# One-command setup for Windows:
#   irm https://raw.githubusercontent.com/NexuraGrid/dotfilesnxg/main/install.ps1 | iex
$ErrorActionPreference = 'Stop'

$repo = if ($env:DOTFILES_REPO) { $env:DOTFILES_REPO } else { 'https://github.com/NexuraGrid/dotfilesnxg.git' }

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget not found. Install "App Installer" from the Microsoft Store, then rerun.'
}

function Update-SessionPath {
    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machinePath;$userPath"
}

foreach ($package in @(@{ Command = 'git'; Id = 'Git.Git' }, @{ Command = 'chezmoi'; Id = 'twpayne.chezmoi' })) {
    if (-not (Get-Command $package.Command -ErrorAction SilentlyContinue)) {
        winget install --id $package.Id --exact --silent --accept-source-agreements --accept-package-agreements
        Update-SessionPath
    }
}

chezmoi init --apply $repo
if ($LASTEXITCODE -ne 0) {
    throw "chezmoi failed with exit code $LASTEXITCODE"
}
Write-Host 'Done. Open a new terminal and run: nvim'
