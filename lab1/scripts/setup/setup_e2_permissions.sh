#!/bin/bash

# E2 - Permissions, umask and shared directory
# Configures a shared directory for lab1_alice and lab1_bob.

set -e

SHARED_DIR="/home/lab1_shared"

echo "=== E2: Creating shared directory ==="

sudo mkdir -p "$SHARED_DIR"

echo "=== E2: Setting ownership ==="

# root owns the directory; lab1_shared is its group
sudo chown root:lab1_shared "$SHARED_DIR"

echo "=== E2: Setting permissions ==="

# 3 = setgid + sticky bit
# 770 = rwx for owner and group, no access for others
sudo chmod 3770 "$SHARED_DIR"

echo
echo "=== E2: Final directory permissions ==="
ls -ld "$SHARED_DIR"

echo
echo "E2 setup complete."
echo
echo "Expected permissions:"
echo "drwxrws--T ... root lab1_shared $SHARED_DIR"

