module apb_fsm (input PCLK,
                input PRESETn,
                input PSEL,
                input PENABLE,
                input PWRITE,
                output reg write_en,
                output reg read_en,
                output reg PREADY);
  parameter IDLE = 2'b00,
            SETUP = 2'b10,
  			ACCESS = 2'b11;
  reg [1:0] current_state;
  reg [1:0] next_state;
  always @ (posedge PCLK or negedge PRESETn)
    begin
      if(!PRESETn)
        begin
          current_state <= IDLE;
        end
      else
        begin
          current_state <= next_state;
        end
    end
  always @ (*)
    begin
      next_state = current_state;
      case (current_state)
        IDLE: 
          begin
            if (PSEL && !PENABLE)
              begin
                next_state = SETUP;
              end
            else
              begin
                next_state = IDLE;
              end
          end
        SETUP:
          begin
            if (PSEL && PENABLE)
              begin
                next_state = ACCESS;
              end
            else if (PSEL && !PENABLE)
              begin
                next_state = SETUP;
              end
            else
              begin
                next_state = IDLE;
              end
          end
        ACCESS:
          begin
            if (!PSEL)
              begin
                next_state = IDLE;
              end
            else
              begin
                next_state = SETUP;
              end
          end
        default:
          begin
            next_state = IDLE;
          end
      endcase
    end
  always @ (*)
    begin
      write_en = 0;
      read_en = 0;
      PREADY = 0;
      
      if(PSEL && PENABLE)
        begin
          PREADY = 1;
          if (PWRITE)
            write_en = 1;
          else
            read_en = 1;
        end
    end
endmodule
    