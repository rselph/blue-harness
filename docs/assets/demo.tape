# demo.tape: reproducible README demo GIF for blue-harness.
#
# Story (~35s): audit a plain build (84/100, 1/9 layers), harden a build that
# links every lever, re-audit (40/100, 9/9 layers incl. both AI-layer defenses),
# and show it still runs.
#
# Record inside WSL/Linux (needs make + gcc + python3 + vhs + ffmpeg + ttyd):
#   1. From the repo root: vhs docs/assets/demo.tape
# The hidden setup builds the samples and copies them into /tmp/demo so the
# repo tree stays clean. Tune the Sleep values if your machine runs slower.

Output docs/assets/demo.gif

Set Shell "bash"
Set FontSize 16
Set Width 1280
Set Height 760
Set Theme "Dracula"
Set TypingSpeed 38ms
Set Padding 22
Set WindowBar Colorful
Set WindowBarSize 36
Set BorderRadius 10
Set Framerate 24

Hide
Type `make -C harness/sample sample_baseline sample_fortified_base >/dev/null 2>&1`
Enter
Type `export PS1='\[\e[1;32m\]$\[\e[0m\] '; alias bh="python3 $PWD/skill/blue_harness.py"; H='EXPOSURE SCORE|DEFENSE COVERAGE|AI-layer'`
Enter
Type `rm -rf /tmp/demo; mkdir -p /tmp/demo; cp harness/sample/sample_baseline /tmp/demo/app; cp harness/sample/sample_fortified_base /tmp/demo/app-fortified; cd /tmp/demo; clear`
Enter
Sleep 400ms
Show

Type "# 1. How exposed is a plain build to an AI reverse-engineering agent?"
Enter
Type `bh report app | grep -E "$H"`
Enter
Sleep 3000ms

Type "# 2. A build with every blue-harness lever. Harden it:"
Enter
Type `bh harden app-fortified | grep -E "APPLIED|checksum|honeytokens|exhaustion|identity"`
Enter
Sleep 4500ms

Hide
Type "clear"
Enter
Show

Type "# 3. Re-audit the hardened build: score down, coverage up"
Enter
Type `bh report app-fortified.hardened | grep -E "$H"`
Enter
Sleep 3500ms

Type "# 9/9 layers, including the two that target the AI itself. And it still runs:"
Enter
Type "./app-fortified.hardened"
Enter
Sleep 2500ms

Type "# Coverage is breadth, not a promise. Every layer ships a named bypass."
Enter
Sleep 3500ms
