# Security policy

## Supported versions

| Version | Supported |
| ------- | --------- |
| `main`  | Yes       |

blue-harness has no tagged release line yet. Fixes land on `main`.

## Reporting a vulnerability

Please do not open a public issue for a security problem.

Email **seiftamer06@gmail.com** with:

- a description of the problem and its impact
- steps to reproduce (the command, the input file or build, and the output you saw)
- the commit or version you tested

You should get a first response within a few days. Please allow time to fix the issue before any public disclosure. We will tell you when a fix is merged and credit you in the changelog if you want that.

## Scope

This policy covers the harness and the skill in this repository: the audit scanners, the hardening passes, the verify suite, the CrackMe and measurement tooling, and the CI workflow.

Reports that a countermeasure can be bypassed are welcome, but they are not vulnerabilities in the usual sense. Each countermeasure documents its strength tier and a known bypass. A bypass that contradicts a documented tier, or a claim that overstates what a countermeasure does, is in scope and worth reporting.
