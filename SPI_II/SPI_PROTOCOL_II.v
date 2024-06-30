// Code your design here
module spi_master 
 (
    input wire clk,           // System clock
    input wire rst_n,         // Active-low reset
    input wire [7:0] data_in, // Data to be transmitted
    input wire start,         // Start signal
    output reg [7:0] data_out,// Received data
    output reg spi_clk,       // SPI clock
    output reg mosi,          // Master Out Slave In
    input wire miso,          // Master In Slave Out
    output reg cs_n,          // Chip Select, active low
   	output reg rec_led,       // LED indicating full data is received  
    input wire cpol,          // Clock polarity
    input wire cpha           // Clock phase
);

    // Parameters
    parameter DIVIDER = 4;    // System Clock divider
    parameter IDLE = 2'b00, SEND = 2'b01, RECEIVE = 2'b10, DONE = 2'b11;  //States to perform task of SPI

  
// Internal signals
    reg [1:0] state;
    reg [7:0] shift_reg;
    reg [3:0] bit_counter;
    reg [2:0] clk_counter; 
  
// Clock generation logic
    always @(posedge clk or negedge rst_n) 
    begin
        if (!rst_n) 
        begin
            clk_counter <= 0;
            spi_clk <= cpol;
        end 
      	else if (clk_counter == (DIVIDER - 1)) 
        begin
            spi_clk <= (cpol == 1) ? spi_clk : ~spi_clk;
            clk_counter <= 0;
        end
        else
      	begin
            clk_counter <= clk_counter + 1;
      	end
    end
  
// State machine logic
    always @(posedge clk or negedge rst_n) 
    begin
       if (!rst_n)
       begin
            shift_reg <= data_in;
            bit_counter <= 0;
            cs_n <= 1;
            mosi <= 0;
            data_out <= 0;
            state <= IDLE;
            rec_led <= 1'b0;
       end
      
       else
       begin   
       case (state)
            
      		IDLE: 
            begin
                  if (start)
                  begin
                    cs_n <= 0;
                    state = SEND;
                  end
                  else 
                    state = IDLE;
            end

            SEND: 
            begin
              if (bit_counter == 9) 
                    state = RECEIVE;
                else 
                    state = SEND;
            end

            RECEIVE: 
            begin
               rec_led <= 1'b1; 
              if(bit_counter == 9 && clk_counter == 1) 
            begin
                data_out <= shift_reg;
               
           // else if (bit_counter == 9) 
                state = DONE;
            end
              
            else 
                 state = RECEIVE;
            
            end

            DONE:
            begin
                rec_led <= 1'b0;
                cs_n <= 1;
                state = IDLE;
            end
          
            default:
                state = IDLE;
         
        endcase
       end
    end

  //task done in send state
  //logic for getting mosi signal (shifting left bit by bit)
    always @(posedge spi_clk) 
    begin
       mosi <= shift_reg[7];
       shift_reg <= {shift_reg[6:0], miso};
       bit_counter <= bit_counter + 1;
    end

endmodule