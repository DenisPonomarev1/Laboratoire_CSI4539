# E5 Proof Failure Analysis (Before/After)

## Scope

The failure is intentionally provoked in `lab3/proof_failure_demo/` to satisfy E5 reproducibly while keeping the final working build separate.

## Before (failing proof)

- Project: `lab3/proof_failure_demo/proof_failure_demo.gpr`
- Evidence log: `lab3/traces/T3-proof-failure-before.log`
- Failing clause:

`validator_failure.ads` postcondition requires:

`Copied_Length = Input'Length + 1` whenever `Accepted = True`.

## Classification

- Classification: **false property**.
- Reason: implementation sets `Copied_Length := Input'Length`, so the postcondition is intentionally incorrect and cannot be proved.

## After (corrected project)

- Project: `lab3/spark_validator/lab3_validator.gpr`
- Evidence log: `lab3/traces/T3-proof-failure-after.log`
- Corrected contract:
  - accepted input implies `Copied_Length = Input'Length`
  - accepted input implies `Fits_Buffer(Input)` and `Is_Allowed_Input(Input)`

## Outcome

- Failure disappears in final project proof run.
- This demonstrates diagnosis, classification, correction, and re-proof as required by E5/T3.
