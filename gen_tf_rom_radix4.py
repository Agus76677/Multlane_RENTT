"""
Generate radix-4 twiddle ROM for Kyber N=256.
- Stage0 stride=64 (J=64, K=1) placed first
- ROM word (MSB->LSB): w2 | w1 | w3 | omega1
- omega1 uses PHI^(N/2) where PHI is 512-th root
"""
from __future__ import annotations
from dataclasses import dataclass
from pathlib import Path
from typing import List

Q = 3329
N = 256
DATA_WIDTH = 12
NUM_STAGES = 4

PRIMITIVE_ROOT = 17
PHI = pow(PRIMITIVE_ROOT, (Q - 1) // (2 * N), Q)  # 512-th root
OMEGA1 = pow(PHI, N // 2, Q)  # 4-th root
W = pow(PHI, 2, Q)  # 256-th root

STAGE_BASE = [0, 1, 5, 21]
J_TABLE = [64, 16, 4, 1]
K_TABLE = [1, 4, 16, 64]


@dataclass
class TwiddleVector:
    stage: int
    k: int
    w2: int
    w1: int
    w3: int
    omega1: int

    def pack_big_endian(self) -> int:
        values = [self.w2, self.w1, self.w3, self.omega1]
        packed = 0
        for idx, val in enumerate(values):
            shift = (len(values) - 1 - idx) * DATA_WIDTH
            packed |= (val & ((1 << DATA_WIDTH) - 1)) << shift
        return packed

    def hex48(self) -> str:
        return f"{self.pack_big_endian():012x}"


def generate_twiddles() -> List[TwiddleVector]:
    vectors: List[TwiddleVector] = []
    for stage, (J, K) in enumerate(zip(J_TABLE, K_TABLE)):
        base = STAGE_BASE[stage]
        for k in range(K):
            tw_base = pow(W, k * J, Q)
            w1 = tw_base
            w2 = pow(w1, 2, Q)
            w3 = pow(w1, 3, Q)
            vectors.append(TwiddleVector(stage, base + k, w2, w1, w3, OMEGA1))
    return vectors


def write_mem(vectors: List[TwiddleVector], path: Path) -> None:
    with path.open("w", encoding="utf-8") as f:
        for v in vectors:
            f.write(v.hex48() + "\n")


def write_debug(vectors: List[TwiddleVector], path: Path) -> None:
    with path.open("w", encoding="utf-8") as f:
        cur_stage = -1
        for v in vectors:
            if v.stage != cur_stage:
                cur_stage = v.stage
                f.write(f"stage {cur_stage}:\n")
            f.write(
                f"  k={v.k:02d} "
                f"w2={v.w2:4d} "
                f"w1={v.w1:4d} "
                f"w3={v.w3:4d} "
                f"omega1={v.omega1:4d}\n"
            )


def main():
    vectors = generate_twiddles()
    mem_path = Path("tf_rom_radix4.mem")
    dbg_path = Path("tf_rom_debug.txt")

    write_mem(vectors, mem_path)
    write_debug(vectors, dbg_path)

    print(f"[OK] Generated {len(vectors)} radix-4 twiddle entries")
    print(f"     MEM   : {mem_path}")
    print(f"     DEBUG : {dbg_path}")


if __name__ == "__main__":
    main()
