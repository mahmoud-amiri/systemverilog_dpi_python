`timescale 1ns/1ps

module top;

    import server_pkg::*;

    // Testbench variables
    string test_data;
    string received_data;
    int port = 8080;
    Server server;
    string large_data;
    string large_received_data;
    initial begin
        $display("Starting server test...");

        // Create a new server instance
        server = new(port);

        // Start the server
        fork
            server.start();
        join_none

        #10;

        // Perform handshake
        server.perform_handshake();

        // Send data to the server
        test_data = "Hello, Server!";
        server.send(test_data);
        $display("Sent data: %s", test_data);

        // Receive data from the server
        fork
            server.receive(received_data);
        join_none

        #10;
        $display("Received data: %s", received_data);

        // Check if received data matches expected
        if (received_data == test_data) begin
            $display("Test passed: Received data matches sent data.");
        end else begin
            $display("Test failed: Received data does not match sent data.");
        end

        // Test sending large data
        large_data = "This is a large data string to test the server's large data handling capability.";
        server.send_large(large_data);
        $display("Sent large data: %s", large_data);

        // Test receiving large data
        large_received_data = server.receive_large(5);
        $display("Received large data: %s", large_received_data);

        // Stop the server
        server.stop();
        $display("Server stopped.");

        $finish;
    end

endmodule
