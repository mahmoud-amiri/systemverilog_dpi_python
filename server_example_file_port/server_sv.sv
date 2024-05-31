import server_pkg::*;
import FileIO_pkg::*;
module top;

    Server srv;
    FileIO file_io;
    string received_data;
    string data_to_send;
    string content;
    int port;

  

    initial begin


        file_io = new();
        file_io.open("./port.txt", "r");
        content = file_io.read_file();
        $display("content = %s",content);
        file_io.close();
        port = content.atoi();//8081;
        $display("port = %d",port);
        // srv = new(port);
        // srv.start();
        // received_data = srv.receive_large(10);
        // $display("Received large data: %s", received_data);

        // data_to_send = "{\"key\": \"value\"}";
        // srv.send_large(data_to_send);

        // srv.stop();
    end

endmodule
