"""Generate radix-4 twiddle ROM for Kyber N=256, q=3329.

Packing (MSB->LSB): w2 | w1 | w3 | omega1
Each field is 12 bits; ROM lines use hex (12 chars).
Pass a custom phi with --phi; default uses Kyber psi = 17^((q-1)/256).
Segments are emitted in opcode order: NTT, INTT, PWM1, PWM0.
"""
from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Tuple

Q = 3329
N = 256
DATA_WIDTH = 12
NUM_STAGES = 4
STAGE_BASE = [0, 1, 5, 21]
K_TABLE = [1, 4, 16, 64]
SEG_ORDER = ("NTT", "INTT", "PWM1", "PWM0")


def mod_pow(base: int, exp: int, mod: int) -> int:
    return pow(base % mod, exp, mod)


def inv(x: int) -> int:
    return pow(x, -1, Q)


@dataclass
class TwiddleVector:
    stage: int
    idx: int
    w2: int
    w1: int
    w3: int
    omega1: int

    def pack_big_endian(self) -> int:
        values = [self.w2, self.w1, self.w3, self.omega1]
        packed = 0
        for val in values:
            packed = (packed << DATA_WIDTH) | (val & ((1 << DATA_WIDTH) - 1))
        return packed

    def hex48(self) -> str:
        return f"{self.pack_big_endian():012x}"


@dataclass
class Segment:
    name: str
    phi: int
    omega1: int
    twiddles: List[TwiddleVector]


def stage_params() -> Iterable[Tuple[int, int, int]]:
    for stage, k_count in enumerate(K_TABLE):
        yield stage, k_count, STAGE_BASE[stage]


def generate_segment(name: str, phi: int, inverse: bool = False) -> Segment:
    omega1 = mod_pow(phi, N // 4, Q)
    phi_use = inv(phi) if inverse else phi
    vecs: List[TwiddleVector] = []
    for stage, k_count, base in stage_params():
        wm = mod_pow(phi_use, N // (4 * (4 ** stage)), Q)
        for k in range(k_count):
            odd = 2 * k + 1
            w1 = mod_pow(wm, odd, Q)
            w2 = mod_pow(wm, 2 * odd, Q)
            w3 = mod_pow(wm, 3 * odd, Q)
            vecs.append(TwiddleVector(stage, base + k, w2, w1, w3, omega1))
    return Segment(name, phi_use, omega1 if not inverse else inv(omega1), vecs)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--phi", type=int, default=mod_pow(17, (Q - 1) // N, Q),
                        help="Primitive N-th root to build twiddles (default Kyber psi)")
    parser.add_argument("--mem", type=Path, default=Path("tf_rom_radix4.mem"))
    parser.add_argument("--debug", type=Path, default=Path("tf_rom_debug.txt"))
    return parser.parse_args()


def write_mem(vectors: List[TwiddleVector], path: Path) -> None:
    with path.open("w", encoding="utf-8") as f:
        for v in vectors:
            f.write(v.hex48() + "\n")


def write_debug(segments: List[Segment], path: Path) -> None:
    with path.open("w", encoding="utf-8") as f:
        for seg in segments:
            f.write(f"Segment {seg.name} (phi={seg.phi}, omega1={seg.omega1})\n")
            cur_stage = -1
            for v in seg.twiddles:
                if v.stage != cur_stage:
                    cur_stage = v.stage
                    f.write(f"  stage {cur_stage}:\n")
                f.write(
                    f"    addr={v.idx:02d} w2={v.w2:4d} w1={v.w1:4d} "
                    f"w3={v.w3:4d} omega1={v.omega1:4d}\n"
                )
            f.write("\n")


def main() -> None:
    args = parse_args()
    segments: List[Segment] = []
    segments.append(generate_segment("NTT", args.phi, inverse=False))
    segments.append(generate_segment("INTT", args.phi, inverse=True))
    segments.append(generate_segment("PWM1", args.phi, inverse=False))
    segments.append(generate_segment("PWM0", args.phi, inverse=False))

    # Flatten with offsets implied by SEG_ORDER
    all_vectors: List[TwiddleVector] = []
    for seg in segments:
        all_vectors.extend(seg.twiddles)

    write_mem(all_vectors, args.mem)
    write_debug(segments, args.debug)

    print(f"[OK] Generated {len(all_vectors)} radix-4 twiddle entries")
    print(f"     MEM   : {args.mem}")
    print(f"     DEBUG : {args.debug}")


if __name__ == "__main__":
    main()
