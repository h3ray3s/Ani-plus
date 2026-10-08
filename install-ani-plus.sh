#!/usr/bin/env bash
set -e

VERSION=1.0.0
REPO_URL="https://github.com/h3ray3s/Ani-plus/releases/download/v${VERSION}-repo"
REPO_NAME="ani-plus"

echo "==> Adding Ani-plus repository to /etc/pacman.conf..."
# Add the repository block to pacman.conf if it doesn't already exist
if ! grep -q "^\[${REPO_NAME}\]" /etc/pacman.conf; then
    sudo tee -a /etc/pacman.conf > /dev/null << EOF

[${REPO_NAME}]
SigLevel = Optional TrustAll
Server = ${REPO_URL}
EOF
    echo "Repository added."
else
    echo "Repository already configured."
fi

echo "==> Updating package database and installing ani-plus..."
sudo pacman -Sy ani-plus --noconfirm

echo ""
echo "✓ ani-plus installed successfully!"
echo "  Run 'ani-plus -h' to get started."
