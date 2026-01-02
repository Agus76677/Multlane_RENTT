import random
from pathlib import Path
from gm_rbfu_hybrid import Q, run_rbfu

RADIX_RAD2 = 0
RADIX_RAD4 = 1
OP_NTT = 0
OP_INTT = 1
OP_PWM = 2

VEC_PATH = Path(__file__).resolve().parent / "rbfu_vectors.txt"
NUM_CASES = 1000


def rand_coeff():
    return random.randrange(Q)


def write_case(fh, radix_mode, opcode, a0, b0, a1, b1, w0, w1, w2, tw_pwm):
    exp = run_rbfu(radix_mode, opcode, a0, b0, a1, b1, w0, w1, w2, tw_pwm)
    fields = [
        radix_mode,
        opcode,
        a0,
        b0,
        a1,
        b1,
        w0,
        w1,
        w2,
        tw_pwm,
        *exp,
    ]
    fh.write(" ".join(f"{v:03x}" for v in fields) + "\n")


def gen_group(fh, radix_mode, opcode, count):
    for _ in range(count):
        a0, b0, a1, b1 = [rand_coeff() for _ in range(4)]
        w0, w1, w2 = [rand_coeff() for _ in range(3)]
        tw_pwm = rand_coeff()
        if opcode == OP_PWM:
            w0 = w1 = w2 = 0
        write_case(fh, radix_mode, opcode, a0, b0, a1, b1, w0, w1, w2, tw_pwm if opcode == OP_PWM else 0)


def main():
    random.seed(0)
    with open(VEC_PATH, "w", encoding="utf-8") as fh:
        gen_group(fh, RADIX_RAD4, OP_NTT, NUM_CASES)
        gen_group(fh, RADIX_RAD4, OP_INTT, NUM_CASES)
        gen_group(fh, RADIX_RAD4, OP_PWM, NUM_CASES)
        gen_group(fh, RADIX_RAD2, OP_NTT, NUM_CASES)
        gen_group(fh, RADIX_RAD2, OP_INTT, NUM_CASES)


if __name__ == "__main__":
    main()
