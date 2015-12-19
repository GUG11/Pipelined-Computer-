// shfiter test bench

`include "shifter16_4.v"

module shifter_tb;
  reg[15:0] A;
  reg[3:0] shft;
  reg[1:0] sigs;
  wire[15:0] B;
  
  shifter16_4 DUT(.A(A), .shf(shft), .sigs(sigs), .B(B));
  
  initial begin
    $monitor("time = %g, A = %b, shft = %d, sigs = %b, B = %b",
      $time, A, shft, sigs, B);
    A = 16'h9201; shft = 3; sigs = 2'b01; // SLL
    #5 sigs = 2'b10;    // SRL
    #5 sigs = 2'b11;    // SRA
    $stop;
  end
endmodule