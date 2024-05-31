import server_api_pkg::*;

class <design-name>_predictor #() extends BASE_T;

    // Declare the ServerAPI instance
    ServerAPI srv;  

    function new(string name, uvm_component parent);
        // Initialize the ServerAPI instance
        srv = new(); 
    endfunction


    virtual function void build_phase(uvm_phase phase);
        // Initialize the ServerAPI instance
        srv.init("./port.json", "port_A");
        srv.start();
    endfunction


    virtual function void write_<design-name>_<interface-name>_agent_ae(<design-name>_<interface-name>_transaction #() t);
        // Prepare data to send through socket
        string data_to_send = t.convert2string();
        srv.send(data_to_send);

        // Receive data from socket
        json_assoc_t received_data = srv.receive();
        `uvm_info("PRED", {"Received Data: ", received_data.to_string()}, UVM_FULL)
    endfunction


    virtual function void final_phase(uvm_phase phase);
        // Stop the socket
        srv.stop();
    endfunction

endclass
