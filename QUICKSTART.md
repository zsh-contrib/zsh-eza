# Quick Start Guide

## 1. Install eza

```bash
# macOS
brew install eza

# Arch Linux
sudo pacman -S eza

# Other systems
# See: https://github.com/eza-community/eza#installation
```

## 2. Install zsh-eza

### With zinit (recommended)

Add to your `.zshrc`:

```zsh
zinit light zsh-contrib/zsh-eza
```

### Manual installation

```bash
git clone https://github.com/zsh-contrib/zsh-eza ~/.zsh/zsh-eza
echo 'source ~/.zsh/zsh-eza/zsh-eza.plugin.zsh' >> ~/.zshrc
```

## 3. Reload your shell

```bash
source ~/.zshrc
```

## 4. Start using it!

```bash
ls          # Use eza instead of ls
ll          # Long listing format
la          # List all files including hidden
lT          # Sort by modification time
lS          # Sort by size
lDD         # Tree view of directories
```

## 5. Explore themes

```bash
eza-themes-list              # See all available themes
eza-theme rose-pine-dawn     # Switch to a light theme
eza-theme catppuccin-mocha   # Switch to a dark theme
```

## That's it!

The plugin automatically:
- ✅ Configures sensible defaults
- ✅ Creates all useful aliases
- ✅ Detects your light/dark preference
- ✅ Applies an appropriate theme

For advanced configuration, see [README.md](README.md)
