#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd -- "$SCRIPT_DIR/../.." && pwd)
SHARED_DIR=/home/lab1_shared
ACL_FILE="$SHARED_DIR/acl_sample.txt"
CAP_PROBE=/usr/local/lib/lab1/lab1_cap_probe

for command_name in setfacl getfacl setcap getcap; do
    command -v "$command_name" >/dev/null || {
        printf 'Required command not found: %s\n' "$command_name" >&2
        exit 1
    }
done

make -C "$ROOT_DIR" all
id lab1_charlie >/dev/null
getent group lab1_shared >/dev/null

printf '%s\n' '=== E3: Grant Charlie read-only ACL access ==='
sudo install -o root -g lab1_shared -m 0640 /dev/null "$ACL_FILE"
printf '%s\n' 'ACL sample readable by the named ACL user.' | sudo tee "$ACL_FILE" >/dev/null
sudo setfacl -b "$ACL_FILE"
sudo setfacl -m u:lab1_charlie:r-- "$ACL_FILE"
sudo setfacl -m u:lab1_charlie:--x "$SHARED_DIR"
getfacl -p "$SHARED_DIR" "$ACL_FILE"
sudo -u lab1_charlie -- /bin/cat "$ACL_FILE"

printf '\n%s\n' '=== E3: Grant only cap_net_raw to the probe ==='
sudo chown root:root "$CAP_PROBE"
sudo chmod 0755 "$CAP_PROBE"
sudo setcap cap_net_raw=ep "$CAP_PROBE"
stat -c '%A (%a) %U:%G %n' "$CAP_PROBE"
getcap "$CAP_PROBE"
sudo -u lab1_alice -- "$CAP_PROBE"