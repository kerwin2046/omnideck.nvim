# Omnideck

> Your personal cyberdeck. One command to turn a fresh machine into a fully-loaded development workstation.

Omnideck is a [chezmoi](https://www.chezmoi.io/)-managed monorepo that bootstraps a complete cross-platform developer workstation in a single command. Package managers, CLI tools, GUI applications, dotfiles, fonts, system defaults, and a fully configured Neovim distro come up together.

## Quickstart

On a fresh macOS or Debian-family machine:

```bash
curl -fsSL https://raw.githubusercontent.com/kerwin2046/omnideck/main/bootstrap.sh | sh
```

That single line will:

1. Detect the OS (macOS or Debian-based Linux).
2. Install the platform package manager (Homebrew on macOS, refresh `apt` on Linux).
3. Install [chezmoi](https://www.chezmoi.io/).
4. Run `chezmoi init --apply kerwin2046/omnideck`, which prompts for `name` / `email` / `machine_kind` and then plays back the lifecycle scripts to install everything.

Open a new shell, run `nvim`, and `lazy.nvim` will finish the last mile by installing plugins.

## Supported platforms

| Platform                                    | Status         |
| ------------------------------------------- | -------------- |
| macOS (Apple Silicon + Intel)               | First-class    |
| Debian / Ubuntu / Pop!_OS / Linux Mint      | First-class    |
| Arch / Fedora / Windows                     | Not supported  |

## What you get

Opinionated, modern defaults across the stack:

- **Editor** — Neovim distro built on [LazyVim](https://www.lazyvim.org/), wired up with Copilot, Codeium, OpenCode, and a Snacks-powered UI.
- **Terminal** — [Kitty](https://sw.kovidgoyal.net/kitty/), JetBrains Mono Nerd Font.
- **Shell** — Zsh + [Starship](https://starship.rs/) + [Atuin](https://atuin.sh/) + [Zoxide](https://github.com/ajeetdsouza/zoxide).
- **Modern CLI** — `eza`, `bat`, `fd`, `ripgrep`, `fzf`, `delta`, `dust`, `duf`, `procs`, `tldr`, `jq`, `yq`, `htop`, `btop`.
- **Git** — `lazygit`, `gh`, `delta` diffing, sane global gitignore, `includeIf` for personal vs work identity.
- **Runtimes** — [mise](https://mise.jdx.dev/) is installed; you pick which language runtimes to add at `chezmoi init` (node / python / go / rust / deno / bun) — default is none, opt in only what you need.
- **Containers** — Docker + `lazydocker` (optional, prompted at install).
- **GUI (macOS)** — Raycast, Rectangle, VS Code, Stats (optional, prompted at install).
- **System defaults** — sensible macOS `defaults write` tweaks; opt-in GNOME / KDE settings on Linux.

## Repository layout

```
omnideck/
├── bootstrap.sh              # curl|sh entrypoint
├── Justfile                  # local commands: just sync / apply / diff / doctor
├── .chezmoiroot              # tells chezmoi the source is "home/"
├── home/                     # chezmoi source tree
│   ├── .chezmoi.toml.tmpl    # first-run prompts
│   ├── .chezmoidata/         # single-source-of-truth package list
│   ├── .chezmoiscripts/      # lifecycle scripts (install pkgs / fonts / runtimes / system defaults)
│   ├── dot_config/nvim/      # the Neovim distro (init.lua, lua/, lazy-lock.json, ...)
│   └── ...                   # zsh, kitty, starship, git, lazygit, atuin, mise, ...
├── scripts/doctor.sh         # health check
└── docs/                     # ADRs and design notes
```

## Daily usage

```bash
just sync       # pull latest dotfiles and re-apply
just diff       # preview pending changes before applying
just apply      # apply local edits to ~
just doctor     # verify the workstation is healthy
just nvim-update
```

## Customization

The first `chezmoi init` writes a config at `~/.config/chezmoi/chezmoi.toml` from your answers to:

- **name** / **email** — feeds your global git config.
- **machine_kind** — `personal` or `work`. Used to switch git `includeIf` blocks and to gate work-only tools.
- **install_gui** / **install_docker** — toggle the heavier categories.
- **runtimes** — multi-select of language runtimes mise should preinstall (node / python / go / rust / deno / bun). Defaults to none; pick what matches your day-to-day work.

Re-run `chezmoi init` (without `--apply`) to change these answers later.

## License

MIT — see [LICENSE](LICENSE).
