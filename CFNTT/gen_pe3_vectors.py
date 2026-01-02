
# gen_pe3_vectors.py
import os
import random

Q = 3329
INV2 = 1665
CONST_W = 1729

def modq(x):
    return x % Q

def pe3_ntt(u, v):
    t = modq(v * CONST_W)
    lower = modq(u + t)
    upper = modq(u - t)
    return upper, lower

def pe3_intt(u, v):
    lower = modq((u + v) * INV2)
    upper = modq((v - u) * CONST_W * INV2)
    return upper, lower

def pack60(u, v, w0, expU, expL):
    return ((u & 0xFFF) << 48) | ((v & 0xFFF) << 36) | ((w0 & 0xFFF) << 24) | ((expU & 0xFFF) << 12) | (expL & 0xFFF)

def main():
    random.seed(3)
    N_WARM = 10
    N_RAND = 6000

    ntt, intt = [], []

    for _ in range(N_WARM):
        u=v=0
        eu, el = pe3_ntt(u,v)
        ntt.append(pack60(u,v,0,eu,el))

    for _ in range(N_WARM):
        u=v=0
        eu, el = pe3_intt(u,v)
        intt.append(pack60(u,v,0,eu,el))

    for _ in range(N_RAND):
        u = random.randrange(Q)
        v = random.randrange(Q)
        eu, el = pe3_ntt(u,v)
        ntt.append(pack60(u,v,0,eu,el))

    for _ in range(N_RAND):
        u = random.randrange(Q)
        v = random.randrange(Q)
        eu, el = pe3_intt(u,v)
        intt.append(pack60(u,v,0,eu,el))

    os.makedirs("tb_vectors", exist_ok=True)
    with open("tb_vectors/pe3_ntt.vec","w") as f:
        for x in ntt:
            f.write(f"{x:015x}\n")
    with open("tb_vectors/pe3_intt.vec","w") as f:
        for x in intt:
            f.write(f"{x:015x}\n")

    print("PE3 vectors generated.")

if __name__ == "__main__":
    main()
