# Day 11 — 4-Bit Up/Down Counter: Structural vs. RTL Implementations

![Verilog](https://img.shields.io/badge/HDL-Verilog-blue)
![Domain](https://img.shields.io/badge/Domain-Digital%20VLSI-orange) 
![Design](https://img.shields.io/badge/Design-4--bit%20Adder%2FSubtractor-green)
![Tool](https://img.shields.io/badge/Synthesis-Cadence%20Genus-red)

<p align="center">
  <b>Digital VLSI • Verilog HDL • RTL Design • Functional Verification • Cadence Genus • PPA Analysis</b>
</p>

<p align="center">
  <code>Specification → Architecture → RTL → Testbench → Simulation → Synthesis → Area → Power → Timing → PPA</code>
</p>

<p align="center">
  <b>Functional Simulation:</b> ALL DAY 11 TESTS PASSED &nbsp; | &nbsp;
  <b>Synthesis:</b> Reported &nbsp; | &nbsp;
  <b>Timing Check:</b> MET for the supplied path
</p>

---

## 1. Project Information

| Parameter | Details |
|---|---|
| **Project** | Day 11 — 4-Bit Up/Down Counter |
| **Domain** | Digital VLSI / RTL Design |
| **Design Type** | Sequential logic with combinational next-state logic |
| **HDL** | Verilog HDL |
| **Counter Width** | 4 bits |
| **Implementations** | Synchronous structural, synchronous RTL, asynchronous structural, asynchronous RTL |
| **Synthesis Tool** | Cadence Genus 21.14-s082_1 |
| **Simulation Tool** | Cadence NC-Sim (`ncsim`) |
| **Standard-Cell Library** | `tsmc18` |
| **Operating Condition** | `slow (balanced_tree)` |
| **Wireload Mode** | `enclosed` |
| **Top Module** | `up_down_counter_top` |
| **Power Unit** | W |
| **Analysis** | Functional simulation, hierarchy, cell area, power, setup timing |
| **Simulation Result** | All logged Day 11 tests passed; no verification errors reported |
| **Synthesis Report Date** | Oct 09, 2026 |
| **Project Status** | Functional simulation and synthesis-report analysis completed; physical-design sign-off not established |

---

## 2. Project Overview

This project implements and verifies a 4-bit up/down counter using four implementation variants:

1. Synchronous-reset structural implementation
2. Synchronous-reset RTL implementation
3. Asynchronous-reset structural implementation
4. Asynchronous-reset RTL implementation

The structural implementation is built from smaller logic blocks, including incrementer/decrementer logic, ripple-carry arithmetic stages, multiplexers, and registers. The RTL implementations describe the counter behavior at a higher level.

The project compares functional behavior across the four variants and examines the supplied Genus synthesis reports for the top-level design.

---

## 3. Objectives

1. Implement a 4-bit up/down counter.
2. Understand synchronous and asynchronous reset behavior.
3. Build and verify reusable combinational logic blocks.
4. Implement incrementer and decrementer datapaths.
5. Use a multiplexer to select the next counter value.
6. Verify structural and RTL implementations against each other.
7. Verify rollover and underflow behavior.
8. Run functional simulation using Cadence NC-Sim.
9. Synthesize the top-level design using Cadence Genus.
10. Read hierarchy, standard-cell area, power, and setup-timing reports.
11. Distinguish measured report values from engineering interpretation.
12. Identify what remains necessary for full timing and physical-design sign-off.

---

## 4. Functional Specification

A 4-bit unsigned counter represents values from `0000` through `1111`.

| Control / Event | Expected behavior |
|---|---|
| Reset asserted | Counter state is cleared to `0000` |
| Up-count enabled at a clock edge | Counter increments by one |
| Down-count selected at a clock edge | Counter decrements by one |
| Up-count from `1111` | Rolls over to `0000` |
| Down-count from `0000` | Underflows to `1111` |

The precise reset timing differs by implementation:

- **Synchronous reset:** the reset operation is applied at the active clock edge.
- **Asynchronous reset:** the reset operation can occur independently of the active clock edge.

The simulation log reports successful checks for both reset styles.

---

## 5. Counter Operation

### Count up

```text
0000 → 0001 → 0010 → 0011 → 0100 → ...
```

### Count down

```text
0000 → 1111 → 1110 → 1101 → 1100 → ...
```

### Rollover and underflow

```text
UP ROLLOVER:  1111 → 0000
DOWN UNDERFLOW: 0000 → 1111
```

These transitions were explicitly checked in the supplied simulation output.

---

## 6. Architecture Overview

The structural next-state path shown by the Genus hierarchy contains the following main blocks:

```text
                   +----------------------+
                   |  up_down_next_state  |
                   +----------------------+
                     |        |        |
                     |        |        |
              +------+   +----+----+   +------+
              |          |         |          |
        +-----------+ +-----------+  +-------------+
        | Increment | | Decrement |  |  2:1 MUXes  |
        +-----------+ +-----------+  +-------------+
              |          |                 |
              +----------+-----------------+
                                |
                         +--------------+
                         |  4-bit REG   |
                         +--------------+
                                |
                                Q
```

**Architecture evidence:** this diagram summarizes the structural modules visible in the hierarchy report. It is not a gate-level schematic or a claim about every optimized post-synthesis connection.

---

## 7. Four Implementation Variants

| Instance | Module | Implementation |
|---|---|---|
| `U1` | `up_down_counter_sync_structural` | Structural logic with synchronous-reset register |
| `U2` | `up_down_counter_sync_rtl` | RTL implementation with synchronous reset |
| `U3` | `up_down_counter_async_structural` | Structural logic with asynchronous-reset register |
| `U4` | `up_down_counter_async_rtl` | RTL implementation with asynchronous reset |

The supplied top-level synthesis reports aggregate results for `up_down_counter_top`. They do not provide separate area, power, or timing results for each of the four variants.

---

## 8. Structural Hierarchy

The supplied Genus hierarchy report expands the structural implementations as follows:

```text
up_down_counter_top
├── U1: up_down_counter_sync_structural
│   ├── NEXT: up_down_next_state
│   │   ├── DEC: decrementer_4bit
│   │   │   └── RCA: ripple_carry_adder_4bit_3_175
│   │   │       └── full-adder / half-adder / gate instances
│   │   ├── INC: incrementer_4bit
│   │   │   └── RCA: ripple_carry_adder_4bit
│   │   │       └── full-adder / half-adder / gate instances
│   │   └── MUX0, MUX1, MUX2, MUX3
│   └── REG: register_4bit_sync
│       └── FF0, FF1, FF2, FF3
├── U2: up_down_counter_sync_rtl
├── U3: up_down_counter_async_structural
│   ├── NEXT: up_down_next_state
│   │   ├── DEC: decrementer_4bit
│   │   ├── INC: incrementer_4bit
│   │   └── MUX0, MUX1, MUX2, MUX3
│   └── REG: register_4bit_async
│       └── FF0, FF1, FF2, FF3
└── U4: up_down_counter_async_rtl
```

The RTL variants are present in the report but their internal hierarchy is not expanded there.

---

## 9. Combinational Building Blocks

The simulation log includes checks for these reusable blocks:

| Block | Verification evidence |
|---|---|
| NOT, AND, OR, XOR gates | Passed listed input combinations |
| 2:1 multiplexer | Passed select checks for `S=0` and `S=1` |
| Half adder | Passed SUM and CARRY checks for all four input combinations |
| Full adder | Passed the listed SUM/COUT vectors |
| 4-bit ripple-carry adder | Passed `3 + 2` and `15 + 1` tests |
| Incrementer | Passed inputs `0`, `5`, and `15`, including overflow |
| Decrementer | Passed inputs `5`, `1`, and `0` |
| Up/down next-state logic | Passed up, down, rollover, and underflow checks |

The table summarizes the test cases visible in the supplied NC-Sim log; it does not imply exhaustive formal verification.

---

## 10. Verification Strategy

The testbench checks the design from individual logic blocks through the top-level counter:

```text
Basic Gates
    ↓
MUX
    ↓
Half Adder / Full Adder
    ↓
4-bit Ripple-Carry Adder
    ↓
Incrementer / Decrementer
    ↓
Next-State Logic
    ↓
DFF / Register
    ↓
Synchronous and Asynchronous Counters
    ↓
Count-Up / Count-Down
    ↓
Rollover / Underflow
    ↓
Structural vs. RTL Comparison
```

---

## 11. Functional Verification Results

<table>
  <tr>
    <td><b>Simulation status</b></td>
    <td><b>ALL DAY 11 TESTS PASSED</b></td>
  </tr>
  <tr>
    <td><b>Verification errors</b></td>
    <td>NO VERIFICATION ERRORS</td>
  </tr>
  <tr>
    <td><b>Simulator</b></td>
    <td>Cadence NC-Sim (`ncsim`)</td>
  </tr>
  <tr>
    <td><b>Completion time</b></td>
    <td>416 ns</td>
  </tr>
  <tr>
    <td><b>Structural vs. RTL</b></td>
    <td>Both synchronous and asynchronous comparisons passed</td>
  </tr>
</table>

### Verification categories

| Verification category | Result |
|---|---|
| Basic gates | PASS |
| Multiplexer | PASS |
| Half adder | PASS |
| Full adder | PASS |
| 4-bit RCA | PASS |
| Incrementer / overflow | PASS |
| Decrementer / underflow | PASS |
| Next-state logic | PASS |
| DFF and register tests | PASS |
| Synchronous / asynchronous reset | PASS |
| Count-up sequences | PASS |
| Count-down sequences | PASS |
| Up rollover | PASS |
| Down underflow | PASS |
| Structural vs. RTL equivalence checks | PASS |

**Evidence scope:** these results reflect the directed checks shown in the supplied testbench log. They do not establish formal equivalence or exhaustive coverage of every possible input sequence.

---

## 12. Counter Reset Verification

The simulation log reports the following reset checks as passing:

- Counter asynchronous structural reset → `0000`
- Counter asynchronous RTL reset → `0000`
- Counter synchronous structural reset → `0000`
- Counter synchronous RTL reset → `0000`

The testbench also reports asynchronous DFF/register reset checks and synchronous DFF/register load checks as passing.

---

## 13. Count-Up Verification

The four counter variants are shown counting through the same tested sequence:

```text
0000 → 0001 → 0010 → 0011 → 0100 → 0101 → 0110 → 0111 → 1000
```

The supplied log reports PASS for each listed count-up state across the synchronous structural, synchronous RTL, asynchronous structural, and asynchronous RTL implementations.

---

## 14. Count-Down Verification

The four counter variants are shown counting down from zero using 4-bit wraparound:

```text
0000 → 1111 → 1110 → 1101 → 1100 → 1011 → 1010 → 1001 → 1000
```

The supplied log reports PASS for each listed count-down state across all four implementations.

---

## 15. Rollover and Underflow Verification

| Condition | Expected transition | Simulation result |
|---|---|---|
| Up-counter rollover | `1111 → 0000` | PASS |
| Down-counter underflow | `0000 → 1111` | PASS |

The log checks these conditions for the structural and RTL variants with both reset styles.

---

## 16. Synthesis Flow

The reported synthesis flow uses Cadence Genus and the `tsmc18` library.

```text
                 Verilog RTL
                      │
                      ▼
                Genus Elaboration
                      │
                      ▼
                 Logic Synthesis
                      │
                      ▼
              Technology Mapping
                      │
                      ▼
               TSMC18 Cell Mapping
                      │
             ┌────────┼────────┐
             ▼        ▼        ▼
           Area     Power    Timing
```

This README records the supplied synthesis reports. It does not claim that placement, clock-tree synthesis, routing, extraction, or sign-off analysis has been completed.

---

## 17. Synthesis Summary — Report Box

<table>
  <tr><td colspan="2"><b>GENUS SYNTHESIS REPORT — up_down_counter_top</b></td></tr>
  <tr><td>Tool</td><td>Cadence Genus 21.14-s082_1</td></tr>
  <tr><td>Report date</td><td>Oct 09, 2026 — 02:47:15 pm</td></tr>
  <tr><td>Operating condition</td><td><code>slow (balanced_tree)</code></td></tr>
  <tr><td>Wireload mode</td><td><code>enclosed</code></td></tr>
  <tr><td>Total instances</td><td><b>113</b></td></tr>
  <tr><td>Total cell area</td><td><b>2,361.744 library area units</b></td></tr>
</table>

> **Area-unit note:** the supplied report gives the area value as `2361.744` but does not explicitly state a physical unit in the pasted report. It is therefore recorded as library area units, not asserted as µm².

---

## 18. Standard-Cell Mapping

The top-level synthesis report lists 113 instances:

| Standard cell | Instances | Area |
|---|---:|---:|
| `AND2X2` | 24 | 319.334 |
| `AOI2BB2X1` | 1 | 23.285 |
| `DFFHQX1` | 2 | 106.445 |
| `DFFRHQX1` | 6 | 419.126 |
| `DFFTRX1` | 4 | 226.195 |
| `DFFX1` | 1 | 56.549 |
| `INVX1` | 18 | 119.750 |
| `INVXL` | 9 | 59.875 |
| `JKFFRXL` | 2 | 172.973 |
| `MXI2X1` | 2 | 46.570 |
| `NAND2BX1` | 4 | 53.222 |
| `NAND2X1` | 4 | 39.917 |
| `NAND3BX1` | 1 | 16.632 |
| `NOR2BXL` | 1 | 13.306 |
| `NOR2X1` | 4 | 39.917 |
| `OAI211X1` | 1 | 19.958 |
| `OAI21XL` | 1 | 13.306 |
| `OAI2BB2XL` | 3 | 69.854 |
| `OR2X2` | 12 | 159.667 |
| `SDFFHQX1` | 1 | 66.528 |
| `XOR2X1` | 12 | 319.334 |
| **Total** | **113** | **2,361.744** |

---

## 19. Area Distribution — Report Box

<table>
  <tr><td colspan="4"><b>GENUS CELL-AREA SUMMARY</b></td></tr>
  <tr><th>Category</th><th>Instances</th><th>Area</th><th>Area %</th></tr>
  <tr><td>Sequential</td><td>16</td><td>1,047.816</td><td>44.4%</td></tr>
  <tr><td>Inverter</td><td>27</td><td>179.626</td><td>7.6%</td></tr>
  <tr><td>Logic</td><td>70</td><td>1,134.302</td><td>48.0%</td></tr>
  <tr><td>Physical cells</td><td>0</td><td>0.000</td><td>0.0%</td></tr>
  <tr><td><b>Total</b></td><td><b>113</b></td><td><b>2,361.744</b></td><td><b>100.0%</b></td></tr>
</table>

### Area interpretation

- Combinational logic is the largest reported category at 48.0%.
- Sequential cells account for 44.4% of the reported area.
- Inverters account for 7.6%.
- These are top-level aggregate figures across the synthesized `up_down_counter_top` hierarchy. They are not separate PPA measurements for each implementation variant.

---

## 20. Power Analysis — Report Box

<table>
  <tr><td colspan="2"><b>GENUS POWER REPORT — up_down_counter_top</b></td></tr>
  <tr><td>Power unit</td><td>W</td></tr>
  <tr><td>Power-analysis frame</td><td><code>/stim#0/frame#0</code></td></tr>
  <tr><td>Leakage power</td><td>9.10858 × 10⁻⁸ W ≈ 0.0911 µW</td></tr>
  <tr><td>Internal power</td><td>1.67485 × 10⁻⁴ W = 167.485 µW</td></tr>
  <tr><td>Switching power</td><td>3.74574 × 10⁻⁵ W = 37.4574 µW</td></tr>
  <tr><td><b>Total reported power</b></td><td><b>2.05033 × 10⁻⁴ W = 205.033 µW</b></td></tr>
</table>

### Power breakdown by category

| Category | Leakage (µW) | Internal (µW) | Switching (µW) | Total (µW) | Share |
|---|---:|---:|---:|---:|---:|
| Register | 0.0309 | 117.171 | 7.891 | 125.093 | 61.01% |
| Logic | 0.0602 | 50.314 | 17.704 | 68.078 | 33.20% |
| Clock | 0.0000 | 0.000 | 11.862 | 11.862 | 5.79% |
| **Subtotal** | **0.0911** | **167.485** | **37.457** | **205.033** | **100.00%** |

Values are converted from the supplied watts report to microwatts and rounded for display.

### Power component percentages

| Component | Reported percentage |
|---|---:|
| Leakage | 0.04% |
| Internal | 81.69% |
| Switching | 18.27% |
| **Total** | **100.00%** |

### Power interpretation

- The register category is the largest contributor at 61.01%.
- Internal power accounts for 81.69% of the reported total.
- The clock category contributes 5.79%, shown as switching power in the supplied report.
- The value applies to the stated power-analysis frame and its activity/model assumptions; it should not be treated as universal power for every frequency or workload.

---

## 21. Setup Timing Analysis — Report Box

<table>
  <tr><td colspan="2"><b>GENUS SETUP TIMING REPORT — PATH 1</b></td></tr>
  <tr><td>Timing check</td><td><b>MET</b></td></tr>
  <tr><td>Startpoint</td><td><code>U3/REG/FF1/Q_reg/CK</code> (launch register path)</td></tr>
  <tr><td>Endpoint</td><td><code>U3/REG/FF3/Q_reg/D</code></td></tr>
  <tr><td>Implementation</td><td><code>up_down_counter_async_structural</code> (U3)</td></tr>
  <tr><td>Clock period</td><td>10,000 ps = 10 ns</td></tr>
  <tr><td>Data path delay</td><td><b>1,871 ps = 1.871 ns</b></td></tr>
  <tr><td>Setup time</td><td>349 ps</td></tr>
  <tr><td>Clock uncertainty</td><td>1,000 ps = 1.000 ns</td></tr>
  <tr><td>Required time</td><td>8,651 ps</td></tr>
  <tr><td><b>Setup slack</b></td><td><b>+6,780 ps = +6.780 ns</b></td></tr>
</table>

### Timing calculation

```text
Required time = Capture edge − Setup time − Clock uncertainty
              = 10,000 − 349 − 1,000
              = 8,651 ps

Slack         = Required time − Data path delay
              = 8,651 − 1,871
              = 6,780 ps
              = +6.780 ns
```

### Reported path sequence

```text
Launch register (FF1)
   ↓
INVX1
   ↓
AND2X2
   ↓
OR2X2
   ↓
AND2X2
   ↓
OR2X2
   ↓
XOR2X1
   ↓
AND2X2
   ↓
OR2X2
   ↓
Capture register (FF3 D)
```

The reported data path passes through decrementer ripple-carry logic and the next-state mux before reaching the destination register.

### Timing interpretation and limitations

- The supplied setup path is reported as **MET**, with +6.780 ns slack.
- This is one reported setup path, not proof that every path meets timing.
- The report uses the stated 10 ns clock period and includes 349 ps setup time and 1 ns uncertainty.
- The 1.871 ns data-path delay is the reported path delay; it is not a universal maximum-delay number for every design path.
- The report alone does not establish final post-route timing, hold closure, or sign-off.
- Do not derive a verified maximum functional clock frequency from this single path alone.

---

## 22. Combined PPA Summary — Report Box

<table>
  <tr><td colspan="2"><b>DAY 11 — REPORTED SYNTHESIS AND TIMING METRICS</b></td></tr>
  <tr><td>Top module</td><td><code>up_down_counter_top</code></td></tr>
  <tr><td>Standard-cell instances</td><td><b>113</b></td></tr>
  <tr><td>Reported cell area</td><td><b>2,361.744 library area units</b></td></tr>
  <tr><td>Reported power</td><td><b>205.033 µW</b></td></tr>
  <tr><td>Supplied setup path delay</td><td><b>1.871 ns</b></td></tr>
  <tr><td>Supplied setup slack</td><td><b>+6.780 ns</b></td></tr>
  <tr><td>Setup status for supplied path</td><td><b>MET</b></td></tr>
  <tr><td>Functional simulation</td><td><b>ALL DAY 11 TESTS PASSED</b></td></tr>
</table>

**Interpretation boundary:** area and power are the supplied top-level synthesis estimates; timing is for the specific path reported. These results are not post-route sign-off metrics.

---

## 23. Synthesis Hierarchy vs. PPA Scope

The hierarchy report identifies four variants, but the supplied area and power reports are for the aggregate top module `up_down_counter_top`.

Therefore:

- The reported 113 cells and area of 2,361.744 must not be assigned to one counter variant alone.
- The reported 205.033 µW is not a separate power result for each implementation.
- The supplied timing path belongs to `U3`, the asynchronous structural implementation.
- A fair four-way PPA comparison requires separate synthesis runs or implementation-specific reports using identical constraints, library, operating conditions, and activity assumptions.

---

## 24. Design Observations

1. **Functional consistency:** all four variants passed the directed counter tests included in the log.
2. **Rollover behavior:** up-count from `1111` returns to `0000`.
3. **Underflow behavior:** down-count from `0000` returns to `1111`.
4. **Structural datapath:** the hierarchy explicitly contains incrementer/decrementer logic and muxes.
5. **Area distribution:** combinational logic is 48.0% and sequential cells are 44.4% of the reported total area.
6. **Power distribution:** registers contribute 61.01% of reported power; internal power contributes 81.69%.
7. **Timing:** the supplied setup path passes with +6.780 ns slack.
8. **Scope limitation:** no separate PPA comparison across U1–U4 or post-route sign-off evidence is included in the supplied reports.

---

## 25. Possible Next Improvements

These are future analysis tasks, not claims that optimization has already been performed:

- Generate implementation-specific area, power, and timing reports for U1, U2, U3, and U4.
- Compare structural and RTL implementations under the same constraints.
- Review the worst setup and hold paths, not only the supplied setup path.
- Confirm clock definitions, input/output delays, uncertainty, and activity assumptions.
- Run post-placement/post-route analysis if physical-design results are required.
- Add randomized test sequences and functional coverage metrics.
- Consider assertions or a reference-model scoreboard for broader verification.

---

## 26. Repository Structure

The following is a suggested documentation layout. Keep actual filenames aligned with the files in the repository.

```text
day11-up-down-counter/
├── README.md
├── rtl/
│   ├── day11_counter_top.v
│   ├── up_down_counter_sync_structural.v
│   ├── up_down_counter_sync_rtl.v
│   ├── up_down_counter_async_structural.v
│   └── up_down_counter_async_rtl.v
├── tb/
│   └── day11_tb.v
├── reports/
│   ├── genus/
│   │   ├── hierarchy_report.txt
│   │   ├── cell_area_report.txt
│   │   ├── power_report.txt
│   │   └── timing_report.txt
│   └── simulation/
│       └── ncsim_day11.log
├── images/
│   └── waveforms/
└── docs/
    └── design_notes.md
```

**Note:** this is a suggested organization, not a verified listing of the current repository files.

---

## 27. Learning Outcomes

This project demonstrates practice with:

- Combinational and sequential Verilog design
- Hierarchical structural modeling
- RTL-based counter design
- Synchronous versus asynchronous reset
- Incrementer and decrementer datapaths
- Ripple-carry arithmetic
- Multiplexer-based next-state selection
- Directed self-checking simulation
- Structural-versus-RTL behavioral comparison
- Genus synthesis hierarchy interpretation
- Standard-cell area reporting
- Internal, switching, and leakage power interpretation
- Setup timing, required time, and slack calculation
- Evidence-based PPA reporting

---

## 28. Industry Relevance

The design and reporting workflow is relevant to entry-level digital design and ASIC development because it connects:

```text
Specification
   ↓
RTL / Structural Modeling
   ↓
Functional Verification
   ↓
Synthesis
   ↓
Technology Mapping
   ↓
Area / Power / Timing Analysis
```

The project is a learning exercise. The available reports demonstrate synthesis analysis and functional simulation, but do not establish tape-out readiness or physical-design sign-off.

---

## 29. Interview Questions

1. What is the difference between synchronous and asynchronous reset?
2. What is the difference between structural RTL and behavioral/RTL modeling?
3. How does a 4-bit counter roll over from 15 to 0?
4. Why does a 4-bit down-counter underflow from 0 to 15?
5. What is the purpose of a next-state multiplexer?
6. What is a ripple-carry adder, and how does carry propagation affect delay?
7. What is the difference between internal power and switching power?
8. What does a positive setup slack indicate?
9. Why is one passing timing path insufficient to claim timing closure?
10. Why must PPA comparisons use consistent constraints and operating conditions?

---

## 30. Final Result — Summary Box

<table>
  <tr><td colspan="2"><b>DAY 11 PROJECT STATUS</b></td></tr>
  <tr><td>Functional simulation</td><td>PASS — all logged tests passed</td></tr>
  <tr><td>Verification errors</td><td>None reported in the supplied log</td></tr>
  <tr><td>Genus top-level instances</td><td>113</td></tr>
  <tr><td>Reported cell area</td><td>2,361.744 library area units</td></tr>
  <tr><td>Reported power</td><td>205.033 µW</td></tr>
  <tr><td>Reported setup path delay</td><td>1.871 ns</td></tr>
  <tr><td>Reported setup slack</td><td>+6.780 ns — MET</td></tr>
  <tr><td>Post-route/sign-off status</td><td>Not established by the supplied reports</td></tr>
</table>

---

## 31. Evidence Rule

All numeric results in this README are based on the supplied NC-Sim and Genus reports. Values are converted to convenient units where indicated. Interpretations are separated from measured report fields.

- No per-variant PPA values are inferred from the aggregate top-level report.
- No post-route timing or power values are claimed.
- The supplied setup slack applies to the specific reported path and constraints.
- Simulation PASS results apply to the directed tests shown in the log; formal equivalence and exhaustive coverage are not claimed.
- The hierarchy/area report does not explicitly specify a physical area unit, so the area is reported as library area units.

---

## 32. Author

**Omkar Kalmesh Hadapad**  
Electronics and Communication Engineering  
Digital VLSI • Verilog HDL • RTL Design • Functional Verification • Synthesis and PPA Analysis

## 26. Next Project --- Day 11

### day12---4bit-up-down-counter

The next project extends counter design by adding a direction control.

``` text
Direction control
       ↓
Up-count / Down-count next-state logic
       ↓
4-bit register
       ↓
Reset behavior
       ↓
Verification of rollover and underflow
       ↓
Synthesis and PPA analysis
```

The Day-12 focus is to understand up-counting, down-counting, rollover,
underflow, reset behavior, and verification of both operating
directions.
