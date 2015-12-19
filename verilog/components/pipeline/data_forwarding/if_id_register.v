/*
* IF/ID Pipeline register
*/

module if_id_register(clk, write_en, clear, instr_next, pc_addr_next, instr, pc_addr);
    input clk, write_en, clear;  // clock
    input[15:0] instr_next, pc_addr_next; // the instruction feteched at next clock cycle
    output reg[15:0] instr, pc_addr; // the current instruction

    always @(posedge clk) begin
        if (clear) begin
            instr <= 16'h1000; // Set PADDSB, which does not change the flag registers
            pc_addr <= 0;
        end
        else if (write_en) begin
            instr <= instr_next;
            pc_addr <= pc_addr_next;
        end
    end

endmodule
