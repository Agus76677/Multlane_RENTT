#!/bin/bash
set -euo pipefail
mode="rad2_ntt"
count=50
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      mode="$2"; shift 2;;
    --n)
      count="$2"; shift 2;;
    *)
      echo "Unknown arg $1" >&2; exit 1;;
  esac
done

if ! command -v iverilog >/dev/null 2>&1; then
  echo "iverilog not found, installing..." >&2
  sudo apt-get update -y >/dev/null
  sudo apt-get install -y iverilog >/dev/null
fi

python3 gen_rbfu_vectors.py --mode "$mode" --n "$count"
iverilog -g2001 -DPIPE1 -DOP0 -I basic_unit -I basic_unit/bitmod_wocsa3 -o .tmp/rbfu_tb.vvp RBFU.v basic_unit/*.v basic_unit/bitmod_wocsa3/*.v tb_rbfu_hybrid.v
vvp .tmp/rbfu_tb.vvp +mode="$mode"
