# zsh-eza

> Modern zsh plugin for [eza](https://github.com/eza-community/eza) with theme support and smart defaults

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

- 🎨 **7 bundled themes** - Catppuccin and Rose Pine with auto light/dark detection
- ⚡ **Smart defaults** - Works perfectly without any configuration
- 🔄 **Full compatibility** - All Oh My Zsh eza plugin aliases work identically
- 🚀 **Framework independent** - Works with zinit, zplug, antigen, or manual sourcing
- 🎯 **Zero configuration** - Sensible defaults, highly customizable when needed
- 🌙 **Auto theme detection** - Adapts to TMUX and macOS appearance settings

## Installation

### Prerequisites

Install [eza](https://github.com/eza-community/eza) first:

```zsh
# macOS
brew install eza

# Arch Linux
pacman -S eza

# Other systems - see https://github.com/eza-community/eza#installation
```

### Plugin Managers

#### zinit

```zsh
zinit light zsh-contrib/zsh-eza
```

#### zplug

```zsh
zplug "zsh-contrib/zsh-eza"
```

#### antigen

```zsh
antigen bundle zsh-contrib/zsh-eza
```

#### oh-my-zsh

```zsh
git clone https://github.com/zsh-contrib/zsh-eza ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-eza
```

Then add `zsh-eza` to your plugins array in `~/.zshrc`:

```zsh
plugins=(... zsh-eza)
```

### Manual Installation

```zsh
git clone https://github.com/zsh-contrib/zsh-eza ~/.zsh/zsh-eza
echo "source ~/.zsh/zsh-eza/zsh-eza.plugin.zsh" >> ~/.zshrc
```

## Aliases

All aliases from the Oh My Zsh eza plugin work identically for easy migration:

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

All aliases include these sensible defaults:

- `--group-directories-first` - Directories listed first
- `--color=auto` - Colored output
- `--icons=auto` - Icons for file types
- `--git` - Git status indicators
- `-g` - Show group ownership
- `-h` - Human-readable sizes
- `--time-style=relative` - Relative timestamps (e.g., "2 hours ago")

## Themes

The plugin comes with 7 beautiful themes from the [eza-themes](https://github.com/eza-community/eza-themes) repository.

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

### Theme Storage

Themes are automatically installed to your eza config directory when the plugin loads:

```
~/.config/eza/themes/
├── catppuccin-mocha/theme.yml
├── rose-pine/theme.yml
└── ...
```

The active theme is symlinked at `~/.config/eza/theme.yml`.

You can customize the installation location with the `EZA_CONFIG_DIR` environment variable:

```zsh
export EZA_CONFIG_DIR="$HOME/.eza"
```

### Auto Theme Detection

The plugin automatically detects your system's appearance and applies an appropriate theme:

1. **TMUX**: Reads `#{client_theme}` variable
   - Light → catppuccin-latte
   - Dark → catppuccin-mocha

2. **macOS**: Reads system appearance setting
   - Light → rose-pine-dawn
   - Dark → rose-pine

3. **Manual**: Set `ZSH_EZA_THEME_MODE` environment variable
4. **Fallback**: catppuccin-mocha (dark)

See [themes/README.md](themes/README.md) for more details on themes and customization.

## Configuration

### Environment Variables

Configure the plugin by setting these variables in your `.zshrc` **before** loading the plugin:

```zsh
# Disable aliases (default: true)
export ZSH_EZA_ENABLE_ALIASES=false

# Disable auto theme detection (default: true)
export ZSH_EZA_AUTO_THEME=false

# Set theme mode (default: auto)
# Options: auto, light, dark, or a specific theme name
export ZSH_EZA_THEME_MODE=light           # Use light themes
export ZSH_EZA_THEME_MODE=dark            # Use dark themes
export ZSH_EZA_THEME_MODE=rose-pine       # Use specific theme
export ZSH_EZA_THEME_MODE=auto            # Auto-detect (default)
```

### zstyle Configuration

Customize eza behavior using zstyle (similar to Oh My Zsh):

```zsh
# Show group information (default: yes)
zstyle ':eza:*' 'show-group' yes

# Show header row (default: yes)
zstyle ':eza:*' 'header' yes

# Icon display mode (default: auto)
# Options: auto, always, never
zstyle ':eza:*' 'icons' auto

# Show git status (default: yes)
zstyle ':eza:*' 'git-status' yes

# Time style (default: relative)
# Options: default, iso, long-iso, full-iso, relative
zstyle ':eza:*' 'time-style' relative

# Group directories first (default: yes)
zstyle ':eza:*' 'group-directories-first' yes

# Color mode (default: auto)
# Options: auto, always, never
zstyle ':eza:*' 'color' auto
```

## Comparison with Oh My Zsh Plugin

| Feature | zsh-eza | Oh My Zsh Plugin |
|---------|---------|------------------|
| **Framework independent** | ✅ Works anywhere | ❌ Requires Oh My Zsh |
| **Bundled themes** | ✅ 7 themes included | ❌ Manual setup needed |
| **Auto theme detection** | ✅ TMUX + macOS | ❌ No auto-detection |
| **Aliases** | ✅ All 10 aliases | ✅ All 10 aliases |
| **Configuration** | ✅ zstyle + env vars | ✅ zstyle only |
| **Installation** | ✅ One command | ✅ One command |
| **Maintenance** | ✅ Standalone updates | ⚠️ Coupled with OMZ |

### Migration from Oh My Zsh

If you're currently using the Oh My Zsh eza plugin:

1. Remove `eza` from your Oh My Zsh plugins array
2. Install `zsh-eza` using any method above
3. All your aliases will work exactly the same
4. Bonus: You now have theme support!

## Examples

```zsh
# Basic listing with icons and colors
ls

# Show all files including hidden ones
la

# Detailed view with git status
ll

# Show only directories as a tree
lDD

# Sort by size, largest first
lS

# Sort by modification time
lT

# Tree view of all files, 2 levels deep
lsd
```

## Advanced Usage

### Customize Themes

After installation, you can modify any theme:

```bash
# Edit the installed rose-pine theme
vim ~/.config/eza/themes/rose-pine/theme.yml

# Switch to see your changes
eza-theme rose-pine
```

Or create your own:

```bash
mkdir -p ~/.config/eza/themes/my-theme
cat > ~/.config/eza/themes/my-theme/theme.yml << 'EOF'
filekinds:
  normal: { foreground: white }
  directory: { foreground: blue, bold: true }
  executable: { foreground: green, bold: true }
EOF

eza-theme my-theme
```

See [eza theme documentation](https://github.com/eza-community/eza/blob/main/THEME.md) for the full format.

### Disable Auto-detection and Choose Manually

```zsh
# In .zshrc
export ZSH_EZA_AUTO_THEME=false

# Then manually switch themes as needed
eza-theme catppuccin-latte  # For daytime work
eza-theme catppuccin-mocha  # For nighttime work
```

### Use Only Specific Aliases

```zsh
# Disable all aliases
export ZSH_EZA_ENABLE_ALIASES=false

# Load plugin
zinit light zsh-contrib/zsh-eza

# Define only the aliases you want
alias ls='eza --icons --git'
alias ll='eza -l --icons --git'
```

## Troubleshooting

### "eza not found" error

Install eza using your package manager. See [eza installation guide](https://github.com/eza-community/eza#installation).

### Themes not applying

1. Check that `~/.config/eza/theme.yml` exists and is a symlink
2. Verify the theme file exists: `ls -l ~/.config/eza/theme.yml`
3. Manually switch theme: `eza-theme catppuccin-mocha`
4. Check eza version supports themes: `eza --version` (requires v0.10.0+)

### Aliases not working

1. Verify aliases are enabled: `echo $ZSH_EZA_ENABLE_ALIASES` (should be "true")
2. Check if another plugin is overriding aliases: `which ls`
3. Source your `.zshrc` again: `source ~/.zshrc`

### Auto-detection not working

1. Check the variable is enabled: `echo $ZSH_EZA_AUTO_THEME` (should be "true")
2. On macOS, verify system appearance: `defaults read -g AppleInterfaceStyle`
3. In TMUX, check client theme: `tmux display -p "#{client_theme}"`
4. Set manual mode: `export ZSH_EZA_THEME_MODE=light` or `dark`

## Related Projects

- [eza](https://github.com/eza-community/eza) - A modern replacement for ls
- [eza-themes](https://github.com/eza-community/eza-themes) - Community themes for eza
- [zsh-fzf](https://github.com/zsh-contrib/zsh-fzf) - Similar plugin architecture for fzf

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[MIT License](LICENSE)

## Credits

- [eza](https://github.com/eza-community/eza) - The amazing modern ls replacement
- [eza-themes](https://github.com/eza-community/eza-themes) - Source of bundled themes
- [Oh My Zsh eza plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/eza) - Alias inspiration
- [zsh-fzf](https://github.com/zsh-contrib/zsh-fzf) - Plugin architecture reference
