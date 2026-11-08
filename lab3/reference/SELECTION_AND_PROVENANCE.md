# Lab3 Starting Routine Selection and Provenance

## Selected C reference
- Selected file: `lab2/Buffer_Overflow_Setuid_Labsetup/Labsetup/code/stack.c`
- Preserved unchanged copy: `lab3/reference/c/stack_reference.c`
- Source commit for selected file: `ec1fdc9581bd6327bee22335f3ead6fea39365a9`

## Why this file is the best-supported starting point
- Lab2 statement, Part D (E7), explicitly says to rewrite the vulnerable input-analysis routine as a fixed-size buffer copy in Ada and replay E3 input with `Constraint_Error` handling.
- Lab2 statement, section on technical requirements, explicitly names vulnerable programs `stack.c` and `retlib.c`, and says vulnerable programs are not modified for attacks while Ada defense is added.
- Existing Lab2 defense in this workspace (`lab2/.../main.adb` and `lab2/.../lab2_defense.gpr`) is a direct Ada rewrite of `stack.c` and already demonstrates `Constraint_Error` on oversized input.
- Lab3 statement says the routine was already rewritten once in Lab2 and that constraint checking turned overflow into an exception, which matches `stack.c` + `main.adb` exactly.

## Historical deleted file (kept as evidence, not selected)
- Historical path: `lab1/src/vulnerable/lab1_vuln.c`
- Added in commit: `a7dfe7dcecdd0a23a36814999fb7556159d83371`
- Deleted in commit: `32a316d754ea9d393e01926e735efa5834977dba`
- Archived copy: `lab3/reference/history/lab1_vuln_from_commit_a7dfe7d.c`

## Move/replace check on deletion commit
- Deletion commit removes `lab1/src/vulnerable/lab1_vuln.c` directly.
- No rename record to another path in that commit for this file.
- New focus in same commit shifts to `lab1/Labsetup/catall*.c` and related scripts.

## Explicit assumptions for Lab3 policy contracts
- Length policy is specified by legacy routine behavior: destination buffer length is 100 bytes (`BUF_SIZE = 100`).
- Character policy is not fully specified in prior instructions; this Lab3 implementation uses an explicit defensive whitelist: ASCII letters, digits, space, underscore, hyphen, dot, slash.
- Effect of this assumption: shell metacharacters and format-string characters are rejected deterministically by SPARK policy, while legacy C routine has no such check.
