import argparse
import os
import random

Q = 3329
ZETA = 17
I_CONST = 1729
I_INV = 1600
INV2 = 1665


def ma(x, y):
    return (x + y) % Q


def ms(x, y):
    return (x - y) % Q


def modmul(x, y):
    return (x * y) % Q


def div2(x):
    return (x * INV2) % Q


def rand_coef():
    return random.randrange(Q)


def gen_rad2_ntt(n):
    vectors = []
    for _ in range(n):
        a0, b0, a1, b1 = rand_coef(), rand_coef(), rand_coef(), rand_coef()
        w0, w1 = rand_coef(), rand_coef()
        d0 = ma(a0, modmul(b0, w0))
        d1 = ms(a0, modmul(b0, w0))
        d2 = ma(a1, modmul(b1, w1))
        d3 = ms(a1, modmul(b1, w1))
        vectors.append((a0, b0, a1, b1, w0, w1, 0, 0, 0, 0, d0, d1, d2, d3))
    return vectors


def gen_rad2_intt(n):
    vectors = []
    for _ in range(n):
        a0, b0, a1, b1 = rand_coef(), rand_coef(), rand_coef(), rand_coef()
        w0, w1 = rand_coef(), rand_coef()
        d0 = div2(ma(a0, b0))
        d1 = modmul(div2(ms(b0, a0)), w0)
        d2 = div2(ma(a1, b1))
        d3 = modmul(div2(ms(b1, a1)), w1)
        vectors.append((a0, b0, a1, b1, w0, w1, 0, 0, 0, 1, d0, d1, d2, d3))
    return vectors


def gen_rad4_ntt(n):
    vectors = []
    for _ in range(n):
        a0, b0, a1, b1 = rand_coef(), rand_coef(), rand_coef(), rand_coef()
        w1, w2, w3 = rand_coef(), rand_coef(), rand_coef()
        t0 = ma(a0, modmul(a1, w2))
        t1 = ms(a0, modmul(a1, w2))
        t2 = ma(modmul(b0, w1), modmul(b1, w3))
        t3 = ms(modmul(b0, w1), modmul(b1, w3))
        t4 = modmul(t3, I_CONST)
        y0 = ma(t0, t2)
        y2 = ms(t0, t2)
        y1 = ma(t1, t4)
        y3 = ms(t1, t4)
        vectors.append((a0, b0, a1, b1, w1, w2, w3, 0, 1, 0, y0, y2, y1, y3))
    return vectors


def gen_rad4_intt(n):
    vectors = []
    for _ in range(n):
        y0, y2, y1, y3 = rand_coef(), rand_coef(), rand_coef(), rand_coef()
        w1, w2, w3 = rand_coef(), rand_coef(), rand_coef()
        t0 = div2(ma(y0, y2))
        t2 = div2(ms(y0, y2))
        t1 = div2(ma(y1, y3))
        t3 = modmul(div2(ms(y1, y3)), I_INV)
        a0 = div2(ma(t0, t1))
        a2 = modmul(div2(ms(t0, t1)), w2)
        a1 = modmul(div2(ma(t2, t3)), w1)
        a3 = modmul(div2(ms(t2, t3)), w3)
        vectors.append((y0, y2, y1, y3, w1, w2, w3, 0, 1, 1, a0, a1, a2, a3))
    return vectors


def gen_pwm(n):
    vectors = []
    for _ in range(n):
        f0, g0, f1, g1 = rand_coef(), rand_coef(), rand_coef(), rand_coef()
        tw = rand_coef()
        s0 = ma(f0, f1)
        s1 = ma(g0, g1)
        m0 = modmul(f0, g0)
        m1 = modmul(f1, g1)
        h0 = ma(m0, modmul(m1, tw))
        h1 = ms(modmul(s0, s1), ma(m0, m1))
        vectors.append((f0, g0, f1, g1, 0, 0, 0, tw, 1, 2, h0, h1, 0, 0))
    return vectors


MODE_GEN = {
    "rad2_ntt": gen_rad2_ntt,
    "rad2_intt": gen_rad2_intt,
    "rad4_ntt": gen_rad4_ntt,
    "rad4_intt": gen_rad4_intt,
    "pwm": gen_pwm,
}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", required=True, choices=MODE_GEN.keys())
    parser.add_argument("--n", type=int, default=50)
    parser.add_argument("--out", default=os.path.join(".tmp", "vec.txt"))
    args = parser.parse_args()

    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    vectors = MODE_GEN[args.mode](args.n)
    with open(args.out, "w") as f:
        for vec in vectors:
            f.write("%d %d %d %d %d %d %d %d %d %d %d %d %d %d\n" % vec)

    print(f"Generated {len(vectors)} vectors to {args.out} for {args.mode}")


if __name__ == "__main__":
    main()
