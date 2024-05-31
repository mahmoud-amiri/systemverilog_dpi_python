import socket
import json


def escape_json_characters(json_string):
    # Define the mapping of JSON characters to custom strings
    replacements = {
        '{': '#1*',
        '}': '#2*',
        '[': '#3*',
        ']': '#4*',
        ':': '#5*',
        ',': '#6*',
        '"': '#7*',
        'true': '#8*',
        'false': '#9*',
        'null': '#0*',
        ' ': '#A*',
        '\n': '#B*',
        '\t': '#C*'
    }

    # Replace each JSON character in the string with the corresponding custom string
    for json_char, custom_str in replacements.items():
        json_string = json_string.replace(json_char, custom_str)

    return json_string

def unescape_json_characters(escaped_string):
    # Define the mapping of custom strings back to JSON characters
    replacements = {
        '#1*': '{',
        '#2*': '}',
        '#3*': '[',
        '#4*': ']',
        '#5*': ':',
        '#6*': ',',
        '#7*': '"',
        '#8*': 'true',
        '#9*': 'false',
        '#0*': 'null',
        '#A*': ' ',
        '#B*': '\n',
        '#C*': '\t'
    }

    # Replace each custom string in the input with the corresponding JSON character
    for custom_str, json_char in replacements.items():
        escaped_string = escaped_string.replace(custom_str, json_char)

    return escaped_string


def escape_json_keys(dictionary):
    for key in dictionary:
        dictionary[key] = escape_json_characters(dictionary[key])

def unescape_json_keys(dictionary):
    for key in dictionary:
        dictionary[key] = unescape_json_characters(dictionary[key])  
    
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
    print(f"send_large_data :{data}")
    serialized_data = json.dumps(data)
    print(serialized_data)
    data_len = len(serialized_data)
    chunk_size = 4096
    num_chunks = (data_len + chunk_size - 1) // chunk_size  # ceil(data_len / chunk_size)

    for i in range(num_chunks):
        start_idx = i * chunk_size
        end_idx = min(start_idx + chunk_size, data_len)
        chunk = serialized_data[start_idx:end_idx]
        print(chunk)
        chunk = escape_json_characters(chunk)
        print(chunk)
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
    port = 8081

    client_socket = start_client(host, port)
    if handshake(client_socket):
        print("Handshake successful")

        # Example data to send
        data = {"frame": "10", "x" : "12", "y" : "25", "value" : "154", "A":"B"}
        send_large_data(client_socket, data)

        # Example to receive data
        received_data = receive_large_data(client_socket)
        print("Received large data:", received_data)
    else:
        print("Handshake failed")

    client_socket.close()


    


if __name__ == "__main__":
    main()
