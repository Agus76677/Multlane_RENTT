# gen_pe2_vectors.py
# Generate PE2 NTT/INTT test vectors (with expected outputs)
# Output files:
#   tb_vectors/pe2_ntt.vec : {u,v,w1,w2,expU,expL} packed as 72-bit hex per line
#   tb_vectors/pe2_intt.vec: {u,v,w1,w2,expU,expL} packed as 72-bit hex per line
#
# Notes:
# - Format is 6 fields x 12 bits = 72 bits => 18 hex chars per line
#   [71:60]=u, [59:48]=v, [47:36]=w1, [35:24]=w2, [23:12]=expU, [11:0]=expL
# - q = 3329 (Kyber)
# - "half" in RTL is modular_half => multiply by INV2 in GF(q)

import os
import random

Q = 3329
INV2 = 1665  # (Q+1)//2 for Kyber q=3329

def modq(x: int) -> int:
    return x % Q

def pe2_ntt(u: int, v: int, w1: int, w2: int):
    # sel=0 in PE2:
    # mult1 = u*w1
    # mult2 = v*w2
    # bf_lower = mult1 + mult2
    # bf_upper = mult1 - mult2
    m1 = modq(u * w1)
    m2 = modq(v * w2)
    outL = modq(m1 + m2)
    outU = modq(m1 - m2)
    return outU, outL

def pe2_intt(u: int, v: int, w1: int, w2: int):
    # sel=1 in PE2:
    # add = (u+v) mod q
    # sub = (v-u) mod q
    # bf_lower = half(add*w1) = (add*w1)/2 mod q
    # bf_upper = half(sub*w2) = (sub*w2)/2 mod q
    addv = modq(u + v)
    subv = modq(v - u)
    outL = modq(addv * w1)
    outL = modq(outL * INV2)
    outU = modq(subv * w2)
    outU = modq(outU * INV2)
    return outU, outL

def pack72(u: int, v: int, w1: int, w2: int, expU: int, expL: int) -> int:
    return ((u & 0xFFF) << 60) | ((v & 0xFFF) << 48) | ((w1 & 0xFFF) << 36) | ((w2 & 0xFFF) << 24) | ((expU & 0xFFF) << 12) | (expL & 0xFFF)

def main():
    random.seed(1)

    # Keep consistent with PE0 style: prepend a small warmup, then many random cases.
    # Testbench memory depth can be smaller than the file line count; extra lines are ignored by $readmemh.
    N_ZERO_WARMUP = 10
    N_RAND = 6000

    ntt_lines = []
    intt_lines = []

    # warmup zeros
    for _ in range(N_ZERO_WARMUP):
        u = v = w1 = w2 = 0
        expU, expL = pe2_ntt(u, v, w1, w2)
        ntt_lines.append(pack72(u, v, w1, w2, expU, expL))

    for _ in range(N_ZERO_WARMUP):
        u = v = w1 = w2 = 0
        expU, expL = pe2_intt(u, v, w1, w2)
        intt_lines.append(pack72(u, v, w1, w2, expU, expL))

    # random cases
    for _ in range(N_RAND):
        u  = random.randrange(0, Q)
        v  = random.randrange(0, Q)
        w1 = random.randrange(0, Q)
        w2 = random.randrange(0, Q)
        expU, expL = pe2_ntt(u, v, w1, w2)
        ntt_lines.append(pack72(u, v, w1, w2, expU, expL))

    for _ in range(N_RAND):
        u  = random.randrange(0, Q)
        v  = random.randrange(0, Q)
        w1 = random.randrange(0, Q)
        w2 = random.randrange(0, Q)
        expU, expL = pe2_intt(u, v, w1, w2)
        intt_lines.append(pack72(u, v, w1, w2, expU, expL))

    os.makedirs("tb_vectors", exist_ok=True)

    with open("tb_vectors/pe2_ntt.vec", "w") as f:
        for x in ntt_lines:
            f.write(f"{x:018x}\n")  # 72-bit = 18 hex chars

    with open("tb_vectors/pe2_intt.vec", "w") as f:
        for x in intt_lines:
            f.write(f"{x:018x}\n")

    print("[OK] wrote tb_vectors/pe2_ntt.vec and tb_vectors/pe2_intt.vec")

if __name__ == "__main__":
    main()
