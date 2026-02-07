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

You can use custom themes by placing your own `theme.yml` file at:

```
~/.config/eza/theme.yml
```

If you have a custom theme, the plugin will back it up before switching to a bundled theme. The backup will be saved as:

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
