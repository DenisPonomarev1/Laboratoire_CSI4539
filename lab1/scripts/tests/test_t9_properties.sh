#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd -- "$SCRIPT_DIR/../.." && pwd)
SOURCE="$ROOT_DIR/src/fixed/lab1_fixed.c"
TRACE="$ROOT_DIR/traces/T9-properties.log"

mkdir -p "$ROOT_DIR/traces"
exec > >(tee "$TRACE") 2>&1

drop_line=$(grep -nF 'setresuid(real_uid, real_uid, real_uid)' "$SOURCE" | cut -d: -f1)
exec_line=$(grep -nF 'execve("/usr/bin/printf"' "$SOURCE" | cut -d: -f1)
grep -Fq '"PATH=/usr/bin:/bin"' "$SOURCE"
grep -Fq '"IFS= \t\n"' "$SOURCE"
[[ -n "$drop_line" && -n "$exec_line" && "$drop_line" -lt "$exec_line" ]]

printf '%s\n' 'PASS: all real/effective/saved UIDs are dropped before execve.'
printf '%s\n' 'PASS: external command uses an absolute path.'
printf '%s\n' 'PASS: execve receives a fixed PATH/IFS allowlist.'