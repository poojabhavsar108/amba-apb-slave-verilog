module register_bank(input PCLK, 
                     input PRESETn, 
                     input write_en, 
                     input ctrl_sel, 
                     input status_sel, 
                     input data_sel, 
                     input mask_sel,
                     input read_en,
                     input ram_sel,
                     input PSLVERR,
                     input valid_address,
                     input [31:0] PWDATA,
                     output reg [31:0] ctrl_reg, 
                     output reg [31:0] status_reg, 
                     output reg [31:0] data_reg, 
                     output reg [31:0] mask_reg);
  
  always @ (posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
      begin
        ctrl_reg <= 32'h00000000;
        status_reg <= 32'h00000000;
        data_reg <= 32'h00000000;
        mask_reg <= 32'h00000000;
      end
  else
    begin
      if (write_en && ctrl_sel)
        ctrl_reg <= PWDATA;
      if (write_en && data_sel)
        data_reg <= PWDATA;
      if (write_en && mask_sel)
        mask_reg <= {16'h0000, PWDATA[15:0]};
      if (write_en && valid_address)
        status_reg[0] <= 1'b1; //Write completed
      if (read_en && valid_address)
        status_reg[1] <= 1'b1; //Read completed
      if (PSLVERR)
        status_reg[2] <= 1'b1; //Error occurred
      if ((write_en || read_en) && ram_sel)
        status_reg[3] <= 1'b1; //RAM accessed
      
    end
  end
endmodule
