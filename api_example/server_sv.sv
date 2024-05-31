import server_api_pkg::*;

module top;

    ServerAPI srv;

    json_assoc_t received_data;
    json_assoc_t data_to_send;
    string content;
    int port;
    // typedef string json_assoc_t[string];
    json_assoc_t assoc;
  

    initial begin

        srv = new();
        srv.init("./port.json", "port_A");
        srv.start();
        received_data = srv.receive();
        $display("received_data :");
        $display(received_data);

        data_to_send = {"frame": "10", "x" : "12", "y" : "25", "value" : "154", "A":"B"};
        srv.send(data_to_send);

        srv.stop();
        // $finish; // Ensure the simulation terminates
    end


endmodule

