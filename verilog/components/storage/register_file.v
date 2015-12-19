// register files 16 16-bit registers

// if the read and write operates concurrently on the same register.
// both the readout and the register will be assign data_w

module register_file(clk, addr_r1, addr_r2, addr_w, 
  write_en, data_w, data_r1, data_r2, data_r0, dr0, dr1, dr2, dr3, dr4, dr5, dr6, dr7, dr8, dr9,dr10, dr11, dr12, dr13, dr14, dr15);
  input[15:0] data_w;
  input[3:0] addr_r1, addr_r2, addr_w;
  input write_en, clk;
  output[15:0] data_r1, data_r2, data_r0;

  output[15:0] dr0, dr1, dr2, dr3, dr4, dr5, dr6, dr7, dr8, dr9, dr10, dr11, dr12, dr13, dr14, dr15; // output the data of registers used in the program, for debug and test only
  
  reg[15:0] registers[15:0];
  
  initial begin 
    registers[0] = 16'd0;
    /*$dumpfile("registers.vcd");
    $dumpvars(0, register_file);*/
  end

  assign data_r0 = registers[0];
  assign data_r1 = registers[addr_r1];
  assign data_r2 = registers[addr_r2];   
   
  always @(data_w,addr_w,clk) begin
    if (write_en && 0 < addr_w && ~clk) begin // why ~clk? the instr.mem fetched at the posedge, so write the register at the next negaedge to allow half a cycle for the op to be decoded and ready. Otherwise the op of the last instruction will influence the current parameters.
      registers[addr_w] = data_w;
    end
  end

  assign dr0 = registers[0];
  assign dr1 = registers[1];
  assign dr2 = registers[2];
  assign dr3 = registers[3];
  assign dr4 = registers[4];
  assign dr5 = registers[5];
  assign dr6 = registers[6];
  assign dr7 = registers[7];
  assign dr8 = registers[8];
  assign dr9 = registers[9];
  assign dr10 = registers[10];
  assign dr11 = registers[11];
  assign dr12 = registers[12];
  assign dr13 = registers[13];
  assign dr14 = registers[14]; 
  assign dr15 = registers[15];

endmodule
      
  
