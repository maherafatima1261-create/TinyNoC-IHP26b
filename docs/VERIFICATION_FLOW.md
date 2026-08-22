# TinyNoC RTL Verification Flow

This document describes the RTL development and verification methodology used for the **TinyNoC-IHP26b** project.

The objective is to detect coding, syntax, style, and functional issues at the RTL stage before proceeding to synthesis and physical design.

---

## 1. Overall RTL Development Flow

The following flow is followed for each TinyNoC module:

```text
RTL Design
    |
    v
Verible Verilog Lint
    |
    v
RTL Compilation
    |
    v
Self-Checking Testbench
    |
    v
Icarus Verilog Simulation
    |
    v
GTKWave Waveform Analysis
    |
    v
Functional Verification
    |
    v
Git Commit / GitHub
    |
    v
Yosys Synthesis
    |
    v
Physical Design and Sign-off
```

Each RTL module is first linted and individually verified before it is integrated into the complete TinyNoC router.

---


## 2. Verible Verilog Lint

### What is Verible?

Verible is an open-source toolset for parsing, formatting, and linting Verilog and SystemVerilog source code.

In the TinyNoC project, **Verible Verilog Lint** is used as a static RTL analysis tool before synthesis.

### Why is Verible Used?

RTL code may compile or synthesize while still containing poor coding practices, suspicious constructs, naming violations, or maintainability issues.

Verible helps detect such problems early in the design flow.

It is used in TinyNoC to check for:

- SystemVerilog syntax problems
- Coding-style violations
- Naming convention violations
- Incorrect or discouraged declarations
- Reserved keyword misuse
- Potentially problematic RTL constructs
- RTL readability and maintainability issues

### Position of Verible in the TinyNoC Flow

Verible is executed immediately after writing or modifying an RTL module:

```text
Write RTL
   |
   v
Run Verible Lint
   |
   +---- Errors / Warnings ----> Correct RTL
   |                                |
   |<-------------------------------+
   |
   v
Lint Clean
   |
   v
Functional Simulation
```

Therefore, RTL is expected to become **lint-clean before proceeding with functional verification and synthesis**.

### Command Used

For an individual RTL module:

```bash
verible-verilog-lint input_fifo.sv
```

For modules with dependencies:

```bash
verible-verilog-lint qos_arbiter.sv round_robin_arbiter.sv
```

When Verible completes without printing any violations, the RTL is considered lint-clean under the enabled lint rules.

### Example from TinyNoC

During development of the QoS arbiter, the signal name:

```systemverilog
logic [3:0] priority;
```

caused a syntax error because `priority` is a reserved SystemVerilog keyword.

The signal was renamed to:

```systemverilog
logic [3:0] qos_priority;
```

After the correction, the module passed Verible lint successfully.

This demonstrates how linting can identify RTL problems before the design reaches synthesis.

### Important Limitation

Passing Verible lint does **not** prove that the hardware behaves correctly.

For this reason, every TinyNoC RTL module is also tested using self-checking SystemVerilog testbenches and Icarus Verilog simulation.

---

## 3. Functional Verification

After an RTL module becomes lint-clean, functional verification is performed to confirm that the hardware behaves according to the design specification.

### Icarus Verilog

Icarus Verilog is used to compile the SystemVerilog RTL together with its testbench.

Example:

```bash
iverilog -g2012 -o ../sim/input_fifo_sim \
../rtl/input_fifo.sv \
input_fifo_tb.sv
```

The compiled simulation is executed using:

```bash
vvp ../sim/input_fifo_sim
```

---

### Self-Checking Testbenches

Each major TinyNoC RTL module is verified using a self-checking SystemVerilog testbench.

Instead of relying only on manual waveform inspection, the testbench automatically compares the actual RTL output with the expected output.

Example simulation result:

```text
PASS: Reset test
PASS: Read a55 correctly
PASS: Read 3c7 correctly
PASS: Full flag asserted
PASS: Underflow protected
PASS: Simultaneous read/write test

ALL FIFO TESTS PASSED
```

This allows functional errors to be detected automatically during simulation.

---

### GTKWave

GTKWave is used for waveform-level inspection when required.

Simulation waveforms are generated in VCD format and can be opened using:

```bash
gtkwave ../sim/input_fifo.vcd
```

Signals such as clock, reset, FIFO control signals, packet data, routing requests, arbitration grants, and error flags can be inspected graphically.

For example, FIFO verification confirmed that packets were read in the same order in which they were written.

---

## 4. Verification Status

The following RTL blocks have currently been developed and individually verified:

| RTL Module | Verible Lint | Self-Checking Simulation | Main Function Verified |
|---|---|---|---|
| `input_fifo.sv` | PASS | PASS | FIFO ordering, full/empty, overflow, underflow and simultaneous read/write |
| `parity_checker.sv` | PASS | PASS | Even-parity error detection |
| `fault_injector.sv` | PASS | PASS | Controlled single-bit fault injection and parity-error detection |
| `route_decode.sv` | PASS | PASS | 4-port destination decoding |
| `round_robin_arbiter.sv` | PASS | PASS | Fair rotating arbitration and contention handling |
| `qos_arbiter.sv` | PASS | PASS | QoS preference, round-robin fairness and starvation prevention |

---

## 5. Next Verification Stages

After individual RTL block verification, the project will proceed toward:

```text
Switch Fabric Verification
          |
          v
4-Port Router Integration
          |
          v
Integration-Level Verification
          |
          v
Corner-Case Testing
          |
          v
Lint-Clean Complete RTL
          |
          v
Yosys Synthesis
          |
          v
Static Timing Analysis
          |
          v
Physical Design
          |
          v
DRC / LVS / Sign-off
```

The verification documentation will be updated as additional TinyNoC modules and integration tests are completed.


