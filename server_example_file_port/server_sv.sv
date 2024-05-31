import server_pkg::*;
import FileIO_pkg::*;
import JSONParser_pkg::*;
module top;

    Server srv;
    FileIO file_io;
    JSONParser parser;
    string received_data;
    string data_to_send;
    string content;
    int port;
    typedef string json_assoc_t[string];
    json_assoc_t assoc;
  

    initial begin


        file_io = new();
        file_io.open("./port.json", "r");
        content = file_io.read_file();
        file_io.close();

        parser = new();
        assoc = parser.parse_json(content);
        port = assoc["port"].atoi();//8081;
        
        srv = new(port);
        srv.start();
        received_data = srv.receive_large(10);
        $display("Received large data: %s", received_data);

        data_to_send = "{\"key\": \"value\"}";
        srv.send_large(data_to_send);

        srv.stop();
        // $finish; // Ensure the simulation terminates
    end


endmodule
