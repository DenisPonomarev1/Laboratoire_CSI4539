#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd -- "$SCRIPT_DIR/../.." && pwd)
TRACE="$ROOT_DIR/traces/T2-acl-capability.log"
SHARED_DIR=/home/lab1_shared
ACL_FILE=/home/lab1_shared/acl_sample.txt
CAP_PROBE=/usr/local/lib/lab1/lab1_cap_probe

mkdir -p "$ROOT_DIR/traces"
exec > >(tee "$TRACE") 2>&1

printf '%s\n' '=== T2: Configure E3 ACL and capability ==='
printf 'Command: bash %s\n' "$ROOT_DIR/scripts/setup/setup_e3_acl_capabilities.sh"
bash "$ROOT_DIR/scripts/setup/setup_e3_acl_capabilities.sh"
printf '\n%s\n' '=== ACL proof and Charlie access ==='
printf 'Commands: getfacl -p %s %s; sudo -u lab1_charlie /bin/cat %s\n' "$SHARED_DIR" "$ACL_FILE" "$ACL_FILE"
sudo getfacl -p "$SHARED_DIR" "$ACL_FILE"
sudo -u lab1_charlie -- /bin/cat "$ACL_FILE"
printf '\n%s\n' '=== Capability proof; no Set-UID bit ==='
printf 'Commands: stat -c ... %s; getcap %s; sudo -u lab1_alice %s\n' "$CAP_PROBE" "$CAP_PROBE" "$CAP_PROBE"
stat -c '%A (%a) %U:%G %n' "$CAP_PROBE"
getcap "$CAP_PROBE"
sudo -u lab1_alice -- /bin/id
sudo -u lab1_alice -- "$CAP_PROBE"