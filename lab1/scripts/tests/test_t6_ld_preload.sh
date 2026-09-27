#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd -- "$SCRIPT_DIR/../.." && pwd)
VULN=/usr/local/lib/lab1/lab1_vuln
PRELOAD="$ROOT_DIR/build/liblab1_preload.so"
MARKER=/tmp/lab1_t6_preload.marker
TRACE="$ROOT_DIR/traces/T6-ld-preload.log"

make -C "$ROOT_DIR" build/liblab1_preload.so
mkdir -p "$ROOT_DIR/traces"
exec > >(tee "$TRACE") 2>&1

printf '%s\n' '=== T6: LD_PRELOAD under Set-UID secure execution ==='
sudo rm -f "$MARKER"
sudo -u lab1_alice -- /bin/id
printf 'Command: sudo -u lab1_alice -- /usr/bin/env LD_PRELOAD=%s %s identify\n' "$PRELOAD" "$VULN"
sudo -u lab1_alice -- /usr/bin/env LD_PRELOAD="$PRELOAD" "$VULN" identify
if [[ -e "$MARKER" ]]; then
    printf '%s\n' 'FAIL: preload constructor ran.'
    exit 1
fi
printf '%s\n' 'EXPECTED: secure-execution mode ignored LD_PRELOAD; no marker was created.'