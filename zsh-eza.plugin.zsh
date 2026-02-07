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

# Load theme manager
if [[ -f "${ZSH_EZA_DIR}/lib/theme-manager.zsh" ]]; then
    source "${ZSH_EZA_DIR}/lib/theme-manager.zsh"

    # Auto-detect and apply theme if enabled
    if [[ "$ZSH_EZA_AUTO_THEME" == "true" ]]; then
        _zsh_eza_auto_theme
    fi
fi
