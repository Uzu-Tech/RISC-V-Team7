/*
COURSEWORK OUTLINE - register file (implement/check in this file)

Purpose:
  Hold the CPU's 32 integer registers, each 32 bits wide.

Already present below:
  Two combinational read ports, one rising-edge write port, write enable,
  protection against writing x0, zero on reads of x0, and a0 = register x10.
  These are already the main register-file behaviours you need.

To work through:
  1. Keep the coursework configuration at 32 registers of 32 bits, selected
     with 5-bit register addresses.
  2. Confirm both source registers can be read independently in one cycle.
  3. Confirm writes occur only on the agreed edge with write enable asserted;
     disabled writes and attempted writes to x0 must have no effect.
  4. Keep x10 available through a0 for the supplied whole-CPU tests.
  5. Agree startup/reset behaviour with the team. Clearing every register is
     not an explicit brief requirement; do not assume unwritten registers
     contain useful values.

Integration boundary:
  This module stores the write_data it receives. Selecting an ALU result,
  load result, or jump return address belongs in top.sv/the writeback datapath.
  Agree same-cycle read/write timing with the pipeline owner when pipelining.

Check before integration:
  Read two different registers; write/read a nonzero register; disable a write;
  try writing x0; check a0 follows writes to x10.

This outline is comments only; existing implementation is retained below.
*/
module regfile #(
    parameter ADDRESS_WIDTH = 5,
    parameter DATA_WIDTH = 32,
    parameter NUM_REGISTERS = 1 << ADDRESS_WIDTH
) (
    input logic                     clk,

    input logic [ADDRESS_WIDTH-1:0] read_addr1,
    input logic [ADDRESS_WIDTH-1:0] read_addr2,
    input logic [ADDRESS_WIDTH-1:0] write_addr,

    input logic                     write_en,
    input logic [DATA_WIDTH-1:0]   write_data,

    output logic [DATA_WIDTH-1:0]   read_data1,
    output logic [DATA_WIDTH-1:0]   read_data2,
);
    logic [DATA_WIDTH-1:0] registers [NUM_REGISTERS-1:0];

    assign read_data1 = (read_addr1 != '0) ? registers[read_addr1] : '0;
    assign read_data2 = (read_addr2 != '0) ? registers[read_addr2] : '0;
    
    always_ff @(posedge clk) begin
        if (write_addr != '0 && write_en) begin
            registers[write_addr] <= write_data;
        end
    end
    
endmodule