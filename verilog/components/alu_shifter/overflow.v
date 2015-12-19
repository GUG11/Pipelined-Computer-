// overflow block

module overflow(a,b,f,v);
  input a,b,f;
  output v;
  
  assign v = (a & b & ~f) | (~a & ~b & f);
  
endmodule 