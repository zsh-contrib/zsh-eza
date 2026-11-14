#!/usr/bin/env bats

# Tests for zsh-eza plugin
#
# Requires bats-core: https://github.com/bats-core/bats-core
# Run: bats tests/plugin.bats

export PLUGIN_DIR
PLUGIN_DIR="$(cd "$BATS_TEST_DIRNAME/.." && pwd -P)"

setup() {
  if ! command -v eza &>/dev/null; then
    skip "eza is not installed"
  fi

  # Keep tests independent of the host: no tmux, no appearance detection.
  # Detection tests opt back in explicitly.
  unset TMUX EZA_THEME _ZSH_EZA_APPLIED_THEME
  export ZSH_EZA_AUTO_THEME=false
}

# ---------------------------------------------------------------------------
# Plugin loading
# ---------------------------------------------------------------------------

@test "plugin loads without error when eza is available" {
  run zsh -c 'source "$PLUGIN_DIR/zsh-eza.plugin.zsh"'
  [[ "$status" -eq 0 ]]
}

@test "plugin exits with error when eza is not in PATH" {
  run zsh -c '
    # Override PATH to hide eza
    local tmpdir=$(mktemp -d)
    export PATH="$tmpdir"
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh" 2>/dev/null
  '
  [[ "$status" -ne 0 ]]
}

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------

@test "ls alias is defined by default" {
  run zsh -fic '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    alias ls
  '
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"eza"* ]]
}

@test "ll alias includes long format flag" {
  run zsh -fic '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    alias ll
  '
  [[ "$status" -eq 0 ]]
  # -l may be combined with other flags (e.g. -gl); use a variable so bash
  # treats it as a regex rather than a literal string
  local re='eza -[[:alpha:]]*l'
  [[ "$output" =~ $re ]]
}

@test "la alias includes all-files flag" {
  run zsh -fic '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    alias la
  '
  [[ "$status" -eq 0 ]]
  # -a may be combined with other flags (e.g. -ga)
  local re='eza -[[:alpha:]]*a'
  [[ "$output" =~ $re ]]
}

@test "lS alias includes sort-by-size option" {
  run zsh -fic '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    alias lS
  '
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--sort=size"* ]]
}

@test "lT alias includes sort-by-modified option" {
  run zsh -fic '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    alias lT
  '
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--sort=modified"* ]]
}

@test "lDD alias includes tree and level options" {
  run zsh -fic '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    alias lDD
  '
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--tree"* ]]
  [[ "$output" == *"--level=2"* ]]
}

@test "ZSH_EZA_ENABLE_ALIASES=false disables all aliases" {
  run zsh -fic '
    export ZSH_EZA_ENABLE_ALIASES=false
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    alias ls 2>/dev/null && echo "defined" || echo "undefined"
  '
  [[ "$status" -eq 0 ]]
  [[ "$output" != *"eza"* ]]
}

# ---------------------------------------------------------------------------
# Theme
# ---------------------------------------------------------------------------

@test "EZA_THEME defaults to catppuccin-mocha" {
  run zsh -c '
    unset EZA_THEME
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    echo "$EZA_THEME"
  '
  [[ "$status" -eq 0 ]]
  [[ "$output" == "catppuccin-mocha" ]]
}

@test "EZA_THEME_DARK defaults to catppuccin-mocha" {
  run zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    echo "$EZA_THEME_DARK"
  '
  [[ "$status" -eq 0 ]]
  [[ "$output" == "catppuccin-mocha" ]]
}

@test "EZA_THEME_LIGHT defaults to catppuccin-latte" {
  run zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    echo "$EZA_THEME_LIGHT"
  '
  [[ "$status" -eq 0 ]]
  [[ "$output" == "catppuccin-latte" ]]
}

@test "EZA_THEME_DIR points to a themes subdirectory" {
  run zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    echo "$EZA_THEME_DIR"
  '
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"/themes/"* ]]
}

@test "EZA_CONFIG_DIR is set when theme directory exists" {
  run zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    [[ -n "$EZA_CONFIG_DIR" ]] && echo "set" || echo "unset"
  '
  [[ "$status" -eq 0 ]]
  [[ "$output" == "set" ]]
}

@test "EZA_THEME absolute path is used as the custom theme directory" {
  local dir
  dir="$(mktemp -d)"
  : > "$dir/theme.yml"
  run env -u TMUX zsh -c '
    export EZA_THEME="$1"
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    echo "$EZA_THEME_DIR"
    echo "$EZA_CONFIG_DIR"
  ' _ "$dir"
  rm -rf "$dir"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "$dir" ]]
  [[ "${lines[1]}" == "$dir" ]]
}

@test "EZA_THEME absolute path without theme.yml warns" {
  local dir
  dir="$(mktemp -d)"
  run env -u TMUX zsh -c '
    export EZA_THEME="$1"
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
  ' _ "$dir"
  rm -rf "$dir"
  [[ "$output" == *"no theme.yml found"* ]]
}

@test "EZA_THEME_DARK absolute path is used under tmux dark mode" {
  local dir bin
  dir="$(mktemp -d)"
  bin="$(mktemp -d)"
  : > "$dir/theme.yml"
  printf '#!/bin/sh\necho dark\n' > "$bin/tmux"
  chmod +x "$bin/tmux"
  run env TMUX=fake ZSH_EZA_AUTO_THEME=true PATH="$bin:$PATH" EZA_THEME_DARK="$dir" zsh -c '
    unset EZA_THEME
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    echo "$EZA_CONFIG_DIR"
  '
  rm -rf "$dir" "$bin"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$dir" ]]
}

# ---------------------------------------------------------------------------
# Theme mode and auto detection
# ---------------------------------------------------------------------------

# Create a fake executable in a temp bin dir; echoes the dir. Usage: _fake name body
_fake() {
  local bin="${FAKE_BIN:-$(mktemp -d)}"
  printf '#!/bin/sh\n%s\n' "$2" > "$bin/$1"
  chmod +x "$bin/$1"
  echo "$bin"
}

@test "ZSH_EZA_THEME_MODE=light selects EZA_THEME_LIGHT" {
  run env ZSH_EZA_THEME_MODE=light zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"; echo "$EZA_THEME"'
  [[ "$output" == "catppuccin-latte" ]]
}

@test "ZSH_EZA_THEME_MODE=dark selects EZA_THEME_DARK" {
  run env ZSH_EZA_THEME_MODE=dark EZA_THEME_DARK=rose-pine zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"; echo "$EZA_THEME"'
  [[ "$output" == "rose-pine" ]]
}

@test "ZSH_EZA_THEME_MODE accepts a theme name" {
  run env ZSH_EZA_THEME_MODE=rose-pine-moon zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"; echo "$EZA_THEME $EZA_CONFIG_DIR"'
  [[ "$output" == "rose-pine-moon $PLUGIN_DIR/themes/rose-pine-moon" ]]
}

@test "auto detection: tmux light client selects EZA_THEME_LIGHT" {
  local bin; bin="$(_fake tmux 'echo light')"
  run env TMUX=fake ZSH_EZA_AUTO_THEME=true PATH="$bin:$PATH" zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"; echo "$EZA_THEME"'
  rm -rf "$bin"
  [[ "$output" == "catppuccin-latte" ]]
}

@test "auto detection: ZSH_EZA_AUTO_THEME=false ignores tmux client theme" {
  local bin; bin="$(_fake tmux 'echo light')"
  run env TMUX=fake ZSH_EZA_AUTO_THEME=false PATH="$bin:$PATH" zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"; echo "$EZA_THEME"'
  rm -rf "$bin"
  [[ "$output" == "catppuccin-mocha" ]]
}

@test "auto detection: macOS dark appearance selects EZA_THEME_DARK" {
  local bin; bin="$(_fake defaults 'echo Dark')"
  run env ZSH_EZA_AUTO_THEME=true PATH="$bin:$PATH" zsh -c '
    OSTYPE=darwin24.0
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"; echo "$EZA_THEME"'
  rm -rf "$bin"
  [[ "$output" == "catppuccin-mocha" ]]
}

@test "auto detection: macOS light appearance selects EZA_THEME_LIGHT" {
  local bin; bin="$(_fake defaults 'exit 1')"
  run env ZSH_EZA_AUTO_THEME=true PATH="$bin:$PATH" zsh -c '
    OSTYPE=darwin24.0
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"; echo "$EZA_THEME"'
  rm -rf "$bin"
  [[ "$output" == "catppuccin-latte" ]]
}

@test "auto detection: pinned EZA_THEME wins over macOS appearance" {
  local bin; bin="$(_fake defaults 'echo Dark')"
  run env ZSH_EZA_AUTO_THEME=true EZA_THEME=rose-pine-dawn PATH="$bin:$PATH" zsh -c '
    OSTYPE=darwin24.0
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"; echo "$EZA_THEME"'
  rm -rf "$bin"
  [[ "$output" == "rose-pine-dawn" ]]
}

@test "auto detection: pinned EZA_THEME is still overridden by tmux" {
  local bin; bin="$(_fake tmux 'echo light')"
  run env TMUX=fake ZSH_EZA_AUTO_THEME=true EZA_THEME=rose-pine PATH="$bin:$PATH" zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"; echo "$EZA_THEME"'
  rm -rf "$bin"
  [[ "$output" == "catppuccin-latte" ]]
}

@test "auto detection: theme inherited from a parent shell is not pinned" {
  local bin; bin="$(_fake defaults 'exit 1')"
  run env ZSH_EZA_AUTO_THEME=true EZA_THEME=catppuccin-mocha \
    _ZSH_EZA_APPLIED_THEME=catppuccin-mocha PATH="$bin:$PATH" zsh -c '
    OSTYPE=darwin24.0
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"; echo "$EZA_THEME"'
  rm -rf "$bin"
  [[ "$output" == "catppuccin-latte" ]]
}

@test "auto detection: a pin survives into a nested shell" {
  local bin; bin="$(_fake defaults 'exit 1')"
  run env ZSH_EZA_AUTO_THEME=true EZA_THEME=rose-pine PATH="$bin:$PATH" zsh -c '
    OSTYPE=darwin24.0
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    zsh -c "OSTYPE=darwin24.0; source \"\$PLUGIN_DIR/zsh-eza.plugin.zsh\"; echo \$EZA_THEME"'
  rm -rf "$bin"
  [[ "$output" == "rose-pine" ]]
}

@test "auto detection: auto-applied theme follows appearance in a nested shell" {
  local bin; bin="$(_fake defaults 'echo Dark')"
  run env ZSH_EZA_AUTO_THEME=true PATH="$bin:$PATH" zsh -c '
    OSTYPE=darwin24.0
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    printf "#!/bin/sh\nexit 1\n" > "'"$bin"'/defaults"
    zsh -c "OSTYPE=darwin24.0; source \"\$PLUGIN_DIR/zsh-eza.plugin.zsh\"; echo \$EZA_THEME"'
  rm -rf "$bin"
  [[ "$output" == "catppuccin-latte" ]]
}

@test "auto detection: no signal falls back to EZA_THEME" {
  run env ZSH_EZA_AUTO_THEME=true EZA_THEME=rose-pine zsh -c '
    OSTYPE=linux-gnu
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"; echo "$EZA_THEME"'
  [[ "$output" == "rose-pine" ]]
}

# ---------------------------------------------------------------------------
# eza-theme / eza-themes-list
# ---------------------------------------------------------------------------

@test "eza-theme switches theme and updates EZA_CONFIG_DIR" {
  run zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    eza-theme rose-pine-dawn
    echo "$EZA_THEME $EZA_CONFIG_DIR"'
  [[ "$status" -eq 0 ]]
  [[ "$output" == "rose-pine-dawn $PLUGIN_DIR/themes/rose-pine-dawn" ]]
}

@test "eza-theme accepts a custom theme directory" {
  local dir; dir="$(mktemp -d)"; : > "$dir/theme.yml"
  run zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    eza-theme "$1"
    echo "$EZA_CONFIG_DIR"' _ "$dir"
  rm -rf "$dir"
  [[ "$output" == "$dir" ]]
}

@test "eza-theme with unknown theme fails and keeps current theme" {
  run zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    eza-theme nope 2>&1
    rc=$?
    echo "rc=$rc theme=$EZA_THEME"'
  [[ "$output" == *"no theme.yml found for 'nope'"* ]]
  [[ "$output" == *"rc=1 theme=catppuccin-mocha"* ]]
}

@test "eza-theme with no argument prints the active theme" {
  run zsh -c 'source "$PLUGIN_DIR/zsh-eza.plugin.zsh"; eza-theme'
  [[ "$output" == "catppuccin-mocha" ]]
}

@test "eza-themes-list lists bundled themes and marks the active one" {
  run zsh -c 'source "$PLUGIN_DIR/zsh-eza.plugin.zsh"; eza-themes-list'
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 7 ]]
  [[ "$output" == *"* catppuccin-mocha"* ]]
  [[ "$output" == *"  rose-pine-dawn"* ]]
}

# ---------------------------------------------------------------------------
# Alias opt-outs and interactive-only
# ---------------------------------------------------------------------------

@test "aliases are not defined in non-interactive shells" {
  run zsh -fc '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    alias ls 2>/dev/null && echo "defined" || echo "undefined"
  '
  [[ "$output" == "undefined" ]]
}

@test "zstyle alias-ls no leaves ls alone but keeps other aliases" {
  run zsh -fic '
    zstyle ":zsh-eza" "alias-ls" no
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    alias ls 2>/dev/null && echo "ls defined" || echo "ls undefined"
    alias ll >/dev/null && echo "ll defined"
  '
  [[ "$output" == *"ls undefined"* ]]
  [[ "$output" == *"ll defined"* ]]
}

@test "lsd alias is skipped when an lsd binary exists" {
  local bin; bin="$(mktemp -d)"
  printf '#!/bin/sh\n' > "$bin/lsd"; chmod +x "$bin/lsd"
  run env PATH="$bin:$PATH" zsh -fic '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    alias lsd 2>/dev/null && echo "lsd defined" || echo "lsd undefined"
    alias lsdl >/dev/null && echo "lsdl defined"
  '
  rm -rf "$bin"
  [[ "$output" == *"lsd undefined"* ]]
  [[ "$output" == *"lsdl defined"* ]]
}

@test "lsd alias is defined when no lsd binary exists" {
  run zsh -fic '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    (( $+commands[lsd] )) && { echo "skip: lsd installed"; exit 0 }
    alias lsd >/dev/null && echo "lsd defined"
  '
  [[ "$output" == *"lsd defined"* || "$output" == *"skip: lsd installed"* ]]
}

@test "inside tmux the theme is shared with the tmux server environment" {
  local log; log="$(mktemp)"
  local bin; bin="$(_fake tmux 'if [ "$1" = display ]; then echo dark; else echo "$@" >> "$TMUX_LOG"; fi')"
  run env TMUX=fake TMUX_LOG="$log" ZSH_EZA_AUTO_THEME=true PATH="$bin:$PATH" zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"'
  local out; out="$(cat "$log")"
  rm -rf "$bin" "$log"
  [[ "$out" == *"set-environment -g EZA_THEME catppuccin-mocha"* ]]
  [[ "$out" == *"set-environment -g EZA_THEME_DIR"* ]]
}

@test "outside tmux nothing is shared with tmux" {
  local log; log="$(mktemp)"
  local bin; bin="$(_fake tmux 'echo "$@" >> "$TMUX_LOG"')"
  run env TMUX_LOG="$log" PATH="$bin:$PATH" zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"'
  local out; out="$(cat "$log")"
  rm -rf "$bin" "$log"
  [[ -z "$out" ]]
}
