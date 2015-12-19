/* decide whether to branch */

module branch(cont_br, Z, N, V, brch);
  input[2:0] cont_br; // control signals
  input Z, N, V; // output of ALU, zero, Sign, Overflow
  output reg brch; // 1 branch, 0 not branch
  
  always @(cont_br, Z, N, V)
  case (cont_br)
    3'b000: brch = ~Z; // Not Equal
    3'b001: brch = Z;  // Equal
    3'b010: brch = ~(Z | N); // Greater Than
    3'b011: brch = N;  // Less Than
    3'b100: brch = Z | ~(Z|N); // Greater Than or Equal
    3'b101: brch = N | Z; // Less Than or Equal
    3'b110: brch = V;     // Overflow
    3'b111: brch = 1'b1;
  endcase
endmodule
