// register file testbench

`include "register_file.v"

module regi_tb;
  reg[15:0] data_w;
  reg[3:0] addr_r1, addr_r2, addr_w;
  reg write_en, clk;
  wire[15:0] data_r1, data_r2;
  
  register_file DUT(.addr_r1(addr_r1), .addr_r2(addr_r2), .addr_w(addr_w),
    .write_en(write_en), .data_r1(data_r1), .data_r2(data_r2), .data_w(data_w));
  
  initial begin
    addr_w = 1;
    write_en = 1;
    data_w = 16'h0100;
    clk = 0;
    #1 addr_r1 = 1; addr_r2 = 1; addr_w = 0;
    #10 addr_r1 = 0;
    $stop;
  end
  
  always begin
    #1 clk = ~clk;
  end
  
  always @(posedge clk) 
    data_w = data_r1 - data_r2;
endmodule
      
