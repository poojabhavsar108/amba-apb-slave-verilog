# 🚀 AMBA APB Slave Design and Verification using Verilog HDL

A complete implementation of an **AMBA APB (Advanced Peripheral Bus) Slave** designed from scratch in **Verilog HDL** as part of my **VLSI Frontend Digital Design Internship**.

This project focuses on designing a synthesizable APB Slave using a modular RTL architecture and verifying its functionality through a self-checking testbench with a behavioral reference (Golden) model. The design implements APB-compliant read and write transactions, memory-mapped registers, RAM access, address decoding, and protocol control using a finite state machine (FSM).

---

# 📖 Project Overview

The Advanced Peripheral Bus (APB) is part of the ARM Advanced Microcontroller Bus Architecture (AMBA) and is widely used for connecting low-bandwidth peripherals such as GPIO, UART, Timers, SPI, and I²C controllers.

In this project, a complete APB Slave has been developed using Verilog HDL. The design consists of separate RTL modules for protocol control, address decoding, register management, memory access, and data selection, which are integrated into a top-level APB Slave.

To ensure functional correctness, the design is verified using a structured self-checking testbench that employs reusable tasks, a behavioral reference model, automatic output comparison, and comprehensive test scenarios covering both valid and invalid APB transactions.

---

# 🎯 Project Objectives

- Understand the AMBA APB protocol and transaction flow.
- Design a modular and synthesizable APB Slave using Verilog HDL.
- Implement an FSM-based APB controller.
- Develop memory-mapped registers and RAM access.
- Perform address decoding for register and memory selection.
- Verify the design using a self-checking testbench with a behavioral reference model.
- Gain practical experience in RTL Design and Functional Verification.

  ---

# ⚙️ APB Slave Specifications

| Feature | Specification |
|---------|---------------|
| Bus Protocol | AMBA APB |
| Data Width | 32-bit |
| Address Width | 32-bit |
| Control FSM | 3-State (IDLE, SETUP, ACCESS) |
| Register Bank | 4 × 32-bit Registers |
| RAM | 256 × 32-bit |
| Register Addresses | 0x00, 0x04, 0x08, 0x0C |
| RAM Address Range | 0x10 – 0x40C (Word Aligned) |
| Read Operation | Supported |
| Write Operation | Supported |
| Address Decoder | Memory-Mapped |
| PREADY Generation | During ACCESS State |
| PSLVERR Generation | Invalid Address Access |
| Reset Type | Active-Low Asynchronous Reset (PRESETn) |
| RTL Style | Modular Design |

---

# 🏗️ AMBA APB Protocol Overview

The Advanced Peripheral Bus (APB) is part of the ARM Advanced Microcontroller Bus Architecture (AMBA) and is specifically designed for communication with low-bandwidth, low-power peripherals. It provides a simple and efficient interface between an APB Master and APB Slave using dedicated address, data, and control signals.

The APB protocol follows a three-state finite state machine (FSM):

```text
        IDLE
          │
          ▼
       SETUP
          │
          ▼
       ACCESS
          │
          ├────────► IDLE
          │
          └────────► SETUP
```

### 💤 IDLE State
- Default state after reset.
- Waits for the master to initiate a transfer.
- No read or write operation is performed.

### ⚙️ SETUP State
- The APB Master selects the slave by asserting **PSEL**.
- Address (`PADDR`), write data (`PWDATA`), and control signals become valid.
- **PENABLE** remains LOW during this state.

### 📤 ACCESS State
- **PENABLE** is asserted HIGH.
- Read or write operation is executed.
- The slave asserts **PREADY** to indicate completion.
- **PRDATA** is driven during read transactions.
- **PSLVERR** is asserted for invalid address accesses.

---

# ⚡ APB Interface Signals

| Signal | Direction | Description |
|---------|-----------|-------------|
| PCLK | Input | APB Clock |
| PRESETn | Input | Active-Low Reset |
| PSEL | Input | Slave Select |
| PENABLE | Input | Access Phase Indicator |
| PWRITE | Input | Write Control Signal |
| PADDR | Input | Address Bus |
| PWDATA | Input | Write Data Bus |
| PRDATA | Output | Read Data Bus |
| PREADY | Output | Transfer Completion Signal |
| PSLVERR | Output | Error Response Signal |

---

# 🏛️ RTL Architecture

The APB Slave is designed using a modular RTL architecture, where each module performs a dedicated function. This modular approach improves readability, simplifies verification, and allows individual modules to be developed and tested independently before system-level integration.

The top-level module (`apb_slave_top.v`) connects all internal modules and manages the communication between the APB interface and the internal register bank and RAM.

The architecture consists of the following RTL modules:

---

## 📌 APB Slave Top (`apb_slave_top.v`)

The top-level module integrates all APB Slave components and provides the interface between the APB Master and the internal hardware modules.

### Responsibilities

- Connects all RTL modules
- Interfaces with APB signals
- Generates valid address detection
- Generates the PSLVERR signal for invalid accesses
- Controls overall data flow between modules

---

## 📌 APB FSM (`apb_fsm.v`)

The APB Finite State Machine controls the protocol operation using three states:

- IDLE
- SETUP
- ACCESS

### Responsibilities

- Controls APB transaction flow
- Generates `write_en` signal for write transactions
- Generates `read_en` signal for read transactions
- Generates the `PREADY` signal during the ACCESS state

---

## 📌 Address Decoder (`apb_address_decoder.v`)

The address decoder monitors the incoming APB address and selects the corresponding register or RAM location.

### Responsibilities

- Decodes memory-mapped addresses
- Selects Control Register
- Selects Status Register
- Selects Data Register
- Selects Mask Register
- Selects RAM for valid memory addresses
- Supports only word-aligned RAM accesses

---

## 📌 Register Bank (`register_bank.v`)

The register bank stores configuration, status, and user data required by the APB Slave.

### Implemented Registers

- Control Register
- Status Register
- Data Register
- Mask Register

The Status Register automatically updates to indicate:

- Successful write operation
- Successful read operation
- Invalid address error
- RAM access

---

## 📌 APB RAM (`apb_ram.v`)

A 256 × 32-bit memory is implemented to support APB memory transactions.

### Features

- Synchronous write operation
- Combinational read operation
- Word-aligned addressing
- Memory-mapped interface

---

## 📌 Read Multiplexer (`apb_read_mux.v`)

The Read Multiplexer selects the appropriate data source during APB read transactions.

Depending on the decoded address, it forwards one of the following to the APB Master:

- Control Register
- Status Register
- Data Register
- Mask Register
- RAM Data

---

## 🔄 Overall Data Flow

During an APB transaction:

1. The APB FSM controls the protocol sequence.
2. The Address Decoder identifies the target register or RAM location.
3. Write operations update the selected register or RAM.
4. Read operations retrieve data through the Read Multiplexer.
5. Invalid addresses generate the `PSLVERR` signal.
6. `PREADY` indicates successful completion of the transaction.

---

APB MASTER
                     │
                     ▼
             +----------------+
             |  APB Slave Top |
             +----------------+
                     │
     ┌───────────────┼───────────────┐
     ▼               ▼               ▼
+---------+    +-----------+   +-----------+
|  FSM    |    | Address   |   | Read MUX  |
|         |    | Decoder   |   |           |
+---------+    +-----------+   +-----------+
                     │
          ┌──────────┴──────────┐
          ▼                     ▼
+----------------+      +----------------+
| Register Bank  |      |   256×32 RAM   |
+----------------+      +----------------+

