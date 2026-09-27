#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd -- "$SCRIPT_DIR/../.." && pwd)
FIXED=/usr/local/lib/lab1/lab1_fixed
TRACE="$ROOT_DIR/traces/T8-privilege-drop.log"

mkdir -p "$ROOT_DIR/traces"
exec > >(tee "$TRACE") 2>&1

printf '%s\n' '=== T8: Permanent privilege drop and re-elevation check ==='
sudo -u lab1_alice -- /bin/id
printf 'Command: sudo -u lab1_alice -- %s --verify-drop %q\n' "$FIXED" 'T8 check'
sudo -u lab1_alice -- "$FIXED" --verify-drop 'T8 check'