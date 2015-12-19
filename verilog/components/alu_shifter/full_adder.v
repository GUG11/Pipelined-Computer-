// one bit full adder

module full_adder(a,b,c_in,sum,c_out);
  input a,b,c_in;
  output sum,c_out;
  
  assign {c_out, sum} = a + b + c_in;
  
endmodule