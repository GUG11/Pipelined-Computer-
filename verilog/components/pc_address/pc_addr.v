/* calculate next PC address */

/*`include "branch.v"
`include "shifter16_4.v"*/

module pc_addr(pc_plus1, addr_brch, addr_ret, addr_call, ctrl_br, ctrl_br_type, Z, V, N, call, ret, pc_next, doJump);
  input[15:0] pc_plus1, addr_ret; 
  input[8:0] addr_brch; // branch address
  input[11:0] addr_call; // call address
  input[2:0] ctrl_br_type; // control signals of branch
  input ctrl_br;
  input Z,V,N; // ALU flags
  input ret, call; // whether to ret, call 
  output[15:0] pc_next; // next PC addressi
  output doJump;

  wire[15:0] addr_brch_ext, pc_call, pc_brch, pc_ret, addr_mid1, addr_mid2;
  wire br_cond, doBranch;
  
  
  // sign extension of addr_brch
  shifter16_4 brch_ext(.A({addr_brch,7'h0}), .shf(4'd7), .sigs(2'b11), .B(addr_brch_ext));
  assign pc_brch = pc_plus1 + addr_brch_ext;
  shifter16_4 call_ext(.A({addr_call,4'h0}), .shf(4'd4), .sigs(2'b11), .B(pc_call));
  branch br_det(.cont_br(ctrl_br_type), .Z(Z), .V(V), .N(N), .brch(br_cond));
  and branch_and_gate(doBranch, br_cond, ctrl_br);
  // mux
  assign addr_mid1 = (doBranch == 1)? pc_brch : pc_plus1;
  assign addr_mid2 = (ret == 1)? addr_ret : addr_mid1;
  assign pc_next = (call == 1)? pc_call : addr_mid2;
  
  assign doJump = doBranch | ret | call;
endmodule  
