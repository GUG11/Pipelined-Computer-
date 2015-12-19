// select in or not(in)


module sig_not_sel(a, sel, out);
  input a, sel;
  output out;
  
  wire not_a;
  
  not not_gate(not_a, a);
  assign out = (sel == 1)? not_a : a;
  
endmodule 
