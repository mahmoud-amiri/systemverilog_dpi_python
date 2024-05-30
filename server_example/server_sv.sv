module top;

    import "DPI-C" function void sv_start_server(input int port);
    import "DPI-C" function void sv_stop_server();
    import "DPI-C" function int sv_handshake();
    import "DPI-C" function void sv_send_large_data(input string json_str);
    import "DPI-C" function string sv_receive_large_data(input int max_attempts);

    initial begin
        int port = 8080;
        string received_data;
        string data_to_send;
        // Start the server
        sv_start_server(port);
        
        // Perform handshake
        if (sv_handshake()) begin
            $display("Handshake successful");

            // Example to receive large data
            received_data = sv_receive_large_data(10);
            $display("Received large data: %s", received_data);

            // Example data to send
            
            data_to_send = "{\"key\": \"value\"}";
            sv_send_large_data(data_to_send);
        end else begin
            $display("Handshake failed");
        end

        // Stop the server
        sv_stop_server();
    end

endmodule
