#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd -- "$SCRIPT_DIR/../.." && pwd)
FIXED=/usr/local/lib/lab1/lab1_fixed
PATH_DIR="$ROOT_DIR/build/path"
T4_MARKER=/tmp/lab1_t4_injection.marker
T5_MARKER=/tmp/lab1_t5_path.marker
TRACE="$ROOT_DIR/traces/T7-fixed-inert.log"
PAYLOAD='lab1-demo; /usr/bin/id -u > /tmp/lab1_t4_injection.marker'

make -C "$ROOT_DIR" build/path/lab1-helper
mkdir -p "$ROOT_DIR/traces"
exec > >(tee "$TRACE") 2>&1

printf '%s\n' '=== T7: Replay T4 input against the fixed program ==='
sudo rm -f "$T4_MARKER" "$T5_MARKER"
sudo -u lab1_alice -- /bin/id
printf 'Command: sudo -u lab1_alice -- %s %q\n' "$FIXED" "$PAYLOAD"
sudo -u lab1_alice -- "$FIXED" "$PAYLOAD"
if [[ -e "$T4_MARKER" ]]; then
    printf '%s\n' 'FAIL: command-injection marker exists.'
    exit 1
fi
printf '%s\n' 'EXPECTED: injection text was printed literally; no marker exists.'

printf '\n%s\n' '=== T7: Replay T5 PATH against the fixed program ==='
printf 'Command: sudo -u lab1_alice -- /usr/bin/env PATH=%q %s lookup\n' "$PATH_DIR" "$FIXED"
sudo -u lab1_alice -- /usr/bin/env PATH="$PATH_DIR" "$FIXED" lookup
if [[ -e "$T5_MARKER" ]]; then
    printf '%s\n' 'FAIL: PATH replacement helper ran.'
    exit 1
fi
printf '%s\n' 'EXPECTED: the PATH replacement was not invoked.'