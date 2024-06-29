module SPI_MASTER_TB;

    // Testbench signals
    reg clk;
    reg reset;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire SCLK;
    wire MOSI;
    reg MISO;
    wire SS;
 	reg [7:0]data_slave;
    reg cpha;
    reg cpol;
  
    // Instantiate the spi_master module
    spi_master uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_out(data_out),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO),
        .SS(SS),
        .cpha(cpha),
        .cpol(cpol)
        
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period (100 MHz)
    end
  
  	initial begin
      	$dumpfile("dump.vcd");
      $dumpvars(0,Master_tb);
    end

    // Test procedure
    initial begin
        integer i;
        // Initialize signals
        reset = 1; // Assert reset
        data_in = 8'b11001100; // Example data to be sent by the master
        MISO = 0; // Initialize MISO
        data_slave = 8'b10101010;  //data received from slave
        cpol = 0;
        cpha = 0;
      
        #20;  
        reset = 0; // Deassert reset

        // Start SPI communication
        // Simulate data received from slave: 8'b10101010
        for (i=0 ; i<8 ; i=i+1)
        begin
          @(posedge SCLK);
       		 MISO <= data_slave[7-i];
        end
		// Finish simulation
        #50;
        $finish;
    end

endmodule
