RTL Modules

This directory contains the synthesizable Verilog HDL implementation of the AMBA APB Slave.



Modules:


• apb_slave_top.v – Top-level module integrating all submodules.

• apb_fsm.v – Implements the APB protocol state machine.

• apb_address_decoder.v – Decodes register and RAM addresses.

• register_bank.v – Implements memory-mapped control, status, data, and mask registers.

• apb_ram.v – 256 × 32-bit RAM module.

• apb_read_mux.v – Multiplexes read data from registers and RAM.
