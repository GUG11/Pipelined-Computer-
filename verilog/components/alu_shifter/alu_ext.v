/* include an ALU and a shifter */

/*`include "shifter16_4.v"*/
module alu_ext(data_r1, data_r2, data_r0, instr, ALUsrc, ALUop, 
  llb, lhb, Shfop, as, result, N, V, Z);
  input[15:0] data_r1, data_r2, data_r0;
  input[7:0] instr;
  // control signals, defined by controller 
  input[1:0] ALUsrc;
  input[2:0] ALUop;
  input[1:0] Shfop;
  input llb, lhb, as/*0 ALU output, 1 shifter output*/;
  
  output[15:0] result;
  output V, N, Z; // calculate V,N,Z to be stored in the flag register, whether to store is decided by the instruction.
  
  wire[15:0] instr_ext4, instr_ext8/*used in LLB*/, highbyte;
  wire[15:0] ALUin1, ALUout, sh_out, sh_llb;
  wire[15:0] ALUin2;
  reg[3:0] ALU_sigs;
  wire V_l, V_h;
  //instr extention
  shifter16_4 sign_ext4(.A({instr[3:0],12'h0}), 
    .shf(4'd12), .sigs(2'b11), .B(instr_ext4));
  shifter16_4 sign_ext8(.A({instr[7:0],8'h0}),
    .shf(4'd8), .sigs(2'b11), .B(instr_ext8));
  
  // Data for LHB
  assign highbyte = {instr[7:0], data_r1[7:0]};
  
  // mux
  assign ALUin1 = (lhb == 1)? highbyte : data_r1;
  
  assign ALUin2 = (ALUsrc == 2'd0) ? data_r0 : 
    ((ALUsrc == 2'd1) ? data_r2 :
    ((ALUsrc == 2'd2) ? instr_ext4 : instr_ext8));
  
  // ALU OP decode
  always @(ALUop) begin
  case (ALUop)
    3'b000: begin 
      ALU_sigs = 4'b0100; // ADD 
    end
    3'b001: begin
      ALU_sigs = 4'b0110; // PADDSB 
    end
    3'b010: begin
      ALU_sigs = 4'b0101; // SUB
    end
    3'b011: begin
      ALU_sigs = 4'b1000; // NAND
    end
    3'b100: begin
      ALU_sigs = 4'b0000; // XOR
    end
  endcase
  end
  
  // ALU operation
  alu ALU(.A(ALUin1),.B(ALUin2),.Sigs(ALU_sigs),.Data_out(ALUout), 
    .V(V), .N(N));
 
  // Shifter operation
  shifter16_4 shifter(.A(data_r1), .shf(instr[3:0]), 
    .sigs(Shfop), .B(sh_out));
  assign sh_llb = (llb == 1)? instr_ext8 : sh_out;
  
  // mux result
  assign result = (as == 1)? sh_llb : ALUout;
  assign Z = ~|(result);

endmodule
