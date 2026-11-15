# blue-harness sample — one source, two builds.
# The ONLY difference between the two targets is -DBH_HARDENED + the guard
# object, so the audit's absent->present flip is attributable to the guards alone.
#
#   make            -> sample_baseline + sample_hardened
#   make clean

CC      ?= cc
CFLAGS  ?= -O0 -g -Wall -Wextra -fno-omit-frame-pointer
HARDEN  := ../harden
INCLUDE := -I$(HARDEN)

.PHONY: all clean
all: sample_baseline sample_hardened

# Unhardened: no guards linked. Audit should report both guards ABSENT.
sample_baseline: sample_app.c
	$(CC) $(CFLAGS) $(INCLUDE) -o $@ sample_app.c

# Clean dev artifact (unstripped, with symbols) consumed by the Slice B identity
# transform. Built on demand (`make sample_dev`), not part of `all`.
sample_dev: sample_app.c
	$(CC) $(CFLAGS) $(INCLUDE) -o $@ sample_app.c

# Hardened: same source + the guard TU, with BH_HARDENED calling the init.
# Audit should report both guards PRESENT (symbols setrlimit/prctl/ptrace +
# the "/proc/self/status","TracerPid" strings are now referenced).
sample_hardened: sample_app.c $(HARDEN)/bh_guards.c $(HARDEN)/bh_guards.h
	$(CC) $(CFLAGS) $(INCLUDE) -DBH_HARDENED -o $@ \
		sample_app.c $(HARDEN)/bh_guards.c

# Slice D: integrity/attestation + anti-Frida guards. Built on demand.
# -O1 keeps the hot function a stable, bounded block (end marker right after it).
sample_attest: sample_attest.c $(HARDEN)/bh_integrity.c $(HARDEN)/bh_antifrida.c \
               $(HARDEN)/bh_integrity.h $(HARDEN)/bh_antifrida.h
	$(CC) -O1 -g -Wall -Wextra $(INCLUDE) -o $@ \
		sample_attest.c $(HARDEN)/bh_integrity.c $(HARDEN)/bh_antifrida.c \
		-lpthread -ldl

# Slice F: build-time string encryption. One source, two builds from one manifest;
# they differ only in the generated header (plaintext vs encrypted byte tables).
GEN := ../harden/bh_string_encrypt.py
STRLOADER := $(HARDEN)/bh_strings.c

sample_strings_enc: sample_strings.c $(STRLOADER) $(HARDEN)/bh_strings.h secret_strings.json
	python3 $(GEN) gen --manifest secret_strings.json --mode enc --out bh_strings_gen_enc.h
	$(CC) -O1 -g -Wall -Wextra $(INCLUDE) -I. -DBH_GEN_HEADER='"bh_strings_gen_enc.h"' \
		-o $@ sample_strings.c $(STRLOADER)

sample_strings_plain: sample_strings.c $(STRLOADER) $(HARDEN)/bh_strings.h secret_strings.json
	python3 $(GEN) gen --manifest secret_strings.json --mode plain --out bh_strings_gen_plain.h
	$(CC) -O1 -g -Wall -Wextra $(INCLUDE) -I. -DBH_GEN_HEADER='"bh_strings_gen_plain.h"' \
		-o $@ sample_strings.c $(STRLOADER)

# Every build-time lever in one binary (the full coverage story for the demo and
# Slice U): guards + anti-Frida + integrity/attest + encrypted strings, built
# -O2 so the link hardening (RELRO/NX/PIE/canary) is on too. Defines >36 of its
# own functions so the identity transform's decoy pass exercises synthesised names.
sample_fortified_base: sample_full.c secret_strings.json \
                       $(HARDEN)/bh_guards.c $(HARDEN)/bh_antifrida.c \
                       $(HARDEN)/bh_integrity.c $(STRLOADER) $(HARDEN)/bh_strings.h
	python3 $(GEN) gen --manifest secret_strings.json --mode enc --out bh_strings_gen_enc.h
	$(CC) -O2 -g -Wall -Wextra $(INCLUDE) -I. -DBH_GEN_HEADER='"bh_strings_gen_enc.h"' \
		-o $@ sample_full.c $(HARDEN)/bh_guards.c $(HARDEN)/bh_antifrida.c \
		$(HARDEN)/bh_integrity.c $(STRLOADER) -lpthread -ldl

clean:
	rm -f sample_baseline sample_hardened sample_dev sample_release_* sample_attest sample_attest_* \
	      sample_strings_enc sample_strings_plain sample_fortified_base sample_fortified_base.* \
	      bh_strings_gen_*.h
