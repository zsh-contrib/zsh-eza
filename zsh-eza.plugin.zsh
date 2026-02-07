#!/usr/bin/env zsh
#
# zsh-eza - Modern zsh plugin for eza with theme support and smart defaults
# https://github.com/zsh-contrib/zsh-eza
#

# Plugin directory resolution (use ${0:A:h} for portability)
typeset -g ZSH_EZA_DIR="${0:A:h}"

# Dependency check
if ! (( $+commands[eza] )); then
  print "zsh-eza: eza not found. Please install eza before using this plugin." >&2
  print "Visit: https://github.com/eza-community/eza" >&2
  return 1
fi

# Configuration with smart defaults (environment variables)
: ${ZSH_EZA_ENABLE_ALIASES:=true}
: ${ZSH_EZA_AUTO_THEME:=true}
: ${ZSH_EZA_THEME_MODE:=auto}  # auto, light, dark, or theme name

# Build default options using array pattern from zsh-fzf
typeset -ga ZSH_EZA_DEFAULT_OPTS_ITEMS
ZSH_EZA_DEFAULT_OPTS_ITEMS=(
    --group-directories-first
    --color=auto
    --icons=auto
    --git
)

# Helper arrays for alias construction
typeset -ga _EZA_HEAD _EZA_TAIL

# Read zstyle settings and build options array
_zsh_eza_configure_opts() {
    _EZA_HEAD=()
    _EZA_TAIL=()

    # Show group information (default: yes)
    if zstyle -T ':eza:*' 'show-group'; then
        _EZA_HEAD+=(g)
    fi

    # Show header row (default: yes)
    if zstyle -T ':eza:*' 'header'; then
        _EZA_HEAD+=(h)
    fi

    # Icons setting (default: auto)
    local icons_mode
    zstyle -s ':eza:*' 'icons' icons_mode || icons_mode='auto'
    _EZA_TAIL+=(--icons="${icons_mode}")

    # Git status (default: yes)
    if zstyle -T ':eza:*' 'git-status'; then
        _EZA_TAIL+=(--git)
    fi

    # Time style (default: relative)
    local time_style
    zstyle -s ':eza:*' 'time-style' time_style || time_style='relative'
    _EZA_TAIL+=(--time-style="${time_style}")

    # Group directories first (default: yes)
    if zstyle -T ':eza:*' 'group-directories-first'; then
        _EZA_TAIL+=(--group-directories-first)
    fi

    # Color setting (default: auto)
    local color_mode
    zstyle -s ':eza:*' 'color' color_mode || color_mode='auto'
    _EZA_TAIL+=(--color="${color_mode}")
}

# Configure options on load
_zsh_eza_configure_opts

# Alias creation helper
_alias_eza() {
    local alias_name="$1"
    local eza_flags="$2"
    local extra_args="$3"

    # Build the command
    local cmd="eza"

    # Add flags if present
    if [[ -n "$eza_flags" ]]; then
        cmd="${cmd} -${eza_flags}"
    fi

    # Add tail options
    if (( ${#_EZA_TAIL[@]} > 0 )); then
        cmd="${cmd} ${(j: :)_EZA_TAIL}"
    fi

    # Add extra arguments
    if [[ -n "$extra_args" ]]; then
        cmd="${cmd} ${extra_args}"
    fi

    alias "$alias_name"="$cmd"
}

# Create all aliases (Oh My Zsh eza plugin compatibility)
if [[ "$ZSH_EZA_ENABLE_ALIASES" == "true" ]]; then
    # Basic listing aliases
    _alias_eza ls ""                              # Just eza with default options
    _alias_eza la "a"                             # All files including hidden
    _alias_eza ll "l"                             # Long format

    # Special listing modes
    _alias_eza ldot "ld" ".*"                     # List only dotfiles
    _alias_eza lD "lD"                            # Long format, only directories
    _alias_eza lDD "lD" "--tree --level=2"        # Directories, tree view, 2 levels

    # List with specialized sorting
    _alias_eza lS "l" "--sort=size"               # Long format, sorted by size
    _alias_eza lT "l" "--sort=modified"           # Long format, sorted by modification time

    # Tree views
    _alias_eza lsd "la" "--tree --level=2"        # Tree view of all files, 2 levels deep
    _alias_eza lsdl "lDa" "--tree --level=2"      # Tree view of all directories, 2 levels deep
fi

# Clean up helper function
unfunction _alias_eza

# ============================================================================
# Theme Management
# ============================================================================

# Get the eza config directory (respects EZA_CONFIG_DIR)
_zsh_eza_config_dir() {
    echo "${EZA_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/eza}"
}

# Install bundled themes to user's config directory
_zsh_eza_install_themes() {
    local config_dir="$(_zsh_eza_config_dir)"
    local themes_dir="${config_dir}/themes"
    local source_dir="${ZSH_EZA_DIR}/themes"

    # Create themes directory if needed
    if [[ ! -d "$themes_dir" ]]; then
        mkdir -p "$themes_dir" 2>/dev/null || return 1
    fi

    # Install each bundled theme to its own subdirectory
    for theme_file in "$source_dir"/*.yml(N); do
        local theme_name="${theme_file:t:r}"
        local theme_subdir="${themes_dir}/${theme_name}"
        local target_file="${theme_subdir}/theme.yml"

        # Skip README.md
        [[ "$theme_name" == "README" ]] && continue

        # Create theme subdirectory
        if [[ ! -d "$theme_subdir" ]]; then
            mkdir -p "$theme_subdir" 2>/dev/null || continue
        fi

        # Copy theme file if it doesn't exist or is outdated
        if [[ ! -f "$target_file" ]] || [[ "$theme_file" -nt "$target_file" ]]; then
            cp "$theme_file" "$target_file" 2>/dev/null
        fi
    done
}

# List available bundled themes
eza-themes-list() {
    local config_dir="$(_zsh_eza_config_dir)"
    local themes_dir="${config_dir}/themes"

    if [[ ! -d "$themes_dir" ]]; then
        print "zsh-eza: themes directory not found at ${themes_dir}" >&2
        print "Run 'source ~/.zshrc' to reinstall themes" >&2
        return 1
    fi

    print "Available eza themes:\n"

    # Catppuccin themes
    print "Catppuccin:"
    for theme_dir in "$themes_dir"/catppuccin-*(N/); do
        local name="${theme_dir:t}"
        local variant="${name#catppuccin-}"
        if [[ "$variant" == "latte" ]]; then
            print "  - $name (light)"
        else
            print "  - $name (dark)"
        fi
    done

    print "\nRose Pine:"
    for theme_dir in "$themes_dir"/rose-pine*(N/); do
        local name="${theme_dir:t}"
        if [[ "$name" == "rose-pine-dawn" ]]; then
            print "  - $name (light)"
        else
            print "  - $name (dark)"
        fi
    done

    print "\nUsage: eza-theme <theme-name>"
    print "Example: eza-theme catppuccin-mocha"
    print "\nThemes are stored in: ${themes_dir}"
}

# Switch to a theme
eza-theme() {
    local theme_name="$1"

    if [[ -z "$theme_name" ]]; then
        print "Usage: eza-theme <theme-name>" >&2
        print "Run 'eza-themes-list' to see available themes" >&2
        return 1
    fi

    local config_dir="$(_zsh_eza_config_dir)"
    local theme_dir="${config_dir}/themes/${theme_name}"
    local theme_file="${theme_dir}/theme.yml"
    local active_theme="${config_dir}/theme.yml"

    # Check if theme exists
    if [[ ! -f "$theme_file" ]]; then
        print "zsh-eza: theme '${theme_name}' not found at ${theme_file}" >&2
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

    # Backup existing theme if present and not a symlink
    if [[ -f "$active_theme" ]] && [[ ! -L "$active_theme" ]]; then
        local backup_file="${active_theme}.backup.$(date +%s)"
        mv "$active_theme" "$backup_file" 2>/dev/null
        print "zsh-eza: backed up existing theme to ${backup_file}"
    fi

    # Remove existing symlink if present
    if [[ -L "$active_theme" ]]; then
        rm "$active_theme" 2>/dev/null
    fi

    # Create symlink to theme
    ln -sf "$theme_file" "$active_theme" 2>/dev/null || {
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

# Install bundled themes to user's config directory
_zsh_eza_install_themes

# Auto-detect and apply theme if enabled
if [[ "$ZSH_EZA_AUTO_THEME" == "true" ]]; then
    _zsh_eza_auto_theme
fi
