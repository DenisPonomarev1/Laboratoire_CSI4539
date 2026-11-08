# Lab3 Submission Checklist

## Mandatory artifacts

- [ ] `lab3/spark_validator/` builds with `gprbuild -P lab3_validator.gpr`.
- [ ] `lab3/spark_validator/` proves with `gnatprove --mode=flow` and `--mode=prove`.
- [ ] `lab3/reference/c/stack_reference.c` remains unchanged reference copy.
- [ ] `lab3/proof_failure_demo/` shows reproducible failing proof for E5 before state.
- [ ] `lab3/traces/T3-proof-failure-before.log` and `T3-proof-failure-after.log` attached.
- [ ] `lab3/traces/T4-comparison.csv` includes at least 12 identical C/SPARK inputs.
- [ ] `lab3/validator_for_lab5/` contains reusable SPARK package + GPR.
- [ ] `JOURNAL.md` Lab3 placeholders completed by both members.
- [ ] AI declaration completed and included in report package.

## Report completeness

- [ ] T1 entry includes procedure, result, evidence, verdict.
- [ ] T2 entry includes procedure, result, evidence, verdict.
- [ ] T3 entry includes procedure, result, evidence, verdict.
- [ ] T4 entry includes procedure, result, evidence, verdict.
- [ ] L3-A section clearly labeled (C vs Ada/SPARK).
- [ ] Limitations section states proof scope boundaries.

## Final packaging

- [ ] Confirm member names `<NomA>`, `<NomB>`.
- [ ] Create archive: `CEG4799_Lab3_<NomA>_<NomB>.zip`.
- [ ] Verify archive contains all required folders/files.
- [ ] Upload before deadline.
