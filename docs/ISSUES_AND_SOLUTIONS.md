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


---

## 6. Integration Testbench Sampling Timing Error

### Issue

During the first complete TinyNoC integration simulation, all three basic routing tests failed:

```text
FAIL: Input 0 -> Output 2
FAIL: Input 1 -> Output 1
FAIL: Input 3 -> Output 0
TINYNOC INTEGRATION FAILED: 3 errors
```

However, the individual RTL blocks had already passed linting and standalone verification.

### Cause

The failure was caused by the testbench sampling the router output too late.

After sending a packet, the testbench originally waited for two additional negative clock edges:

```systemverilog
repeat (2) @(negedge clk);
```

The router had already forwarded the packet and removed it from the input FIFO before the testbench checked `out_valid` and `out_packet`.

Therefore, the testbench reported a false failure even though the datapath was operating correctly.

### Solution

The unnecessary delay was removed and the output was checked shortly after the packet-send task completed:

```systemverilog
#1;
```

This allowed the combinational routing and arbitration logic to settle while the output packet was still valid.

### Result

After correcting the testbench sampling time, the integration simulation reported:

```text
PASS: Input 0 routed to Output 2
PASS: Input 1 routed to Output 1
PASS: Input 3 routed to Output 0

BASIC TINYNOC INTEGRATION PASSED
```

### Learning

This issue demonstrated that:

```text
Lint Clean
    !=
Module Verification
    !=
Integration Verification
```

Correct testbench timing is essential when validating cycle-level RTL behavior.

## IHP SG13G2 Synthesis and Physical Design

### 1. Cell Count Exceeded the Target

**Problem:**  
The initial IHP SG13G2 synthesis of the TinyNoC core produced 1117 mapped standard cells, exceeding the target of 1000 cells.

**Solution:**  
The FIFO depth of all four input FIFOs was reduced from 4 to 2. RTL integration verification was repeated after the optimization and passed successfully.

The optimized TinyNoC core required 769 mapped standard cells. After adding the external tapeout wrapper, the final synthesis resulted in 939 mapped SG13G2 standard cells.

---

### 2. Static Timing Analysis

**Problem:**  
OpenSTA was initially unavailable on Ubuntu and had to be built with its required dependencies.

**Solution:**  
OpenSTA 3.1.0 was successfully built and used with the IHP SG13G2 typical timing library.

A preliminary clock period of 20 ns (50 MHz) was used for timing analysis.

Results:

- Setup worst slack: +15.24 ns
- Hold worst slack: +0.26 ns
- Setup timing: MET
- Hold timing: MET

These results correspond to preliminary pre-layout STA.

---

### 3. OpenROAD Build Issue

**Problem:**  
Building OpenROAD locally required several dependencies and significant compilation time. The source build could not be completed efficiently on the available system.

**Solution:**  
Instead of continuing the local OpenROAD compilation, LibreLane was installed in a Python virtual environment and Docker was used to provide the required physical-design tools.

---

### 4. Docker Permission Error

**Problem:**  
LibreLane initially reported:

`permission denied while trying to connect to the docker API`

**Solution:**  
The user was added to the Docker group:

`sudo usermod -aG docker $USER`

The new group was activated using:

`newgrp docker`

Docker operation was then verified successfully.

---

### 5. IHP SG13G2 PDK Not Detected

**Problem:**  
LibreLane initially attempted to use/download its default PDK environment and reported that `ihp-sg13g2` could not be found.

**Solution:**  
The existing local IHP Open PDK was used through LibreLane's manual PDK mode.

The selected technology configuration was:

- PDK: `ihp-sg13g2`
- Standard-cell library: `sg13g2_stdcell`

This allowed LibreLane to use the local IHP SG13G2 technology files directly.

---

## Final Physical Design Results

The complete LibreLane physical-design flow successfully reached GDSII.

Final results:

- Standard-cell synthesis result: 939 cells
- Design instance area: 39,060.4 µm²
- Die area: 48,198.1 µm²
- Standard-cell utilization: 55.4162%
- Final routed wire length: 39,942 µm
- Antenna violations: 0
- Magic DRC errors: 0
- KLayout DRC errors: 0
- LVS device differences: 0
- LVS net differences: 0
- LVS unmatched pins: 0
- Setup TNS: 0
- Hold TNS: 0

The flow successfully completed:

`RTL → Verification → Synthesis → STA → Floorplanning → Placement → CTS → Routing → DRC → LVS → GDSII`

Final generated deliverables include GDSII, DEF, LEF, post-layout netlist, SDF, SDC, SPICE netlist, layout render, and implementation metrics.

### Timing Note

LibreLane reported that dedicated `PNR_SDC_FILE` and `SIGNOFF_SDC_FILE` files were not explicitly provided, so generic fallback SDC constraints were used for some PnR/sign-off stages. Therefore, the physical implementation completed successfully, but final tapeout timing constraints should be confirmed against the required shuttle specification.

