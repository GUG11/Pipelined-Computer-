/* a shifter. Input 16 bits, shift 4 bits
  shift A by shf bits
  signal control table
  instr  s0  s1
  SLL    1   0
  SRL    0   1
  SRA    1   1  */
  

module shifter16_4(A, shf, sigs, B);
  input[15:0] A;
  input[3:0] shf;
  input[1:0] sigs;
  output[15:0] B;

  wire[15:0] sll, srl, sra;
  assign sll = A << shf;
  assign srl = A >> shf;
  assign sra = $signed(A) >>> shf; 
  assign B = (sigs == 2'b01) ? sll : ((sigs == 2'b10) ? srl : sra);
  
  
endmodule 
