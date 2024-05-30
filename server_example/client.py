import socket
import json

def start_client(host, port):
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.connect((host, port))
    return client_socket

def handshake(client_socket):
    client_socket.sendall(b"HELLO SERVER")
    response = client_socket.recv(4096).decode()
    if response == "HELLO CLIENT":
        client_socket.sendall(b"OK")
        return True
    return False

def send_data(client_socket, data):
    serialized_data = json.dumps(data) + '\n'
    client_socket.sendall(serialized_data.encode())

def receive_data(client_socket):
    buffer = b""
    while True:
        part = client_socket.recv(4096)
        buffer += part
        if b'\n' in buffer:
            break
    return json.loads(buffer.decode())

def send_large_data(client_socket, data):
    serialized_data = json.dumps(data)
    data_len = len(serialized_data)
    chunk_size = 4096
    num_chunks = (data_len + chunk_size - 1) // chunk_size  # ceil(data_len / chunk_size)

    for i in range(num_chunks):
        start_idx = i * chunk_size
        end_idx = min(start_idx + chunk_size, data_len)
        chunk = serialized_data[start_idx:end_idx]

        chunk_obj = {
            "chunk": chunk,
            "index": i,
            "total": num_chunks
        }
        send_data(client_socket, chunk_obj)
        response = receive_data(client_socket)
        print("Server answered:", response)

def receive_large_data(client_socket, max_attempts=10):
    partial_data = []
    attempts = 0

    while attempts < max_attempts:
        chunk_obj = receive_data(client_socket)
        if chunk_obj:
            chunk = chunk_obj["chunk"]
            index = chunk_obj["index"]
            total = chunk_obj["total"]

            while len(partial_data) <= index:
                partial_data.append(None)
            partial_data[index] = chunk

            send_data(client_socket, {"message": "Chunk received successfully"})

            if all(partial_data):
                complete_data = ''.join(partial_data)
                return json.loads(complete_data)
        else:
            attempts += 1

    return None

def main():
    host = "localhost"
    port = 8080

    client_socket = start_client(host, port)
    if handshake(client_socket):
        print("Handshake successful")

        # Example data to send
        data = {"key": "value"}
        send_large_data(client_socket, data)

        # Example to receive data
        received_data = receive_large_data(client_socket)
        print("Received large data:", received_data)
    else:
        print("Handshake failed")

    client_socket.close()

if __name__ == "__main__":
    main()
