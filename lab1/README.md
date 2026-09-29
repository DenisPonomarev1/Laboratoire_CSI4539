# Lab 1: Linux Access Control and Set-UID Security

This workspace contains a controlled SEED-VM lab implementation for E1-E9 and
the T1-T8 evidence runs. The vulnerable executable intentionally demonstrates
privileged command injection and PATH lookup. Install and run it only in the
disposable course VM: it can execute arbitrary commands as root when invoked
through its `shell` mode. Its proof payloads in this repository only write UID
values to `/tmp`.

## Contents

- `scripts/setup/setup_e1_users.sh`: creates Alice, Bob, Charlie and the two groups.
- `scripts/setup/setup_e2_permissions.sh`: creates the setgid, sticky shared directory.
- `scripts/setup/setup_e3_acl_capabilities.sh`: grants Charlie read-only ACL access and gives the probe only `cap_net_raw`.
- `src/vulnerable/lab1_vuln.c`: intentionally unsafe shell and PATH examples (E4-E6).
- `src/fixed/lab1_fixed.c`: drops all three UIDs and uses absolute `execve` with a small fixed environment (E7-E9).
- `src/fixed/cap_net_raw_probe.c`: capability-only raw-socket demonstration (E3).
- `scripts/attacks/`: controlled exploit scripts for T4 and T5.
- `scripts/tests/`: T1-T3 and T6-T9 repeatable checks; each writes a trace under `traces/`.
- `corpus/`: eight documented dangerous inputs and environment cases.
- `E5_ANALYSIS.md`: analysis of the three input surfaces required by E5.
- `REPORT_TEMPLATE.md`: report outline and evidence checklist; fill in observed results and team-specific facts.

The existing `JOURNAL.md` is one directory above this workspace. Update it
with the actual team roles, decisions, dates, and Git milestone; those facts
cannot be generated from the code.

## Build and prepare

Run from this directory, as the regular VM account with sudo access:

```sh
make
bash scripts/setup/setup_e1_users.sh
bash scripts/setup/setup_e2_permissions.sh
make install
```

`make install` installs root-owned binaries under `/usr/local/lib/lab1` and
marks only the two demonstration programs Set-UID root. Do not install these
files on a personal or shared system. Configure the ACL and capability after
installation:

```sh
bash scripts/setup/setup_e3_acl_capabilities.sh
```

Expected environment: Linux, a C compiler, Make, sudo, POSIX ACL tools, and
libcap tools. The VM must support file capabilities and permit `CAP_NET_RAW`.
The account running the scripts must be allowed to use `sudo -u` for the lab
users.

## Run the test/evidence scripts

Run each command from the workspace root. Scripts print the commands and
identities they use, then save terminal output in `traces/`:

```sh
bash scripts/tests/test_t1_shared_directory.sh
bash scripts/tests/test_t2_acl_capability.sh
bash scripts/tests/test_t3_privilege_model.sh
bash scripts/attacks/attack_t4_command_injection.sh
bash scripts/attacks/attack_t5_path_hijack.sh
bash scripts/tests/test_t6_ld_preload.sh
bash scripts/tests/test_t7_fixed_inert.sh
bash scripts/tests/test_t8_privilege_drop.sh
bash scripts/tests/test_t9_properties.sh
```

T1-T8 are the assignment's required trials. T9 is an extra source-level check
for the E9 properties. Inspect each trace and confirm its result before citing
it in the report; do not claim a test passed if the VM reports a prerequisite
or permission error. `make uninstall` removes only the installed lab binaries
and their capability. It does not remove users, shared files, traces, or
markers under `/tmp`.

## T1-T8 map

| Trial | Script | What it demonstrates |
| --- | --- | --- |
| T1 | `test_t1_shared_directory.sh` | Shared ownership, umask-derived modes, setgid inheritance, sticky-bit deletion denial. |
| T2 | `test_t2_acl_capability.sh` | Named read-only ACL for Charlie and one file capability on a non-Set-UID probe. |
| T3 | `test_t3_privilege_model.sh` | Owner/mode plus real, effective, and saved UIDs before the vulnerable program does work. |
| T4 | `attack_t4_command_injection.sh` | Shell metacharacters in an argument run under the program's effective UID. |
| T5 | `attack_t5_path_hijack.sh` | Caller-controlled PATH selects a helper executable; its trace records all three UIDs. |
| T6 | `test_t6_ld_preload.sh` | `LD_PRELOAD` constructor is not loaded for secure Set-UID execution. |
| T7 | `test_t7_fixed_inert.sh` | T4's input is printed as data; T5's fake PATH helper is not selected. |
| T8 | `test_t8_privilege_drop.sh` | All UIDs are set to the real UID; attempting `setresuid(0,0,0)` fails afterward. |

E1-E9 are assignment requirement IDs; T1-T8 are the specific terminal trials.
T9 is supplemental and is not a replacement for an assigned trial.

## Security model notes

When the kernel successfully executes a root-owned file with its Set-UID bit,
it changes the process effective UID to the file owner's UID before the first
instruction of the program. `getresuid()` exposes real, effective, and saved
UIDs; the saved UID normally receives the effective UID at `execve()` time.
The vulnerable program therefore starts with the caller's real UID and root
effective/saved UIDs. `system()` or another shell invocation is not what raises
privilege; the Set-UID `execve()` transition does.

The legacy `Labsetup/catall.c` treats `argv[1]` as a filename, but concatenates
it without quoting into `/bin/cat <argument>` and passes that string to
`system()`. The shell therefore parses attacker-controlled filename text as
shell syntax. The actual shell used by `system()` is `/bin/sh`; the T4/T5
scripts temporarily point it to zsh because some `/bin/sh` implementations
drop Set-UID privileges. This shell behavior is platform-dependent and is not
what grants the initial privilege: the kernel does that when it executes the
root-owned Set-UID binary. See [E5_ANALYSIS.md](E5_ANALYSIS.md) for the E5
surface-by-surface analysis.

The fixed `Labsetup/catall_fixed.c` instead passes the argument as one `execve`
argument to `/bin/cat`, without invoking a shell. It does not depend on a bare
command name or an inherited shell environment for that operation.

The fixed program performs no privileged external work. It calls
`setresuid(real, real, real)` before `execve`, permanently replacing real,
effective, and saved IDs. It passes user text as a `%s` argument to a constant
format string, invokes `/usr/bin/printf` by absolute path, and supplies only a
fixed environment containing `PATH`, `IFS`, and `LANG`. The `--verify-drop`
mode attempts to restore root and records the expected failure.

E9 properties checked by the fixed implementation are: no external program is
invoked before all three UIDs are dropped; the only external command has an
absolute path; and `execve` receives a fixed environment rather than inherited
caller variables. T7 exercises the original malicious inputs; T8 attempts
re-elevation after the saved UID has also been replaced.

The dynamic loader enters secure-execution mode for a Set-UID transition and
ignores/restricts variables such as `LD_PRELOAD` and `LD_LIBRARY_PATH`. This
mitigates those loader-variable attacks; it does not make application-level
shell or PATH use safe. Password verifiers belong in `/etc/shadow`, not the
public `/etc/passwd` fields. A per-password random salt prevents equal passwords
from having equal stored hashes and frustrates precomputed hash tables; the
shadow file's restricted permissions limit access to those verifiers.

For the shared directory, setgid causes new entries to inherit the directory
group. A file's creation mode is filtered by the creator's umask (for example,
0666 with umask 0002 gives 0664; umask 0027 gives 0640). The sticky bit on a
shared writable directory restricts deletion/renaming to the file owner,
directory owner, or a privileged process.

## Cleanup

After collecting evidence, remove installed binaries with `make uninstall`.
If the capability setup was run, uninstall clears the capability from the
probe. User accounts, `/home/lab1_shared`, `traces/`, and marker files are kept
for inspection and must be removed separately if desired.