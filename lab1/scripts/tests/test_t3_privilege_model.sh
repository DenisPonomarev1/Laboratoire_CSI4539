#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd -- "$SCRIPT_DIR/../.." && pwd)
VULN=/usr/local/lib/lab1/lab1_vuln
TRACE="$ROOT_DIR/traces/T3-privilege-model.log"

mkdir -p "$ROOT_DIR/traces"
exec > >(tee "$TRACE") 2>&1

printf '%s\n' '=== T3: Real user identity ==='
printf '%s\n' 'Command: sudo -u lab1_alice -- /bin/id'
sudo -u lab1_alice -- /bin/id
printf '\n%s\n' '=== T3: Set-UID program identity ==='
printf 'Commands: stat -c ... %s; sudo -u lab1_alice %s identify\n' "$VULN" "$VULN"
stat -c '%A (%a) %U:%G %n' "$VULN"
sudo -u lab1_alice -- "$VULN" identify