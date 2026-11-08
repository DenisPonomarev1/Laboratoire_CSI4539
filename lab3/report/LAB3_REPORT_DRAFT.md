# Laboratoire 3 Draft Report

## 1. Introduction and target module

This Lab3 work secures a vulnerable C input routine by re-implementing the validation logic in Ada/SPARK and proving runtime safety with GNATprove. Based on available workspace evidence, the selected starting routine is `lab2/Buffer_Overflow_Setuid_Labsetup/Labsetup/code/stack.c` (fixed-size buffer copy vulnerable to overflow), previously rewritten in Ada in Lab2.

Selection evidence is documented in `lab3/reference/SELECTION_AND_PROVENANCE.md`.

## 2. SPARK designation and flow analysis (E1, E2, T1)

Project:
- `lab3/spark_validator/lab3_validator.gpr`

SPARK package:
- `lab3/spark_validator/src/validator.ads`
- `lab3/spark_validator/src/validator.adb`

Non-SPARK harness (isolated I/O):
- `lab3/spark_validator/src/main.adb`

Commands:

```sh
cd lab3/spark_validator
mkdir -p obj bin
gprbuild -P lab3_validator.gpr
/home/seed/.local/bin/gnatprove -P lab3_validator.gpr --mode=flow
```

Evidence:
- `lab3/traces/T1-build.log`
- `lab3/traces/T1-flow.log`

Observed result:
- Build succeeds.
- Flow analysis reports no warnings on SPARK module.

Verdict T1: PASS.

## 3. Contracts and proof of runtime safety (E3, E4, T2)

Implemented contracts include:
- constrained maximum input length (`Max_Length = 100`)
- explicit character policy predicate (`Is_Allowed_Char`)
- validator postcondition for accepted/rejected outcomes
- `Global` and `Depends` contracts

Commands:

```sh
cd lab3/spark_validator
/home/seed/.local/bin/gnatprove -P lab3_validator.gpr --mode=prove --level=1 --report=all
```

Evidence:
- `lab3/traces/T2-prove.log`
- `lab3/spark_validator/obj/gnatprove/gnatprove.out`

Observed result:
- Run-time checks proved for SPARK validator unit.
- Final summary indicates no unproved runtime checks for analyzed SPARK package.

Verdict T2: PASS.

## 4. Proof failure diagnosis (E5, T3)

A reproducible failing proof is isolated in:
- `lab3/proof_failure_demo/`

Before command:

```sh
cd lab3/proof_failure_demo
mkdir -p obj
/home/seed/.local/bin/gnatprove -P proof_failure_demo.gpr --mode=prove --level=1 --report=all
```

Before evidence:
- `lab3/traces/T3-proof-failure-before.log`

Classification:
- false property (postcondition intentionally states `Copied_Length = Input'Length + 1` for accepted input)

After evidence (corrected project):
- `lab3/traces/T3-proof-failure-after.log`

Detailed analysis:
- `lab3/report/PROOF_FAILURE_ANALYSIS.md`

Verdict T3: PASS.

## 5. C vs Ada/SPARK comparison (E6, T4, L3-A)

Comparison run command:

```sh
cd /home/seed/Documents/Laboratoire/lab1_v2
./lab3/tests/run_comparison.sh
```

Evidence:
- CSV table: `lab3/traces/T4-comparison.csv`
- Per-case traces: `lab3/traces/*.c.out`, `lab3/traces/*.spark.out`

Observed behavior summary:
- Valid short and boundary cases are accepted by SPARK and complete in C.
- Inputs violating policy (length/characters) are rejected by SPARK.
- Large dangerous corpus entries trigger repeated segmentation faults in the C reference (`exit 139` on observed runs), while SPARK rejects safely with explicit status output.

Conventions comparison:
- C reference behavior depends on unsafe `strcpy` over file bytes without policy checks.
- SPARK version encodes policy explicitly and proves runtime safety of validation logic.

Verdict T4: PASS.

## 6. Assumptions and limitations

Explicit assumptions:
- Length bound derives from legacy fixed buffer size (`BUF_SIZE=100`).
- Character policy was not fully specified in prior statements; this implementation uses an explicit whitelist: `[A-Za-z0-9 _./-]`.

Proof scope limitations:
- GNATprove covers SPARK program logic and runtime checks for the analyzed package.
- Proof does not cover OS behavior, toolchain defects, or non-SPARK harness internals.

## 7. Teamwork section placeholder

Fill from `JOURNAL.md` Lab3 section placeholders:
- role rotation per session
- contract ownership per member
- proof-failure diagnosis ownership per member
- disagreement handling

## 8. Sources and AI declaration

- Lab2 statement PDF: `CEG4799_CSI4539A_Lab2_Automne_2026.pdf`
- Lab3 statement PDF: `CEG4799_CSI4539A_Lab3_Automne_2026.pdf`
- Lab3 assistant slides: `Lab3_Presentation_Assistant.pptx`
- Workspace preparation notes: `lab2/Buffer_Overflow_Setuid_Labsetup/Labsetup/code/preparation.txt`
- AI declaration draft: `lab3/report/AI_DECLARATION.md`

## 9. Reusable validator handoff (Lab5)

- Folder: `lab3/validator_for_lab5/`
- Includes proved SPARK package and project file for integration.
