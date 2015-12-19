/* single cycle processor */

/*`include "pc_reg.v"
`include "register_file.v"
`include "data_mem.v"
`include "instr_mem.v"
`include "pc_addr.v"
`include "branch.v"
`include "alu_ext.v"*/


module cpu(clk, rst_n, hlt, pc);
  input clk /*clock*/, rst_n /*reset*/;
  output hlt /*halt*/;
  output[15:0] pc/*current pc*/;

  reg pc_reg_en; // enable pc count  
  wire[15:0] pc_next, pc_jump, pc_plus1, pc_reg_in; /*next address according to the instruction*/
  wire[15:0] instr;
  wire[3:0] addr_w;
  
  // Data
  wire[15:0] data_r1, data_r2, data_r0, data_w;
  wire[15:0] alu_result, mem_out, data_wb;
  
  // ALU flags
  wire N, V, Z;
  // control signals
  wire[3:0] op;
  wire[1:0] RegDst, ALUsrc, ShfOp;
  wire MemRead, MemWrite, MemtoReg, RegWrite, Branch;
  wire run, call, llb, lhb, as, ret;
  wire[2:0] ALUOp;
  
  // Jump signal
  wire doJump;

  initial begin
    $monitor("time=%d, pc=%h, instr=%h, Register read data 1 = %h, Register read data 2 = %h, Register write data = %h, Register write address = %h",$time, pc, instr, data_r1, data_r2, data_w, addr_w);
  end
  // PC
  assign pc_next = (doJump == 1) ? pc_jump : pc_plus1;
  assign pc_reg_in = (rst_n == 0) ? 16'd0 : pc_next;
  assign hlt = ~run;
  always @(hlt, rst_n) begin // rst_n == 1 and hlt == 1 cannot coexist
    if (hlt == 1)
      pc_reg_en = 0;
    else if (rst_n == 0)
      pc_reg_en = 1;
  end
  
    
  // connect each module
  pc_reg pc_register(.pc_next(pc_reg_in), .pc_curr(pc), 
    .clk(clk), .en(pc_reg_en)); 
  // IF
  IM instr_mem(.clk(clk),.addr(pc),.rd_en(1'b1),.instr(instr)); 
  assign pc_plus1 = pc + 1;
  // ID
  assign addr_w = (RegDst == 0) ? instr[3:0] : ((RegDst == 1) ? instr[7:4] : 
    ((RegDst == 2) ? instr[11:8] : 4'd15)); 
  register_file registers(.clk(clk), .addr_r1(instr[11:8]), .addr_r2(instr[7:4]), .addr_w(addr_w), 
    .write_en(RegWrite), .data_w(data_w), .data_r1(data_r1), .data_r2(data_r2), .data_r0(data_r0));
  instr_decoder decoder(.op(instr[15:12]), .RegDst(RegDst), .MemRead(MemRead), .MemWrite(MemWrite),
    .Branch(Branch), .ALUOp(ALUOp), .ShfOp(ShfOp), .MemtoReg(MemtoReg), .ALUsrc(ALUsrc), 
    .RegWrite(RegWrite), .run(run), .call(call), .llb(llb), .lhb(lhb), .as(as), .ret(ret));
  //  EX
  alu_ext alu(.data_r1(data_r1), .data_r2(data_r2), .data_r0(data_r0), .instr(instr[7:0]), 
    .ALUsrc(ALUsrc), .ALUop(ALUOp), .llb(llb), .lhb(lhb), .Shfop(ShfOp), .as(as), 
    .result(alu_result), .N(N), .V(V), .Z(Z));
    
  pc_addr calc_next(.pc_plus1(pc_plus1), .addr_brch(instr[8:0]), .addr_ret(data_r1), 
    .addr_call(instr[11:0]), .ctrl_br(Branch), .ctrl_br_type(instr[11:9]), .Z(Z), 
    .V(V), .N(N), .call(call), .ret(ret), .pc_next(pc_jump), .doJump(doJump));
  
  // MEM
  DM data_mem(.clk(clk),.addr(alu_result),.re(MemRead),.we(MemWrite),.wrt_data(data_r2),.rd_data(mem_out));
  assign data_wb = (MemtoReg == 1) ? mem_out : alu_result;
  
  // WB
  assign data_w = (call == 1) ? (pc_plus1) : data_wb;
endmodule
