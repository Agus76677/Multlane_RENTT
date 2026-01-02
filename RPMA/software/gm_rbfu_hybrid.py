import random

Q = 3329
ZETA = 17
I = 1729
I_INV = pow(I, Q - 2, Q)
INV2 = (Q + 1) // 2


def ma(x, y):
    return (x + y) % Q


def ms(x, y):
    return (x - y) % Q


def modmul(x, y):
    return (x * y) % Q


def div2(x):
    return ((x % Q) * INV2) % Q


def rad2_ntt_pair(a, b, w):
    t = modmul(b, w)
    return ma(a, t), ms(a, t)


def rad2_intt_pair(a, b, w):
    s = div2(ma(a, b))
    d = div2(ms(b, a))
    return s, modmul(d, w)


def rad4_ntt(a0, a1, a2, a3, w1, w2, w3):
    t0 = ma(a0, modmul(a2, w2))
    t1 = ms(a0, modmul(a2, w2))
    t2 = ma(modmul(a1, w1), modmul(a3, w3))
    t3 = ms(modmul(a1, w1), modmul(a3, w3))
    t4 = modmul(t3, I)

    y0 = ma(t0, t2)
    y2 = ms(t0, t2)
    y1 = ma(t1, t4)
    y3 = ms(t1, t4)
    return y0, y2, y1, y3


def rad4_intt(y0, y2, y1, y3, w1, w2, w3):
    t0 = div2(ma(y0, y2))
    t2 = div2(ms(y0, y2))
    t1 = div2(ma(y1, y3))
    t3 = modmul(div2(ms(y1, y3)), I_INV)

    a0 = div2(ma(t0, t1))
    a2 = modmul(div2(ms(t0, t1)), w2)
    a1 = modmul(div2(ma(t2, t3)), w1)
    a3 = modmul(div2(ms(t2, t3)), w3)
    return a0, a1, a2, a3


def pwm(f0, g0, f1, g1, tw):
    s0 = ma(f0, f1)
    s1 = ma(g0, g1)
    m0 = modmul(f0, g0)
    m1 = modmul(f1, g1)
    h0 = ma(m0, modmul(m1, tw))
    h1 = ms(modmul(s0, s1), ma(m0, m1))
    return h0, h1, 0, 0


def run_rbfu(radix_mode, opcode, a0, b0, a1, b1, w0, w1, w2, tw_pwm):
    if opcode == 0:  # NTT
        if radix_mode:
            return rad4_ntt(a0, b0, a1, b1, w0, w1, w2)
        return (*rad2_ntt_pair(a0, b0, w0), *rad2_ntt_pair(a1, b1, w1))
    if opcode == 1:  # INTT
        if radix_mode:
            return rad4_intt(a0, b0, a1, b1, w0, w1, w2)
        return (*rad2_intt_pair(a0, b0, w0), *rad2_intt_pair(a1, b1, w1))
    if opcode == 2:  # PWM
        return pwm(a0, b0, a1, b1, tw_pwm)
    raise ValueError("unsupported opcode")


if __name__ == "__main__":
    random.seed(0)
    for _ in range(5):
        vals = [random.randrange(Q) for _ in range(10)]
        print(run_rbfu(1, 0, *vals[:4], *vals[4:7], vals[7], vals[8], vals[9]))
