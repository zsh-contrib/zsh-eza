#!/usr/bin/env bats

# Tests for zsh-eza plugin
#
# Requires bats-core: https://github.com/bats-core/bats-core
# Run: bats tests/plugin.bats

export PLUGIN_DIR
PLUGIN_DIR="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

setup() {
  if ! command -v eza &>/dev/null; then
    skip "eza is not installed"
  fi
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
  run zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    alias ls
  '
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"eza"* ]]
}

@test "ll alias includes long format flag" {
  run zsh -c '
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
  run zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    alias la
  '
  [[ "$status" -eq 0 ]]
  # -a may be combined with other flags (e.g. -ga)
  local re='eza -[[:alpha:]]*a'
  [[ "$output" =~ $re ]]
}

@test "lS alias includes sort-by-size option" {
  run zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    alias lS
  '
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--sort=size"* ]]
}

@test "lT alias includes sort-by-modified option" {
  run zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    alias lT
  '
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--sort=modified"* ]]
}

@test "lDD alias includes tree and level options" {
  run zsh -c '
    source "$PLUGIN_DIR/zsh-eza.plugin.zsh"
    alias lDD
  '
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--tree"* ]]
  [[ "$output" == *"--level=2"* ]]
}

@test "ZSH_EZA_ENABLE_ALIASES=false disables all aliases" {
  run zsh -c '
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
