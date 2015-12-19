/*
* MEM/WB register
*/

module mem_wb_register(clk, write_en, clear, RegDst_next, MemtoReg_next, RegWrite_next, run_next, call_next, Rd_next, pc_addr_next, ALU_result_next, Mem_out_next, RegDst, MemtoReg, RegWrite, run, call, Rd, pc_addr, ALU_result, Mem_out);
    input clk, write_en, clear;
    input[1:0] RegDst_next;
    input MemtoReg_next, RegWrite_next, run_next, call_next;
    input[15:0] pc_addr_next/*for CALL*/, ALU_result_next, Mem_out_next;
    input[3:0] Rd_next;
    output reg[1:0] RegDst;
    output reg MemtoReg, RegWrite, run, call;
    output reg[15:0] pc_addr, ALU_result, Mem_out;
    output reg[3:0] Rd;

    always @(posedge clk) begin
        if (clear) begin
            RegDst <= 0;
            MemtoReg <= 0;
            RegWrite <= 0;
            run <= 1;
            call <= 0;
            pc_addr <= 0;
            ALU_result <= 0;
            Mem_out <= 0;
            Rd <= 0;
        end
        else if (write_en) begin
            RegDst <= RegDst_next;
            MemtoReg <= MemtoReg_next;
            RegWrite <= RegWrite_next;
            run <= run_next;
            pc_addr <= pc_addr_next;
            ALU_result <= ALU_result_next;
            Mem_out <= Mem_out_next;
            Rd <= Rd_next;
            call <= call_next;
        end
    end
endmodule

