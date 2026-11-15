# demo.tape: reproducible README demo GIF for blue-harness
#
# Story (about 25s): audit a plain build (84/100, wide open), harden the
# guarded build, re-audit (40/100, partially hardened), and show it still runs.
#
# Record inside WSL/Linux, where make + gcc + python3 exist:
#   1. Install VHS + ffmpeg + ttyd: https://github.com/charmbracelet/vhs
#   2. Build the samples once:      make -C harness/sample sample_baseline sample_hardened
#   3. From the repo root:          vhs docs/assets/demo.tape
#
# "app-guarded" is the same source as "app", built with blue-harness's guards
# (harness/harden/bh_guards.c) linked in. The tape copies both samples
# into /tmp/demo so the repo tree stays clean.

Output docs/assets/demo.gif

Set Shell "bash"
Set FontSize 17
Set Width 1240
Set Height 720
Set Theme "Dracula"
Set TypingSpeed 40ms
Set Padding 22
Set WindowBar Colorful
Set WindowBarSize 36
Set BorderRadius 10
Set Framerate 24

Hide
Type `export REPO="$PWD" PS1='\[\e[1;32m\]$\[\e[0m\] '; alias blue-harness="python3 $REPO/skill/blue_harness.py"; rm -rf /tmp/demo; mkdir -p /tmp/demo; cp harness/sample/sample_baseline /tmp/demo/app; cp harness/sample/sample_hardened /tmp/demo/app-guarded; cd /tmp/demo; clear`
Enter
Sleep 500ms
Show

# Scene 1: measure, then harden
Type "# 1. How exposed is my binary to an AI reverse-engineering agent?"
Enter
Type `blue-harness report app | grep -E 'SCORE|TIER'`
Enter
Sleep 2500ms

Type "# 2. Same app with blue-harness guards linked in. Now harden the binary:"
Enter
Type "blue-harness harden app-guarded | head -17"
Enter
Sleep 5500ms

Hide
Type "clear"
Enter
Show

# Scene 2: prove it
Type "# 3. Re-audit the hardened build"
Enter
Type `blue-harness report app-guarded.hardened | grep -E 'SCORE|TIER'`
Enter
Sleep 2500ms

Type "# 4. ...and it still runs"
Enter
Type "./app-guarded.hardened"
Enter
Sleep 2000ms

Type "# Every defense ships with a tier and a named bypass. Nothing is unbreakable."
Enter
Sleep 3500ms
