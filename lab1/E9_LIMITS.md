# E9: Legacy Corpus and Security Limits

This note documents all eight legacy payload classes in `corpus/` and explains
what the fixed implementation guarantees and what it does not guarantee.

## Corpus coverage (8 entries)

1. `01-semicolon-injection.txt`
   - Legacy risk: command separator (`;`) lets attacker append commands.
   - Fixed behavior: entire string is passed as one filename argument to
     `/bin/cat` via `execve`, so shell parsing never happens.

2. `02-and-injection.txt`
   - Legacy risk: `&&` chains follow-up commands.
   - Fixed behavior: no shell evaluation; text stays inert data.

3. `03-pipe-injection.txt`
   - Legacy risk: `|` pipes command output into attacker command.
   - Fixed behavior: no shell pipeline parsing; payload is treated as plain text.

4. `04-backtick-substitution.txt`
   - Legacy risk: backticks trigger command substitution.
   - Fixed behavior: no shell invocation, so backticks are not executed.

5. `05-dollar-substitution.txt`
   - Legacy risk: `$()` substitution executes command.
   - Fixed behavior: no shell parsing, so substitution syntax is inert.

6. `06-newline-injection.txt`
   - Legacy risk: newline can terminate one command and start another.
   - Fixed behavior: argument is not interpreted by a shell.

7. `07-path-substitution.txt`
   - Legacy risk: attacker-controlled `PATH` selects malicious helper.
   - Fixed behavior: fixed program calls `/usr/bin/printf` and `/bin/cat` by
     absolute path, so `PATH` cannot redirect execution.

8. `08-ld-preload.txt`
   - Legacy risk: attacker attempts loader-level code injection through
     `LD_PRELOAD`/related variables.
   - Fixed behavior: no inherited caller environment is used for the external
     call. `execve` receives a controlled allowlist (`PATH`, `IFS`, `LANG`).

## Verified E9 properties

The fixed source `src/fixed/lab1_fixed.c` satisfies these properties:

- All three UIDs are dropped before external execution:
  `setresuid(real_uid, real_uid, real_uid)` occurs before `execve(...)`.
- External execution uses an absolute path:
  `execve("/usr/bin/printf", ...)`.
- Environment is fixed/allowlisted:
  `PATH=/usr/bin:/bin`, `IFS= \t\n`, `LANG=C`.

## Evidence files

- `traces/T7-fixed-inert.log`: T4/T5 payload replay is inert.
- `traces/T8-privilege-drop.log`: re-elevation fails after dropping UIDs.
- `traces/T9-properties.log`: source-level property checks pass.

## Limits (important for the report)

This fix guarantees that the current privileged flow does not invoke a shell,
does not rely on command lookup through inherited `PATH`, and does not keep a
privileged saved UID after the drop.

This fix does NOT guarantee universal safety for arbitrary future features.
If a later change reintroduces shell execution, dynamic command construction,
or inherited environments before the drop, new injection paths could appear.
OS-level isolation, permissions, and code review are still required.
