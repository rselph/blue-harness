# Contributing to blue-harness

Thanks for looking at blue-harness. Contributions are welcome, and small focused changes are the easiest to review.

## Running it locally

You need Linux or WSL with `python3`, `make`, and `gcc`.

```sh
git clone https://github.com/seifheakal/blue-harness.git
cd blue-harness
make demo      # measure a sample build, then prove the hardening fires
make verify    # run every verify slice and print one posture summary
```

## How tests work

Every countermeasure must ship with a test that proves it fires and proves that the audit detects it. A countermeasure without a test is not done.

The verify slices live in `harness/verify/`. Each one checks the mechanism directly, for example by comparing binaries byte for byte, checking that an audit score changes, or checking that a hardened build still runs.

`make verify` must stay green. CI runs it on every push and pull request, so a red run blocks the change.

## Opening a pull request

- Keep each PR small and focused on one change.
- Label commits by phase: `research:`, `analysis:`, `harness:`, `skill:`, or `docs:`. For example, `harness: add PE overlay decoy pass`.
- Explain why the change is needed in the commit message. The diff already shows what changed.
- For a countermeasure, name its strength tier and its known bypass in the PR and in the docs. Do not claim it is unbreakable.
- Fill in the pull request template.

## Licensing

blue-harness is AGPL-3.0 (open source), with a commercial dual-license option (see `COMMERCIAL-LICENSE.md`). By contributing, you agree that your contribution is licensed under AGPL-3.0. You also agree that the maintainer may also license your contribution commercially. This is what makes the dual-license model possible.

## Questions and security

Use GitHub issues for bugs, feature ideas, and general questions. For security problems, follow `SECURITY.md` and do not open a public issue.

Please read `CODE_OF_CONDUCT.md` before taking part.
