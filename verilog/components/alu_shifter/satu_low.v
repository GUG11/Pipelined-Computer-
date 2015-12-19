// saturation block for low 8 bits

//`include "../../utils/mux2_1.v"

module satu_low(MSB, V, fi, s1, arith_out);
  input[1:0] MSB, V; // {f7,f15} ,{V_l, V_h}
  input fi, s1/*paddsb sig*/;
  output arith_out;
  
  wire msb_sel, v_sel; // selected MSB and V
  
  assign msb_sel = MSB[s1];
  assign v_sel = V[s1];
  assign arith_out = (v_sel == 1) ? msb_sel : fi;
  /*
  mux2_1 mux_f(.data_in(MSB), .sel(s1), .data_out(msb_sel));
  mux2_1 mux_v(.data_in(V), .sel(s1), .data_out(v_sel));
  mux2_1 mux_ovfl(.data_in({msb_sel, fi}), .sel(v_sel), .data_out(arith_out));
  */
endmodule 
