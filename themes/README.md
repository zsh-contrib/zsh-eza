# Eza Themes

This directory contains bundled themes from the [eza-themes](https://github.com/eza-community/eza-themes) repository.

## Available Themes

### Catppuccin

A soothing pastel theme with warm, cozy colors.

- **catppuccin-mocha** (dark) - Rich, warm dark theme with high contrast
- **catppuccin-latte** (light) - Soft, creamy light theme perfect for daytime
- **catppuccin-macchiato** (dark) - Medium-dark variant with balanced contrast
- **catppuccin-frappe** (dark) - Cool-toned dark variant

### Rose Pine

An elegant theme inspired by natural pine forests.

- **rose-pine** (dark) - Deep, rich dark theme with earthy tones
- **rose-pine-dawn** (light) - Gentle light theme with soft pastels
- **rose-pine-moon** (dark) - Muted dark variant with subtle colors

## Theme Storage

When you first load the plugin, all bundled themes are automatically installed to your eza config directory:

```
~/.config/eza/themes/
├── catppuccin-mocha/
│   └── theme.yml
├── catppuccin-latte/
│   └── theme.yml
├── rose-pine/
│   └── theme.yml
└── ...
```

The active theme is symlinked at `~/.config/eza/theme.yml`.

### Custom Config Directory

You can customize the theme installation location by setting the `EZA_CONFIG_DIR` environment variable:

```zsh
export EZA_CONFIG_DIR="$HOME/.eza"
# Themes will be installed to ~/.eza/themes/
```

## Usage

### List Available Themes

```zsh
eza-themes-list
```

### Switch to a Theme

```zsh
eza-theme rose-pine       # Switch to Rose Pine dark
eza-theme catppuccin-latte # Switch to Catppuccin light
```

## Auto-detection

The plugin automatically detects your system theme preference and applies an appropriate theme:

1. **TMUX**: Uses `#{client_theme}` to detect terminal appearance
   - Light mode → catppuccin-latte
   - Dark mode → catppuccin-mocha

2. **macOS**: Reads `AppleInterfaceStyle` system preference
   - Light mode → rose-pine-dawn
   - Dark mode → rose-pine

3. **Manual override**: Set `ZSH_EZA_THEME_MODE` environment variable
   - `ZSH_EZA_THEME_MODE=light` → catppuccin-latte
   - `ZSH_EZA_THEME_MODE=dark` → catppuccin-mocha
   - `ZSH_EZA_THEME_MODE=rose-pine` → Specific theme
   - `ZSH_EZA_THEME_MODE=auto` → Auto-detect (default)

4. **Fallback**: catppuccin-mocha (dark theme)

## Disable Auto-detection

To disable automatic theme detection:

```zsh
# In your .zshrc before loading the plugin
export ZSH_EZA_AUTO_THEME=false
```

Then manually switch themes when needed:

```zsh
eza-theme catppuccin-latte
```

## Custom Themes

### Option 1: Customize an Installed Theme

After installing, you can modify any theme directly:

```bash
# Edit the rose-pine theme
vim ~/.config/eza/themes/rose-pine/theme.yml

# Switch to it to see your changes
eza-theme rose-pine
```

Your customizations will persist across plugin updates.

### Option 2: Create Your Own Theme

Create a new theme directory:

```bash
mkdir -p ~/.config/eza/themes/my-theme
vim ~/.config/eza/themes/my-theme/theme.yml
```

Then switch to it:

```zsh
eza-theme my-theme
```

### Option 3: Use a Custom theme.yml

Place your theme directly at `~/.config/eza/theme.yml`. The plugin will back it up before switching to a bundled theme:

```
~/.config/eza/theme.yml.backup.<timestamp>
```

## Theme Format

Eza themes are YAML files that define colors for various file types and attributes. For the format specification and to create your own themes, see:

- [eza color customization](https://github.com/eza-community/eza/blob/main/THEME.md)
- [eza-themes repository](https://github.com/eza-community/eza-themes)

## Credits

All bundled themes are sourced from the [eza-themes](https://github.com/eza-community/eza-themes) repository:

- **Catppuccin** themes: [Catppuccin](https://github.com/catppuccin/catppuccin)
- **Rose Pine** themes: [Rose Pine](https://github.com/rose-pine/rose-pine-theme)
