/*
* Hazard control
* combinational logic only
*
* Stall condition
* if (ID/EX.RegWrite &&
* ID/EX.Rd != 0 && (IF/ID.Rs == ID/EX.Rd) && (IF/ID.Rt == ID/EX.Rd))
* || (EX/MEM.RegWrite && ID/EX.Rd != 0 && (IF/ID.Rs == EX/MEM.Rd) && (IF/ID.Rt == EX/MEM.Rd))
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
*/


module hazardControl(if_id_Rs, if_id_Rt, id_ex_RegWrite, id_ex_Rd, ex_mem_RegWrite, ex_mem_Rd, doJump, stall, clear, pc_write_en, if_id_write_en, if_id_clean, id_ex_clean, ex_mem_clean, mem_wb_clean, llb, lhb, Branch, call, ret, run);
    input[3:0] if_id_Rs, if_id_Rt, id_ex_Rd, ex_mem_Rd;
    input id_ex_RegWrite, ex_mem_RegWrite, doJump;
    input llb, lhb, ret; // llb, lhb and ret use only rs so it should be handled specially.
    input Branch, call, run; // Branch call run does not have data dependence at all
    output stall, clear, pc_write_en, if_id_write_en, if_id_clean, id_ex_clean, ex_mem_clean, mem_wb_clean;

    wire ex_match, mem_match;
    wire rsOnly;
    wire nonDpd;

    assign rsOnly = llb | lhb | ret;
    assign nonDpd = Branch | call | ~run;

    // data hazard control
    assign ex_match = (((rsOnly === 1'b0) && id_ex_RegWrite && (id_ex_Rd != 0) && ((if_id_Rs == id_ex_Rd) || (if_id_Rt == id_ex_Rd))) || ((rsOnly === 1'b1) && id_ex_RegWrite && (id_ex_Rd != 0) &&(if_id_Rs == id_ex_Rd))) & (nonDpd !== 1'b1);
    assign mem_match = (((rsOnly === 1'b0) && ex_mem_RegWrite && (ex_mem_Rd != 0) && ((if_id_Rs == ex_mem_Rd) || (if_id_Rt == ex_mem_Rd))) || ((rsOnly === 1'b1) && ex_mem_RegWrite && (ex_mem_Rd != 0) && (if_id_Rs == ex_mem_Rd))) & (nonDpd !== 1'b1);
    assign stall = (ex_match | mem_match) & (clear !== 1'b1); // sometimes clear and stall are both 1, this happens at 0011(MEM) phase. However, the stall is invalid as the IF,ID,EX should be flushed.

    // control hazard
    assign clear = doJump;

    assign pc_write_en = ~stall;
    assign if_id_write_en = ~stall;
    assign if_id_clean = clear;
    assign id_ex_clean = clear | stall;
    assign ex_mem_clean = clear;
    //assign mem_wb_clean = clear; // Do not clear, even Branch in WB phase is useless, it won't write the register

endmodule


