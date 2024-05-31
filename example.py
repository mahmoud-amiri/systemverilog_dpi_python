from dpi.client_api import SocketClient

if __name__ == "__main__":
    host = "localhost"
    port = 8081

    client = SocketClient(host, port)
    if client.handshake():
        print("Handshake successful")

        # Example data to send
        data = {"frame": "10", "x": "12", "y": "25", "value": "154", "A": "B"}
        client.send_large_data(data)

        # Example to receive data
        received_data = client.receive_large_data()
        print("Received large data:", received_data)
    else:
        print("Handshake failed")

    client.close()