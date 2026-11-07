# dotfilesnxg

One command sets up a machine with my tools and configuration on Linux, WSL and Windows. Managed with [chezmoi](https://www.chezmoi.io).

## Install

**Linux / WSL**

```sh
curl -fsSL https://raw.githubusercontent.com/NexuraGrid/dotfilesnxg/main/install.sh | sh
```

**Windows (PowerShell)**

```powershell
irm https://raw.githubusercontent.com/NexuraGrid/dotfilesnxg/main/install.ps1 | iex
```

The first run takes several minutes. It installs system packages, Neovim plugins, language servers and Treesitter parsers. Rerunning it is safe.

On Windows, set **JetBrainsMono Nerd Font** in your terminal so icons render. On WSL, set it in the Windows terminal and install the font on the Windows side.

## Daily use

| I want to | Command |
|---|---|
| Pull changes onto this machine | `chezmoi update` |
| Save an edited file to the repo | `chezmoi re-add ~/.config/nvim/after/plugin/personal.lua` |
| Start tracking a new file | `chezmoi add ~/.config/fish/config.fish` |
| See pending changes | `chezmoi diff` |
| Publish my changes | `chezmoi cd`, then commit and push with git |

Before `chezmoi add`, check the file for tokens, passwords and private hosts. **This repository is public.**

## Layout

| Path | Purpose |
|---|---|
| `install.sh`, `install.ps1` | Entry points: install chezmoi and apply everything |
| `home/` | Mirrors the home directory; `dot_config/` becomes `~/.config/` |
| `home/.chezmoidata/packages.yaml` | System packages per platform |
| `home/.chezmoiexternal.toml` | Third-party configs pinned to a commit |
| `home/.chezmoiscripts/` | Install steps, split into `unix/` and `windows/` |

## Common changes

**Add a system package:** add one line to `home/.chezmoidata/packages.yaml`.

**Node:** managed with [fnm](https://github.com/Schniz/fnm). A fresh machine gets the LTS version as default. A machine that already has Node keeps its setup.

**Add a config for another tool:** run `chezmoi add` on it. It lands under `home/` and every machine gets it on the next `chezmoi update`.

**Change Neovim:** edit `after/plugin/personal.lua`. Files that come from upstream are overwritten on apply, so do not edit them directly.

## Neovim

Requires Neovim 0.12 or newer.

The base is [craftzdog's config](https://github.com/craftzdog/dotfiles). It is downloaded from the author's repository at a pinned commit and is not stored here. To update it, change the commit in `home/.chezmoiexternal.toml`.

This repository only holds my additions: key discovery with which-key, tooling for Go, Rust, Python, PHP, Vue and Angular, and keymaps restored to standard Vim behavior.

PHP is not formatted on save because PHP runs in Docker, not on the host.

## Credits

Neovim base configuration by [Takuya Matsuyama (craftzdog)](https://github.com/craftzdog).
