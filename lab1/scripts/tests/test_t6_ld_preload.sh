#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd -- "$SCRIPT_DIR/../.." && pwd)
LAB_DIR="$ROOT_DIR/Labsetup"
SUID_PROBE="$SCRIPT_DIR/show_ids"
PROBE_SOURCE="$LAB_DIR/show_ids.c"
TRACE=${TRACE:-"$ROOT_DIR/traces/T6-ld-preload.log"}

if (( EUID == 0 )); then
    printf '%s\n' 'ERROR: run this test as an unprivileged user in the isolated SEED VM.' >&2
    exit 1
fi

if [[ ! -x "$SUID_PROBE" || ! -u "$SUID_PROBE" || $(stat -c '%u' "$SUID_PROBE") != 0 ]]; then
    printf 'ERROR: %s must be an executable, root-owned Set-UID binary. Run T3 first.\n' "$SUID_PROBE" >&2
    exit 1
fi

if ! command -v gcc >/dev/null 2>&1; then
    printf '%s\n' 'ERROR: gcc is required.' >&2
    exit 1
fi

mkdir -p "$ROOT_DIR/traces"
exec > >(tee "$TRACE") 2>&1

TEMP_DIR=$(mktemp -d)
trap 'rm -rf -- "$TEMP_DIR"' EXIT
PRELOAD="$TEMP_DIR/libpreload_marker.so"
PRELOAD_SOURCE="$TEMP_DIR/preload_marker.c"
CONTROL="$TEMP_DIR/show-ids-control"
MARKER="$TEMP_DIR/preload-constructor-ran"

printf '%s\n' '=== T6: LD_PRELOAD and Set-UID secure execution ==='
cat > "$PRELOAD_SOURCE" <<'EOF'
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>

__attribute__((constructor)) static void mark_preload_loaded(void)
{
    const char *marker = getenv("LAB1_T6_MARKER");
    static const char message[] = "LD_PRELOAD constructor executed\n";

    if (marker == NULL) {
        return;
    }

    int fd = open(marker, O_WRONLY | O_CREAT | O_EXCL, 0600);
    if (fd < 0) {
        return;
    }

    (void)write(fd, message, sizeof(message) - 1);
    close(fd);
}
EOF

gcc -Wall -Wextra -Wpedantic -fPIC -shared -o "$PRELOAD" "$PRELOAD_SOURCE"
gcc -Wall -Wextra -Wpedantic -o "$CONTROL" "$PROBE_SOURCE"

printf '%s\n' '=== Root-owned Set-UID probe ==='
printf 'Binary owner/mode: '
stat -c '%U:%G %A' "$SUID_PROBE"

export LD_PRELOAD="$PRELOAD"
export LAB1_T6_MARKER="$MARKER"

printf '%s\n' '=== Non-Set-UID control: constructor must run ==='
"$CONTROL"
if [[ ! -s "$MARKER" ]]; then
    printf '%s\n' 'FAIL: preload constructor did not create the control marker.'
    exit 1
fi
cat "$MARKER"

rm -f -- "$MARKER"
printf '%s\n' '=== Root-owned Set-UID probe: constructor must not run ==='
UID_OUTPUT=$("$SUID_PROBE")
printf '%s\n' "$UID_OUTPUT"
if [[ "$UID_OUTPUT" != *'UID effectif   (euid) = 0'* ]]; then
    printf '%s\n' 'FAIL: the Set-UID probe did not run with effective UID 0.'
    exit 1
fi
if [[ -e "$MARKER" ]]; then
    printf '%s\n' 'FAIL: LD_PRELOAD constructor ran for the Set-UID probe.'
    exit 1
fi

printf '%s\n' 'PASS: the control loaded LD_PRELOAD; the Set-UID probe ran as root without loading it.'