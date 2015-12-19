// cachae controller: an FSM
module cache_controller(clk, rst_n, we, re, dhit, dirty, ihit, memrdy, drdy, irdy, mem_re, mem_we, icache_we, dcache_we, addr_instr, addr_data, itag_out, dtag_out, iaddr, daddr, di_active);
input clk, rst_n, we, re; // from pipeline
input dhit, dirty, ihit; // from cache
input memrdy;  // from memory

// address
input[13:0] addr_instr, addr_data;
input[7:0] itag_out, dtag_out;
output reg[13:0] iaddr, daddr;

output drdy, irdy;
output reg mem_re, mem_we; // to memory
output reg icache_we, dcache_we; // to cache
output reg di_active; // 0: I-cache active, 1: D-cache active


reg[1:0] state, next_state;

assign drdy = ~((re===1 || we===1) && dhit===0);
assign irdy = ihit;


always @(posedge clk, negedge rst_n)
    if (!rst_n)
        state <= IDLE;
    else 
        state <= next_state;

// Define states of FSM
localparam IDLE = 2'b00;
localparam EVICT = 2'b01;

localparam DATA_RD = 2'b10;
localparam INSTR_RD = 2'b11;

always @(state, we, re, dhit, dirty, ihit, memrdy, addr_instr, addr_data)
begin
    case (state)
        IDLE:
        begin
            iaddr = addr_instr; daddr = addr_data;
            if(((re!==1 && we!==1) || dhit!==0) && ihit!==0) begin // output
            mem_re = 0; mem_we = 0;
            icache_we = 0; dcache_we = we; // stay in IDLE
            end else if ((re===1||we===1) && dhit===0 && dirty===1) begin 
            next_state = EVICT;
            mem_re = 0; mem_we = 0;
            icache_we = 0; dcache_we = 0; 
            end else if ((re===1||we===1) && dhit===0 && dirty!==1) begin 
            next_state = DATA_RD;
            mem_re = 0; mem_we = 0;
            icache_we = 0; dcache_we = 0;
            end else if ((!(re===1||we===1) || dhit!==0) && ihit===0) begin
            next_state = INSTR_RD;
            mem_re = 0; mem_we = 0;
            icache_we = 0; dcache_we = 0;
            end
        end

        EVICT: begin // output
                mem_we = 1; mem_re = 0;
                dcache_we = 0; icache_we = 0;
                daddr = {dtag_out[7:0], addr_data[5:0]};
                di_active = 1;
                if (memrdy===1) begin // to DATA_RD
                    next_state = DATA_RD;
                end else begin
                    next_state = EVICT;
                end
            end

        DATA_RD: begin // output
                mem_we = 0; mem_re = 1;
                icache_we = 0;
                daddr = addr_data;
                di_active = 1;
                if (memrdy===1 && ihit!==0) begin 
                    next_state = IDLE;
                    dcache_we = 1;
                end else if (memrdy===1 && ihit===0) begin
                    next_state = INSTR_RD;
                    dcache_we = 1;
                end else begin
                    next_state = DATA_RD;
                    dcache_we = 0;
                end 
            end

        INSTR_RD: begin // output
                mem_we = 0; mem_re = 1;
                iaddr = addr_instr;
                dcache_we = 0;
                di_active = 0;
                if (memrdy===1) begin
                    next_state = IDLE;
                    icache_we = 1; // only write cache when memrdy
                end else begin
                    next_state = INSTR_RD;
                    icache_we = 0;
                end// else stay in INSTR_RD
        end
    endcase
end 
endmodule
         
