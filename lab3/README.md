# Lab3 Workspace

This folder contains a complete, reproducible Lab3 implementation based on materials available in this repository and local Git history.

## Key folders

- `reference/`: source selection evidence and preserved C references.
- `spark_validator/`: final SPARK validator project (proved target).
- `proof_failure_demo/`: intentional proof failure used for E5 diagnostics.
- `tests/`: shared C/SPARK corpus runner.
- `traces/`: build, proof, and execution evidence.
- `validator_for_lab5/`: reusable validator package handoff.
- `report/`: report draft and analysis notes.

## Tool check (already executed)

- `lab3/toolchain_check/` was used to verify `gprbuild` and `gnatprove` execution before the real project.

## Re-run commands

```sh
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/spark_validator
mkdir -p obj bin
gprbuild -P lab3_validator.gpr
/home/seed/.local/bin/gnatprove -P lab3_validator.gpr --mode=flow
/home/seed/.local/bin/gnatprove -P lab3_validator.gpr --mode=prove --level=1 --report=all
```

```sh
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/proof_failure_demo
mkdir -p obj
/home/seed/.local/bin/gnatprove -P proof_failure_demo.gpr --mode=prove --level=1 --report=all
```

```sh
cd /home/seed/Documents/Laboratoire/lab1_v2
chmod +x lab3/tests/run_comparison.sh
./lab3/tests/run_comparison.sh
```
