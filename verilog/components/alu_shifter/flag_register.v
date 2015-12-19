/*
* Flag register
* Store V(Overflow), N(Nagetive), Z(Zero)
*
* SUB, ADD can change V,N,Z
* AND, XOR, SLL, SRL, SRA can change Z
* The others can change nothing
*
    * Let the change happen in the low-level clock in order to allow for
    * instruction and flag preparation
*/

module flag_register(clk, change_en_Z, change_en_VN, Vin, Nin, Zin, V, N, Z);
    input change_en_Z, change_en_VN;
    input clk, Vin, Nin, Zin;
    output reg V, N, Z;

    always @(clk, Z, change_en_Z) begin
        if(~clk & change_en_Z) begin
           Z <= Zin;
       end
    end

    always @(clk, V, N, change_en_VN) begin
        if(~clk & change_en_VN) begin
          V <= Vin;
          N <= Nin;
        end
    end

endmodule 

