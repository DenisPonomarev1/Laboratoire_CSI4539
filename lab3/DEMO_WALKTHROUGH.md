# Demo Walkthrough (T1-T4)

## T1: Build + flow analysis

```sh
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/spark_validator
mkdir -p obj bin
gprbuild -P lab3_validator.gpr
/home/seed/.local/bin/gnatprove -P lab3_validator.gpr --mode=flow
```

What to explain:
- `validator.ads` and `validator.adb` are SPARK (`SPARK_Mode => On`).
- `main.adb` is harness-only (I/O), intentionally outside SPARK core.
- Flow mode checks initialization, data/flow dependencies, parameter modes.

## T2: Prove mode

```sh
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/spark_validator
/home/seed/.local/bin/gnatprove -P lab3_validator.gpr --mode=prove --level=1 --report=all
```

What to explain:
- Contracts encode length bound and character policy.
- `Global`/`Depends` are explicit.
- Proof report in `obj/gnatprove/gnatprove.out` shows discharged runtime checks.

## T3: Failure diagnosis and correction

Before (intentional failure):

```sh
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/proof_failure_demo
mkdir -p obj
/home/seed/.local/bin/gnatprove -P proof_failure_demo.gpr --mode=prove --level=1 --report=all
```

After (corrected project):

```sh
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/spark_validator
/home/seed/.local/bin/gnatprove -P lab3_validator.gpr --mode=prove --level=1 --report=all
```

Classification to state:
- Failure demo is a **false property**: postcondition intentionally contradicted implementation.

## T4: C vs SPARK on same dangerous inputs

```sh
cd /home/seed/Documents/Laboratoire/lab1_v2
./lab3/tests/run_comparison.sh
```

Where to show results:
- Table: `lab3/traces/T4-comparison.csv`
- Per-case traces: `lab3/traces/*.c.out` and `lab3/traces/*.spark.out`

Injection case to show live:
- `12-lab1-path-subst.txt` (or any large corpus entry) typically segfaults C (`exit 139` observed) while SPARK rejects safely.

## Live-edit micro exercise (5 min prep)

Suggested exercise:
1. In `validator.adb`, change allowed policy (e.g., temporarily allow `%`).
2. Re-run `gprbuild` and `gnatprove --mode=prove`.
3. Re-run `./lab3/tests/run_comparison.sh` and show changed behavior on `05-invalid-format-string.txt`.
4. Revert the change and re-run.

This demonstrates understanding of contracts, proof, and behavior impact.

## Practice oral questions

1. Why is `main.adb` outside SPARK while `validator` is in SPARK?
2. What does `Depends` add beyond type checking?
3. Why does a false postcondition fail even when code compiles?
4. What exactly is proved, and what is not proved (OS/libs/time/runtime environment)?
5. Why can C behavior vary on undefined behavior, and why should we record actual observed output only?
