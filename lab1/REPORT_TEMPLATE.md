# Lab 1 Report Template

Replace every bracketed prompt with your team's verified observations. Attach
the generated terminal traces and screenshots; do not treat expected output as
observed output. Keep the report to the course limit of eight pages excluding
annexes.

## 1. Introduction and threat model

[Purpose, SEED VM version, protected assets, attacker identity/capabilities,
and the supplied Set-UID program's role.]

## 2. Access control (E1-E3)

[Users/groups and relevant `getent passwd`, `getent group`, `id` evidence.
Explain passwd fields, shadow, salts, and why hashes are not included here.]

[Shared directory owner/group/mode; umask observations for T1; setgid and
sticky-bit behavior. Include `ls -l` and `getfacl` evidence.]

[Named ACL for Charlie and the capability probe's `getcap` plus mode evidence.
Explain why `cap_net_raw` is narrower than a root Set-UID program.]

## 3. Vulnerability analysis (E4-E5)

[Program owner, mode, and `getresuid()` values. Explain when the kernel applies
Set-UID and distinguish real/effective/saved UIDs.]

| Surface | Implicit assumption | Evidence / consequence |
| --- | --- | --- |
| User arguments/data | [Fill in] | [Fill in] |
| Environment: PATH/IFS | [Fill in] | [Fill in] |
| Dynamic linking | [Fill in] | [Fill in] |

## 4. Exploits (E6)

For T4 and T5, include the exact replay command, root/effective-UID evidence,
the observed marker contents, root cause, and the violated property. Explain
why T6's `LD_PRELOAD` attempt has no effect in secure-execution mode.

## 5. Fix and verification (E7-E8)

[Explain the absolute `execve`, constant format string, controlled environment,
and ordering of privileged/non-privileged work. Compare T4/T5 with T7.]

[Include T8's before/after `getresuid` and failed re-elevation.]

## 6. Legacy corpus and limits (E9)

[Describe all eight corpus entries. State what the correction guarantees and
what it does not guarantee; in particular, it does not validate arbitrary
input for every possible future command or replace OS-level isolation.]

## 7. Team work

[Roles per session, rotation, five-lab schedule, decisions/disagreements and
resolution, individual contributions, and links to dated Git history.]

## 8. Sources and generative-AI declaration

[List course materials, man pages, other sources, and the exact AI tool/version
and use, or write “aucun usage” if applicable.]

## Annexes

[Attach code excerpts and the actual T1-T8 traces/screenshots.]