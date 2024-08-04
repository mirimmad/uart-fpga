


module uart_top(
	input clk,
	input wire uart_rx,
	output wire uart_tx,
	output wire[3:0] led
	
    );
	 
wire [7:0] data8;
wire data8_avail;
wire filter_data_avail;
reg [7:0] led_reg;
wire [7:0] filter_data; 
wire active;
wire done;

uart_rx#(.CLKS_PER_BIT(2813))  UART_RX (
	.clock (clk),
	.i_rx (uart_rx),
	.o_data_byte (data8),
	.o_data_avail(data8_avail)
	);

filter LPF (
 .clock(clk),
 .i_data_avail(data8_avail),
 .i_data_byte(data8),
 .o_data_byte(filter_data),
 .o_data_avail(filter_data_avail)
 
);


uart_tx# (.CLKS_PER_BIT(2813)) UART_TX (
	.clock(clk),
	.i_data_avail(filter_data_avail),
	.i_data_byte(filter_data),
	//.i_data_avail(data8_avail),
	//.i_data_byte(data8),
	.o_active (active),
	.o_tx (uart_tx),
	.o_done (done)
);

assign led = led_reg;

always @ (posedge clk)
begin
if (filter_data_avail)
 led_reg <= filter_data[3:0];
  
 end

endmodule
