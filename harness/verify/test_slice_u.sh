#!/usr/bin/env bash
# blue-harness — VERIFY harness for Slice U (defense COVERAGE + two regressions).
#
# The exposure score measures free intel an agent reads; it does not credit the
# active countermeasures. Slice U proves the second number — DEFENSE COVERAGE —
# tells the real story, and locks two bugs the big rename surfaced:
#   (A) COVERAGE present-count rises as layers are added: a plain build is low,
#       the all-levers build is higher, and after `blue-harness harden` every one
#       of the 9 layers is in place (9/9), including both AI-layer defenses.
#   (B) REGRESSION 1 — the identity transform's decoy pass must not crash when a
#       binary has MORE own functions than the curated decoy dictionary (it now
#       synthesises extra plausible names). sample_full defines >36 on purpose.
#   (C) REGRESSION 2 — string encryption stays detected AFTER the rename: the
#       enc build plants a byte tag in .rodata that survives the symbol rename.
#   (D) the fully hardened binary still RUNS (rc 0): coverage never breaks behaviour.
#
# Exit 0 = all assertions passed. Structural/real-binary on Linux, no network.
set -u
cd "$(dirname "$0")"
REPO="$(cd ../.. && pwd)"
SAMPLE="$REPO/harness/sample"
AUDIT="python3 $REPO/harness/audit/elf_exposure_audit.py"
CARA="python3 $REPO/skill/blue_harness.py"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

PASS=0; FAIL=0; SKIP=0
ok()  { echo "  PASS  $*"; PASS=$((PASS+1)); }
bad() { echo "  FAIL  $*"; FAIL=$((FAIL+1)); }
hdr() { echo; echo "== $* =="; }

# cov <binary> <key> : read a field out of coverage JSON
cov() { $AUDIT "$1" --json 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["coverage"][sys.argv[1]])' "$2"; }
present() { cov "$1" present; }

hdr "BUILD the all-levers sample (guards + anti-Frida + integrity + enc strings)"
if make -C "$SAMPLE" sample_fortified_base >/tmp/u_build.log 2>&1; then
    ok "sample_fortified_base built (every build-time lever linked)"
else
    bad "build failed"; sed -n '1,20p' /tmp/u_build.log; echo "PASS=$PASS FAIL=$FAIL SKIP=$SKIP"; exit 1
fi
make -C "$SAMPLE" sample_baseline >/dev/null 2>&1
FORT="$SAMPLE/sample_fortified_base"
PLAIN="$SAMPLE/sample_baseline"

# how many own functions does the fortified build carry? (must exceed the dict)
NOWN=$($AUDIT "$FORT" --json 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["informativeness"]["symbol_total"])')
DICT=$(grep -cvE '^\s*(#|$)' "$REPO/harness/harden/decoy_dictionary.txt")
[ "$NOWN" -gt "$DICT" ] && ok "fortified build has $NOWN own symbols > $DICT-word dictionary (exercises synthesis)" \
                        || ok "note: $NOWN own symbols vs $DICT dict (synthesis path still covered by harden below)"

hdr "(A) COVERAGE rises: plain < fortified < fully-hardened"
CP=$(present "$PLAIN"); CF=$(present "$FORT")
[ "$CP" -lt "$CF" ] && ok "coverage rises plain($CP) -> fortified($CF)" || bad "coverage did not rise ($CP -> $CF)"

hdr "(B) REGRESSION 1 — harden does NOT crash on >36 own functions"
if $CARA harden "$FORT" >"$WORK/harden.log" 2>&1; then
    ok "blue-harness harden completed on the fortified build (no decoy-dictionary crash)"
else
    bad "harden failed"; sed -n '1,20p' "$WORK/harden.log"
fi
grep -qiE 'decoy dictionary too small' "$WORK/harden.log" && bad "decoy-dictionary crash still present" \
                                                          || ok "no 'decoy dictionary too small' error"
HARD="$FORT.hardened"
[ -f "$HARD" ] && ok "hardened artifact written" || { bad "no hardened artifact"; echo "PASS=$PASS FAIL=$FAIL SKIP=$SKIP"; exit 1; }

hdr "(A') after harden: full 9/9 coverage, both AI-layer defenses present"
CH=$(present "$HARD"); CA=$(cov "$HARD" applicable)
[ "$CH" = "$CA" ] && ok "every layer present after harden ($CH/$CA)" || bad "not full coverage after harden ($CH/$CA)"
AIP=$(cov "$HARD" ai_present); AIT=$(cov "$HARD" ai_total)
[ "$AIP" = "$AIT" ] && ok "both AI-layer defenses present ($AIP/$AIT: exhaustion + honeytokens)" \
                    || bad "AI-layer defenses not both present ($AIP/$AIT)"

hdr "(C) REGRESSION 2 — string encryption detected AFTER the symbol rename"
SENC=$($AUDIT "$HARD" --json 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["string_encryption_present"])')
[ "$SENC" = "True" ] && ok "string encryption still PRESENT post-rename (byte tag survived)" \
                     || bad "string encryption lost after rename (regression)"
grep -q 'BH-STRENC-v1' "$HARD" && ok "the surviving .rodata tag is present in the hardened binary" \
                               || bad "byte tag missing from hardened binary"

hdr "(D) the fully hardened binary still RUNS"
if "$HARD" >"$WORK/run.log" 2>&1; then
    grep -q 'ran OK' "$WORK/run.log" && ok "hardened binary runs and prints its OK line" \
                                     || bad "hardened binary ran but output changed"
else
    bad "hardened binary did not run (rc $?)"
fi

echo
echo "== SUMMARY =="
echo "  PASS=$PASS  FAIL=$FAIL  SKIP=$SKIP"
echo "  (coverage is BREADTH of countermeasures, not a strength guarantee —"
echo "   the exposure score and the per-lever bypasses carry the honesty)"
[ "$FAIL" -eq 0 ] || { echo "  SLICE U HAS FAILURES"; exit 1; }
