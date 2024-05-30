package server_pkg;

    import "DPI-C" function void start_server(input int port);
    import "DPI-C" function void stop_server();
    import "DPI-C" function void send_data(input string data);
    import "DPI-C" function void receive_data(output string data);
    import "DPI-C" function int handshake();
    import "DPI-C" function void send_large_data(input string data);
    import "DPI-C" function string receive_large_data(input int max_attempts);

    class Server;
        int port;
        string received_data;

        function new(int port);
            this.port = port;
        endfunction

        task start();
            start_server(port);
            $display("Server started on port %0d", port);
        endtask

        task stop();
            stop_server();
            $display("Server stopped on port %0d", port);
        endtask

        task send(string data);
            send_data(data);
        endtask

        task receive(output string data);
            receive_data(data);
            this.received_data = data;
        endtask

        function string get_received_data();
            return received_data;
        endfunction

        task automatic perform_handshake();
            int result;
            result = handshake();
            if (result) begin
                $display("Handshake successful");
            end else begin
                $display("Handshake failed");
                stop();
            end
        endtask

        task send_large(string data);
            send_large_data(data);
        endtask

        function string receive_large(int max_attempts);
            return receive_large_data(max_attempts);
        endfunction
    endclass

endpackage