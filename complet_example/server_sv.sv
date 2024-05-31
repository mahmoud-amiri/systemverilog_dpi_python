import server_pkg::*;

module top;

    Server srv;
    string received_data;
    string data_to_send;
    int port;

    initial begin
        port = 8080;
        srv = new(port);
        srv.start();
        received_data = srv.receive_large(10);
        $display("Received large data: %s", received_data);

        data_to_send = "{\"key\": \"value\"}";
        srv.send_large(data_to_send);

        srv.stop();
    end

endmodule
