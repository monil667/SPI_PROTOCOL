module tb_spi_master;

    // Test bench signals
    reg clk;
    reg rst_n;
    reg [7:0] data_in;
    reg start;
    wire [7:0] data_out;
    wire spi_clk;
    wire mosi;
    reg miso;
    wire cs_n;
    reg cpol;
    reg cpha;

    // Instantiate the SPI master module
    spi_master uut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .start(start),
        .data_out(data_out),
        .spi_clk(spi_clk),
        .mosi(mosi),
        .miso(miso),
        .cs_n(cs_n),
        .cpol(cpol),
        .cpha(cpha)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Task to perform an SPI transaction
    task perform_spi_transaction(input [7:0] send_data, input [7:0] expected_data);
        integer i;
        begin
            data_in = send_data;
            start = 1;
            #10 start = 0;

            // Provide MISO data and monitor SPI_CLK
            for (i = 0; i < 8; i = i + 1)
            begin
              @(posedge spi_clk); 
              miso <= expected_data [7-i]; 
            //    @(posedge spi_clk); // Data is sampled on rising edge
            end

            // Wait for the transaction to complete
            #40; // Adjust as needed based on the clock divider and bit timing
        end
    endtask

    // Test stimulus
    initial begin
        // Initialize signals
        rst_n = 0;
        data_in = 8'hA5; // Example data to transmit
        start = 0;
        miso = 0;
        cpol = 0;
        cpha = 0;

        // Initialize the dump file for waveform viewing
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_spi_master);
      
        // Reset the system
        #20;
        rst_n = 1;

        // Wait for reset to complete
        #20;

        // Test Mode 0: CPOL = 0, CPHA = 0
        $display("Testing Mode 0: CPOL = 0, CPHA = 0");
        cpol = 0;
        cpha = 0;
        perform_spi_transaction(8'hA5, 8'h5A); // Send 0xA5, expect to receive 0x5A

        // End of simulation
        #100;
        $stop;
    end
endmodule