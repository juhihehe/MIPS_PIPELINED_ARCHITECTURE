# MIPS_PIPELINED_ARCHITECTURE
5-stage pipelined MIPS CPU in Verilog with hazard detection and forwarding, built on a single-cycle design.
# Pipelined MIPS Processor (Verilog)

A 5-stage pipelined MIPS processor implemented in Verilog, built on top of a
previously completed and verified [single-cycle MIPS design](https://github.com/juhihehe/MIPS_single_cycle).
The pipeline follows the classic IF → ID → EX → MEM → WB structure, with
hazard detection and data forwarding to keep the pipeline running correctly
without unnecessary stalls.

## Architecture

- **Pipeline registers:** IF/ID, ID/EX, EX/MEM, MEM/WB
- **Hazard detection unit:** detects load-use hazards and stalls the pipeline
  when a dependent instruction immediately follows a `lw`
- **Forwarding unit:** resolves data hazards via EX/MEM and MEM/WB forwarding
  paths, avoiding stalls for back-to-back ALU-dependent instructions
- **Branch handling:** branches are resolved early, in the EX stage

## Supported instructions

Same instruction set as the single-cycle base design:

| Type | Instructions |
|------|-------------|
| R-type | `add`, `sub`, `and`, `or`, `slt`, `nor` |
| I-type | `addi`, `lw`, `sw`, `beq` |
| J-type | `j` |

## Verification

Verified through full top-level simulation (`tb_mips_top.v`) rather than
isolated per-module testbenches, to confirm correct end-to-end pipeline
behavior. Confirmed working correctly:

- `addi`, `add`, `sub`, `lw`, `sw`
- ALU-to-ALU forwarding (EX/MEM and MEM/WB paths)
- Load-use hazard stalling

## Known limitations / TODO

- **Branch flush not yet implemented.** Branches resolve in EX, but
  instructions fetched from the wrong path (currently sitting in IF/ID and
  ID/EX at resolution time) are not yet flushed. This is the next planned
  addition.

## Design approach

Built incrementally on a hazard-free pipeline first (correct data flow with
forwarding and load-use stalling), with stall/flush logic layered in
afterward — rather than trying to handle all hazards simultaneously from the
start.

## References

- Patterson & Hennessy, *Computer Organization and Design* (Chapters 2 and 4)
- Harris & Harris, *Digital Design and Computer Architecture: RISC-V Edition*
  (for future RISC-V work)

## Tools

Designed and simulated in Quartus (Analysis & Elaboration).
