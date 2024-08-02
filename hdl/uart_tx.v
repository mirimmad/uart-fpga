

module uart_tx #(parameter CLKS_PER_BIT = 2813)
                (input clock,
                 input i_data_avail,
                 input [7:0] i_data_byte,
                 output reg o_active,
                 output reg o_tx,
                 output reg o_done);
    
    localparam IDLE_STATE     = 2'b00;
    localparam START_STATE    = 2'b01;
    localparam SEND_BIT_STATE = 2'b10;
    localparam STOP_STATE     = 2'b11;
    
    reg [1:0] state     = 0;
    reg [15:0] counter  = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] data_byte = 0;
	 reg tx;
	 
	 
    
    always @(posedge clock)
    begin
        case(state)
            IDLE_STATE:
            begin
                o_tx      <= 1;
                o_done    <= 0;
                counter   <= 0;
                bit_index <= 0;
                if (i_data_avail == 1)
                begin
                    o_active  <= 1;
                    data_byte <= i_data_byte;
                    state     <= START_STATE;
                end
                else
                begin
                    state    <= IDLE_STATE;
                    o_active <= 0;
                end
            end
            
            START_STATE:
            begin
                o_tx <= 0;
                if (counter < CLKS_PER_BIT - 1)
                begin
                    counter <= counter + 16'b1;
                    state   <= START_STATE;
                end
                else
                begin
                    counter <= 0;
                    state   <= SEND_BIT_STATE;
                end
            end
            
            SEND_BIT_STATE:
            begin
                o_tx <= data_byte[bit_index];
                if (counter < CLKS_PER_BIT - 1)
                begin
                    counter <= counter + 16'b1;
                    state   <= SEND_BIT_STATE;
                end
                else
                begin
                    counter <= 0;
                    if (bit_index < 7)
                    begin
                        bit_index <= bit_index + 3'b1;
                        state     <= SEND_BIT_STATE;
                    end
                    else
                    begin
                        bit_index <= 0;
                        state     <= STOP_STATE;
                    end
                end
                
            end
            
            STOP_STATE:
            begin
                o_tx <= 1;
                if (counter < CLKS_PER_BIT - 1)
                begin
                    counter <= counter + 16'b1;
                    state   <= STOP_STATE;
                end
                else
                begin
                    o_done   <= 1;
                    state    <= IDLE_STATE;
                    o_active <= 0;
                end
            end
				
            default: state <= IDLE_STATE;
            
            
            
            
        endcase
    end
    
    
endmodule
