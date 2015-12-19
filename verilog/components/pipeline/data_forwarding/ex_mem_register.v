/*
* EX/MEM Register
*/

module ex_mem_register(clk, write_en, clear, RegDst_next, MemRead_next, MemWrite_next, MemtoReg_next, RegWrite_next, Branch_next, BranchType_next, run_next, call_next, ret_next, Rd_next, Address_next, retAddr_next, pc_addr_next, V_next, Z_next, N_next, ALU_result_next, data_r2_next, RegDst, MemRead, MemWrite, MemtoReg, RegWrite, Branch, BranchType, Address,retAddr, pc_addr, V, N, Z, Rd, run, call, ret, ALU_result, data_r2);
    input clk, write_en, clear;
    // Control signals
    // For MEM phase
    input MemWrite_next, MemRead_next;
    output reg MemWrite, MemRead;
    // For address calculation (in MEM phase)
    input Branch_next, call_next, ret_next;
    output reg Branch, call, ret;
    input[2:0] BranchType_next;
    output reg[2:0] BranchType;
    input[11:0] Address_next;
    output reg[11:0] Address;
    input[15:0] retAddr_next, pc_addr_next;
    output reg[15:0] retAddr, pc_addr;
    input V_next, Z_next, N_next;
    output reg V,Z,N;
    // For WB phase
    input[1:0] RegDst_next;
    input MemtoReg_next, RegWrite_next, run_next;
    output reg[1:0] RegDst;
    output reg MemtoReg, RegWrite, run;

    // Data
    input[3:0] Rd_next;
    output reg[3:0] Rd;
    input[15:0] ALU_result_next, data_r2_next/*the Rt of SW*/;
    output reg[15:0] ALU_result, data_r2;
    

    always @(posedge clk) begin
        if (clear) begin
            MemWrite <= 0;
            MemRead <= 0;
       
            Branch <= 0;
            BranchType <= 0;
            call <= 0;
            ret <= 0;
            Address <= 0;
            retAddr <= 0;
            pc_addr <= 0;
        
            MemtoReg <= 0;
            RegWrite <= 0;
            run <= 1;
            RegDst <= 0;

            Rd <= 0;
            ALU_result <= 0;
            data_r2 <= 0;
        end      
        else if (write_en) begin
            MemWrite <= MemWrite_next;
            MemRead <= MemRead_next;
       
            Branch <= Branch_next;
            BranchType <= BranchType_next;
            call <= call_next;
            ret <= ret_next;
            Address <= Address_next;
            retAddr <= retAddr_next;
            pc_addr <= pc_addr_next;
            V <= V_next;
            Z <= Z_next;
            N <= N_next;
        
            MemtoReg <= MemtoReg_next;
            RegWrite <= RegWrite_next;
            run <= run_next;
            RegDst <= RegDst_next;

            Rd <= Rd_next;
            ALU_result <= ALU_result_next;
            data_r2 <= data_r2_next;
        end
    end

endmodule    
    
