module reg_file #(
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
    output logic [DATA_WIDTH-1:0]   read_data2
);
    logic [DATA_WIDTH-1:0] registers [NUM_REGISTERS-1:0];

    assign read_data1 <= (read_addr1 != '0) ? registers[read_addr1] : '0;
    assign read_data2 <= (read_addr2 != '0) ? registers[read_addr2] : '0;

    always_ff @(posedge clk) begin
        if (write_addr != '0 && write_en) begin
            registers[write_addr] <= write_data;
        end
    end
    
endmodule