`timescale 1ns/1ns
module tb;
  reg PCLK;
  reg PRESETn;
  reg PSEL;
  reg PENABLE;
  reg PWRITE;
  reg [31:0] PADDR;
  reg [31:0] PWDATA;
  wire [31:0] PRDATA;
  wire PREADY;
  wire PSLVERR;
  reg [31:0] exp_ctrl_reg;
  reg [31:0] exp_status_reg;
  reg [31:0] exp_data_reg;
  reg [31:0] exp_mask_reg;
  reg [31:0] exp_mem [0:255];
  reg [31:0] exp_PRDATA;
  reg exp_PREADY;
  reg exp_PSLVERR;
  integer pass_count;
  integer fail_count;
  
  parameter PH_RESET_ACTIVE = 4'd0,
  			PH_RESET_RELEASED = 4'd1,
  			PH_WRITE_SETUP = 4'd2,
  			PH_WRITE_ACCESS = 4'd3,
  			PH_WRITE_DONE = 4'd4,
  			PH_READ_SETUP = 4'd5,
  			PH_READ_ACCESS = 4'd6,
  			PH_IDLE_WRITE = 4'd7,
  			PH_IDLE_READ = 4'd8;
  
  apb_slave_top dut (.PCLK(PCLK),
                     .PRESETn(PRESETn),
                     .PSEL(PSEL),
                     .PENABLE(PENABLE),
                     .PWRITE(PWRITE),
                     .PADDR(PADDR),
                     .PWDATA(PWDATA),
                     .PRDATA(PRDATA),
                     .PREADY(PREADY),
                     .PSLVERR(PSLVERR));
  
  initial PCLK = 0;
  always begin
    #5 PCLK = ~ PCLK;
  end
  
  initial begin
    $timeformat(-9,0," ns",10);
  end
  
  task reset_dut;
    begin
      PRESETn = 0;
      PSEL = 0;
      PENABLE = 0;
      PWRITE = 0;
      PADDR = 0;
      PWDATA = 0;
      exp_ctrl_reg = 32'h0000_0000;
      exp_status_reg = 32'h0000_0000;
      exp_data_reg = 32'h0000_0000;
      exp_mask_reg = 32'h0000_0000;
      exp_PRDATA = 32'h0000_0000;
      #1;
      show_apb_status(PH_RESET_ACTIVE);
      #10;
      @ (negedge PCLK);
      PRESETn = 1;
      @ (posedge PCLK);
      #1;
      show_apb_status(PH_RESET_RELEASED);
    end
  endtask
  
  task update_reference_model;
    input [31:0] addr;
    input [31:0] pdata;
    begin
      case (addr)
        32'h0000_0000:
          begin
            exp_ctrl_reg = pdata;
          end
        32'h0000_0004:
          begin
            exp_status_reg = exp_status_reg;
          end
        32'h0000_0008:
          begin
            exp_data_reg = pdata;
          end
        32'h0000_000C:
          begin
            exp_mask_reg = {16'h0000, pdata[15:0]};
          end
        default:
          if ((addr >= 32'h0000_0010) && (addr <= 32'h0000_040C) && (addr [1:0] == 2'b00))
            begin
              exp_mem[(addr - 32'h0000_0010) >> 2] = pdata;
            end
      endcase
    end
  endtask
  
  task apb_write;
    input [31:0] addr;
    input [31:0] data_in;
    begin
      PADDR = addr;
      PWDATA = data_in;
      
      //SETUP
      PSEL = 1;
      PENABLE = 0;
      PWRITE = 1;
      @ (posedge PCLK);
      #1;
      show_apb_status(PH_WRITE_SETUP);
      
      //ACCESS
      PSEL = 1;
      PENABLE = 1;
      @ (posedge PCLK);
      #1;
      
      //Write has completed on this ACCESS edge
      update_reference_model(addr,data_in);
      
      //Update expected hardware status
      if ((addr == 32'h0000_0000) || (addr == 32'h0000_0004) || (addr == 32'h0000_0008) || (addr == 32'h0000_000C) || ((addr >= 32'h0000_0010) && (addr <= 32'h0000_040C) && (addr[1:0] == 2'b00)))
          begin
            exp_status_reg[0] = 1'b1; //Valid write completed
          end
      else
        begin
          exp_status_reg[2] = 1'b1; //Invalid address error
        end
      if ((addr >= 32'h0000_0010) && (addr <= 32'h0000_040C) && (addr[1:0] == 2'b00))
        begin
          exp_status_reg[3] = 1'b1; //RAM was accessed
        end
      show_apb_status(PH_WRITE_ACCESS);
      
      //IDLE
      PSEL = 0;
      PENABLE = 0;
      PWRITE = 0;
      PADDR = 0;
      PWDATA = 0;
      @ (posedge PCLK);
      #1;
      show_apb_status(PH_IDLE_WRITE);
    end
  endtask
  
  task read_expected;
    input [31:0] addr;
    begin
      exp_PRDATA = 32'h0000_0000;
      case (addr)
        32'h0000_0000:
          begin
            exp_PRDATA = exp_ctrl_reg;
          end
        32'h0000_0004:
          begin
            exp_PRDATA = exp_status_reg;
          end
        32'h0000_0008:
          begin
            exp_PRDATA = exp_data_reg;
          end
        32'h0000_000C:
          begin
            exp_PRDATA = exp_mask_reg;
          end
        default:
          if ((addr >= 32'h0000_0010) && (addr <= 32'h0000_040C) && (addr [1:0] == 2'b00))
            begin
              exp_PRDATA = exp_mem[(addr - 32'h0000_0010) >> 2];
            end
      endcase
    end
  endtask
  
  task apb_read;
    input [31:0] addr;
    begin
      PADDR = addr;
      PWDATA = 0;
      
      //SETUP
      PSEL = 1;
      PENABLE = 0;
      PWRITE = 0;
      @ (posedge PCLK);
      #1;
      show_apb_status(PH_READ_SETUP);
      
      //ACCESS
      PSEL = 1;
      PENABLE = 1;
      @ (posedge PCLK);
      #1;
      
      //Update expected STATUS REGISTER 
      if ((addr == 32'h0000_0000) || (addr == 32'h0000_0004) || (addr == 32'h0000_0008) || (addr == 32'h0000_000C) || ((addr >= 32'h0000_0010) && (addr <= 32'h0000_040C) && (addr[1:0] == 2'b00)))
        begin
          exp_status_reg[1] = 1'b1; //Valid read completed
        end
      else
        begin
          exp_status_reg[2] = 1'b1; //Invalid address error
        end
      if ((addr >= 32'h0000_0010) && (addr <= 32'h0000_040C) && (addr[1:0] == 2'b00))
        begin
          exp_status_reg[3] = 1'b1; //RAM accessed
        end
      
      //Calculate expected PRDATA
      read_expected(addr);
      exp_PREADY = 1;
      if ((addr == 32'h0000_0000) || (addr == 32'h0000_0004) || (addr == 32'h0000_0008) || (addr == 32'h0000_000C) || ((addr >= 32'h0000_0010) && (addr <= 32'h0000_040C) && (addr [1:0] == 2'b00)))
        begin
          exp_PSLVERR = 0;
        end
      else
        begin
          exp_PSLVERR = 1;
        end
      
      show_apb_status(PH_READ_ACCESS);
      check_outputs;
      
      //IDLE
      PSEL = 0;
      PENABLE = 0;
      PWRITE = 0;
      PADDR = 0;
      @ (posedge PCLK);
      #1;
      exp_PREADY = 0;
      exp_PSLVERR = 0;
      exp_PRDATA = exp_ctrl_reg; //PADDR = 0 selects CTRL register in IDLE
      
      show_apb_status(PH_IDLE_READ);
      check_outputs;
    end
  endtask
  
  initial begin
    pass_count = 0;
    fail_count = 0;
  end
  
  task check_outputs;
    begin
      #1;
      if ((PRDATA == exp_PRDATA) && (PREADY == exp_PREADY) && (PSLVERR == exp_PSLVERR))
        begin
          $display("TEST RESULT = PASS");
          $display("Checked: PADDR=%h PRDATA=%h PREADY=%b PSLVERR=%b",PADDR,PRDATA,PREADY,PSLVERR);
          pass_count = pass_count + 1;
        end
      else
        begin
          $display("TEST RESULT = FAIL");
          $display("Expected: PRDATA=%h PREADY=%b PSLVERR=%b",exp_PRDATA,exp_PREADY,exp_PSLVERR);
          $display("Actual: PRDATA=%h PREADY=%b PSLVERR=%b",PRDATA,PREADY,PSLVERR);
          fail_count = fail_count + 1;
        end
    end
  endtask
  
  
  task show_apb_status;
    input [3:0] phase_code;
    integer ram_index;
    begin
      $display("==================================================================");
      $display("SIMULATION TIME = %0t",$time);
      case (phase_code)
        PH_RESET_ACTIVE:
          $display("PHASE = RESET ACTIVE");
        PH_RESET_RELEASED:
          $display("PHASE = RESET RELEASED");
        PH_WRITE_SETUP:
          $display("PHASE = WRITE SETUP");
        PH_WRITE_ACCESS:
          $display("PHASE = WRITE ACCESS");
        PH_WRITE_DONE:
          $display("PHASE = WRITE DONE");
        PH_READ_SETUP:
          $display("PHASE = READ SETUP");
        PH_READ_ACCESS:
          $display("PHASE = READ ACCESS");
        PH_IDLE_WRITE:
          $display("PHASE = IDLE AFTER WRITE");
        PH_IDLE_READ:
          $display("PHASE = IDLE AFTER READ");
        default:
          $display("PHASE = UNKNOWN");
      endcase
      
      case (dut.fsm_inst.current_state)
        2'b00:
          $display("FSM STATE = IDLE");
        2'b10:
          $display("FSM STATE = SETUP");
        2'b11:
          $display("FSM STATE = ACCESS");
        default:
          $display("FSM STATE = UNKNOWN");
      endcase
      
      $display("PCLK=%b PRESETn=%b PSEL=%b PENABLE=%b PWRITE=%b",PCLK,PRESETn,PSEL,PENABLE,PWRITE);
      
      if (!PRESETn)
        $display("OPERATION = RESET");
      else if (!PSEL)
        $display("OPERATION = NO ACTIVE TRANSFER");
      else if (PWRITE)
        $display("OPERATION = WRITE");
      else
        $display("OPERATION = READ");
      
      $display("PADDR=%h PWDATA=%h PRDATA=%h",PADDR,PWDATA,PRDATA);
      $display("PREADY=%b PSLVERR=%b write_en=%b read_en=%b",PREADY,PSLVERR,dut.write_en,dut.read_en);
      $display("SELECTS: CTRL=%b STATUS=%b DATA=%b MASK=%b RAM=%b",dut.ctrl_sel,dut.status_sel,dut.data_sel,dut.mask_sel,dut.ram_sel);
      
      if(dut.ctrl_sel)
        begin
          $display("TARGET = CTRL REGISTER");
          $display("CTRL_REG VALUE=%h",dut.ctrl_reg);
        end
      else if (dut.status_sel)
        begin
          $display("TARGET = STATUS REGISTER");
          $display("STATUS_REG VALUE=%h",dut.status_reg);
        end
      else if (dut.data_sel)
        begin
          $display("TARGET = DATA REGISTER");
          $display("DATA_REG VALUE=%h",dut.data_reg);
        end
      else if (dut.mask_sel)
        begin
          $display("TARGET = MASK REGISTER");
          $display("MASK_REG VALUE=%h",dut.mask_reg);
        end
      else if (dut.ram_sel)
        begin
          ram_index = (PADDR - 32'h0000_0010) >> 2;
          $display("TARGET = RAM");
          $display("RAM ADDRESS IS VALID AND WORD ALIGNED");
          $display("RAM INDEX =%d",ram_index);
          $display("RAM[%d] VALUE =%h",ram_index,dut.ram_inst.mem[ram_index]);
        end
      else
        begin
          $display("TARGET = INVALID ADDRESS");
          if ((PADDR >= 32'h0000_0010) && (PADDR <= 32'h0000_040C) && (PADDR[1:0] != 2'b00))
            begin
              $display("ADDRESS ERROR = RAM ADDRESS IS NOT WORD ALIGNED");
            end
          else
            begin
              $display("ADDRESS ERROR = OUTSIDE REGISTER AND RAM RANGE");
            end
        end
      
      if (PSLVERR)
        $display("SLAVE ERROR = YES");
      else
        $display("SLAVE ERROR = NO");
    end
  endtask
  
  
   initial begin
    $dumpfile("file.vcd");
    $dumpvars;
  end
  
  initial begin
    exp_PREADY = 0;
    exp_PSLVERR = 0;
    reset_dut;
    
    //Check reset values
    apb_read(32'h0000_0000); //CTRL = 0000_0000
    apb_read(32'h0000_0004); //Read hardware updated status register
    apb_read(32'h0000_0008); //DATA = 0000_0000
    apb_read(32'h0000_000C); //MASK = 0000_0000
    
    //CTRL 
    apb_write(32'h0000_0000, 32'hAAAA_1111);
    apb_read(32'h0000_0000);
    
    //STATUS
    apb_write(32'h0000_0004, 32'h1111_AAAA);
    apb_read(32'h0000_0004);
    
    //DATA
    apb_write(32'h0000_0008, 32'hBBBB_5555);
    apb_read(32'h0000_0008);
    
    //MASK
    apb_write(32'h0000_000C, 32'h5555_BBBB);
    apb_read(32'h0000_000C);
    
    reset_dut;
    
    
    //RAM
    apb_write(32'h0000_0010, 32'h7777_3333);
    apb_read(32'h0000_0010);
    apb_write(32'h0000_001C, 32'h9999_AAAA);
    apb_read(32'h0000_001C);
    apb_write(32'h0000_040C, 32'h6666_CCCC);
    apb_read(32'h0000_040C);
    
    //INVALID ADDRESS
    apb_write(32'h0000_045C, 32'h7575_5757);
    apb_read(32'h0000_045C);
    
    $display("pass_count=%d",pass_count);
    $display("fail_count=%d",fail_count);
    
    if (fail_count == 0)
      $display("Final Result: ALL Tests Passed");
    else
      $display("Final Result: Test Failed");
    $finish;
  end
endmodule
  
  