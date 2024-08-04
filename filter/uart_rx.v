
module uart_rx #(parameter CLKS_PER_BIT = 2813)
                (input clock,
                 input i_rx,
                 output [7:0] o_data_byte,
                 output o_data_avail);
    
    localparam IDLE_STATE    = 2'b00;
    localparam START_STATE   = 2'b01;
    localparam GET_BIT_STATE = 2'b10;
    localparam STOP_STATE    = 2'b11;
    
    reg rx_buffer = 1'b1;
    reg rx        = 1'b1;
    
    reg [1:0] state     = 0;
    reg [15:0] counter  = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] data_byte = 0;
    reg data_avail      = 0;
    
    assign o_data_avail = data_avail;
    assign o_data_byte  = data_byte;
    
    always @(posedge clock)
    begin
        rx_buffer <= i_rx;
        rx        <= rx_buffer;
    end
    
    always @(posedge clock)
    begin
        case (state)
            IDLE_STATE:
            begin
                data_avail <= 0;
                counter    <= 0;
                bit_index  <= 0;
                if (rx == 0) // start bit detected
                    state <= START_STATE;
                else
                    state <= IDLE_STATE;
            end
            
            START_STATE:
            begin
                if (counter == (CLKS_PER_BIT - 1) / 2)
                begin
                    if (rx == 0) // still low?
                    begin
                        counter <= 0;
                        state   <= GET_BIT_STATE;
                    end
                    else
                    begin
                        state <= IDLE_STATE;
                    end
                end
                else
                begin
                    counter <= counter + 16'b1;
                    state   <= START_STATE;
                end
            end
            
            GET_BIT_STATE:
            begin
                if (counter < CLKS_PER_BIT - 1)
                begin
                    counter <= counter + 16'b1;
                    state   <= GET_BIT_STATE;
                end
                else
                begin
                    counter              <= 0;
                    data_byte[bit_index] <= rx;
                    if (bit_index < 7)
                    begin
                        bit_index <= bit_index + 3'b1;
                        state     <= GET_BIT_STATE;
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
                if (counter < CLKS_PER_BIT - 1)
                begin
                    counter <= counter + 16'b1;
                    state   <= STOP_STATE;
                end
                else
                begin
                    data_avail <= 1;
                    counter    <= 0;
                    state      <= IDLE_STATE;
                end
            end
            
            default:
            state <= IDLE_STATE;
            
            
            
            
        endcase
    end
    
endmodule
