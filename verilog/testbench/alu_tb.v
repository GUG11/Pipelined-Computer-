// ALU testbench

`include "alu.v"

module alu_tb;
  reg[16:0] A, B;
  wire[15:0] D;
  wire Vl, Vh, Z, N;
  reg[3:0] Sigs;
  
  alu DUT(.A(A[15:0]),.B(B[15:0]),.Sigs(Sigs),.Data_out(D),.V_l(Vl),.V_h(Vh), .Z(Z), .N(N)); 
  
  initial begin
    $monitor("time=%g, A=%h, B=%h, Sigs=%b, D=%h, Vl=%b, Vh=%b, Z=%b, N=%b",
      $time, A, B, Sigs, D, Vl, Vh, Z, N);
    
    // function test
    A = 16'h2314; B = 16'h3241;
    Sigs = 4'b0100; // add
    #5 Sigs = 4'b0101; // sub
    #5 Sigs = 4'b0110; // paddsb
    #5 Sigs = 4'b1000; // nand
    #5 Sigs = 4'b0000; // xor
    
    // zero test
    #5 A = 16'd0; B = 16'd0;
    
    // saturation test
    #5 Sigs = 4'b0100; A = 16'h8032; B = 16'h8043;
    #5 A = 16'h7F43; B=16'h6E43;
    #5 Sigs = 4'b0110; A = 16'h8182; B=16'h8182;
    #5 A=16'h8100; B=16'h8300;
    #5 A=16'h0081; B=16'h0083;
    $stop;
  end
endmodule