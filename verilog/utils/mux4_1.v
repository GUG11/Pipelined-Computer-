// Mux 4 to 1

module mux4_1(data_in, sel, data_out);
  input[3:0] data_in;
  input[1:0] sel;
  output data_out;
    
  assign data_out = data_in[sel];
endmodule