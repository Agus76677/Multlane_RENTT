# gen_compact_bf_vectors.py
# Generate test vectors for compact_bf (full radix-4 butterfly) with expected outputs.
#
# Vector format: 132-bit per line (33 hex chars)
#   {u0, v0, u1, v1, wa1, wa2, wa3, exp_bf0U, exp_bf0L, exp_bf1U, exp_bf1L}
# bit mapping (MSB..LSB):
#   [131:120]=u0   [119:108]=v0   [107:96]=u1   [95:84]=v1
#   [83:72]  =wa1  [71:60]  =wa2  [59:48] =wa3
#   [47:36]  =exp_bf0U (bf_0_upper)
#   [35:24]  =exp_bf0L (bf_0_lower)
#   [23:12]  =exp_bf1U (bf_1_upper)
#   [11:0]   =exp_bf1L (bf_1_lower)
#
# IMPORTANT (matches compact_bf.v internal wiring):
#   u0 = a0, v0 = a2, u1 = a1, v1 = a3
#
# q = 3329 (Kyber). Division by 2 is implemented as mul by INV2=1665 mod q.
#
# -----------------------------------------------------------------------------#

import os
import random

Q = 3329
INV2 = 1665          # (Q+1)//2  => x/2 mod q = x*INV2 mod q
W4  = 1729           # ω4^1 (constant used in PE3: const_w = 1729)

def modq(x: int) -> int:
    return x % Q

def pack132(u0, v0, u1, v1, wa1, wa2, wa3, exp_bf0U, exp_bf0L, exp_bf1U, exp_bf1L) -> int:
    x = 0
    x = (x << 12) | (u0 & 0xFFF)
    x = (x << 12) | (v0 & 0xFFF)
    x = (x << 12) | (u1 & 0xFFF)
    x = (x << 12) | (v1 & 0xFFF)
    x = (x << 12) | (wa1 & 0xFFF)
    x = (x << 12) | (wa2 & 0xFFF)
    x = (x << 12) | (wa3 & 0xFFF)
    x = (x << 12) | (exp_bf0U & 0xFFF)
    x = (x << 12) | (exp_bf0L & 0xFFF)
    x = (x << 12) | (exp_bf1U & 0xFFF)
    x = (x << 12) | (exp_bf1L & 0xFFF)
    return x

# =============================================================================
# Golden model (full radix-4 butterfly)
# =============================================================================

def compact_bf_ntt(u0, v0, u1, v1, wa1, wa2, wa3):
    """
    sel=0 (NTT) golden model for compact_bf.

    ---- PE mapping annotations (NTT) ----
    PE0 (uses wa2):
        T0 = (a0 + a2 * ω2) mod q
        T1 = (a0 - a2 * ω2) mod q
        Here: a0=u0, a2=v0, ω2=wa2

    PE2 (uses wa1, wa3):
        T2 = (a1 * ω1 + a3 * ω3) mod q
        T3 = (a1 * ω1 - a3 * ω3) mod q
        Here: a1=u1, a3=v1, ω1=wa1, ω3=wa3

    PE1 (add/sub, no twiddle):
        A0 = (T0 + T2) mod q   -> bf_0_lower
        A2 = (T0 - T2) mod q   -> bf_1_lower

    PE3 (const ω4^1 = 1729):
        A1 = (T1 + T3 * ω4) mod q   -> bf_0_upper
        A3 = (T1 - T3 * ω4) mod q   -> bf_1_upper
        Here: ω4 = W4 = 1729
    """
    # --- PE0: T0/T1 ---
    T0 = modq(u0 + v0 * wa2)
    T1 = modq(u0 - v0 * wa2)

    # --- PE2: T2/T3 ---
    t_u1 = modq(u1 * wa1)
    t_v1 = modq(v1 * wa3)
    T2 = modq(t_u1 + t_v1)
    T3 = modq(t_u1 - t_v1)

    # --- PE1: A0/A2 ---
    A0 = modq(T0 + T2)
    A2 = modq(T0 - T2)

    # --- PE3: A1/A3 (uses ω4) ---
    T3w4 = modq(T3 * W4)
    A1 = modq(T1 + T3w4)
    A3 = modq(T1 - T3w4)

    # compact_bf outputs: bf_0_upper, bf_0_lower, bf_1_upper, bf_1_lower
    bf0U, bf0L, bf1U, bf1L = A1, A0, A3, A2
    return bf0U, bf0L, bf1U, bf1L

def compact_bf_intt(u0, v0, u1, v1, wa1, wa2, wa3):
    """
    sel=1 (INTT) golden model for compact_bf.

    ---- PE mapping annotations (INTT) ----
    Stage-1 (compute T0..T3):

    PE3 (const ω4^1 = 1729):
        T0 = 1/2 * (a0 + a2) mod q
        T1 = 1/2 * (a2 - a0) * ω4 mod q
        Here: a0=u0, a2=v0, ω4=W4

    PE1 (add/sub + /2):
        T2 = 1/2 * (a1 + a3) mod q
        T3 = 1/2 * (a3 - a1) mod q
        Here: a1=u1, a3=v1

    Stage-2 (final A0..A3):

    PE0 (uses wa2):
        A0 = 1/2 * (T0 + T2) mod q
        A2 = 1/2 * (T2 - T0) * ω2 mod q
        Here: ω2=wa2

    PE2 (uses wa1, wa3):
        A1 = 1/2 * (T1 + T3) * ω1 mod q
        A3 = 1/2 * (T3 - T1) * ω3 mod q
        Here: ω1=wa1, ω3=wa3
    """
    # --- Stage-1: PE3 -> T0/T1 ---
    T0 = modq((u0 + v0) * INV2)
    T1 = modq((v0 - u0) * W4 * INV2)

    # --- Stage-1: PE1 -> T2/T3 ---
    T2 = modq((u1 + v1) * INV2)
    T3 = modq((v1 - u1) * INV2)

    # --- Stage-2: PE0 -> A0/A2 ---
    A0 = modq((T0 + T2) * INV2)
    A2 = modq((T2 - T0) * wa2 * INV2)

    # --- Stage-2: PE2 -> A1/A3 ---
    A1 = modq((T1 + T3) * wa1 * INV2)
    A3 = modq((T3 - T1) * wa3 * INV2)

    bf0U, bf0L, bf1U, bf1L = A1, A0, A3, A2
    return bf0U, bf0L, bf1U, bf1L

# =============================================================================
# Vector generation
# =============================================================================

def main():
    random.seed(7)

    N_ZERO_WARMUP = 10
    N_RAND = 6000

    ntt_lines = []
    intt_lines = []

    # warmup zeros
    for _ in range(N_ZERO_WARMUP):
        u0=v0=u1=v1=0
        wa1=wa2=wa3=0
        e0U,e0L,e1U,e1L = compact_bf_ntt(u0,v0,u1,v1,wa1,wa2,wa3)
        ntt_lines.append(pack132(u0,v0,u1,v1,wa1,wa2,wa3,e0U,e0L,e1U,e1L))

    for _ in range(N_ZERO_WARMUP):
        u0=v0=u1=v1=0
        wa1=wa2=wa3=0
        e0U,e0L,e1U,e1L = compact_bf_intt(u0,v0,u1,v1,wa1,wa2,wa3)
        intt_lines.append(pack132(u0,v0,u1,v1,wa1,wa2,wa3,e0U,e0L,e1U,e1L))

    # random cases (u0=a0, v0=a2, u1=a1, v1=a3)
    for _ in range(N_RAND):
        u0 = random.randrange(0, Q)
        v0 = random.randrange(0, Q)
        u1 = random.randrange(0, Q)
        v1 = random.randrange(0, Q)
        wa1 = random.randrange(0, Q)
        wa2 = random.randrange(0, Q)
        wa3 = random.randrange(0, Q)
        e0U,e0L,e1U,e1L = compact_bf_ntt(u0,v0,u1,v1,wa1,wa2,wa3)
        ntt_lines.append(pack132(u0,v0,u1,v1,wa1,wa2,wa3,e0U,e0L,e1U,e1L))

    for _ in range(N_RAND):
        u0 = random.randrange(0, Q)
        v0 = random.randrange(0, Q)
        u1 = random.randrange(0, Q)
        v1 = random.randrange(0, Q)
        wa1 = random.randrange(0, Q)
        wa2 = random.randrange(0, Q)
        wa3 = random.randrange(0, Q)
        e0U,e0L,e1U,e1L = compact_bf_intt(u0,v0,u1,v1,wa1,wa2,wa3)
        intt_lines.append(pack132(u0,v0,u1,v1,wa1,wa2,wa3,e0U,e0L,e1U,e1L))

    os.makedirs("tb_vectors", exist_ok=True)

    with open("tb_vectors/compact_bf_ntt.vec", "w") as f:
        for x in ntt_lines:
            f.write(f"{x:033x}\n")  # 132-bit = 33 hex chars

    with open("tb_vectors/compact_bf_intt.vec", "w") as f:
        for x in intt_lines:
            f.write(f"{x:033x}\n")

    print("[OK] wrote tb_vectors/compact_bf_ntt.vec and tb_vectors/compact_bf_intt.vec")

if __name__ == "__main__":
    main()
