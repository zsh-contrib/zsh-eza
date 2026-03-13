# zsh-eza

A Zsh plugin for [eza](https://github.com/eza-community/eza) with Catppuccin and Rose Pine theming, smart defaults, and full alias support.

## Features

- 7 bundled themes with auto light/dark detection
- Smart defaults that work without any configuration
- Full Oh My Zsh eza plugin alias compatibility
- Theme synchronization with TMUX and macOS appearance
- Configurable via environment variables and zstyle

## Requirements

- [eza](https://github.com/eza-community/eza) - A modern replacement for ls

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

### Default Options

All aliases include these defaults:

- `--group-directories-first` - Directories listed first
- `--color=auto` - Colored output
- `--icons=auto` - Icons for file types
- `--git` - Git status indicators
- `-g` - Show group ownership
- `--time-style=relative` - Relative timestamps

## Themes

### Available Themes

**Catppuccin** (warm, cozy colors)
- `catppuccin-mocha` - Dark theme (high contrast)
- `catppuccin-latte` - Light theme (soft and creamy)
- `catppuccin-macchiato` - Dark variant (medium contrast)
- `catppuccin-frappe` - Dark variant (cool tones)

**Rose Pine** (elegant, natural tones)
- `rose-pine` - Dark theme (rich, earthy)
- `rose-pine-dawn` - Light theme (gentle pastels)
- `rose-pine-moon` - Dark variant (muted colors)

### Theme Commands

```zsh
# List available themes
eza-themes-list

# Switch to a specific theme
eza-theme catppuccin-mocha
eza-theme rose-pine-dawn
```

### Auto Theme Detection

The plugin automatically detects your system appearance:

1. **TMUX** - Reads `#{client_theme}` (light -> catppuccin-latte, dark -> catppuccin-mocha)
2. **macOS** - Reads system appearance (light -> rose-pine-dawn, dark -> rose-pine)
3. **Manual** - Set `ZSH_EZA_THEME_MODE` environment variable
4. **Fallback** - catppuccin-mocha (dark)

## Configuration

### Environment Variables

Set these in your `.zshrc` before loading the plugin:

```zsh
export ZSH_EZA_ENABLE_ALIASES=false    # Disable aliases (default: true)
export ZSH_EZA_AUTO_THEME=false        # Disable auto theme detection (default: true)
export ZSH_EZA_THEME_MODE=light        # Options: auto, light, dark, or a specific theme name
```

### zstyle Configuration

```zsh
# Boolean options (yes/no)
zstyle ':zsh-eza' 'show-group' yes        # Show group information (default: yes)
zstyle ':zsh-eza' 'header' yes            # Show header row (default: no)
zstyle ':zsh-eza' 'git-status' yes        # Show git status (default: yes)
zstyle ':zsh-eza' 'dirs-first' yes        # Group directories first (default: yes)

# String options
zstyle ':zsh-eza' 'icons' always          # auto/always/never (default: auto)
zstyle ':zsh-eza' 'time-style' relative   # default/iso/long-iso/full-iso/relative (default: relative)
zstyle ':zsh-eza' 'color' auto            # auto/always/never (default: auto)
```

## Directory Structure

```
zsh-eza/
├── zsh-eza.plugin.zsh   # Main entry point
├── themes/               # Bundled eza themes
│   ├── catppuccin-mocha/
│   ├── catppuccin-latte/
│   ├── catppuccin-macchiato/
│   ├── catppuccin-frappe/
│   ├── rose-pine/
│   ├── rose-pine-dawn/
│   └── rose-pine-moon/
├── README.md
└── LICENSE
```

## License

MIT License - see [LICENSE](./LICENSE) for details.
