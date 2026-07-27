module apb_address_decoder (input [31:0] PADDR,
                            output reg ctrl_sel,
                            output reg status_sel,
                            output reg data_sel,
                            output reg mask_sel,
                            output reg ram_sel);
  always @ (*)
    begin
      ctrl_sel = 0;
      status_sel = 0;
      data_sel = 0;
      mask_sel = 0;
      ram_sel = 0;
      case(PADDR)
        32'h0000_0000:
          begin
            ctrl_sel = 1;
          end
        32'h0000_0004:
          begin
          	status_sel = 1;
          end
        32'h0000_0008:
          begin
            data_sel = 1;
          end
        32'h0000_000C:
          begin
            mask_sel = 1;
          end
        default:
          begin
            if ((PADDR >= 32'h0000_0010) && (PADDR <= 32'h0000_040C) && (PADDR[1:0] == 2'b00))
              begin
                ram_sel = 1;
              end
          end
      endcase
    end
endmodule

