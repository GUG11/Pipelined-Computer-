/*
* ID/EX register 
*/

module id_ex_register(clk, write_en, clear, RegDst_next, ALUSrc_next, ShfOp_next, MemRead_next, MemWrite_next, MemtoReg_next, RegWrite_next, Branch_next, ALUOp_next, run_next, call_next, llb_next, lhb_next, as_next, ret_next, Rd_next, BranchType_next, Address_next, pc_addr_next, data_r0_next, data_r1_next, data_r2_next, change_en_Z_next, change_en_VN_next, forwardA_next, forwardB_next, RegDst, ALUSrc, ShfOp, MemRead, MemWrite, MemtoReg, RegWrite, Branch, ALUOp, run, call, llb, lhb, as, ret, Rd, BranchType, Address, pc_addr, data_r0, data_r1, data_r2, change_en_Z, change_en_VN, forwardA, forwardB);
    input clk, write_en, clear; // clock
    // Control signals
    // For EX phase
    input llb_next, lhb_next, as_next;
    input[1:0] ALUSrc_next, ShfOp_next;
    input[2:0] ALUOp_next;
    output reg llb, lhb, as;
    output reg[1:0] ALUSrc, ShfOp;
    output reg[2:0] ALUOp;

    input change_en_Z_next, change_en_VN_next;
    output reg change_en_Z, change_en_VN;
    // For MEM Phase
    input MemRead_next, MemWrite_next, Branch_next, call_next, ret_next;
    input[2:0] BranchType_next;
    output reg MemRead, MemWrite, Branch, call, ret;
    output reg [2:0] BranchType;
    // For WB Phase
    input[1:0] RegDst_next;
    input MemtoReg_next, RegWrite_next, run_next;
    output reg[1:0] RegDst;
    output reg MemtoReg, RegWrite, run;

    // Data
    input[11:0] Address_next; // 12 bits, [11:0] for call, [7:0] for LLB/LHB, [3:0] for SW/LW and shift
    output reg[11:0] Address;
    inout[3:0] Rd_next;
    output reg[3:0] Rd;
    input[15:0] pc_addr_next;
    output reg[15:0] pc_addr;
    input[15:0] data_r0_next, data_r1_next, data_r2_next;
    output reg[15:0] data_r0, data_r1, data_r2;

    // Data forwarding
    input[1:0] forwardA_next, forwardB_next;
    output reg[1:0] forwardA, forwardB;

    always @(posedge clk) begin
        if (clear) begin
            llb <= 0;
            lhb <= 0;
            as <= 0;
            ALUSrc <= 0;
            ShfOp <= 0;
            ALUOp <= 3'd1; // set PADDSB, which does not change the flag register.

            MemRead <= 0;
            MemWrite <= 0;
            Branch <= 0;
            call <= 0;
            ret <= 0;
            BranchType <= 0;

            RegDst <= 0;
            MemtoReg <= 0;
            RegWrite <= 0;
            run <= 1; // cannot be cleared. Only HLT can set run 0
            
            Address <= 0;
            Rd <= 0;
            pc_addr <= 0;
            data_r0 <= 0;
            data_r1 <= 0;
            data_r2 <= 0;
            change_en_Z <= 0;
            change_en_VN <= 0;
            forwardA <= 2'd0;
            forwardB <= 2'd0;
        end
        else if (write_en) begin
            llb <= llb_next;
            lhb <= lhb_next;
            as <= as_next;
            ALUSrc <= ALUSrc_next;
            ShfOp <= ShfOp_next;
            ALUOp <= ALUOp_next;

            MemRead <= MemRead_next;
            MemWrite <= MemWrite_next;
            Branch <= Branch_next;
            call <= call_next;
            ret <= ret_next;
            BranchType <= BranchType_next;

            RegDst <= RegDst_next;
            MemtoReg <= MemtoReg_next;
            RegWrite <= RegWrite_next;
            run <= run_next;
    
            Address <= Address_next;
            Rd <= Rd_next;

            pc_addr <= pc_addr_next;
            data_r0 <= data_r0_next;
            data_r1 <= data_r1_next;
            data_r2 <= data_r2_next;

            change_en_Z <= change_en_Z_next;
            change_en_VN <= change_en_VN_next;
            forwardA <= forwardA_next;
            forwardB <= forwardB_next; 
        end
    end
endmodule
