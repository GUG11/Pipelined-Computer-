// The memeory hierarchy: 
// I-cache + D-cache + uniform memory
//

module mem_hierarchy(clk, rst_n, i_addr, instr, i_rdy, d_addr, wrt_data, rd_data, re, we, d_rdy);
input clk, rst_n;
// Instruction
input[15:0] i_addr;
output[15:0] instr;
output i_rdy;
// Data
input re, we;
input[15:0] d_addr, wrt_data;
output[15:0] rd_data;
output d_rdy;

wire[13:0] i_addr_ctrl, d_addr_ctrl;
wire icache_we, dcache_we, icache_re, dcache_re;
wire dirty, ihit, dhit;
wire di_active; // 0: I-cache interacts with main mem, 1: D-cache interacts with main mem
wire[7:0] i_tag_out, d_tag_out;

// cache data readout
wire[63:0] i_data_out, d_data_out, d_data_wrt0, d_data_wrt1, d_data_wrt2, d_data_wrt3, d_data_wrt, d_data_in;

// memory 
wire[13:0] mem_addr;
wire[63:0] mem_wdata, mem_rdata;
wire memrdy, mem_we, mem_re;

// cache
assign instr = (i_addr[1:0] == 2'd0) ? i_data_out[15:0] : ( (i_addr[1:0] == 2'd1) ? i_data_out[31:16] : ( (i_addr[1:0] == 2'd2) ? i_data_out[47:32] : i_data_out[63:48]));
assign rd_data = (d_addr[1:0] == 2'd0) ? d_data_out[15:0] : ( (d_addr[1:0] == 2'd1) ? d_data_out[31:16] : ( (d_addr[1:0] == 2'd2) ? d_data_out[47:32] : d_data_out[63:48]));

assign d_data_wrt0 = {d_data_out[63:16],wrt_data};
assign d_data_wrt1 = {d_data_out[63:32],wrt_data,d_data_out[15:0]};
assign d_data_wrt2 = {d_data_out[63:48],wrt_data,d_data_out[31:0]};
assign d_data_wrt3 = {wrt_data, d_data_out[47:0]};

assign d_data_wrt = (d_addr[1:0] == 2'd0) ? d_data_wrt0 : ( (d_addr[1:0] == 2'd1) ? d_data_wrt1 : ((d_addr[1:0] == 2'd2) ? d_data_wrt2 : d_data_wrt3));
assign d_data_in = (d_rdy == 1) ? d_data_wrt : mem_rdata;

assign icache_re = 1'b1; 
assign dcache_re = 1'b1;

cache icache(.clk(clk), .rst_n(rst_n), .addr(i_addr_ctrl), .wr_data(mem_rdata), .wdirty(1'b0), .we(icache_we), .re(icache_re), .rd_data(i_data_out), .tag_out(i_tag_out), .hit(ihit));
cache dcache(.clk(clk), .rst_n(rst_n), .addr(d_addr_ctrl), .wr_data(d_data_in), .wdirty(dcache_we), .we(dcache_we), .re(dcache_re), .rd_data(d_data_out), .tag_out(d_tag_out), .hit(dhit), .dirty(dirty));

// memory
assign mem_addr = (di_active == 1) ? d_addr_ctrl : i_addr_ctrl;
assign mem_wdata = d_data_out;

unified_mem main_mem(.clk(clk), .rst_n(rst_n), .addr(mem_addr), .re(mem_re), .we(mem_we), .wdata(mem_wdata), .rd_data(mem_rdata), .rdy(memrdy));

// controller
cache_controller cache_ctrl(.clk(clk), .rst_n(rst_n), .we(we), .re(re), .dhit(dhit), .dirty(dirty), .ihit(ihit), .memrdy(memrdy), .drdy(d_rdy), .irdy(i_rdy), .mem_re(mem_re), .mem_we(mem_we), .icache_we(icache_we), .dcache_we(dcache_we), .addr_instr(i_addr[15:2]), .addr_data(d_addr[15:2]), .itag_out(i_tag_out), .dtag_out(d_tag_out), .iaddr(i_addr_ctrl), .daddr(d_addr_ctrl), .di_active(di_active));

endmodule
