# Development Workflow

This document outlines the development workflow for the nix-config repository, including code quality, formatting, and contribution guidelines.

## 🔧 Pre-commit Hooks

The repository uses pre-commit hooks to ensure code quality and consistency. These hooks run automatically before each commit to catch issues early.

### Setup

1. **Ensure packages are installed**: The required tools are included in your nix configuration
2. **Run the setup script**:
   ```bash
   ./scripts/setup-precommit.sh
   ```

### Configured Hooks

- **File Quality Checks**:
  - Trailing whitespace removal
  - End of file fixing
  - Line ending normalization (LF)
  - Merge conflict detection

- **Format Validation**:
  - YAML syntax checking
  - JSON syntax checking
  - TOML syntax checking

- **Nix-specific Checks**:
  - `nixpkgs-fmt`: Nix code formatting
  - `nix flake check`: Flake validation (no build)

- **Security**:
  - `detect-secrets`: Prevents committing secrets
  - `shellcheck`: Shell script analysis

### Manual Execution

Run hooks manually on all files:
```bash
pre-commit run --all-files
```

Run specific hook:
```bash
pre-commit run nixpkgs-fmt --all-files
```

## 📝 Code Formatting

### Nix Files
- Use `nixpkgs-fmt` for consistent formatting
- 2-space indentation
- Consistent attribute formatting

### Shell Scripts
- Follow `shellcheck` recommendations
- Use `#!/usr/bin/env bash` shebang
- Include `set -euo pipefail` for safety

## 🔍 Code Quality Standards

### Configuration Files
- Use clear, descriptive names for options
- Include comments for complex configurations
- Group related configurations together
- Use module system for reusable components

### Documentation
- Keep README.md up to date
- Document any new hosts or modules
- Include examples for configuration options
- Maintain troubleshooting sections

## 🚀 Contribution Workflow

1. **Create a branch** for your changes
2. **Make changes** following the guidelines above
3. **Test locally**:
   ```bash
   # For NixOS
   nixos-rebuild build --flake .#<hostname>

   # For Darwin
   darwin-rebuild build --flake .#mbp
   ```
4. **Commit changes** (pre-commit hooks will run automatically)
5. **Push and create pull request** if collaborating

## 🔄 Maintenance Tasks

### Regular Updates
- Update flake inputs monthly: `nix flake update`
- Review and update dependencies
- Test configurations after updates

### Security
- Rotate secrets as needed using SOPS
- Review SSH keys and access
- Update security configurations

### Performance
- Monitor rebuild times
- Profile slow configurations
- Optimize as needed

## 🛠️ Troubleshooting

### Pre-commit Issues

**Hook fails to run**:
```bash
# Reinstall hooks
pre-commit install --install-hooks
```

**Secrets detection false positive**:
```bash
# Update baseline
detect-secrets scan --baseline .secrets.baseline --force-use-all-plugins
```

**Nix formatting issues**:
```bash
# Format all Nix files
find . -name "*.nix" -exec nixpkgs-fmt {} \;
```

### Build Issues

**Flake check fails**:
```bash
# Check specific configuration
nix flake check --show-trace
```

**Hardware configuration outdated**:
```bash
# Regenerate for current system
sudo nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
```

## 📚 Resources

- [Pre-commit Documentation](https://pre-commit.com/)
- [nixpkgs-fmt](https://github.com/nix-community/nixpkgs-fmt)
- [Shellcheck](https://www.shellcheck.net/)
- [SOPS](https://github.com/Mic92/sops-nix)
