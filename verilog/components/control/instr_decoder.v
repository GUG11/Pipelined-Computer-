/* instruction decoder */

module instr_decoder(op, RegDst, MemRead, MemWrite,
  Branch, ALUOp, ShfOp, MemtoReg, ALUsrc, RegWrite, 
  run, call, llb, lhb, as, ret, change_en_Z, change_en_VN);
  input[3:0] op;
  output reg[1:0] RegDst, ALUsrc, ShfOp;
  output reg MemRead, MemWrite, MemtoReg, RegWrite, Branch;
  output reg run, call, llb, lhb, as, ret;
  output reg[2:0] ALUOp;
  output change_en_Z, change_en_VN; // enable change flag registers, new added
  
  always @(op) begin
  case (op)
    4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100: begin // ADD, PADDSB, SUB, NAND, XOR $rd, $rs, $rt
      assign RegDst = 2'b00; // rd
      assign ALUsrc = 2'b01; // rt
      assign MemRead = 0;
      assign MemWrite = 0;
      assign MemtoReg = 0;
      assign RegWrite = 1;
      assign run = 1;
      assign call = 0;
      assign llb = 0;
      assign lhb = 0;
      assign as = 0;
      assign ret = 0;
      assign Branch = 0;
      assign ALUOp = op[2:0];
      assign ShfOp = 2'd0;
    end
    4'b0101, 4'b0110, 4'b0111: begin // SLL, SRL, SRA $rt, $rs, imm
      assign RegDst = 2'b01; // rt
      assign ALUsrc = 2'b10; // imm4
      assign MemRead = 0;
      assign MemWrite = 0;
      assign MemtoReg = 0;
      assign RegWrite = 1;
      assign run = 1;
      assign call = 0;
      assign llb = 0;
      assign lhb = 0;
      assign as = 1;
      assign ret = 0;
      assign Branch = 0;
      assign ALUOp = 3'd0;
      assign ShfOp = op[1:0];
    end
    4'b1000: begin // LW
      assign RegDst = 2'b01; // rt
      assign ALUsrc = 2'b10; // imm4
      assign MemtoReg = 1;
      assign run = 1;
      assign call = 0;
      assign llb = 0;
      assign lhb = 0;
      assign as = 0;
      assign ret = 0;
      assign Branch = 0;
      assign ALUOp = 3'b000; // ADD
      assign ShfOp = 2'd0;
      assign MemRead = 1;
      assign MemWrite = 0;
      assign RegWrite = 1;  
    end
    4'b1001: begin // SW
      assign RegDst = 2'b01; // rt
      assign ALUsrc = 2'b10; // imm4
      assign MemtoReg = 1;
      assign run = 1;
      assign call = 0;
      assign llb = 0;
      assign lhb = 0;
      assign as = 0;
      assign ret = 0;
      assign Branch = 0;
      assign ALUOp = 3'b000; // ADD
      assign ShfOp = 2'd0;  
      assign MemRead = 0;
      assign MemWrite = 1;
      assign RegWrite = 0;          
    end
    4'b1010: begin // LHB
      assign RegDst = 2'b10; // rs
      assign ALUsrc = 2'b00; // 0
      assign MemRead = 0;
      assign MemWrite = 0;
      assign MemtoReg = 0;
      assign RegWrite = 1;
      assign run = 1;
      assign call = 0;
      assign llb = 0;
      assign lhb = 1;
      assign as = 0;
      assign ret = 0;
      assign Branch = 0;
      assign ALUOp = 3'd0; // ADD
      assign ShfOp = 2'd0;
    end
    4'b1011: begin // LLB
      assign RegDst = 2'b10; // rs
      assign ALUsrc = 2'b00; // 0
      assign MemRead = 0;
      assign MemWrite = 0;
      assign MemtoReg = 0;
      assign RegWrite = 1;
      assign run = 1;
      assign call = 0;
      assign llb = 1;
      assign lhb = 0;
      assign as = 1;
      assign ret = 0;
      assign Branch = 0;
      assign ALUOp = 3'd0; // don't care
      assign ShfOp = 2'b11; // SRA
    end
    4'b1100: begin // B
      assign RegDst = 2'd0; // don't care
      assign ALUsrc = 2'd0; // don't care
      assign MemRead = 0;
      assign MemWrite = 0;
      assign MemtoReg = 0;
      assign RegWrite = 0;
      assign run = 1;
      assign call = 0;
      assign llb = 0;
      assign lhb = 0;
      assign as = 1'd0; // don't care
      assign ret = 0;
      assign Branch = 1;
      assign ALUOp = 3'd0; // don't care
      assign ShfOp = 2'd0; // don't care
    end
    4'b1101: begin // CALL
      assign RegDst = 2'b11; // $15
      assign ALUsrc = 2'd0; // don't care
      assign MemRead = 0;
      assign MemWrite = 0;
      assign MemtoReg = 0;
      assign RegWrite = 1;
      assign run = 1;
      assign call = 1;
      assign llb = 0;
      assign lhb = 0;
      assign as = 1'd0; // don't care
      assign ret = 0;
      assign Branch = 0;
      assign ALUOp = 3'd0; // don't care
      assign ShfOp = 2'd0; // don't care
    end    
    4'b1110: begin // RET
      assign RegDst = 2'd0; // don't care
      assign ALUsrc = 2'd0; // don't care
      assign MemRead = 0;
      assign MemWrite = 0;
      assign MemtoReg = 0;
      assign RegWrite = 0;
      assign run = 1;
      assign call = 0;
      assign llb = 0;
      assign lhb = 0;
      assign as = 1'd0; // don't care
      assign ret = 1;
      assign Branch = 0;
      assign ALUOp = 3'd0; // don't care
      assign ShfOp = 2'd0; // don't care
    end
    4'b1111: begin // HLT
      assign RegDst = 2'd0; // $15
      assign ALUsrc = 2'd0; // don't care
      assign MemRead = 0;
      assign MemWrite = 0;
      assign MemtoReg = 0;
      assign RegWrite = 0;
      assign run = 0;
      assign call = 0;
      assign llb = 0;
      assign lhb = 0;
      assign as = 1'd0; // don't care
      assign ret = 0;
      assign Branch = 0;
      assign ALUOp = 3'd0; // don't care
      assign ShfOp = 2'd0; // don't care
    end
  endcase
  end

  assign change_en_Z = ~op[3] & (op[2] | op[1] | ~op[0]); // 0x0 ~ 0x7 except 0x1(PADDSB)
  assign change_en_VN = ~(op[0] | op[2] | op[3]); // ADD, SUB only

endmodule
