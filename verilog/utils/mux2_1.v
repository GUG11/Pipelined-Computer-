// Mux 2 to 1

module mux2_1(data_in, sel, data_out);
  input[1:0] data_in;
  input sel;
  output data_out;
  
  assign data_out = data_in[sel];  
endmodule
