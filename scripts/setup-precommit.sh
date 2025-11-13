#!/usr/bin/env bash
# Pre-commit setup script for nix-config repository

set -euo pipefail

echo "🔧 Setting up pre-commit hooks for nix-config repository..."

# Check if we're in the right directory
if [[ ! -f "flake.nix" ]]; then
    echo "❌ Error: This script must be run from the nix-config repository root"
    exit 1
fi

# Check if pre-commit is available
if ! command -v pre-commit &> /dev/null; then
    echo "❌ Error: pre-commit is not available in PATH"
    echo "Please ensure you've rebuilt your configuration with the updated packages:"
    echo "  darwin-rebuild switch --flake .#mbp"
    exit 1
fi

# Install pre-commit hooks
echo "📦 Installing pre-commit hooks..."
pre-commit install

# Create secrets baseline if it doesn't exist
if [[ ! -f ".secrets.baseline" ]]; then
    echo "🔐 Creating secrets baseline..."
    detect-secrets scan --baseline .secrets.baseline
fi

# Run initial check to make sure everything works
echo "✅ Running initial pre-commit check..."
if pre-commit run --all-files; then
    echo "🎉 Pre-commit setup completed successfully!"
    echo ""
    echo "📋 What's been set up:"
    echo "  - Pre-commit hooks installed"
    echo "  - Nix code formatting (nixpkgs-fmt)"
    echo "  - Shell script checking (shellcheck)"
    echo "  - General file checks (trailing whitespace, etc.)"
    echo "  - Secrets detection"
    echo "  - Nix flake validation"
    echo ""
    echo "🚀 Your repository is now protected by pre-commit hooks!"
    echo "   Hooks will run automatically on git commit."
else
    echo "⚠️  Pre-commit found some issues that need to be addressed."
    echo "   Please fix the issues above and commit the changes."
fi
