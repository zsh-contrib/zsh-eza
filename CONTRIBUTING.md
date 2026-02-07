# Contributing to zsh-eza

Thank you for your interest in contributing to zsh-eza! This document provides guidelines and information for contributors.

## Development Setup

1. Fork and clone the repository:
   ```bash
   git clone https://github.com/your-username/zsh-eza
   cd zsh-eza
   ```

2. Test the plugin locally:
   ```bash
   source ./zsh-eza.plugin.zsh
   ```

## Code Style

### Shell Script Guidelines

- Follow existing code patterns (reference: zsh-fzf plugin)
- Use `${0:A:h}` for plugin directory resolution
- Use array-based configuration: `${(j: :)array}` for joining
- Check command availability: `(( $+commands[cmd] ))`
- Use `: ${VAR:=default}` for default values
- Prefer dedicated tools over bash commands (Read, Edit, Grep, Glob)

### Naming Conventions

- **Functions**: Use prefixes for scoping
  - Public functions: `eza-theme`, `eza-themes-list`
  - Private functions: `_zsh_eza_function_name`
- **Variables**:
  - Plugin variables: `ZSH_EZA_*`
  - Internal variables: `_EZA_*`
- **zstyle namespace**: `:eza:*`

### Comments

- Add comments for non-obvious logic
- Document function parameters and return values
- Explain why, not what (code shows what)

## Testing

Before submitting a PR, ensure:

1. **Syntax check**:
   ```bash
   zsh -n zsh-eza.plugin.zsh
   zsh -n lib/theme-manager.zsh
   ```

2. **Load test**:
   ```bash
   zsh -c "source ./zsh-eza.plugin.zsh && echo 'OK'"
   ```

3. **Alias test**:
   ```bash
   zsh -c "source ./zsh-eza.plugin.zsh && alias | grep eza"
   ```

4. **Theme test**:
   ```bash
   zsh -c "source ./zsh-eza.plugin.zsh && eza-themes-list && eza-theme catppuccin-mocha"
   ```

5. **Configuration test**:
   ```bash
   zsh -c "ZSH_EZA_ENABLE_ALIASES=false source ./zsh-eza.plugin.zsh && ! alias la"
   ```

## Adding New Themes

1. Download theme from [eza-themes](https://github.com/eza-community/eza-themes):
   ```bash
   curl -sL https://raw.githubusercontent.com/eza-community/eza-themes/main/themes/THEME_NAME.yml \
     -o themes/THEME_NAME.yml
   ```

2. Verify the theme file is valid YAML

3. Update `themes/README.md` with theme information

4. Test theme installation and switching:
   ```bash
   # Source plugin to install themes
   source ./zsh-eza.plugin.zsh

   # Verify theme was installed
   ls ~/.config/eza/themes/THEME_NAME/theme.yml

   # Switch to theme
   eza-theme THEME_NAME

   # Verify colors work
   ls -l
   ```

5. Test with custom `EZA_CONFIG_DIR`:
   ```bash
   EZA_CONFIG_DIR="/tmp/test" zsh -c "source ./zsh-eza.plugin.zsh && eza-theme THEME_NAME"
   ```

## Adding New Features

### Before Starting

1. Check existing issues for similar feature requests
2. Create an issue describing your proposed feature
3. Wait for maintainer feedback before implementing large changes

### Implementation Guidelines

- **Maintain backward compatibility**: Don't break existing configurations
- **Follow the plugin architecture**:
  - Core logic in `zsh-eza.plugin.zsh`
  - Theme management in `lib/theme-manager.zsh`
  - New subsystems in separate `lib/*.zsh` files
- **Update documentation**:
  - Add feature to README.md
  - Update QUICKSTART.md if relevant
  - Add examples

### Feature Checklist

- [ ] Implementation follows existing patterns
- [ ] Code is commented appropriately
- [ ] Documentation updated (README.md)
- [ ] Quick start updated if needed (QUICKSTART.md)
- [ ] Manual testing performed
- [ ] No syntax errors
- [ ] Backward compatible

## Pull Request Process

1. **Create a descriptive branch name**:
   ```bash
   git checkout -b feature/theme-preview
   git checkout -b fix/alias-escaping
   ```

2. **Make focused commits**:
   - One logical change per commit
   - Write clear commit messages
   - Follow format: `Add X`, `Fix Y`, `Update Z`

3. **Test thoroughly**:
   - Run all tests listed above
   - Test with different plugin managers (zinit, manual)
   - Test on different systems if possible

4. **Update documentation**:
   - README.md for new features
   - Code comments for complex logic
   - CHANGELOG.md (if it exists)

5. **Submit PR**:
   - Provide clear description of changes
   - Link related issues
   - Include test results
   - Add before/after examples if relevant

## Commit Message Format

Follow conventional commit format:

```
<type>: <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

Examples:
```
feat: add theme preview command

Add eza-theme-preview command to display theme colors
before switching. Uses eza to show sample output with
each available theme.

Closes #42
```

```
fix: properly escape paths with spaces in aliases

Wrap all path arguments in quotes to handle spaces correctly.
Fixes issue where "My Documents" directory caused errors.

Fixes #15
```

## Code Review

All PRs require review before merging. Reviewers will check:

- Code quality and style
- Test coverage
- Documentation completeness
- Backward compatibility
- Performance impact

## Questions?

- Open an issue for questions
- Check existing issues/PRs for similar discussions
- Be patient - maintainers are volunteers

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
