# Computer-Aided Design (CAD) of Digital Systems 

This repository hosts a collection of advanced digital design projects implemented in Verilog, ranging from RTL modeling of cryptographic algorithms to automated logic synthesis and High-Level Synthesis (HLS).

**Authors:**
* **Sadra Madaeni**
* **Amir Hossein Alikhani**

---

## 📂  Project Descriptions

### 🔹 CA1: Hash Generator (RTL & LFSR Design)
**Objective:** Implementation of a 128-bit Hash Generator utilizing a 64-round compression function and a custom Pseudo-Random Number Generator (PRNG).

#### 🔧 Technical Details
The design features a decoupled **Datapath** and **Controller**. The core component is the PRNG which generates random indices for message word selection using a Linear Feedback Shift Register (LFSR) mechanism.

**Mathematical Model (PRNG Logic):**
The PRNG updates its state $x$ in every cycle based on the following feedback polynomial logic:
$$fb = x[5] \oplus x[3] \oplus x[1]$$
$$x_{next} = (x_{current} \ll 1) \lor fb$$
$$rnd\_index = ((x_{current} \ll 1) \lor x[4])[1:0]$$

**Key Features:**
* **Memory Interface:** Fetches constants (`K[i]`) from a ROM.
* **Compression Function:** Implements 64 rounds of logic operations (AND, OR, XOR, NOT) combined with dynamic bitwise rotations.

---

### 🔹 CA2: Bit-Serial Vector Accelerator (Stripes Architecture)
**Objective:** Design of a specialized **Processing Element (PE)** for calculating vector dot products using **Bit-Serial** arithmetic. This architecture trades latency for area, allowing for massive parallelism in neural network accelerators.

#### 🔧 Technical Details
Instead of using massive parallel multipliers, this design processes the input vector $A$ bit-by-bit (MSB to LSB) while keeping vector $B$ parallel.

**Mathematical Operation:**
The PE calculates the dot product $\vec{A} \cdot \vec{B}$:
$$Result = \sum_{i=0}^{N-1} (a_i \times b_i)$$

**Bit-Serial Logic (Shift-and-Add):**
For each cycle $j$ (processing bit $j$ of input $A$), the accumulator updates as follows:
$$Acc_{j} = (Acc_{j-1} \ll 1) + \sum_{i=0}^{N-1} (a_{i}[j] ? b_i : 0)$$
* If the current bit of $A$ is `1`, the corresponding element of $B$ is added.
* If the current bit of $A$ is `0`, only a shift operation occurs.
* **Optimization:** A tree-adder structure aggregates the partial sums from different vector elements.

---

### 🔹 CA3: Structural Manual Synthesis (Hand-Crafted Optimization)
**Objective:** A low-level structural implementation of an 8-bit Hash variant, strictly mapped to a specific Standard Cell Library (**Actel-like**).

#### 🔧 Technical Details
* **Constraints:** No behavioral operators (`+`, `-`, `*`) allowed. All logic is manually instantiated using `C1`, `C2` (Combinational) and `S1`, `S2` (Sequential) cells.
* **Algorithmic Modification:** The standard rotation was replaced by a "Split Multiplier" to reduce complexity:
    $$B_{new} = B_{old} + (F[7:4] \times F[3:0])$$
* **Optimization Strategy:**
    * **MUX Implementation:** Used **C1 cells (10 gates)** for Multiplexers instead of C2 (11 gates) to minimize area.
    * **Internal Muxing:** Utilized the internal select lines of **S2 cells** to merge the "Load/Hold" logic directly into the Flip-Flops, saving ~320 gates.

---

### 🔹 CA4: Automated Synthesis Flow (Yosys & Python)
**Objective:** Development of an automated "RTL-to-GDSII" style flow using **Yosys** and a custom **Technology Mapping** script.

#### 🔧 Mapping Logic (`lut2mapper.py`)
The flow converts generic synthesized logic into the target Actel library:

1.  **Synthesis:** Yosys converts Verilog to generic 2-input Look-Up Tables (LUT2).
2.  **Mapping Algorithm:** A Python script parses the LUTs and maps them to **C2 Cells** (Universal Logic Modules).
    * **Logic:** The 4 bits of the LUT's truth table are applied to the Data Inputs ($D_{00}, D_{01}, D_{10}, D_{11}$) of the C2 cell.
    * **Connections:** The LUT inputs ($I_0, I_1$) are connected to the Select lines ($S_0, S_1$) of the C2 cell.

**Comparison Results:**
| Metric | Manual Design (CA3) | Automated Synthesis (CA4) |
| :--- | :---: | :---: |
| **Gate Count** | **3,754** | **~6,387** |
| **Efficiency** | High (Architectural Awareness) | Lower (Generic Mapping) |

---

### 🔹 CA5: High-Level Synthesis (HLS) Generator
**Objective:** Generating synthesizable Verilog (Datapath + Controller) directly from mathematical expressions (e.g., `y = a*b + c`).

#### 🔧 Algorithms Implemented
1.  **Parser:** Converts the input expression into a **Data Flow Graph (DFG)**.
2.  **Scheduler:**
    * **ML-RC (Min-Latency, Resource-Constrained):** Optimizes execution time given a fixed number of ALUs/Multipliers.
    * **MR-LC (Min-Resource, Latency-Constrained):** Minimizes hardware cost given a maximum time budget.
3.  **Code Gen:** Automates the creation of the FSM state transitions based on the schedule step.

---

## 🚀 How to Run

### Simulation (Projects 1-3)
```bash
# Using ModelSim / Questasim
vlog *.v
vsim -voptargs=+acc work.tb_top
run -all
