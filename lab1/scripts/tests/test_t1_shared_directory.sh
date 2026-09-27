#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd -- "$SCRIPT_DIR/../.." && pwd)
SHARED_DIR=/home/lab1_shared
TRACE="$ROOT_DIR/traces/T1-permissions-umask.log"
FILE_0002="$SHARED_DIR/t1_umask_0002.txt"
FILE_0027="$SHARED_DIR/t1_umask_0027.txt"

mkdir -p "$ROOT_DIR/traces"
exec > >(tee "$TRACE") 2>&1

printf '%s\n' '=== T1: Shared directory, umask, and sticky bit ==='
printf '%s\n' 'Commands: sudo -u lab1_alice /bin/id; create files with umask 0002 and umask 0027.'
sudo -u lab1_alice -- /bin/id
sudo -u lab1_bob -- /bin/id
sudo rm -f "$FILE_0002" "$FILE_0027"
sudo -u lab1_alice -- /bin/bash -c '
    set -eu
    cd "$1"
    umask
    umask 0002
    umask
    printf "%s\n" "created with umask 0002" > t1_umask_0002.txt
    umask 0027
    umask
    printf "%s\n" "created with umask 0027" > t1_umask_0027.txt
' _ "$SHARED_DIR"

printf '\n%s\n' '=== Directory and file modes ==='
ls -ld "$SHARED_DIR"
ls -l "$FILE_0002" "$FILE_0027"
getfacl -p "$SHARED_DIR"

printf '\n%s\n' '=== Sticky-bit deletion check (Bob deleting Alice file) ==='
printf 'Command: sudo -u lab1_bob -- /bin/rm %s\n' "$FILE_0002"
if sudo -u lab1_bob -- /bin/rm "$FILE_0002"; then
    printf '%s\n' 'FAIL: Bob unexpectedly deleted Alice file.'
    exit 1
else
    printf '%s\n' 'EXPECTED: Bob could not delete Alice file in the sticky directory.'
fi
ls -l "$FILE_0002"