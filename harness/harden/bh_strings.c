/* blue-harness runtime string loader — implementation (libc only).
 * Decodes the byte tables emitted by bh_string_encrypt.py. The xorshift32
 * keystream here is byte-identical to the Python encoder; the round-trip is
 * proven in ../verify/test_slice_f.sh.
 */
#ifndef BH_GEN_HEADER
#define BH_GEN_HEADER "bh_strings_gen.h"
#endif

#define BH_STRINGS_IMPL
#include BH_GEN_HEADER
#include "bh_strings.h"

#include <stdint.h>
#include <string.h>

#define BH_NBUF  8
#define BH_BUFSZ 512

void bh_cstr_into(int id, char *out, size_t cap)
{
    if (!out || cap == 0)
        return;
    if (id < 0 || id >= BH_ENC_COUNT) {
        out[0] = '\0';
        return;
    }
    const unsigned char *d = bh_enc_table[id].d;
    unsigned n = bh_enc_table[id].n;
    if (n > cap - 1)
        n = (unsigned)(cap - 1);

#ifdef BH_STRINGS_ENCRYPTED
    /* position-dependent xorshift32 keystream, seeded per string id */
    uint32_t s = (uint32_t)BH_STR_KEY ^ ((uint32_t)id * 0x9E3779B1u);
    if (s == 0)
        s = 1;
    for (unsigned j = 0; j < n; j++) {
        s ^= s << 13;
        s ^= s >> 17;
        s ^= s << 5;
        out[j] = (char)(d[j] ^ (unsigned char)(s & 0xFF));
    }
#else
    memcpy(out, d, n);
#endif
    out[n] = '\0';
}

const char *bh_cstr(int id)
{
    static char bufs[BH_NBUF][BH_BUFSZ];
    static unsigned cur = 0;
    char *b = bufs[cur];
    cur = (cur + 1) % BH_NBUF;
    bh_cstr_into(id, b, BH_BUFSZ);
    return b;
}
