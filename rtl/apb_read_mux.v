module apb_read_mux(input ctrl_sel,
                    input status_sel,
                    input data_sel,
                    input mask_sel,
                    input ram_sel,
                    input [31:0] ctrl_reg,
                    input [31:0] status_reg,
                    input [31:0] data_reg,
                    input [31:0] mask_reg,
                    input [31:0] ram_rdata,
                    output reg [31:0] PRDATA);
  always @ (*)
    begin
      PRDATA = 32'h0000_0000;
      if (ctrl_sel)
        begin
          PRDATA = ctrl_reg;
        end
      else if (status_sel)
        begin
          PRDATA = status_reg;
        end
      else if (data_sel)
        begin
          PRDATA = data_reg;
        end
      else if (mask_sel)
        begin
          PRDATA = mask_reg;
        end
      else if (ram_sel)
        begin
          PRDATA = ram_rdata;
        end
    end
endmodule