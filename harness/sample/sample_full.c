/* sample_full.c: the sample app with EVERY build-time blue-harness lever linked,
 * so one binary exercises the full coverage story (audit + harden -> 9/9 layers).
 *
 *   bh_guards     : core-dump suppression + anti-ptrace
 *   bh_antifrida  : maps / thread-name / port-27042 scan
 *   bh_integrity  : hot-function self-checksum + server-nonce attestation
 *   bh_strings    : secrets encrypted at build time, decoded on demand
 *
 * It also defines > 36 of its own functions on purpose, so the identity
 * transform's decoy pass must synthesise names past the curated dictionary
 * (the regression this build guards against). Build:
 *
 *   make sample_fortified_base     # all levers, release (-O2)
 *
 * then `blue-harness harden` adds the post-build passes (decoy / exhaust /
 * honeytokens). See harness/verify/test_slice_u.sh.
 */
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "bh_guards.h"
#include "bh_antifrida.h"
#include "bh_integrity.h"
#include "bh_strings.h"
#include BH_GEN_HEADER

int bh_hotfn(int x);
void bh_hotfn_end(void);

/* the "licensed" logic an attacker would want to patch */
int bh_hotfn(int x)
{
    int acc = 0;
    for (int i = 0; i < 64; ++i) acc += (x ^ i) * 31;
    return acc > 0;
}
void bh_hotfn_end(void) { }

static unsigned fnv1a(const char *s)
{
    unsigned h = 2166136261u;
    while (*s) { h ^= (unsigned char)*s++; h *= 16777619u; }
    return h;
}

/* 40 small worker functions so own-symbol count exceeds the curated decoy
 * dictionary (forces the synthesised-name path in the identity transform). */
#define WORKER(n) static unsigned worker_##n(unsigned x) { return (x ^ (n##u)) * 2654435761u; }
WORKER(0)  WORKER(1)  WORKER(2)  WORKER(3)  WORKER(4)  WORKER(5)  WORKER(6)  WORKER(7)
WORKER(8)  WORKER(9)  WORKER(10) WORKER(11) WORKER(12) WORKER(13) WORKER(14) WORKER(15)
WORKER(16) WORKER(17) WORKER(18) WORKER(19) WORKER(20) WORKER(21) WORKER(22) WORKER(23)
WORKER(24) WORKER(25) WORKER(26) WORKER(27) WORKER(28) WORKER(29) WORKER(30) WORKER(31)
WORKER(32) WORKER(33) WORKER(34) WORKER(35) WORKER(36) WORKER(37) WORKER(38) WORKER(39)

typedef unsigned (*worker_fn)(unsigned);
static const worker_fn WORKERS[40] = {
    worker_0,  worker_1,  worker_2,  worker_3,  worker_4,  worker_5,  worker_6,  worker_7,
    worker_8,  worker_9,  worker_10, worker_11, worker_12, worker_13, worker_14, worker_15,
    worker_16, worker_17, worker_18, worker_19, worker_20, worker_21, worker_22, worker_23,
    worker_24, worker_25, worker_26, worker_27, worker_28, worker_29, worker_30, worker_31,
    worker_32, worker_33, worker_34, worker_35, worker_36, worker_37, worker_38, worker_39,
};

int main(void)
{
    if (bh_guards_init() == BH_TRACER_DETECTED) {
        fprintf(stderr, "BLUE-HARNESS: tracer detected at init — refusing to run\n");
        return 42;
    }

    char detail[256] = {0};
    if (bh_antifrida_scan(detail, sizeof detail) != 0) {
        /* instrumentation present; a real app would decide policy here */
    }

    uint8_t cs[32];
    bh_hotfn_checksum(cs);   /* integrity baseline (attested server-side in real use) */

    char banner[128];
    bh_cstr_into(CSTR_LIC_ERR, banner, sizeof banner);

    unsigned acc = fnv1a(banner) ^ cs[0];
    for (int i = 0; i < 40; ++i)
        acc = WORKERS[i](acc);
    acc += (unsigned)bh_hotfn((int)acc);

    printf("sample: ran OK (work=%u)\n", acc & 0xffff);
    return 0;
}
