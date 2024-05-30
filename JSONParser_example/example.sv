module test_JSONParser;
    // Import the package
    import JSONParser_pkg::*;

    // Variables
    JSONParser parser;
    string json;
    string assoc[string] ;
    string result_json;
    string key; // Declare key outside of foreach

    // Initial block for test
    initial begin
        // Create an instance of JSONParser
        parser = new();

        // Test 1: Parse JSON string to associative array
        json = "{\"name\": \"John\", \"age\": \"30\"}";
        assoc = parser.parse_json(json);

        // Display the parsed associative array
        $display("Test 1: Parsing JSON to Associative Array");
        $display(assoc);
        // foreach (key in assoc) begin
        //     $display("Key: %s, Value: %s", key, assoc[key]);
        // end

        // Test 2: Convert associative array back to JSON string
        result_json = parser.assoc_to_json(assoc);
        $display("Test 2: Associative Array to JSON String");
        $display("Resulting JSON: %s", result_json);

        // Test 3: Set and Get internal associative array
        parser.set_assoc(assoc);
        string[string] internal_assoc;
        internal_assoc = parser.get_assoc();

        // Display the internal associative array
        $display("Test 3: Setting and Getting Internal Associative Array");
        foreach (assoc[key]) begin
            $display("Key: %s, Value: %s", key, internal_assoc[key]);
        end

        // Verify correctness of the conversion back to JSON string
        if (result_json == "{\"name\":\"John\",\"age\":\"30\"}") begin
            $display("Test Passed: JSON string matches expected output.");
        end else begin
            $display("Test Failed: JSON string does not match expected output.");
        end

        // End of tests
        $finish;
    end

endmodule
