module apb_ram(input PCLK,
               input PRESETn,
               input ram_sel,
               input write_en,
               input read_en,
               input [31:0] PADDR,
               input [31:0] PWDATA,
               output reg [31:0] ram_rdata);
  reg [31:0] mem [0:255];
  //Synchronous write
  always @ (posedge PCLK)
    begin
      if (PRESETn && ram_sel && write_en)
        begin
          mem[(PADDR - 32'h0000_0010) >> 2] <= PWDATA;
        end
    end
  
  //Combinational read
  always @ (*)
    begin
      ram_rdata = 32'h0000_0000;
      if (PRESETn && ram_sel && read_en)
        begin
          ram_rdata = mem[(PADDR - 32'h0000_0010) >> 2];
        end
    end
endmodule
  