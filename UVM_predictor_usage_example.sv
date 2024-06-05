import server_api_pkg::*;

class <design-name>_predictor #() extends BASE_T;

// pragma uvmf custom class_item_additional begin
    // Declare the ServerAPI instance
    ServerAPI srv;  
// pragma uvmf custom class_item_additional end


    function new(string name, uvm_component parent);
    // pragma uvmf custom new begin
        // Initialize the ServerAPI instance
        srv = new(); 
    // pragma uvmf custom new end
    endfunction


    virtual function void build_phase(uvm_phase phase);
    // pragma uvmf custom build_phase begin
        // Initialize the ServerAPI instance
        srv.init("./port.json", "port_A");
        srv.start();
    // pragma uvmf custom build_phase end
    endfunction


    function string int_to_str(int num);
        automatic string str0 = "";
        string digit_str;
        int digit;
        while(num > 0) begin
            digit = num % 10;
            num = num / 10;
            $sformat(digit_str, "%0d", digit);
            str0 = {digit_str, str0};
        end
        return str0;
    endfunction

    virtual function void write_<design-name>_<interface-name>_agent_ae(<design-name>_<interface-name>_transaction #() t);
        // pragma uvmf custom decoder_in_agent_ae_predictor begin
        json_assoc_t   data_to_send, received_data;
        string res;
        decoder_in_agent_ae_debug = t;

        `uvm_info("PRED", "Transaction Received through <design-name>_<interface-name>_agent_ae", UVM_MEDIUM)
        `uvm_info("PRED", {"            Data: ",t.convert2string()}, UVM_FULL)
        // Construct one of each output transaction type.
        <design-name>_sb_ap_output_transaction = <design-name>_sb_ap_output_transaction_t::type_id::create("<design-name>_sb_ap_output_transaction");
        //  UVMF_CHANGE_ME: Implement predictor model here.  

        data_to_send["input"] = int_to_str(t.in);
        `uvm_info("PRED", {"sent Data: ", data_to_send["input"]}, UVM_FULL)
        srv.send(data_to_send);

        received_data = srv.receive();
        $sscanf(received_data["output"], "%d", <design-name>_sb_ap_output_transaction.out);
        `uvm_info("PRED", {"Received Data: ", received_data["output"]}, UVM_FULL)

        // Code for sending output transaction out through decoder_sb_ap
        // Please note that each broadcasted transaction should be a different object than previously 
        // broadcasted transactions.  Creation of a different object is done by constructing the transaction 
        // using either new() or create().  Broadcasting a transaction object more than once to either the 
        // same subscriber or multiple subscribers will result in unexpected and incorrect behavior.
        <design-name>_sb_ap.write(<design-name>_sb_ap_output_transaction);
        // pragma uvmf custom decoder_in_agent_ae_predictor end
    endfunction


    // pragma uvmf custom external begin
    virtual function void final_phase(uvm_phase phase);
        // Stop the socket
        srv.stop();
    endfunction
    // pragma uvmf custom external end

endclass
