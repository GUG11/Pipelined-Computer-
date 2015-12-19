//`include "single_cycle_processor.v"


module cpu_tb();

reg clk,rst_n;

wire [15:0] pc;
wire hlt;

//////////////////////
// Instantiate CPU //
////////////////////
cpu iCPU(.clk(clk), .rst_n(rst_n), .hlt(hlt), .pc(pc));

initial begin
  clk = 0;
  $display("rst assert\n");
  rst_n = 0; // rst_n = 0 -> reset
  @(posedge clk);
  @(negedge clk);
  rst_n = 1; // rst_n = 1 -> release
  $display("rst deassert\n");
//  #1000 $finish;
end 
  
always
  #1 clk = ~clk;
  
initial begin
  @(posedge hlt);
  @(posedge clk);
  //$stop();
  $finish;
end  

// monitor and show waves

initial begin
    $dumpfile("cpu_watched_wave.vcd");
    $dumpvars(0,cpu_tb);
end

endmodule
