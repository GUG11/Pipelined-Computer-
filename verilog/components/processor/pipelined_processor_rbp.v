/*
* A pipelined processor with five phases: IF, ID, EX, MEM, WB
* with register bypassing but without data forwarding
*/

module cpu(clk, rst_n, hlt, pc);
    input clk /*clock*/, rst_n /*reset*/;
    output  hlt /*halt*/;
    output[15:0] pc/*current pc*/;

    reg pc_reg_en; // enable pc count
    wire[15:0] pc_next/*next pc address*/, pc_plus1/*pc+1*/, pc_jump/*jump address*/, pc_reg_in/*address put into the pc register*/; 
    wire[15:0] instr;
    wire[3:0] addr_w;

    // Data
    wire[15:0] data_r1, data_r2, data_r0, data_w;
    wire[15:0] alu_result, mem_out, data_wb;

    // ALU flags
    wire N, V, Z;
    // control signals
    wire[3:0] op;
    wire[2:0] ALUOp;
    wire[1:0] RegDst, ALUsrc, ShfOp;
    wire MemRead, MemWrite, MemtoReg, RegWrite, Branch;
    wire run, call, llb, lhb, as, ret;

    // New added
    wire change_en_Z, change_en_VN;
    wire flag_register_V, flag_register_N, flag_register_Z;

    // Pipelined registers
    // IF/ID
    wire[15:0] if_id_instr, if_id_pcaddr;
    // ID/EX
    wire[2:0] id_ex_ALUOp;
    wire[1:0] id_ex_ALUSrc, id_ex_ShfOp;
    wire id_ex_llb, id_ex_lhb, id_ex_as;
    wire id_ex_MemRead, id_ex_MemWrite, id_ex_Branch, id_ex_call, id_ex_ret;
    wire[2:0] id_ex_BranchType;
    wire[1:0] id_ex_RegDst;
    wire id_ex_MemtoReg, id_ex_RegWrite, id_ex_run;
    wire[11:0] id_ex_address;
    wire[3:0] id_ex_Rd;
    wire[15:0] id_ex_pcaddr;
    wire[15:0] id_ex_data_r0, id_ex_data_r1, id_ex_data_r2;

    wire id_ex_change_en_Z, id_ex_change_en_VN;

    // EX/MEM
    wire ex_mem_MemWrite, ex_mem_MemRead, ex_mem_Branch, ex_mem_call, ex_mem_ret;
    wire[2:0] ex_mem_BranchType;
    wire[11:0] ex_mem_address;
    wire[15:0] ex_mem_retAddr, ex_mem_pcaddr;
    wire ex_mem_V, ex_mem_Z, ex_mem_N;
    wire[1:0] ex_mem_RegDst;
    wire ex_mem_MemtoReg, ex_mem_RegWrite, ex_mem_run;
    wire[15:0] ex_mem_ALU_result, ex_mem_data_r2;
    wire[3:0] ex_mem_Rd;
    // MEM/WB
    wire[1:0] mem_wb_RegDst;
    wire mem_wb_MemtoReg, mem_wb_RegWrite, mem_wb_run, mem_wb_call;
    wire[15:0] mem_wb_pcaddr, mem_wb_ALU_result, mem_wb_Mem_out;
    wire[3:0] mem_wb_Rd;

    // Used register values (for test only)
    wire[15:0] R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15;

    // Hazard control
    wire doJump, hc_pcwrite_en, hc_ifid_write_en, hc_if_id_clean, hc_id_ex_clean, hc_ex_mem_clean, hc_mem_wb_clean;
    wire if_id_write_en, if_id_clean, id_ex_clean, ex_mem_clean, mem_wb_clean; 
    // PC
    assign pc_next = (doJump === 1)? pc_jump : pc_plus1; 
    assign pc_reg_in = (rst_n == 0)? 16'd0 : pc_next;
    assign hlt = ~mem_wb_run; // in fact run is unncessary
    always @(hlt, rst_n, hc_pcwrite_en) begin // rst_n == 1 and hlt == 1 cannot coexist
        if (hlt === 1)
            pc_reg_en = 0;
        else if (rst_n == 0)
            pc_reg_en = 1;
        else 
            pc_reg_en = (hc_pcwrite_en !== 1'b0); // data hazard
    end

    // connect each module
    pc_reg pc_register(.pc_next(pc_reg_in), .pc_curr(pc), .clk(clk), .en(pc_reg_en));
    // IF
    IM instr_mem(.clk(clk), .addr(pc), .rd_en(1'b1), .instr(instr));
    assign pc_plus1 = pc + 1;
    // IF/ID register
    assign if_id_write_en = (hc_ifid_write_en !== 1'b0);
    assign if_id_clean = (hc_if_id_clean === 1'b1);
    if_id_register IF_ID_Reg(.clk(clk), .write_en(if_id_write_en), .clear(if_id_clean), .instr_next(instr), .pc_addr_next(pc_plus1), .instr(if_id_instr), .pc_addr(if_id_pcaddr));
    // ID
    assign addr_w = (RegDst == 0) ? if_id_instr[3:0] : ((RegDst == 1) ? if_id_instr[7:4] : ((RegDst == 2) ? if_id_instr[11:8] : 4'd15));
    register_file registers(.clk(clk), .addr_r1(if_id_instr[11:8]), .addr_r2(if_id_instr[7:4]), .addr_w(mem_wb_Rd), .write_en(mem_wb_RegWrite), .data_w(data_w), .data_r1(data_r1), .data_r2(data_r2), .data_r0(data_r0), .dr0(R0), .dr1(R1), .dr2(R2), .dr3(R3), .dr4(R4), .dr5(R5), .dr6(R6), .dr7(R7), .dr8(R8), .dr9(R9), .dr10(R10), .dr11(R11), .dr12(R12), .dr13(R13), .dr14(R14), .dr15(R15));
    instr_decoder decoder(.op(if_id_instr[15:12]), .RegDst(RegDst), .MemRead(MemRead), .MemWrite(MemWrite), .Branch(Branch), .ALUOp(ALUOp), .ShfOp(ShfOp), .MemtoReg(MemtoReg), .ALUsrc(ALUsrc), .RegWrite(RegWrite), .run(run), .call(call), .llb(llb), .lhb(lhb), .as(as), .ret(ret), .change_en_Z(change_en_Z), .change_en_VN(change_en_VN));
    // ID/EX register
    assign id_ex_clean = (hc_id_ex_clean === 1'b1);
    id_ex_register ID_EX_Reg(.clk(clk), .write_en(1'b1), .clear(id_ex_clean), .RegDst_next(RegDst), .ALUSrc_next(ALUsrc), .ShfOp_next(ShfOp), .MemRead_next(MemRead), .MemWrite_next(MemWrite), .MemtoReg_next(MemtoReg), .RegWrite_next(RegWrite), .Branch_next(Branch), .ALUOp_next(ALUOp), .run_next(run), .call_next(call), .llb_next(llb), .lhb_next(lhb), .as_next(as), .ret_next(ret), .Rd_next(addr_w), .BranchType_next(if_id_instr[11:9]), .Address_next(if_id_instr[11:0]), .pc_addr_next(if_id_pcaddr), .data_r0_next(data_r0), .data_r1_next(data_r1), .data_r2_next(data_r2), .change_en_Z_next(change_en_Z), .change_en_VN_next(change_en_VN),.ALUSrc(id_ex_ALUSrc), .ShfOp(id_ex_ShfOp), .MemRead(id_ex_MemRead), .MemWrite(id_ex_MemWrite), .MemtoReg(id_ex_MemtoReg), .RegWrite(id_ex_RegWrite), .Branch(id_ex_Branch), .ALUOp(id_ex_ALUOp), .run(id_ex_run), .call(id_ex_call), .llb(id_ex_llb), .lhb(id_ex_lhb), .as(id_ex_as), .ret(id_ex_ret), .Rd(id_ex_Rd), .BranchType(id_ex_BranchType), .Address(id_ex_address), .pc_addr(id_ex_pcaddr), .data_r0(id_ex_data_r0), .data_r1(id_ex_data_r1), .data_r2(id_ex_data_r2), .change_en_Z(id_ex_change_en_Z), .change_en_VN(id_ex_change_en_VN));
    // EX 
    alu_ext alu(.data_r1(id_ex_data_r1), .data_r2(id_ex_data_r2), .data_r0(id_ex_data_r0), .instr(id_ex_address[7:0]), .ALUsrc(id_ex_ALUSrc), .ALUop(id_ex_ALUOp), .llb(id_ex_llb), .lhb(id_ex_lhb), .Shfop(id_ex_ShfOp), .as(id_ex_as), .result(alu_result), .N(N), .V(V), .Z(Z));
    flag_register flag_regi(.clk(clk), .change_en_Z(id_ex_change_en_Z), .change_en_VN(id_ex_change_en_VN), .Vin(V), .Nin(N), .Zin(Z), .V(flag_register_V), .N(flag_register_N), .Z(flag_register_Z));
    // EX/MEM
    assign ex_mem_clean = (hc_ex_mem_clean === 1'b1);
    ex_mem_register EX_MEM_Reg(.clk(clk), .write_en(1'b1), .clear(ex_mem_clean), .RegDst_next(id_ex_RegDst)/*no need in fact*/, .MemRead_next(id_ex_MemRead), .MemWrite_next(id_ex_MemWrite), .MemtoReg_next(id_ex_MemtoReg), .RegWrite_next(id_ex_RegWrite), .Branch_next(id_ex_Branch), .BranchType_next(id_ex_BranchType), .run_next(id_ex_run), .call_next(id_ex_call), .ret_next(id_ex_ret), .Rd_next(id_ex_Rd), .Address_next(id_ex_address), .retAddr_next(id_ex_data_r1), .pc_addr_next(id_ex_pcaddr), .V_next(flag_register_V), .Z_next(flag_register_Z), .N_next(flag_register_N), .ALU_result_next(alu_result), .data_r2_next(id_ex_data_r2), .RegDst(ex_mem_RegDst), .MemRead(ex_mem_MemRead), .MemWrite(ex_mem_MemWrite), .MemtoReg(ex_mem_MemtoReg), .RegWrite(ex_mem_RegWrite), .Branch(ex_mem_Branch), .BranchType(ex_mem_BranchType), .Address(ex_mem_address) , .retAddr(ex_mem_retAddr), .pc_addr(ex_mem_pcaddr), .V(ex_mem_V), .N(ex_mem_N), .Z(ex_mem_Z), .Rd(ex_mem_Rd), .run(ex_mem_run), .call(ex_mem_call), .ret(ex_mem_ret), .ALU_result(ex_mem_ALU_result), .data_r2(ex_mem_data_r2));
    // MEM
    pc_addr calc_next(.pc_plus1(ex_mem_pcaddr), .addr_brch(ex_mem_address[8:0]), .addr_ret(ex_mem_retAddr), .addr_call(ex_mem_address[11:0]), .ctrl_br(ex_mem_Branch), .ctrl_br_type(ex_mem_BranchType), .Z(flag_register_Z), .V(flag_register_V), .N(flag_register_N), .call(ex_mem_call), .ret(ex_mem_ret), .pc_next(pc_jump), .doJump(doJump));
    DM data_mem(.clk(clk),.addr(ex_mem_ALU_result),.re(ex_mem_MemRead),.we(ex_mem_MemWrite),.wrt_data(ex_mem_data_r2),.rd_data(mem_out));
    // MEM/WB
    assign mem_wb_clean = (hc_mem_wb_clean === 1'b1);
    mem_wb_register MEM_WB_Reg(.clk(clk), .write_en(1'b1), .clear(mem_wb_clean), .RegDst_next(ex_mem_RegDst), .MemtoReg_next(ex_mem_MemtoReg), .RegWrite_next(ex_mem_RegWrite), .run_next(ex_mem_run), .call_next(ex_mem_call), .Rd_next(ex_mem_Rd), .pc_addr_next(ex_mem_pcaddr), .ALU_result_next(ex_mem_ALU_result), .Mem_out_next(mem_out), .RegDst(mem_wb_RegDst), .MemtoReg(mem_wb_MemtoReg), .RegWrite(mem_wb_RegWrite), .run(mem_wb_run), .call(mem_wb_call), .Rd(mem_wb_Rd), .pc_addr(mem_wb_pcaddr), .ALU_result(mem_wb_ALU_result), .Mem_out(mem_wb_Mem_out));
    // WB
    assign data_wb = (mem_wb_MemtoReg == 1) ? mem_wb_Mem_out : mem_wb_ALU_result;
    assign data_w = (mem_wb_call == 1) ? (mem_wb_pcaddr) : data_wb;
  
    // Hazard control
    hazardControl hazard_ctrl(.if_id_Rs(if_id_instr[11:8]), .if_id_Rt(if_id_instr[7:4]), .id_ex_RegWrite(id_ex_RegWrite), .id_ex_Rd(id_ex_Rd), .ex_mem_RegWrite(ex_mem_RegWrite), .ex_mem_Rd(ex_mem_Rd), .doJump(doJump), .pc_write_en(hc_pcwrite_en), .if_id_write_en(hc_ifid_write_en), .if_id_clean(hc_if_id_clean), .id_ex_clean(hc_id_ex_clean), .ex_mem_clean(hc_ex_mem_clean), .mem_wb_clean(hc_mem_wb_clean), .llb(llb), .lhb(lhb), .Branch(Branch), .ret(ret), .call(call), .run(run));


endmodule

