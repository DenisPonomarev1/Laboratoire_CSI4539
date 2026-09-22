#!/bin/bash

# E1 - Users and Groups
# Creates the users and groups required for Lab 1.

set -e

echo "=== E1: Creating groups ==="

# Create groups if they do not already exist
sudo groupadd -f lab1_shared
sudo groupadd -f lab1_admin

echo "=== E1: Creating users ==="

# Create users if they do not already exist
if ! id lab1_alice >/dev/null 2>&1; then
    sudo useradd -m -s /bin/bash lab1_alice
fi

if ! id lab1_bob >/dev/null 2>&1; then
    sudo useradd -m -s /bin/bash lab1_bob
fi

if ! id lab1_charlie >/dev/null 2>&1; then
    sudo useradd -m -s /bin/bash lab1_charlie
fi

echo "=== E1: Configuring group memberships ==="

# Alice and Bob belong to the shared group
sudo usermod -aG lab1_shared lab1_alice
sudo usermod -aG lab1_shared lab1_bob

# Charlie belongs to the second group
sudo usermod -aG lab1_admin lab1_charlie

echo
echo "=== E1: Users ==="
id lab1_alice
id lab1_bob
id lab1_charlie

echo
echo "=== E1: Groups ==="
getent group lab1_shared
getent group lab1_admin

echo
echo "=== E1: Relevant passwd entries ==="
getent passwd lab1_alice
getent passwd lab1_bob
getent passwd lab1_charlie

echo
echo "E1 setup complete."
