module apb_slave_top(input PCLK,
                     input PRESETn,
                     input PSEL,
                     input PENABLE,
                     input PWRITE,
                     input [31:0] PADDR,
                     input [31:0] PWDATA,
                     output [31:0] PRDATA,
                     output PREADY,
                     output PSLVERR);
  
  wire write_en, read_en;
  wire ctrl_sel, status_sel, data_sel, mask_sel, ram_sel;
  wire [31:0] ctrl_reg;
  wire [31:0] status_reg;
  wire [31:0] data_reg;
  wire [31:0] mask_reg;
  wire [31:0] ram_rdata;
  wire valid_address;
  
  assign valid_address = ctrl_sel | status_sel | data_sel | mask_sel | ram_sel;
  assign PSLVERR = PSEL && PENABLE && PREADY && !valid_address;
  apb_fsm fsm_inst (.PCLK(PCLK),
               		.PRESETn(PRESETn),
               		.PSEL(PSEL),
               		.PENABLE(PENABLE),
               		.PWRITE(PWRITE),
               		.write_en(write_en),
               		.read_en(read_en),
               		.PREADY(PREADY));
  
  apb_address_decoder decoder_inst(.PADDR(PADDR),
                          		   .ctrl_sel(ctrl_sel),
                                   .status_sel(status_sel),
                                   .data_sel(data_sel),
                                   .mask_sel(mask_sel),
                                   .ram_sel(ram_sel));
  
  register_bank regbank_inst(.PCLK(PCLK),
                    		 .PRESETn(PRESETn),
                    		 .write_en(write_en),
                             .read_en(read_en),
                    		 .ctrl_sel(ctrl_sel),
                    		 .status_sel(status_sel),
                    		 .data_sel(data_sel),
                    		 .mask_sel(mask_sel),
                             .ram_sel(ram_sel),
                             .PSLVERR(PSLVERR),
                             .valid_address(valid_address),
                    		 .PWDATA(PWDATA),
                    		 .ctrl_reg(ctrl_reg),
                    		 .status_reg(status_reg),
                    		 .data_reg(data_reg),
                    		 .mask_reg(mask_reg));
  
  apb_ram ram_inst (.PCLK(PCLK), 
                    .PRESETn(PRESETn), 
                    .ram_sel(ram_sel), 
                    .write_en(write_en), 
                    .read_en(read_en), 
                    .PADDR(PADDR), 
                    .PWDATA(PWDATA), 
                    .ram_rdata(ram_rdata));
  
  apb_read_mux mux_inst (.ctrl_sel(ctrl_sel),
                		 .status_sel(status_sel),
                		 .data_sel(data_sel),
                		 .mask_sel(mask_sel),
                		 .ram_sel(ram_sel),
                		 .ctrl_reg(ctrl_reg),
                		 .status_reg(status_reg),
                		 .data_reg(data_reg),
                		 .mask_reg(mask_reg),
                		 .ram_rdata(ram_rdata),
                		 .PRDATA(PRDATA));
endmodule
  
                     
           
              