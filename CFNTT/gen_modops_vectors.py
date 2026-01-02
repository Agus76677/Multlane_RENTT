# gen_modops_vectors.py
import random
from pathlib import Path

Q = 3329
DW = 12
MASK = (1 << DW) - 1

def mod_add(x, y, q=Q):
    return (x + y) % q

def mod_sub(x, y, q=Q):
    return (x - y) % q

def mod_half(x, q=Q):
    # q is odd (3329), so (q+1)/2 is integer
    if (x & 1) == 0:
        return (x >> 1) % q
    else:
        return ((x + q) >> 1) % q

def mod_mul(a, b, q=Q):
    return (a * b) % q

def fmt12(x):
    return f"{x & MASK:03x}"

def write_vec_add(path, n, rng):
    with open(path, "w") as f:
        for _ in range(n):
            x = rng.randrange(0, Q)
            y = rng.randrange(0, Q)
            e = mod_add(x, y)
            f.write(f"{fmt12(x)} {fmt12(y)} {fmt12(e)}\n")

def write_vec_sub(path, n, rng):
    with open(path, "w") as f:
        for _ in range(n):
            x = rng.randrange(0, Q)
            y = rng.randrange(0, Q)
            e = mod_sub(x, y)
            f.write(f"{fmt12(x)} {fmt12(y)} {fmt12(e)}\n")

def write_vec_half(path, n, rng):
    with open(path, "w") as f:
        for _ in range(n):
            x = rng.randrange(0, Q)
            e = mod_half(x)
            f.write(f"{fmt12(x)} {fmt12(e)}\n")

def write_vec_mul(path, n, rng):
    with open(path, "w") as f:
        for _ in range(n):
            a = rng.randrange(0, Q)
            b = rng.randrange(0, Q)
            e = mod_mul(a, b)
            f.write(f"{fmt12(a)} {fmt12(b)} {fmt12(e)}\n")

def main():
    outdir = Path("tb_vectors")
    outdir.mkdir(parents=True, exist_ok=True)

    # 固定种子，便于复现
    rng = random.Random(20250101)

    N_ADD  = 20000
    N_SUB  = 20000
    N_HALF = 20000
    N_MUL  = 20000

    write_vec_add(outdir / "vec_add.txt",  N_ADD,  rng)
    write_vec_sub(outdir / "vec_sub.txt",  N_SUB,  rng)
    write_vec_half(outdir / "vec_half.txt", N_HALF, rng)
    write_vec_mul(outdir / "vec_mul.txt",  N_MUL,  rng)

    print("Generated vectors in:", outdir.resolve())

if __name__ == "__main__":
    main()
