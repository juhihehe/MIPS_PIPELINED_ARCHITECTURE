# 5-Stage Pipelined MIPS Processor

A 32-bit 5-stage pipelined MIPS processor implemented in Verilog, built on top of a
previously completed and verified [single-cycle MIPS design](https://github.com/juhihehe/MIPS_single_cycle).
Features data forwarding, hazard detection, branch handling, jump support, and
self-checking verification.

## Pipeline Architecture

```text
IF → IF/ID → ID → ID/EX → EX → EX/MEM → MEM → MEM/WB → WB
```

**Stages:**
- **IF** — instruction fetch and PC update
- **ID** — instruction decoding, register read, branch evaluation
- **EX** — ALU operation and forwarding
- **MEM** — data memory access
- **WB** — register write-back

## Supported instructions

Same core ISA as the single-cycle base design:

| Type | Instructions |
|------|-------------|
| R-type | `add`, `sub`, `and`, `or`, `slt` |
| I-type | `addi`, `lw`, `sw`, `beq` |
| J-type | `j` |

## Features

- EX/MEM and MEM/WB data forwarding
- Load-use hazard detection and pipeline stalling
- Branch resolution in the ID stage (reduces taken-branch penalty)
- Branch operand forwarding and branch-specific stalls
- Jump handling and pipeline flushing
- Data memory read/write support
- Sign extension for immediate instructions
- Self-checking Verilog testbench

## Hazard handling

Forwarding resolves most RAW data hazards. For load-use dependencies such as:

\`\`\`asm
lw  \$t4, 0(\$zero)
add \$t5, \$t4, \$t1
\`\`\`

the hazard detection unit inserts a pipeline stall until the loaded value
becomes available.

Branches are resolved in the ID stage to reduce the taken-branch penalty,
with additional forwarding and stall logic to handle branch dependencies.

## Verification

A self-checking Verilog testbench verifies:

- Arithmetic and logical instructions
- Load/store operations
- EX/MEM and MEM/WB forwarding
- Load-use stalls
- Store forwarding
- Taken and not-taken branches
- Branch data dependencies
- Jump target handling
- Pipeline flushing
- Signed \`slt\` and immediate operations

The complete directed test suite passes successfully in QuestaSim.

## Tools

- Verilog HDL
- QuestaSim / ModelSim
- Git

## Status

- **RTL Design:** Complete
- **Functional Verification:** Complete
## Design for Testability (DFT)

To make the design production-realistic and testable post-fabrication, full scan DFT was implemented on top of the verified pipeline.

### Scan Implementation
- All pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB) converted to scan flip-flops
- Single scan chain stitched through all scan cells
- `scan_enable` control signal switches each register between normal functional operation and shift mode
- In shift mode, registers form a serial shift register for test pattern loading (scan-in) and response capture (scan-out)

### Verification
- Dedicated scan testbench (`tb_dft_scan.v`) verifies:
  - **Shift operation**: a known test pattern is serially shifted into the scan chain and correctly shifted out, confirming chain integrity
  - **Capture operation**: functional mode captures pipeline state correctly into the scan cells for observation
- Verified in QuestaSim with waveform inspection confirming correct shift-in/shift-out behavior

### Why DFT
Real silicon can't be probed internally after fabrication — scan chains give external test equipment (ATE) a way to shift in known inputs and shift out internal state to detect manufacturing defects, without needing to exercise the full functional pipeline. This mirrors the kind of DFT integration done in industry ASIC/FPGA test flows.
