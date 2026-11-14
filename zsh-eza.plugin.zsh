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

typeset -ga ZSH_EZA_DEFAULT_OPTS_ITEMS
# Build default options using array pattern
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
    if zstyle -T ':zsh-eza' 'show-group'; then
        _EZA_HEAD+=(g)
    fi

    # Show header row (default: no)
    if zstyle -t ':zsh-eza' 'header'; then
        _EZA_HEAD+=(h)
    fi

    # Icons setting (default: auto)
    local icons_mode
    zstyle -s ':zsh-eza' 'icons' icons_mode || icons_mode='auto'
    _EZA_TAIL+=(--icons="${icons_mode}")

    # Git status (default: yes)
    if zstyle -T ':zsh-eza' 'git-status'; then
        _EZA_TAIL+=(--git)
    fi

    # Time style (default: relative)
    local time_style
    zstyle -s ':zsh-eza' 'time-style' time_style || time_style='relative'
    _EZA_TAIL+=(--time-style="${time_style}")

    # Group directories first (default: yes) - support both option names
    if zstyle -T ':zsh-eza' 'dirs-first' || \
       zstyle -T ':zsh-eza' 'group-directories-first'; then
        _EZA_TAIL+=(--group-directories-first)
    fi

    # Color setting (default: auto)
    local color_mode
    zstyle -s ':zsh-eza' 'color' color_mode || color_mode='auto'
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

    # Combine HEAD flags with provided flags
    local combined_flags=""
    if (( ${#_EZA_HEAD[@]} > 0 )); then
        combined_flags="${(j::)_EZA_HEAD}"  # Join without separator
    fi
    if [[ -n "$eza_flags" ]]; then
        combined_flags="${combined_flags}${eza_flags}"
    fi

    # Add combined flags if present
    if [[ -n "$combined_flags" ]]; then
        cmd="${cmd} -${combined_flags}"
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
# Aliases are for interactive use only: non-interactive shells (scripts,
# `zsh -c`, anything sourcing this from .zshenv) keep the real commands.
if [[ "$ZSH_EZA_ENABLE_ALIASES" == "true" && -o interactive ]]; then
    # Basic listing aliases
    # `ls` can be left alone: zstyle ':zsh-eza' 'alias-ls' no
    if zstyle -T ':zsh-eza' 'alias-ls'; then
        _alias_eza ls ""                          # Just eza with default options
    fi
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
    # Don't shadow the lsd (LSDeluxe) binary if it is installed
    if (( ! $+commands[lsd] )); then
        _alias_eza lsd "la" "--tree --level=2"    # Tree view of all files, 2 levels deep
    fi
    _alias_eza lsdl "lDa" "--tree --level=2"      # Tree view of all directories, 2 levels deep
fi

# Clean up helper function
unfunction _alias_eza

# Theme configuration
# An EZA_THEME you set yourself is "pinned": it wins over macOS appearance
# detection (tmux detection still applies). A value merely inherited from a
# parent shell's plugin load is not pinned, so nested shells keep following
# the system appearance.
typeset -g _zsh_eza_pinned=0
if [[ -n "$EZA_THEME" && "$EZA_THEME" != "$_ZSH_EZA_APPLIED_THEME" ]]; then
    _zsh_eza_pinned=1
fi

export EZA_THEME="${EZA_THEME:-catppuccin-mocha}"
export EZA_THEME_DARK="${EZA_THEME_DARK:-catppuccin-mocha}"
export EZA_THEME_LIGHT="${EZA_THEME_LIGHT:-catppuccin-latte}"

# Print the theme directory for a theme name or absolute path
_zsh_eza_theme_dir() {
    local theme="$1"

    if [[ "$theme" == /* ]]; then
        print -r -- "$theme"
    else
        print -r -- "${ZSH_EZA_DIR}/themes/${theme}"
    fi
}

# Print "light" or "dark" from the tmux client or macOS appearance.
# Prints nothing when no signal is available.
#
# Arguments:
#   $1 - (optional) "no-macos" to skip the macOS appearance check
_zsh_eza_detect_mode() {
    if [[ -n "$TMUX" ]] && (( $+commands[tmux] )); then
        local client_theme
        client_theme="$(tmux display -p "#{client_theme}" 2>/dev/null)"
        if [[ "$client_theme" == (light|dark) ]]; then
            print -r -- "$client_theme"
            return
        fi
    fi

    if [[ "$1" != "no-macos" && "$OSTYPE" == darwin* ]] && (( $+commands[defaults] )); then
        # AppleInterfaceStyle exists only in dark mode
        if defaults read -g AppleInterfaceStyle &>/dev/null; then
            print dark
        else
            print light
        fi
    fi
}

# Print the theme to use, honouring ZSH_EZA_THEME_MODE and ZSH_EZA_AUTO_THEME
_zsh_eza_resolve_theme() {
    case "$ZSH_EZA_THEME_MODE" in
        light) print -r -- "$EZA_THEME_LIGHT" ;;
        dark)  print -r -- "$EZA_THEME_DARK" ;;
        auto)
            local mode=""
            if [[ "$ZSH_EZA_AUTO_THEME" == "true" ]]; then
                # A pinned EZA_THEME wins over macOS appearance, but not over tmux
                if (( _zsh_eza_pinned )); then
                    mode="$(_zsh_eza_detect_mode no-macos)"
                else
                    mode="$(_zsh_eza_detect_mode)"
                fi
            fi
            case "$mode" in
                light) print -r -- "$EZA_THEME_LIGHT" ;;
                dark)  print -r -- "$EZA_THEME_DARK" ;;
                *)     print -r -- "$EZA_THEME" ;;
            esac
            ;;
        *) print -r -- "$ZSH_EZA_THEME_MODE" ;;  # explicit theme name
    esac
}

# Share the active theme with the tmux server, so that what tmux starts
# (run-shell, popups) does not keep the theme of the shell that started the
# server, which could only look at the macOS appearance.
_zsh_eza_sync_tmux() {
    [[ -n "$TMUX" ]] && (( $+commands[tmux] )) || return 0
    local var
    for var in EZA_THEME EZA_THEME_DIR EZA_CONFIG_DIR; do
        [[ -n "${(P)var}" ]] && tmux set-environment -g "$var" "${(P)var}" &>/dev/null
    done
    return 0
}

# Point eza at a theme (name or absolute path) for the current shell, and
# share it with tmux
_zsh_eza_apply_theme() {
    local theme="$1"
    local dir
    dir="$(_zsh_eza_theme_dir "$theme")"

    export EZA_THEME="$theme"
    export EZA_THEME_DIR="$dir"
    if [[ -d "$dir" ]]; then
        export EZA_CONFIG_DIR="$dir"
    fi

    _zsh_eza_sync_tmux
}

# List bundled themes, marking the active one
eza-themes-list() {
    local dir name
    for dir in "$ZSH_EZA_DIR"/themes/*(/N); do
        name="${dir:t}"
        if [[ "$name" == "$EZA_THEME" ]]; then
            print "* $name"
        else
            print "  $name"
        fi
    done
}

# Switch theme in the current shell. With no argument, print the active theme.
eza-theme() {
    if (( $# == 0 )); then
        print -r -- "$EZA_THEME"
        return 0
    fi

    local theme="$1"
    local dir
    dir="$(_zsh_eza_theme_dir "$theme")"

    if [[ ! -f "$dir/theme.yml" ]]; then
        print "eza-theme: no theme.yml found for '$theme' (looked in $dir)" >&2
        print "Run eza-themes-list to see available themes." >&2
        return 1
    fi

    _zsh_eza_apply_theme "$theme"
}

# ZSH_EZA_THEME_MODE: auto, light, dark, or a theme name
_zsh_eza_apply_theme "$(_zsh_eza_resolve_theme)"

# Remember what was auto-applied so child shells can tell it from a pin
if (( ! _zsh_eza_pinned )); then
    export _ZSH_EZA_APPLIED_THEME="$EZA_THEME"
fi

if [[ "$EZA_THEME" == /* && ! -f "$EZA_THEME_DIR/theme.yml" ]]; then
    print "zsh-eza: no theme.yml found in custom theme directory: $EZA_THEME_DIR" >&2
fi
