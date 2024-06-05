from dpi.client_api import SocketClient

if __name__ == "__main__":
    host = "localhost"
    port = 8081

    client = SocketClient(host, port)
    if client.handshake():
        print("Handshake successful")
        while True:
            received_data = client.receive_large_data()
            print("received data:", received_data)
            if received_data["input"]:
                try:
                    input_value = int(received_data["input"])
                    data = input_value + 1  # Note: add the prediction functionality
                except ValueError:
                    print("Error: received_data['input'] is not a valid integer")
                    data = 0
            else:
                print("Error: received_data['input'] is empty")
                data = 0    

            data = {"output": str(data)}
            print("send data:", data["output"])
            client.send_large_data(data)
        
    else:
        print("Handshake failed")

    # client.close()