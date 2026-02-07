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

# Theme configuration
export EZA_THEME="${EZA_THEME:-catppuccin-mocha}"
export EZA_THEME_DARK="${EZA_THEME_DARK:-catppuccin-mocha}"
export EZA_THEME_LIGHT="${EZA_THEME_LIGHT:-catppuccin-latte}"

if [[ -n "$TMUX" ]]; then
  TMUX_CLIENT_THEME="$(tmux display -p "#{client_theme}")"

  if [[ "$TMUX_CLIENT_THEME" == "light" ]]; then
    export EZA_THEME="$EZA_THEME_LIGHT"
  else
    export EZA_THEME="$EZA_THEME_DARK"
  fi
fi

export EZA_THEME_DIR="${0:A:h}/themes"
# Load theme file
if [[ -f "$EZA_THEME_DIR/$EZA_THEME" ]]; then
    export EZA_CONFIG_DIR="$EZA_THEME_DIR/$EZA_THEME"
fi
