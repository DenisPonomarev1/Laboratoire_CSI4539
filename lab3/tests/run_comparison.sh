#!/usr/bin/env bash
set -u
set -o pipefail

ROOT="/home/seed/Documents/Laboratoire/lab1_v2"
LAB3="$ROOT/lab3"
CASES="$LAB3/tests/cases"
TRACES="$LAB3/traces"
CBUILD="$LAB3/build_c_ref"
SPARK_DIR="$LAB3/spark_validator"
SPARK_BIN="$SPARK_DIR/bin/main"
CSV="$TRACES/T4-comparison.csv"

mkdir -p "$CASES" "$TRACES" "$CBUILD" "$SPARK_DIR/obj" "$SPARK_DIR/bin"

# Build unchanged C reference.
gcc -O0 -g -fno-stack-protector -z execstack \
  -o "$CBUILD/stack_ref" "$LAB3/reference/c/stack_reference.c"

# Build SPARK harness.
(
  cd "$SPARK_DIR"
  gprbuild -P lab3_validator.gpr
)

# Generate deterministic local cases.
python3 - <<'PY'
from pathlib import Path
root = Path('/home/seed/Documents/Laboratoire/lab1_v2/lab3/tests/cases')
root.mkdir(parents=True, exist_ok=True)
(root / '01-valid-short.txt').write_bytes(b'Alpha_42')
(root / '02-valid-path.txt').write_bytes(b'safe/path-file.txt')
(root / '03-valid-boundary-100.txt').write_bytes(b'A' * 100)
(root / '04-invalid-length-101.txt').write_bytes(b'A' * 101)
(root / '05-invalid-format-string.txt').write_bytes(b'%x%x%x')
PY

# Reuse dangerous-input corpus from Lab1.
cp "$ROOT/lab1/corpus/01-semicolon-injection.txt" "$CASES/06-lab1-semicolon.txt"
cp "$ROOT/lab1/corpus/02-and-injection.txt" "$CASES/07-lab1-and.txt"
cp "$ROOT/lab1/corpus/03-pipe-injection.txt" "$CASES/08-lab1-pipe.txt"
cp "$ROOT/lab1/corpus/04-backtick-substitution.txt" "$CASES/09-lab1-backtick.txt"
cp "$ROOT/lab1/corpus/05-dollar-substitution.txt" "$CASES/10-lab1-dollar.txt"
cp "$ROOT/lab1/corpus/06-newline-injection.txt" "$CASES/11-lab1-newline.txt"
cp "$ROOT/lab1/corpus/07-path-substitution.txt" "$CASES/12-lab1-path-subst.txt"

# Optional Lab2 overflow payload reuse if present.
if [[ -f "$ROOT/lab2/Buffer_Overflow_Setuid_Labsetup/Labsetup/code/badfile-t3" ]]; then
  cp "$ROOT/lab2/Buffer_Overflow_Setuid_Labsetup/Labsetup/code/badfile-t3" \
     "$CASES/13-lab2-badfile-t3.bin"
fi

printf 'case_file,bytes,expected_policy,c_exit,c_observation,spark_exit,spark_accepted,spark_observation\n' > "$CSV"

expected_policy() {
  python3 - "$1" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
data = p.read_bytes()
allowed = set(b'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 _-./')
ok = len(data) <= 100 and all(b in allowed for b in data)
print('ACCEPT' if ok else 'REJECT')
PY
}

for case_path in "$CASES"/*; do
  case_name="$(basename "$case_path")"
  bytes="$(wc -c < "$case_path" | tr -d ' ')"
  expected="$(expected_policy "$case_path")"

  cp "$case_path" "$CBUILD/badfile"

  (cd "$CBUILD" && ./stack_ref > "$TRACES/${case_name}.c.out" 2>&1)
  c_exit=$?

  "$SPARK_BIN" "$case_path" > "$TRACES/${case_name}.spark.out" 2>&1
  s_exit=$?

  c_obs="$(head -n 2 "$TRACES/${case_name}.c.out" | tr '\n' ';' | sed 's/,/;/g')"
  s_acc="$(grep -E '^ACCEPTED=' "$TRACES/${case_name}.spark.out" | tail -n 1 | cut -d= -f2 | tr -d ' ')"
  s_obs="$(head -n 5 "$TRACES/${case_name}.spark.out" | tr '\n' ';' | sed 's/,/;/g')"

  printf '%s,%s,%s,%s,%s,%s,%s,%s\n' \
    "$case_name" "$bytes" "$expected" "$c_exit" "$c_obs" "$s_exit" "${s_acc:-N/A}" "$s_obs" >> "$CSV"
done

echo "Wrote $CSV"
