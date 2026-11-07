# Project status

Last updated: 2026-11-06. Read this first when resuming work.

**The one-command install is not verified yet.** The latest commit has not passed a clean install, and Windows has never been run. Do not rely on it on a new machine until the checks below pass.

## Pending, in order

1. Run the clean Ubuntu install with per-stage timing and confirm it passes.
2. Confirm that a new terminal resolves `node` through fnm.
3. Report the real time per stage. The user finds about 15 minutes unacceptable, so cut more if it is still high.
4. Run `install.ps1` on a real Windows machine.
5. Run `chezmoi init` on the main WSL machine, confirm `chezmoi diff` is empty, and measure how long it takes.
6. Decide on the local `~/.config/nvim/.git` repository, which chezmoi makes redundant.
7. Decide whether to migrate the main WSL machine from nvm to fnm. See the decisions below.
8. When a Laravel project exists, add Pint through Docker. It needs an async formatter, because `docker exec` alone costs about 420 ms and format-on-save stops at 500 ms.
9. Add the next configs (fish, zellij, git). Check each for secrets first: this repository is public.

## Verification so far

| Area | Result |
|---|---|
| Neovim on the main WSL machine | Passing: theme, Treesitter, LSP, Windows clipboard |
| Applying files in an isolated home | Passing: matches the working config, plus `scripts/` |
| Secret scan of this repository | Passing |
| Bash, PowerShell and fish syntax | Passing, static checks only |
| Clean Ubuntu install, last complete run | Failed on one item: `basedpyright` needs `python3`; 46 parsers and `gopls` installed |
| Python fix and speedups (latest commits) | Not verified: the timed run was still in progress when this was written |
| `node` in a new terminal through fnm | Not verified: fnm installed Node, but the run stopped before this check |
| Windows install | Never run: only template rendering, syntax and winget package IDs were checked |
| React and Tailwind behavior in Neovim | Not tested with real files |

## Decisions

| Decision | Reason |
|---|---|
| Use chezmoi | Handles Linux, WSL and Windows with one source and per-platform scripts |
| Download the craftzdog config instead of storing it | It has no license, so it is pinned by commit in `home/.chezmoiexternal.toml` and not redistributed |
| Keep personal Neovim changes in `after/plugin/personal.lua` | It runs after all upstream setup; upstream files stay untouched and are overwritten on apply |
| Manage Node with fnm | User requirement. The main WSL machine still uses nvm and does not have fnm, so it stays as is until the user decides |
| Keep a machine's existing Node | Avoids breaking the nvm setup and its global packages |
| Use native Docker inside WSL | Docker for Windows is no longer used. PHP runs in containers, so the host has no PHP |
| Disable intelephense formatting | With no PHP formatter it rewrote code style on save: 9 of 12 sampled files changed |
| Limit `angularls` to Angular projects | It otherwise started in every TS, TSX and HTML buffer |
| Have the Neovim bootstrap fail loudly | It retries once, then exits non-zero naming what is missing |

## Known gaps

- `gopls` was still installing after bootstrap exited in one clean run. The cause was never found. It installed normally in the later run, and bootstrap now checks for it.
- On Windows, `fnm` setup changes the CurrentUser execution policy to `RemoteSigned` when it is undefined, so PowerShell profiles can load.
- `lazygit`, Copilot auth (`:Copilot auth`) and Nerd Font rendering were never checked in a real terminal session.
