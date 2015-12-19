/* the ALU module

 signals control table
 Instr  s0 s1 s2 s3
 ADD    0  0  1  0
 SUB    1  0  1  0
 PADDSB 0  1  1  0
 NAND   0  0  0  1
 XOR    0  0  0  0 */


/*`include "satu_low.v"
`include "sig_not_sel.v"
`include "overflow.v"*/

module alu(A,B,Sigs,Data_out, V, Z, N);
  parameter Nb = 16;
  parameter Ns = 4;
  
  input[Nb-1:0] A, B;
  input[Ns-1:0] Sigs;
  output[Nb-1:0] Data_out;
  output V; // overflow flag
  output Z; // zero flag
  output N; // negative flag
  wire V_l, V_h; // overflow flags for PADDSB
  wire[Nb-1:0] Bin, C_in, Sum, C_out, C_out_not, Sat, Ar_out/*arithmetic out*/;
  wire par_sel_b8, not_f7; 
  wire set_nv_flag; // 1 : (ADD,SUB) can change N,V flag, 0 : others cannot change N,V flag 

  genvar i; // adder design
  generate for(i = 0; i < Nb; i = i + 1) begin
      if (i == 0) begin
        sig_not_sel preb_i(.a(B[i]), .sel(Sigs[0]), .out(Bin[i]));
        and precin_i(C_in[i], Sigs[0], Sigs[2]);
        full_adder fa_0(.a(A[i]), .b(Bin[i]), .c_in(C_in[i]), .sum(Sum[i]), .c_out(C_out[i]));
      end
      else if (i == 8) begin
        sig_not_sel preb_i(.a(B[i]), .sel(Sigs[0]), .out(Bin[i]));
        assign par_sel_b8 = (Sigs[1] == 1) ? Sigs[0] : C_out[7]; // whether parallalizm
        and precin_i(C_in[i], par_sel_b8, Sigs[2]);
        full_adder fa_8(.a(A[i]), .b(Bin[i]), .c_in(C_in[i]), .sum(Sum[i]), .c_out(C_out[i]));
      end
      else begin
        sig_not_sel preb_i(.a(B[i]), .sel(Sigs[0]), .out(Bin[i]));
        and precin_i(C_in[i], C_out[i-1], Sigs[2]);
        full_adder fa_i(.a(A[i]), .b(Bin[i]), .c_in(C_in[i]), .sum(Sum[i]), .c_out(C_out[i]));
      end
    end
  endgenerate
    
  // Overflow detection
  overflow ofH(.a(A[15]),.b(Bin[15]),.f(Sum[15]),.v(V_h));
  overflow ofL(.a(A[7]),.b(Bin[7]),.f(Sum[7]),.v(V_l));
    
  // Saturation 
  generate for (i = 0; i < Nb; i = i + 1) begin
    if (i < 7) begin
      satu_low satu_i(.MSB({Sum[7],Sum[15]}), .V({V_l, V_h}), .fi(Sum[i]), .s1(Sigs[1]), .arith_out(Sat[i]));
    end
    else if (i == 7) begin
      not not_sat7(not_f7, Sum[7]);
      satu_low satu_i(.MSB({not_f7,Sum[15]}), .V({V_l, V_h}), .fi(Sum[i]), .s1(Sigs[1]), .arith_out(Sat[i]));
    end
    else if (i < 15) begin
      assign Sat[i] = (V_h == 1) ? Sum[15] : Sum[i];
    end
    else begin
      sig_not_sel satu_i(.a(Sum[15]), .sel(V_h), .out(Sat[i]));
    end
  end
  endgenerate

  // Choose between SATURATION and XOR
  generate 
  for (i = 0; i < Nb; i = i + 1) begin
    assign Ar_out[i] = (Sigs[2] == 1) ? Sat[i] : Sum[i];
  end
  endgenerate
  
  // Choose between ARITH and LOGIC(NAND)  
  generate
  for (i = 0; i < Nb; i = i + 1) begin
    not not_cout_i(C_out_not[i], C_out[i]);
    assign Data_out[i] = (Sigs[3] == 1) ? C_out_not[i] : Ar_out[i];
  end
  endgenerate 
  
  assign set_nv_flag = (~Sigs[3] && Sigs[2] && ~Sigs[1]);
  assign N = (set_nv_flag == 1'b1) ? Data_out[Nb-1] : N;
  assign V = (set_nv_flag == 1'b1) ? V_h : V;
  assign Z = ~|(Data_out);

endmodule
