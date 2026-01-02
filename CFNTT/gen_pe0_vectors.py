# gen_pe0_tv.py
# Generate PE0 NTT/INTT test vectors (with expected outputs)
# Output files:
#   pe0_ntt.vec : {u,v,w,expU,expL} packed as 60-bit hex per line
#   pe0_intt.vec: {u,v,w,expU,expL} packed as 60-bit hex per line

import random

Q = 3329
INV2 = 1665  # (Q+1)//2 for Kyber q=3329

def modq(x: int) -> int:
    x %= Q
    return x

def pe0_ntt(u: int, v: int, w: int):
    # NTT mode in your PE0:
    # T0 = (u + v*w) mod q
    # T1 = (u - v*w) mod q
    t = modq(v * w)
    outL = modq(u + t)      # bf_lower in sel=0 is add_out_q1
    outU = modq(u - t)      # bf_upper in sel=0 is sub_out_q1
    return outU, outL

def pe0_intt(u: int, v: int, w: int):
    # INTT mode mapping (u=T0, v=T2, w=omega2) based on your corrected formula:
    # A0 = 1/2*(T0 + T2) mod q
    # A2 = 1/2*(T2 - T0)*omega2 mod q
    a0 = modq((u + v) * INV2)
    a2 = modq(modq(v - u) * w)
    a2 = modq(a2 * INV2)
    # In sel=1, bf_lower = half(add_path), bf_upper = half(mult_path)
    outL = a0
    outU = a2
    return outU, outL

def pack60(u, v, w, expU, expL) -> int:
    # [59:48]=u, [47:36]=v, [35:24]=w, [23:12]=expU, [11:0]=expL
    return ((u & 0xFFF) << 48) | ((v & 0xFFF) << 36) | ((w & 0xFFF) << 24) | ((expU & 0xFFF) << 12) | (expL & 0xFFF)

def main():
    random.seed(1)

    # You can tune counts
    N_ZERO_WARMUP = 10   # helps visually see pipeline warmup, optional
    N_RAND = 6000

    ntt_lines = []
    intt_lines = []

    # warmup zeros
    for _ in range(N_ZERO_WARMUP):
        u=v=w=0
        expU, expL = pe0_ntt(u,v,w)
        ntt_lines.append(pack60(u,v,w,expU,expL))
    for _ in range(N_ZERO_WARMUP):
        u=v=w=0
        expU, expL = pe0_intt(u,v,w)
        intt_lines.append(pack60(u,v,w,expU,expL))

    # random cases
    for _ in range(N_RAND):
        u = random.randrange(0, Q)
        v = random.randrange(0, Q)
        w = random.randrange(0, Q)
        expU, expL = pe0_ntt(u,v,w)
        ntt_lines.append(pack60(u,v,w,expU,expL))

    for _ in range(N_RAND):
        u = random.randrange(0, Q)
        v = random.randrange(0, Q)
        w = random.randrange(0, Q)
        expU, expL = pe0_intt(u,v,w)
        intt_lines.append(pack60(u,v,w,expU,expL))

    with open("tb_vectors/pe0_ntt.vec", "w") as f:
        for x in ntt_lines:
            f.write(f"{x:015x}\n")  # 60-bit = 15 hex chars

    with open("tb_vectors/pe0_intt.vec", "w") as f:
        for x in intt_lines:
            f.write(f"{x:015x}\n")

    print("[OK] wrote pe0_ntt.vec and pe0_intt.vec")

if __name__ == "__main__":
    main()
