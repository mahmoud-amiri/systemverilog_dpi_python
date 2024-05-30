import FileIO_pkg::*;


module top;

    FileIO file_io;
    string line;

    initial begin
        file_io = new();
        file_io.open("example_write.txt", "w");
        file_io.write_line("Hello, World!");
        file_io.write_line("SystemVerilog File I/O Example");
        file_io.close();

        // Open file for reading
        file_io.open("example_write.txt", "r");

        line = file_io.read_line();
        while (line != "") begin
            $display("Read line: %s", line);
            line = file_io.read_line();
        end
        file_io.close();
    end

endmodule
