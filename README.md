# Multlane_RENTT quick start (P=2 regression)

## Run simulation and checks (P=2 / OP0)
1. Build and run the RTL testbench (requires `iverilog`):
   ```bash
   iverilog -g2012 -I RTL -I RTL/basic_unit -I RTL/basic_unit/bitmod_wocsa3 \
       -DOP0 -DPIPE6 -o sim.out Testbench/tb_polytop_RE.v $(find RTL -name "*.v")
   vvp sim.out +TB_DATA_DIR=software/testbench_data
   ```
2. Compare simulation outputs against the Python model:
   ```bash
   python3 software/run_compare.py
   ```

## Notes on parameter scaling (P=4/8/16)
- Update `RTL/parameter.v` to select the desired parallelism macro (`OP1` for P=4, `OP2` for P=8, `OP3` for P=16) and the pipeline depth macro as needed.
- The permute network, testbench data-path, and Python comparison all derive widths and bank counts from `P`, so no structural rewrites are needed when switching configurations.
- When running simulation with a different `P`, pass the matching `-DOPx` flag to `iverilog` and ensure the corresponding testbench data is available under `software/testbench_data` (or override via `+TB_DATA_DIR=<path>`).
