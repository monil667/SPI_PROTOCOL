module spi_master (
    input wire clk,       // System clock
    input wire reset,     // System reset
    input wire [7:0] data_in, // Data to be sent
    output reg [7:0] data_out, // Data received
    output reg SCLK,      // SPI clock
    output reg MOSI,      // Master Out Slave In
    input wire MISO,      // Master In Slave Out
    output reg SS,         // Slave Select
    input cpha,
    input cpol
);

reg [3:0] bit_cnt; // Bit counter
reg [7:0] shift_reg; // Shift register for data
  
always @(posedge clk or posedge reset) 
begin
    if (reset)
    begin
        bit_cnt <= 4'b0000;
        shift_reg <= data_in;
        SCLK <= 0;
        SS <= 1;
        MOSI <= 0;
        data_out <= 8'b00;
    end 
    else 
    begin
        SS <= 0;
        SCLK <= ~SCLK;
    end
end

always @(posedge SCLK) 
begin
        MOSI <= data_in[7 - bit_cnt];
        shift_reg <= {shift_reg[6:0], MISO};
        bit_cnt <= bit_cnt + 1; 
   
   
    if( bit_cnt == 9) 
    begin
          data_out <= shift_reg;
          SS <= 1;
          bit_cnt <= 3'b000; // Reset the counter
          shift_reg <= 8'b00000000; // Clear the shift register
    end
end

endmodule
