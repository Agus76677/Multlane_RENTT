# gen_pe1_vectors.py
# Generate PE1 test vectors (with expected outputs)
# Output files:
#   tb_vectors/pe1_ntt.vec : {u,v,w0,expU,expL} packed as 60-bit hex per line
#   tb_vectors/pe1_intt.vec: {u,v,w0,expU,expL} packed as 60-bit hex per line
#
# Notes:
# - PE1 RTL has ports (u,v) only; we keep a dummy w field (=0) in vectors to
#   stay format-compatible with the PE0 vector/testbench style.

import os
import random

Q = 3329
INV2 = 1665  # (Q+1)//2 for Kyber q=3329


def modq(x: int) -> int:
    return x % Q


def pe1_ntt(u: int, v: int):
    """PE1 sel=0 behavior: (u+v, u-v) butterfly over mod q.

    RTL summary (ignoring pure pipeline delays):
      add_out = (u + v) mod q
      sub_out = (u - v) mod q
      bf_lower = add_out (after pipeline)
      bf_upper = sub_out (after pipeline)
    """
    outL = modq(u + v)
    outU = modq(u - v)
    return outU, outL


def pe1_intt(u: int, v: int):
    """PE1 sel=1 behavior: half-butterfly used in inverse path.

    RTL summary (ignoring pure pipeline delays):
      add_out = (u + v) mod q
      sub_out = (v - u) mod q   # swapped operands when sel=1
      bf_lower = half(add_out)
      bf_upper = half(sub_out)
    """
    outL = modq((u + v) * INV2)
    outU = modq((v - u) * INV2)
    return outU, outL


def pack60(u: int, v: int, w0: int, expU: int, expL: int) -> int:
    # [59:48]=u, [47:36]=v, [35:24]=w0(dummy), [23:12]=expU, [11:0]=expL
    return ((u & 0xFFF) << 48) | ((v & 0xFFF) << 36) | ((w0 & 0xFFF) << 24) | ((expU & 0xFFF) << 12) | (expL & 0xFFF)


def main():
    random.seed(1)

    # Match PE0 style; total lines = N_ZERO_WARMUP + N_RAND
    N_ZERO_WARMUP = 10
    N_RAND = 6000

    ntt_lines = []
    intt_lines = []

    # warmup zeros (useful for observing pipeline fill)
    for _ in range(N_ZERO_WARMUP):
        u = v = 0
        expU, expL = pe1_ntt(u, v)
        ntt_lines.append(pack60(u, v, 0, expU, expL))

    for _ in range(N_ZERO_WARMUP):
        u = v = 0
        expU, expL = pe1_intt(u, v)
        intt_lines.append(pack60(u, v, 0, expU, expL))

    # random cases
    for _ in range(N_RAND):
        u = random.randrange(0, Q)
        v = random.randrange(0, Q)
        expU, expL = pe1_ntt(u, v)
        ntt_lines.append(pack60(u, v, 0, expU, expL))

    for _ in range(N_RAND):
        u = random.randrange(0, Q)
        v = random.randrange(0, Q)
        expU, expL = pe1_intt(u, v)
        intt_lines.append(pack60(u, v, 0, expU, expL))

    os.makedirs("tb_vectors", exist_ok=True)

    with open("tb_vectors/pe1_ntt.vec", "w") as f:
        for x in ntt_lines:
            f.write(f"{x:015x}\n")  # 60-bit = 15 hex chars

    with open("tb_vectors/pe1_intt.vec", "w") as f:
        for x in intt_lines:
            f.write(f"{x:015x}\n")

    print("[OK] wrote tb_vectors/pe1_ntt.vec and tb_vectors/pe1_intt.vec")


if __name__ == "__main__":
    main()
