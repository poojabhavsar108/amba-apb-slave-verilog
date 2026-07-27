
# AMBA APB Slave Design and Verification using Verilog HDL

A complete implementation of an **AMBA APB (Advanced Peripheral Bus) Slave** designed from scratch in **Verilog HDL** as part of my **VLSI Frontend Digital Design Internship**.

The objective of this project is to understand the AMBA APB protocol, RTL design, finite state machines (FSM), register bank implementation, address decoding, and functional verification by designing and verifying an APB Slave from scratch.

---

# 📖 Project Overview

The AMBA APB Slave is a low-power peripheral interface used in the AMBA bus architecture for communication between an APB Master and peripheral devices.

This project implements a complete APB Slave supporting read and write operations through a register bank and RAM, while following the APB transaction protocol.

Each RTL module was designed, verified independently using self-checking testbenches, and finally integrated into a complete APB Slave.

---

# 🎯 Project Objectives

- Understand the AMBA APB Protocol
- Design synthesizable RTL using Verilog HDL
- Implement a modular APB Slave architecture
- Learn FSM-based protocol implementation
- Design an address decoder and register bank
- Perform functional verification using self-checking testbenches
- Integrate multiple RTL modules into a complete design
- Strengthen RTL Design and Digital Design fundamentals

---

# 🏗️ APB Slave Architecture

The APB Slave consists of the following RTL modules:

- APB Slave Top Module
- APB FSM Controller
- Address Decoder
- Register Bank
- Read Multiplexer
- RAM

---

# 🔄 AMBA APB Protocol Overview

The Advanced Peripheral Bus (APB) is part of the ARM AMBA (Advanced Microcontroller Bus Architecture) family. It is designed for low-bandwidth, low-power peripherals such as GPIO, UART, Timers, SPI, and I²C controllers.

The APB protocol provides a simple and efficient communication interface between an APB Master and an APB Slave using dedicated address, data, and control signals.

The APB Slave operates using a three-state finite state machine (FSM):

- **IDLE**
- **SETUP**
- **ACCESS**

Every data transfer follows the sequence:

```
IDLE
  ↓
SETUP
  ↓
ACCESS
```

After completing a transfer, the slave either returns to the **IDLE** state or proceeds to another **SETUP** state if a new transfer begins immediately.

---

# ⚙️ APB Interface Signals

| Signal | Direction | Description |
|---------|-----------|-------------|
| PCLK | Input | APB Clock |
| PRESETn | Input | Active-Low Reset |
| PSEL | Input | Selects the APB Slave |
| PENABLE | Input | Indicates the Access State |
| PWRITE | Input | High for Write, Low for Read |
| PADDR | Input | Address Bus |
| PWDATA | Input | Write Data Bus |
| PRDATA | Output | Read Data Bus |
| PREADY | Output | Indicates the Slave is Ready |
| PSLVERR | Output | Indicates an Invalid Transfer or Error |

---

# 🔄 APB State Description

### 💤 IDLE State

- Default state after reset
- Waits for the master to initiate a transfer
- `PSEL = 0`
- No data transfer occurs

---

### ⚙️ SETUP State

- The master selects the slave by asserting `PSEL`
- Address and control signals become valid
- `PENABLE` remains LOW
- The slave prepares for the transaction

---

### 📤 ACCESS State

- `PENABLE` is asserted HIGH
- Read or Write operation is performed
- `PREADY` indicates successful completion
- `PRDATA` is driven during read operations
- `PSLVERR` is asserted for invalid accesses

---

# 🗺️ Register Map

The APB Slave implements four 32-bit registers, each mapped to a unique address.

| Address | Register | Reset Value | Description |
|---------|----------|-------------|-------------|
| 0x00 | Control Register | 0x00000000 | Stores control information |
| 0x04 | Status Register | 0x00000001 | Stores peripheral status |
| 0x08 | Data Register | 0x00000000 | Stores data for read/write operations |
| 0x0C | Mask Register | 0x00000000 | Stores mask values for configurable operations |

---
