#!/usr/bin/env bash
set -e

[ "$EUID" -ne 0 ] && { echo "Run with sudo"; exit 1; }

REPO="ani-plus"
URL="https://github.com/h3ray3s/Ani-plus/releases/download/v1.0.0-repo"

echo "==> Adding $REPO repository..."
if ! grep -q "^\[$REPO\]" /etc/pacman.conf; then
    cat >> /etc/pacman.conf << CONF

[$REPO]
SigLevel = Optional TrustAll
Server = $URL
CONF
    echo "Added."
else
    echo "Already present."
fi

echo "==> Installing $REPO..."
pacman -Sy --noconfirm $REPO

echo "✓ Installed. Run: ani-plus -h"
