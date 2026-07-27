
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
