# TinyNoC – Final RTL to GDSII Implementation Report

## 1. Project Overview

**Project Title:** TinyNoC – Compact 4-Port Network-on-Chip Router

**Technology:** IHP SG13G2 130 nm Open PDK

**Final Top Module:** `tinynoc_wrapper`

TinyNoC is a compact four-port Network-on-Chip (NoC) router designed for a constrained ASIC/tapeout environment. The design implements packet routing, input buffering, arbitration, QoS-based priority handling, and switching between four input and four output ports.

The internal packet width is 12 bits with the following format:

- Bits `[11:10]` – Destination address
- Bit `[9]` – QoS priority
- Bits `[8:1]` – Payload
- Bit `[0]` – Parity

The design was developed in SystemVerilog and verified through RTL simulation before being synthesized and physically implemented using the IHP SG13G2 130 nm technology.

## 2. Major RTL Modules

The TinyNoC design contains the following major RTL blocks:

- `input_fifo.sv` – Input packet buffering
- `route_decode.sv` – Destination-based route decoding
- `round_robin_arbiter.sv` – Round-robin arbitration logic
- `qos_arbiter.sv` – QoS-aware arbitration
- `switch_fabric.sv` – Packet switching between ports
- `tinynoc_top.sv` – Four-port TinyNoC core
- `tinynoc_wrapper.sv` – External tapeout interface wrapper

Additional independently verified modules include:

- `parity_checker.sv`
- `fault_injector.sv`

These two modules were not integrated into the final TinyNoC core in order to keep the implementation within the project's area/cell-count constraint.

## 3. RTL Verification

RTL verification was performed using Icarus Verilog with SystemVerilog support. The integrated TinyNoC testbench verified packet routing and QoS arbitration behavior.

### 3.1 Basic Routing Tests

The following routing cases were successfully verified:

- Input Port 0 → Output Port 2
- Input Port 1 → Output Port 1
- Input Port 3 → Output Port 0

The packets were correctly routed according to the destination field `[11:10]`.

### 3.2 QoS Contention Test

A contention test was performed in which Input Port 0 and Input Port 1 simultaneously requested the same output port.

Input Port 1 was assigned high QoS priority using packet bit `[9]`.

The QoS arbiter correctly selected the high-priority packet first. The normal-priority packet was subsequently forwarded.

This verified that the QoS-aware arbitration mechanism operates correctly under output-port contention.

### 3.3 Verification Result

The final integrated RTL simulation completed successfully with:

`BASIC TINYNOC INTEGRATION PASSED`

After reducing the input FIFO depth from 4 to 2 during area optimization, the complete integration test was repeated and passed again, confirming that the optimization preserved the required TinyNoC functionality.

## 4. Synthesis and Area Optimization

### 4.1 Technology Mapping

The TinyNoC design was synthesized and technology-mapped using the IHP SG13G2 130 nm standard-cell library.

An initial synthesis of the TinyNoC core with an input FIFO depth of 4 resulted in:

- Mapped standard cells: 1117

This exceeded the project target of approximately 1000 standard cells.

### 4.2 FIFO Depth Optimization

Analysis showed that the four input FIFOs contributed significantly to the sequential logic and overall cell count.

To reduce the implementation size, the FIFO depth of all four input ports was reduced:

- Original FIFO depth: 4
- Optimized FIFO depth: 2

RTL integration verification was repeated after this modification and passed successfully.

The optimized TinyNoC core synthesis resulted in:

- Mapped standard cells: 769
- Synthesized core cell area: 13,669.047 µm²

This reduced the core implementation below the 1000-cell target.

### 4.3 Final Wrapper Synthesis

A tapeout wrapper was added around the TinyNoC core to provide a compact external interface compatible with the available I/O resources.

The final `tinynoc_wrapper` synthesis produced:

- Synthesized standard cells: 928
- Synthesized standard-cell area: 15,814.6506 µm²
- Sequential cells: 146

Therefore, the final synthesized wrapper remained below the project's 1000-standard-cell implementation target.

## 5. Static Timing Analysis and Physical Design

### 5.1 Preliminary Static Timing Analysis

Pre-layout static timing analysis was performed using OpenSTA 3.1.0 with the IHP SG13G2 typical timing library.

A preliminary clock period of 20 ns, corresponding to 50 MHz, was used for analysis.

The preliminary STA results were:

- Setup worst slack: +15.24 ns
- Hold worst slack: +0.26 ns
- Setup timing status: MET
- Hold timing status: MET

These values represent preliminary pre-layout timing analysis and should not be interpreted as the final maximum operating frequency of the design.

### 5.2 Physical Design Flow

The final TinyNoC wrapper was implemented using LibreLane with the IHP SG13G2 130 nm Open PDK.

The physical-design flow completed the following stages:

1. Logic synthesis
2. Floorplanning
3. Placement
4. Clock Tree Synthesis (CTS)
5. Global and detailed routing
6. Timing optimization
7. Antenna checking
8. Design Rule Checking (DRC)
9. Layout Versus Schematic (LVS)
10. GDSII generation

### 5.3 Final Physical Design Metrics

The completed physical implementation produced the following results:

| Metric | Final Result |
|---|---:|
| Synthesized standard cells | 928 |
| Synthesized cell area | 15,814.6506 µm² |
| Final die area | 48,198.1 µm² |
| Standard-cell utilization | 55.42% |
| Final routed wire length | 39,942 µm |
| Antenna violations | 0 |
| Magic DRC errors | 0 |
| KLayout DRC errors | 0 |
| LVS device differences | 0 |
| LVS net differences | 0 |
| LVS unmatched devices/nets/pins | 0 |
| Final GDSII | Generated successfully |

### 5.4 Post-Placement Cell Count

The physical-design flow inserted additional implementation cells for timing repair, hold fixing, clock distribution, and physical completion.

Therefore, the post-P&R standard-cell count is higher than the original synthesis count. Filler cells and implementation cells should not be interpreted as additional functional TinyNoC logic.

The verified synthesis count for the final functional `tinynoc_wrapper` is 928 standard cells.

### 5.5 Timing Constraint Note

During the LibreLane physical-design run, dedicated project-specific `PNR_SDC_FILE` and `SIGNOFF_SDC_FILE` constraints were not explicitly supplied, and the flow reported the use of generic fallback SDC constraints for some implementation/sign-off stages.

Therefore, although the physical-design flow completed without reported setup/hold WNS or TNS violations under those constraints, a final shuttle-specific SDC should be applied before claiming a tapeout-qualified maximum operating frequency.


## 6. Final GDSII Deliverables

The completed physical-design flow generated the final implementation files for `tinynoc_wrapper`.

Important deliverables include:

- `tinynoc_wrapper.gds` – Final GDSII layout
- `tinynoc_wrapper.def` – Final placed and routed DEF
- `tinynoc_wrapper.lef` – Final LEF abstraction
- `tinynoc_wrapper.pnl.v` – Post-layout netlist
- `tinynoc_wrapper.sdf` – Standard Delay Format timing data
- `tinynoc_wrapper.sdc` – Generated timing constraints
- `tinynoc_wrapper.spice` – SPICE/LVS netlist
- `tinynoc_wrapper.png` – Final rendered layout
- `metrics.csv` – Physical-design and sign-off metrics
- `synthesis_stat.rpt` – Final wrapper synthesis statistics

The key final deliverables are stored in:

`physical_design/final_results/`

## 7. Final Layout

The final routed layout was inspected using KLayout with the IHP SG13G2 layer definitions.

The layout contains the placed SG13G2 standard cells, clock distribution, signal routing, vias, and multiple metal routing layers.

A rendered view of the final layout is available at:

`physical_design/final_results/tinynoc_wrapper.png`

The actual GDSII layout is available at:

`physical_design/final_results/tinynoc_wrapper.gds`

## 8. Final Implementation Status

| Design Stage | Status |
|---|---|
| RTL Design | Completed |
| RTL Verification | Passed |
| QoS Contention Verification | Passed |
| Logic Synthesis | Completed |
| Area Optimization | Completed |
| Preliminary STA | Passed |
| Floorplanning | Completed |
| Placement | Completed |
| Clock Tree Synthesis | Completed |
| Routing | Completed |
| Antenna Check | Passed – 0 violations |
| DRC | Passed – 0 final violations |
| LVS | Passed – 0 differences |
| GDSII Generation | Completed |

## 9. Conclusion

TinyNoC was successfully designed, verified, synthesized, optimized, and physically implemented using the IHP SG13G2 130 nm Open PDK.

The final tapeout wrapper synthesized to 928 standard cells, remaining below the 1000-standard-cell implementation target. Reducing the input FIFO depth from four entries to two was an effective area optimization while preserving the verified routing and QoS functionality.

The complete physical-design flow successfully progressed through floorplanning, placement, clock tree synthesis, routing, physical verification, and GDSII generation. Final verification reported zero Magic DRC errors, zero KLayout DRC errors, zero LVS differences, and zero antenna violations.

Thus, the project demonstrates a complete open-source ASIC implementation flow for a compact four-port QoS-aware Network-on-Chip router from SystemVerilog RTL through final GDSII.

Further work should include applying the exact shuttle-specific top-level interface and timing constraints, followed by timing re-verification against the final submission requirements.


