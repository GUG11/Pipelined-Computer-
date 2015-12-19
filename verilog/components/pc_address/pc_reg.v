/* PC Register 16 bits */

module pc_reg(pc_next, pc_curr, clk, en);
  input[15:0] pc_next; // the address of next instruction
  input clk/*clock*/, en/*enable*/;
  output reg[15:0] pc_curr; // the address of current instruction
  
  always @(posedge clk) begin
    if (en == 1)
      pc_curr <= pc_next;
  end
  
endmodule