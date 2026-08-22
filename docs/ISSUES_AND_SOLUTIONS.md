# TinyNoC - Issues and Solutions Log

This document records important issues encountered during the RTL development and verification of the TinyNoC project and the solutions used to resolve them.

## 1. Verible local parameter naming warning

### Issue

While linting `input_fifo.sv`, Verible reported that the local parameter name did not follow the configured naming convention.

Example:

```text
Localparam name does not match the naming convention
[Style: constants] [parameter-name-style]
```

###Cause

The local parameter naming style did not follow the Verible coding-style convention.

###Solution

The parameter name was changed to follow the required naming convention.

###Result

The RTL passed Verible lint successfully.

---

## 2. Verible Unpacked Array Style Warning

### Issue

While linting `input_fifo.sv`, Verible reported:

```text
When an unpacked dimension range is zero-based [0:N-1],
declare size as [N] instead.
[Style: unpacked-dimensions-range-ordering]
```

### Cause

The FIFO memory was originally declared using an explicit zero-based unpacked array range:

```systemverilog
logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
```

Verible recommends using the compact size notation for this type of zero-based unpacked array.

### Solution

The memory declaration was changed to:

```systemverilog
logic [DATA_WIDTH-1:0] mem [DEPTH];
```

### Result

The Verible warning was removed, and the FIFO continued to pass all functional simulation tests.

---

## 3. SystemVerilog Reserved Keyword Error in QoS Arbiter

### Issue

While linting `qos_arbiter.sv`, Verible reported multiple syntax errors. The first error was:

```text
qos_arbiter.sv:5:24-31: syntax error at token "priority"
```

Several additional syntax errors appeared afterward at tokens such as `assign`, `always_comb`, and `always_ff`.

### Cause

The signal was originally declared as:

```systemverilog
input logic [3:0] priority;
```

However, `priority` is a reserved keyword in SystemVerilog. It is used with constructs such as `priority if` and `priority case`, so it cannot be used as a normal signal name.

The later syntax errors were cascading errors caused by this first problem.

### Solution

The signal was renamed from:

```systemverilog
priority
```

to:

```systemverilog
qos_priority
```

All references to the signal inside `qos_arbiter.sv` were also updated.

### Result

After renaming the signal, the command:

```bash
verible-verilog-lint qos_arbiter.sv round_robin_arbiter.sv
```

completed without any lint errors.

The QoS arbiter was then compiled and simulated successfully, and all QoS arbitration tests passed.

---

## 4. Icarus Verilog always_comb Warning

### Issue

While compiling `round_robin_arbiter.sv` using Icarus Verilog, the following message appeared:

```text
sorry: constant selects in always_* processes are not currently supported
(all bits will be included).
```

The message appeared several times during compilation.

### Cause

This was caused by a limitation in Icarus Verilog when handling constant bit selections inside `always_comb` processes.

It was not an RTL syntax error or a functional failure. Icarus included all relevant bits in the sensitivity handling and still generated the simulation executable.

### Solution

No unnecessary changes were made to the RTL.

The generated simulation was executed normally using:

```bash
vvp ../sim/round_robin_arbiter_sim
```

The self-checking testbench was then used to verify the behavior of the arbiter.

### Result

All round-robin arbitration tests passed successfully, including:

- Rotating priority
- Multiple simultaneous requests
- Single request
- Contention between inputs
- No-request condition

Therefore, the Icarus message was treated as a simulator limitation rather than an RTL functional error.

---

## 5. LibreLane / Nix Build Taking Excessive Time

### Issue

While setting up the LibreLane environment for the IHP SG13G2 physical-design flow, Nix started building several EDA dependencies locally.

The build process took a very long time and consumed significant system resources.

### Cause

Some required packages were being built locally instead of being obtained directly from the available binary cache.

Since the development environment was running inside an Ubuntu virtual machine, compiling large EDA dependencies locally was time-consuming.

### Solution

The running Nix build was safely stopped using:

```text
Ctrl + C
```

Instead of delaying RTL development, the project was continued using the tools already available for the front-end flow:

```text
Verible       -> RTL linting
Icarus Verilog -> RTL simulation
GTKWave       -> Waveform analysis
Yosys         -> Synthesis
```

The LibreLane and IHP SG13G2 environment will be resumed when the design reaches the physical-design stage.

### Result

RTL development and verification could continue independently without waiting for the complete physical-design environment.

This separated the project into front-end and back-end stages and prevented the tool installation process from blocking RTL development.


