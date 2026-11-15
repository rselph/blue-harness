# demo.tape — reproducible README demo GIF for blue-harness (Carapace)
#
# Renders docs/assets/demo.gif: the one-command showcase that audits a sample
# build, shows its hardening plan, then PROVES every countermeasure fires.
#
# HOW TO RECORD (run inside WSL/Linux, where make + gcc + python3 exist):
#   1. Install VHS + ffmpeg:   https://github.com/charmbracelet/vhs
#        (WSL/Ubuntu: `sudo apt install ffmpeg` then grab the vhs binary)
#   2. From the repo root:     vhs docs/assets/demo.tape
#   3. Commit the generated docs/assets/demo.gif
#
# Keep the GIF short (aim < 10s of actual output). Tune the Sleep below so the
# recording ends right after "ALL CHECKS PASSED", not with dead air.

Output docs/assets/demo.gif

Set FontSize 18
Set Width 1200
Set Height 680
Set Theme "Dracula"
Set TypingSpeed 55ms
Set Margin 16
Set Padding 16
Set BorderRadius 8

# Start already inside the repo (hidden setup).
Hide
Type "clear"  Enter
Show
Sleep 400ms

Type "make demo"
Sleep 700ms
Enter

# Let the audit + proof run. Adjust this to match your machine's real runtime.
Sleep 14s

# Hold on the final "all passed" summary so the loop reads clearly.
Sleep 1500ms

# ---------------------------------------------------------------------------
# ALTERNATIVE narrative (attacker's-eye view): swap the two lines above for a
# mock-attacker run that shows the agent trying the plain build, then the
# hardened one, with the before/after score. No local model needed:
#
#   Type "make slice-k-run-mock"
#   Sleep 700ms
#   Enter
#   Sleep 20s
#
# Use whichever reads better once you watch both back.
