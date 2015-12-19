/*
* Hazard control V2: including cache stall
* combinational logic only
* 
* EXMatch = ID/EX.RegWrite && ID/EX.Rd != 0 && (IF/ID.Rs == ID/EX.Rd) && (IF/ID.Rt ==
    * ID/EX.Rd) 
    * MEMMatch = EX/MEM.RegWrite && EX/MEM.Rd != 0 && (IF/ID.Rs == EX/MEM.Rd)
    * && (IF/ID.Rt == EX/MEM.Rd)
    *
* data forwarding condition
* if (EXMatch && !ID/EX.MemRead)
    * EX forwarding
* if (!EXMatch && MEMMatch)
    * MEM forwarding
* if (EXMatch && ID/EX.MemRead)
    * Stall
*
* Stall operation
* PCWrite = 0;
* IF/ID.Write = 0;
* clear ID/EX 
*
* Jump condition
* if jump
* Jump operation: clear IF/ID, ID/EX, EX/MEM
*
* priority: Cache miss > Jump > Stall
*/


module hazardControl(if_id_Rs, if_id_Rt, id_ex_RegWrite, id_ex_MemRead, id_ex_Rd, ex_mem_RegWrite, ex_mem_Rd, doJump, i_rdy, d_rdy, pc_write_en, if_id_write_en, id_ex_write_en, ex_mem_write_en, mem_wb_write_en, if_id_clean, id_ex_clean, ex_mem_clean, mem_wb_clean, llb, lhb, Branch, call, ret, run, forwardA, forwardB);
    input[3:0] if_id_Rs, if_id_Rt, id_ex_Rd, ex_mem_Rd;
    input id_ex_RegWrite, ex_mem_RegWrite, doJump, id_ex_MemRead;
    input llb, lhb, ret; // llb, lhb and ret use only rs so it should be handled specially.
    input Branch, call, run; // Branch call run does not have data dependence at all
    input i_rdy, d_rdy; // i-cache, d-cache ready
    output pc_write_en, if_id_write_en, id_ex_write_en, ex_mem_write_en, mem_wb_write_en, if_id_clean, id_ex_clean, ex_mem_clean, mem_wb_clean;
    output[1:0] forwardA, forwardB; // 00: no data forwarding, 01: ex data forwarding, 10: mem data forwarding. A: Rs, B: Rt

    wire stall /*only stall IF/ID */, stall_all/*stall all the five stages*/, clear; 
    wire ex_matchA, ex_matchB, mem_matchA, mem_matchB;
    wire rsOnly;
    wire nonDpd;

    assign rsOnly = llb | lhb | ret;
    assign nonDpd = Branch | call | ~run;

    // data hazard control
    assign ex_matchA = (id_ex_RegWrite === 1'b1) && (id_ex_Rd !== 0) && (if_id_Rs === id_ex_Rd);
    assign ex_matchB = (rsOnly === 1'b0) & (id_ex_RegWrite === 1'b1) && (id_ex_Rd !== 0) && (if_id_Rt === id_ex_Rd);
    assign mem_matchA = (ex_mem_RegWrite === 1'b1) && (ex_mem_Rd !== 0) && (if_id_Rs === ex_mem_Rd); 
    assign mem_matchB = (rsOnly === 1'b0) & (ex_mem_RegWrite === 1'b1) && (ex_mem_Rd !== 0) && (if_id_Rt === ex_mem_Rd);
    assign forwardA[0] = (ex_matchA === 1'b1) & (id_ex_MemRead !== 1'b1);
    assign forwardA[1] = (mem_matchA === 1'b1) & (ex_matchA !== 1'b1);
    assign forwardB[0] = (ex_matchB === 1'b1) & (id_ex_MemRead !== 1'b1);
    assign forwardB[1] = (mem_matchB === 1'b1) & (ex_matchB !== 1'b1);
    assign stall = (ex_matchA === 1'b1 || ex_matchB === 1'b1) & (id_ex_MemRead === 1'b1) & (clear !== 1'b1) & (stall_all !== 1'b1); // sometimes clear and stall are both 1, this happens at 0011(MEM) phase. However, the stall is invalid as the IF,ID,EX should be flushed.
    assign stall_all = (~(i_rdy & d_rdy)); // What if jump in MEM phase and I-cache miss concurrently happen?
    // control hazard
    assign clear = doJump & (stall_all !== 1);
    
    assign pc_write_en = ~stall_all & ~stall;
    assign if_id_write_en = ~stall_all & ~stall;
    assign id_ex_write_en = ~stall_all;
    assign ex_mem_write_en = ~stall_all;
    assign mem_wb_write_en = ~stall_all;
    assign if_id_clean = clear;
    assign id_ex_clean = clear | stall;
    assign ex_mem_clean = clear;
    //assign mem_wb_clean = clear; // Do not clear, even Branch in WB phase is useless, it won't write the register

endmodule


