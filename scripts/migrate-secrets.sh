#!/usr/bin/env bash
#
# Migration script for SOPS secrets reorganization
# Run this on nix-server with access to the age keys
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OLD_SECRETS="$REPO_ROOT/secrets/secrets.yaml"
NEW_HA_SECRETS="$REPO_ROOT/secrets/services/home-assistant.yaml"

echo "🔐 Migrating SOPS secrets from old to new structure..."

# Check if we have access to SOPS and the secrets
if ! command -v sops >/dev/null 2>&1; then
    echo "❌ Error: sops command not found. Install sops first."
    exit 1
fi

if [[ ! -f "$OLD_SECRETS" ]]; then
    echo "❌ Error: Old secrets file not found at $OLD_SECRETS"
    exit 1
fi

# Test if we can decrypt the old secrets
echo "🔓 Testing decryption of old secrets..."
if ! sops -d "$OLD_SECRETS" >/dev/null 2>&1; then
    echo "❌ Error: Cannot decrypt old secrets. Make sure age keys are available."
    echo "Expected age key location: ~/.config/sops/age/keys.txt"
    exit 1
fi

# Extract the mosquitto password
echo "📤 Extracting mosquitto password..."
MOSQUITTO_PASSWORD=$(sops -d --extract '["mosquitto"]["password"]' "$OLD_SECRETS")

if [[ -z "$MOSQUITTO_PASSWORD" ]]; then
    echo "❌ Error: Could not extract mosquitto password"
    exit 1
fi

# Create the new home-assistant secrets file with the actual password
echo "📝 Creating new home-assistant secrets file..."
cat > "$NEW_HA_SECRETS" << EOF
# Home Assistant service secrets
mosquitto:
    password: "$MOSQUITTO_PASSWORD"
home_assistant:
    # Future secrets for Home Assistant integrations
    # api_key: "PLACEHOLDER_FOR_API_KEY"
    # webhook_secrets: "PLACEHOLDER_FOR_WEBHOOK"
EOF

# Encrypt the new file
echo "🔐 Encrypting new secrets file..."
sops -e -i "$NEW_HA_SECRETS"

# Verify the new file can be decrypted
echo "✅ Verifying new secrets file..."
if sops -d "$NEW_HA_SECRETS" >/dev/null 2>&1; then
    echo "✅ Migration successful!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Test the new configuration: sudo nixos-rebuild test"
    echo "2. If working, apply: sudo nixos-rebuild switch"
    echo "3. After confirming everything works, you can remove: $OLD_SECRETS"
    echo ""
    echo "📁 New secrets structure:"
    find "$REPO_ROOT/secrets" -name "*.yaml" | sort
else
    echo "❌ Error: New secrets file cannot be decrypted"
    exit 1
fi