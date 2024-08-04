
module filter (input wire clock,
               input wire i_data_avail,
               input wire [7:0] i_data_byte,
               output reg [7:0] o_data_byte,
               output reg o_data_avail);
    
    // Number of taps (50 in this case)
    parameter N = 50;
    
    // Internal registers for the filter
    reg [7:0] shift_reg [0:N-1];  // Shift register to hold the last N samples
    reg [15:0] sum;               // Accumulated sum, 16-bit to handle overflow
    integer i;
    
    // Initialize shift registers and output
    initial begin
        sum             = 16'd0;
        // o_data_avail = 1'b0;
        o_data_byte     = 8'd0;
        for (i = 0; i < N; i = i + 1) begin
            shift_reg[i] = 8'd0;
        end
    end
    
    always @(posedge clock) begin
        if (i_data_avail) begin
            // Update sum by subtracting the oldest value and adding the new value
            sum = sum - shift_reg[N-1] + i_data_byte;
            
            // Shift all values in the shift register
            for (i = N-1; i > 0; i = i - 1) begin
                shift_reg[i] <= shift_reg[i-1];
            end
            
            
            shift_reg[0] <= i_data_byte;
            
            // total sum / no. of taps
            o_data_byte <= sum / N;
            
            
            o_data_avail <= 1'b1;
            end else begin
            
            o_data_avail <= 1'b0;
        end
    end
    
endmodule
