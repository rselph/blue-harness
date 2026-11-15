# Changelog

All notable changes to blue-harness are recorded here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed
- Renamed the project from its working name "Carapace" to **blue-harness**. The CLI is now `skill/blue_harness.py`, hardening modules are `harness/harden/bh_*`, C symbols and macros use the `bh_` / `BH_` prefix, and decoy/honeytoken section names changed to match (for example `.bh_honey`). Rebuild anything linked against the old `carapace_*` guards.

## [0.1.0] - 2026-11-15

- Audit-first posture scanners for native binaries: ELF, PE, and Mach-O exposure audits, each read-only and scored with a stated tier. Format is detected by magic byte.
- Post-build harden paths for all three native formats, each with a named bypass. ELF has identity transforms, analysis-surface decoys, and honeytokens. PE has COFF and PDB stripping, an overlay decoy, and honeytokens. Mach-O has local-symbol stripping, a non-mapped decoy segment, and honeytokens.
- Build-time guards for ELF (core-dump suppression, anti-ptrace, string encryption, runtime integrity attestation, anti-Frida scanning) with a reference attestation server.
- Mobile-container reach: APK, AAB, and IPA files are unpacked, their native payloads are audited and hardened through the same per-format paths, and the container is repacked. Repacking invalidates the signature, so the operator must re-sign. The tool says so and does not claim otherwise.
- A Claude skill that drives the harness through audit, recommend, apply, harden, and report, and refuses transforms a format does not support.
- A one-command empirical before-and-after run (`make slice-k-run`) with a CrackMe and a scorer that counts a crack only when it matches the seal. A mock attacker runs the full pipeline in CI. Measured effectiveness numbers are not included and need an operator-run isolated environment.
- CI enforces `make verify` on every push and pull request. The verify suite proves that each countermeasure fires and that the audit detects it. It does not prove that any countermeasure is unbreakable.
- Known limits: PE and Mach-O runtime behavior is verified structurally on Linux, not by running the binaries on Windows or macOS. Signing and build-time levers that need a real toolchain are reported as not applied, not faked.
