#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

python3 software/gen_vec_rbfu_hybrid.py

iverilog -g2001 -I . -I basic_unit -I basic_unit/bitmod_wocsa3 -o rbfu_tb.out \
  RBFU.v \
  basic_unit/MA.v basic_unit/MS.v basic_unit/Div2.v basic_unit/Modmul.v basic_unit/intmul.v basic_unit/bitmod_wocsa3/*.v \
  Testbench/tb_rbfu_hybrid.v

vvp rbfu_tb.out
