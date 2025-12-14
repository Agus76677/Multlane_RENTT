#!/usr/bin/env python3
"""
Generate radix-4 twiddle ROM for Kyber (N=256, q=3329).

This generator is aligned with the current Multlane_RENTT hardware:
- Pure radix-4 NTT
- 4PE (P = 4)
- stage0 butterfly stride = 64
- ROM outputs 4 twiddles per address: (w2, w1, w3, omega1)
- Big-endian packing to match wa[] reverse mapping in polytop_RE.v

Outputs:
  1) tf_rom_radix4.mem   -- ROM initialization file
  2) tf_rom_debug.txt   -- human-readable twiddle dump
  3) tf_ROM.v           -- ROM wrapper using parameter.v macros
"""

from __future__ import annotations
from dataclasses import dataclass
from pathlib import Path
from typing import List

# ============================================================
# Kyber parameters
# ============================================================

Q = 3329
N = 256
DATA_WIDTH = 12           # must match `DATA_WIDTH in parameter.v
NUM_STAGES = 4            # log4(256) = 4

PRIMITIVE_ROOT = 17
PHI = pow(PRIMITIVE_ROOT, (Q - 1) // (2 * N), Q)   # 512-th root
OMEGA1 = pow(PHI, N // 4, Q)                       # 4-th primitive root


# ============================================================
# Data structure
# ============================================================

@dataclass
class TwiddleVector:
    stage: int
    j: int
    w2: int
    w1: int
    w3: int
    omega1: int

    def pack_big_endian(self) -> int:
        """
        Big-endian pack into 48 bits:
        MSB ........................................ LSB
        [ w2 | w1 | w3 | omega1 ]
        This matches:
          wa[0] = w2
          wa[1] = w1
          wa[2] = w3
          wa[3] = omega1
        after the reverse mapping in polytop_RE.v
        """
        values = [self.w2, self.w1, self.w3, self.omega1]
        packed = 0
        for idx, val in enumerate(values):
            shift = (len(values) - 1 - idx) * DATA_WIDTH
            packed |= (val & ((1 << DATA_WIDTH) - 1)) << shift
        return packed

    def hex48(self) -> str:
        return f"{self.pack_big_endian():012x}"


# ============================================================
# Twiddle generation
# ============================================================

def generate_twiddles() -> List[TwiddleVector]:
    """
    Generate radix-4 twiddle vectors stage by stage.

    Stage p:
      J = 4^p
      wm = phi^(N / (4J))
      exponents use (2j+1)
    """
    vectors: List[TwiddleVector] = []

    for stage in range(NUM_STAGES):
        J = 4 ** stage
        wm = pow(PHI, N // (4 * J), Q)

        for j in range(J):
            e = 2 * j + 1
            w1 = pow(wm, e, Q)
            w2 = pow(wm, 2 * e, Q)
            w3 = pow(wm, 3 * e, Q)
            vectors.append(
                TwiddleVector(stage, j, w2, w1, w3, OMEGA1)
            )

    return vectors


# ============================================================
# File writers
# ============================================================

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
                f"  j={v.j:02d} "
                f"w2={v.w2:4d} "
                f"w1={v.w1:4d} "
                f"w3={v.w3:4d} "
                f"omega1={v.omega1:4d}\n"
            )


def write_verilog_wrapper(mem_name: str, depth: int, path: Path) -> None:
    """
    ROM wrapper using project macros.
    Enforces P=4 because radix-4 consumes 4 twiddles per cycle.
    """
    body = f"""`include "parameter.v"

// ------------------------------------------------------------
// Auto-generated radix-4 twiddle ROM (Kyber N=256)
// Each ROM word = 4 * DATA_WIDTH = 48 bits
// Order (MSB -> LSB): w2 | w1 | w3 | omega1
// ------------------------------------------------------------
module tf_ROM_radix4(
    input                           clk,
    input       [`ADDR_ROM_WIDTH-1:0] A,
    input                           REN,
    output reg  [(4*`DATA_WIDTH)-1:0] Q
);

    // Radix-4 requires exactly 4 twiddles per cycle
    initial begin
        if (`P != 4) begin
            $display("ERROR: radix-4 tf_ROM expects P=4, but P=%0d", `P);
            $fatal;
        end
    end

    localparam integer DEPTH = {depth};

    reg [(4*`DATA_WIDTH)-1:0] rom [0:DEPTH-1];
    initial $readmemh("{mem_name}.mem", rom);

    always @(posedge clk) begin
        if (REN)
            Q <= rom[A];
        else
            Q <= {{(4*`DATA_WIDTH){{1'b0}}}};
    end

endmodule
"""
    path.write_text(body, encoding="utf-8")


# ============================================================
# Main
# ============================================================

def main():
    vectors = generate_twiddles()

    mem_path   = Path("tf_rom_radix4.mem")
    dbg_path   = Path("tf_rom_debug.txt")
    vlg_path   = Path("tf_ROM_radix4.v")

    write_mem(vectors, mem_path)
    write_debug(vectors, dbg_path)
    write_verilog_wrapper(mem_path.stem, len(vectors), vlg_path)

    print(f"[OK] Generated {len(vectors)} radix-4 twiddle entries")
    print(f"     MEM   : {mem_path}")
    print(f"     DEBUG : {dbg_path}")
    print(f"     RTL   : {vlg_path}")


if __name__ == "__main__":
    main()
