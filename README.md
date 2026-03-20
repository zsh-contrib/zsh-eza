# zsh-eza

eza for Zsh — Catppuccin and Rose Pine theming, smart defaults, and full alias support.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Drop `ls` and never look back. `zsh-eza` wraps [eza](https://github.com/eza-community/eza) with a curated set of aliases, automatic light/dark theme detection, and full Oh My Zsh eza plugin compatibility — so you get beautiful file listings from the moment the plugin loads.

## Requirements

- [eza](https://github.com/eza-community/eza) (`eza`)

**macOS (Homebrew):**

```bash
brew install eza
```

**Nix:**

```bash
nix profile install nixpkgs#eza
```

## Installation

### Using zinit

```zsh
zinit load zsh-contrib/zsh-eza
```

### Using sheldon

```toml
[plugins.zsh-eza]
github = "zsh-contrib/zsh-eza"
```

### Manual

```zsh
git clone https://github.com/zsh-contrib/zsh-eza.git ~/.zsh/plugins/zsh-eza
source ~/.zsh/plugins/zsh-eza/zsh-eza.plugin.zsh
```

## Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `ls` | `eza` | Basic file listing with icons and colors |
| `la` | `eza -a` | List all files including hidden files |
| `ll` | `eza -l` | Long format with details |
| `ldot` | `eza -ld .*` | List only dotfiles |
| `lD` | `eza -lD` | List only directories in long format |
| `lDD` | `eza -lD --tree --level=2` | List directories as tree (2 levels) |
| `lS` | `eza -l --sort=size` | Long format sorted by file size |
| `lT` | `eza -l --sort=modified` | Long format sorted by modification time |
| `lsd` | `eza -la --tree --level=2` | Tree view of all files (2 levels) |
| `lsdl` | `eza -lDa --tree --level=2` | Tree view of all directories (2 levels) |

All aliases include `--group-directories-first`, `--color=auto`, `--icons=auto`, `--git`, `-g`, and `--time-style=relative`.

## Themes

### Available Themes

**Catppuccin** (warm, cozy colors)

- `catppuccin-mocha` — dark, high contrast
- `catppuccin-latte` — light, soft and creamy
- `catppuccin-macchiato` — dark, medium contrast
- `catppuccin-frappe` — dark, cool tones

**Rose Pine** (elegant, natural tones)

- `rose-pine` — dark, rich and earthy
- `rose-pine-dawn` — light, gentle pastels
- `rose-pine-moon` — dark, muted colors

### Theme Commands

```zsh
eza-themes-list          # list available themes
eza-theme catppuccin-mocha
eza-theme rose-pine-dawn
```

### Auto Theme Detection

1. **TMUX** — reads `#{client_theme}` (light → catppuccin-latte, dark → catppuccin-mocha)
2. **macOS** — reads system appearance (light → rose-pine-dawn, dark → rose-pine)
3. **Manual** — set `ZSH_EZA_THEME_MODE` before loading
4. **Fallback** — catppuccin-mocha

## Configuration

### Environment Variables

```zsh
export ZSH_EZA_ENABLE_ALIASES=false    # disable aliases (default: true)
export ZSH_EZA_AUTO_THEME=false        # disable auto theme detection (default: true)
export ZSH_EZA_THEME_MODE=light        # auto, light, dark, or a theme name
```

### zstyle

```zsh
zstyle ':zsh-eza' 'show-group' yes        # show group information (default: yes)
zstyle ':zsh-eza' 'header' yes            # show header row (default: no)
zstyle ':zsh-eza' 'git-status' yes        # show git status (default: yes)
zstyle ':zsh-eza' 'dirs-first' yes        # group directories first (default: yes)
zstyle ':zsh-eza' 'icons' always          # auto/always/never (default: auto)
zstyle ':zsh-eza' 'time-style' relative   # default/iso/long-iso/full-iso/relative
zstyle ':zsh-eza' 'color' auto            # auto/always/never (default: auto)
```

## The zsh-contrib Ecosystem

| Repo | What it provides |
|------|-----------------|
| [zsh-aws](https://github.com/zsh-contrib/zsh-aws) | AWS credential management with aws-vault and tmux |
| **zsh-eza** ← you are here | eza with Catppuccin and Rose Pine theming |
| [zsh-fzf](https://github.com/zsh-contrib/zsh-fzf) | fzf with Catppuccin and Rose Pine theming |
| [zsh-op](https://github.com/zsh-contrib/zsh-op) | 1Password CLI with secure caching and SSH key management |
| [zsh-tmux](https://github.com/zsh-contrib/zsh-tmux) | Automatic tmux window title management |
| [zsh-vivid](https://github.com/zsh-contrib/zsh-vivid) | vivid LS_COLORS generation with theme support |

## License

[MIT](LICENSE) — Copyright (c) 2025 zsh-contrib

<!-- markdownlint-disable-file MD013 -->
