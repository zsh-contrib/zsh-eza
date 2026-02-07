#!/usr/bin/env zsh
#
# Theme management for zsh-eza
# Handles theme switching and auto-detection
#

# List available bundled themes
eza-themes-list() {
    local theme_dir="${ZSH_EZA_DIR}/themes"

    if [[ ! -d "$theme_dir" ]]; then
        print "zsh-eza: themes directory not found" >&2
        return 1
    fi

    print "Available eza themes:\n"

    # Catppuccin themes
    print "Catppuccin:"
    for theme in "$theme_dir"/catppuccin-*.yml(N); do
        local name="${theme:t:r}"
        local variant="${name#catppuccin-}"
        if [[ "$variant" == "latte" ]]; then
            print "  - $name (light)"
        else
            print "  - $name (dark)"
        fi
    done

    print "\nRose Pine:"
    for theme in "$theme_dir"/rose-pine*.yml(N); do
        local name="${theme:t:r}"
        if [[ "$name" == "rose-pine-dawn" ]]; then
            print "  - $name (light)"
        else
            print "  - $name (dark)"
        fi
    done

    print "\nUsage: eza-theme <theme-name>"
    print "Example: eza-theme catppuccin-mocha"
}

# Switch to a theme
eza-theme() {
    local theme_name="$1"

    if [[ -z "$theme_name" ]]; then
        print "Usage: eza-theme <theme-name>" >&2
        print "Run 'eza-themes-list' to see available themes" >&2
        return 1
    fi

    local theme_file="${ZSH_EZA_DIR}/themes/${theme_name}.yml"
    local config_dir="${HOME}/.config/eza"
    local config_file="${config_dir}/theme.yml"

    # Check if theme exists
    if [[ ! -f "$theme_file" ]]; then
        print "zsh-eza: theme '${theme_name}' not found" >&2
        print "Run 'eza-themes-list' to see available themes" >&2
        return 1
    fi

    # Create config directory if it doesn't exist
    if [[ ! -d "$config_dir" ]]; then
        mkdir -p "$config_dir" 2>/dev/null || {
            print "zsh-eza: failed to create config directory: $config_dir" >&2
            return 1
        }
    fi

    # Backup existing theme if present
    if [[ -f "$config_file" ]] && [[ ! -L "$config_file" ]]; then
        local backup_file="${config_file}.backup.$(date +%s)"
        mv "$config_file" "$backup_file" 2>/dev/null
        print "zsh-eza: backed up existing theme to ${backup_file}"
    fi

    # Remove existing symlink if present
    if [[ -L "$config_file" ]]; then
        rm "$config_file" 2>/dev/null
    fi

    # Create symlink to theme
    ln -sf "$theme_file" "$config_file" 2>/dev/null || {
        print "zsh-eza: failed to create symlink to theme" >&2
        return 1
    }

    print "zsh-eza: switched to theme '${theme_name}'"
}

# Auto-detect light/dark mode and apply theme
_zsh_eza_auto_theme() {
    # Priority 1: Check if user specified a theme name explicitly
    if [[ "$ZSH_EZA_THEME_MODE" != "auto" ]] && [[ "$ZSH_EZA_THEME_MODE" != "light" ]] && [[ "$ZSH_EZA_THEME_MODE" != "dark" ]]; then
        # User specified a theme name directly
        eza-theme "$ZSH_EZA_THEME_MODE" 2>/dev/null
        return
    fi

    # Priority 2: Check TMUX (like zsh-fzf does)
    if [[ -n "$TMUX" ]]; then
        local tmux_theme="$(tmux display -p "#{client_theme}" 2>/dev/null)"
        if [[ "$tmux_theme" == "light" ]]; then
            eza-theme catppuccin-latte 2>/dev/null
        else
            eza-theme catppuccin-mocha 2>/dev/null
        fi
        return
    fi

    # Priority 3: Check macOS dark mode
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if defaults read -g AppleInterfaceStyle &>/dev/null; then
            # Dark mode is enabled
            eza-theme rose-pine 2>/dev/null
        else
            # Light mode or no preference
            eza-theme rose-pine-dawn 2>/dev/null
        fi
        return
    fi

    # Priority 4: Use ZSH_EZA_THEME_MODE explicit light/dark setting
    case "$ZSH_EZA_THEME_MODE" in
        light)
            eza-theme catppuccin-latte 2>/dev/null
            ;;
        dark)
            eza-theme catppuccin-mocha 2>/dev/null
            ;;
        auto|*)
            # Default to dark theme
            eza-theme catppuccin-mocha 2>/dev/null
            ;;
    esac
}
