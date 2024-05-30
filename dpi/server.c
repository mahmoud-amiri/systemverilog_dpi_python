#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cJSON.h"
#include <math.h> // For ceil function

#ifdef _WIN32
#include <winsock2.h>
#include <ws2tcpip.h>
#pragma comment(lib, "ws2_32.lib")

WSADATA wsaData;
#define close closesocket
#else
#include <unistd.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#endif

#define CHUNK_SIZE 4096

int server_socket, client_socket;
struct sockaddr_in server_addr, client_addr;
#ifdef __cplusplus
extern "C" {
#endif

void start_server(int port);
void stop_server();
void send_data(const struct json_object *data);
void receive_data(struct json_object **data);
int handshake();
void send_large_data(const struct json_object *data);
struct json_object* receive_large_data(int max_attempts);
#ifdef __cplusplus
}
#endif

void start_server(int port) {
#ifdef _WIN32
    if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0) {
        fprintf(stderr, "WSAStartup failed.\n");
        exit(EXIT_FAILURE);
    }
#endif

    server_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (server_socket < 0) {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }

    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(port);

    if (bind(server_socket, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
        perror("Bind failed");
        exit(EXIT_FAILURE);
    }

    if (listen(server_socket, 1) < 0) {
        perror("Listen failed");
        exit(EXIT_FAILURE);
    }

    int addrlen = sizeof(client_addr);
    client_socket = accept(server_socket, (struct sockaddr*)&client_addr, (socklen_t*)&addrlen);
    if (client_socket < 0) {
        perror("Accept failed");
        exit(EXIT_FAILURE);
    }

    if (handshake()) {
        printf("Handshake successful, connection is OK\n");
        // communicate();
    } else {
        printf("Handshake failed\n");
        stop_server();
    }
}

void stop_server() {
    if (client_socket) {
        close(client_socket);
    }
    close(server_socket);

#ifdef _WIN32
    WSACleanup();
#endif
    printf("Server has stopped\n");
    //exit(EXIT_SUCCESS);
}

void send_data(const struct json_object *data) {
    const char *serialized_data = json_object_to_json_string_ext(data, JSON_C_TO_STRING_PLAIN);
    char buffer[CHUNK_SIZE];
    snprintf(buffer, sizeof(buffer), "%s\n", serialized_data);
    if (send(client_socket, buffer, strlen(buffer), 0) < 0) {
        perror("Send failed");
        stop_server();
    }
}

void receive_data(struct json_object **data) {
    char buffer[CHUNK_SIZE];
    int bytes_received = recv(client_socket, buffer, CHUNK_SIZE - 1, 0);
    if (bytes_received < 0) {
        perror("Receive failed");
        stop_server();
    }
    buffer[bytes_received] = '\0';
    printf("receive_data = %s\n", buffer);
    struct json_object *parsed_json = json_tokener_parse(buffer);
    if (parsed_json == NULL) {
        fprintf(stderr, "Failed to parse JSON\n");
        stop_server();
    }
    *data = parsed_json;
}

int handshake() {
    char buffer[CHUNK_SIZE] = {0};
    int bytes_received;
    bytes_received = recv(client_socket, buffer, CHUNK_SIZE, 0);
    if (bytes_received < 0) {
        perror("Receive failed");
        return 0;
    }
    buffer[bytes_received] = '\0';

    if (strcmp(buffer, "HELLO SERVER") == 0) {
        send(client_socket, "HELLO CLIENT", strlen("HELLO CLIENT"), 0);
        memset(buffer, 0, CHUNK_SIZE);
        bytes_received = recv(client_socket, buffer, CHUNK_SIZE, 0);
        if (bytes_received < 0) {
            perror("Receive failed");
            return 0;
        }
        buffer[bytes_received] = '\0';

        if (strcmp(buffer, "OK") == 0) {
            return 1;
        }
    }
    return 0;
}

void send_large_data(const struct json_object *data) {
    const char *serialized_data = json_object_to_json_string_ext(data, JSON_C_TO_STRING_PLAIN);
    int data_len = strlen(serialized_data);
    int num_chunks = (int)ceil((double)data_len / CHUNK_SIZE);
    
    for (int i = 0; i < num_chunks; i++) {
        int start_idx = i * CHUNK_SIZE;
        int end_idx = start_idx + CHUNK_SIZE;
        if (end_idx > data_len) end_idx = data_len;

        struct json_object *chunk_obj = json_object_new_object();
        json_object_object_add(chunk_obj, "chunk", json_object_new_string_len(serialized_data + start_idx, end_idx - start_idx));
        json_object_object_add(chunk_obj, "index", json_object_new_int(i));
        json_object_object_add(chunk_obj, "total", json_object_new_int(num_chunks));

        send_data(json_object_to_json_string_ext(chunk_obj, JSON_C_TO_STRING_PLAIN));
        printf("Chunk number %d sent\n", i);

        char *response;
        receive_data(&response);
        printf("Server answered: %s\n", response);
        free(response);

        json_object_put(chunk_obj);
    }
}

struct json_object* receive_large_data(int max_attempts) {
    struct json_object *partial_data_obj = json_object_new_array();
    int attempts = 0;

    while (attempts < max_attempts) {
        printf("Attempts: %d\n", attempts);
        char *chunk_str;
        receive_data(&chunk_str);
        if (chunk_str) {
            struct json_object *chunk_obj = json_tokener_parse(chunk_str);
            free(chunk_str);

            if (chunk_obj) {
                const char *chunk_data = json_object_get_string(json_object_object_get(chunk_obj, "chunk"));
                int index = json_object_get_int(json_object_object_get(chunk_obj, "index"));
                int total = json_object_get_int(json_object_object_get(chunk_obj, "total"));

                json_object_array_put_idx(partial_data_obj, index, json_object_new_string(chunk_data));
                json_object_put(chunk_obj);

                struct json_object *response_obj = json_object_new_object();
                json_object_object_add(response_obj, "data", json_object_new_string_len(chunk_data, strlen(chunk_data)));
                json_object_object_add(response_obj, "message", json_object_new_string("Chunk received successfully"));
                send_data(json_object_to_json_string_ext(response_obj, JSON_C_TO_STRING_PLAIN));
                json_object_put(response_obj);

                printf("Index = %d / Total = %d\n", index, total - 1);
                if (index + 1 == total) {
                    printf("Last chunk received\n");
                    const char *complete_data = json_object_to_json_string_ext(partial_data_obj, JSON_C_TO_STRING_PLAIN);
                    struct json_object *result = json_tokener_parse(complete_data);
                    json_object_put(partial_data_obj);
                    return result;
                }
            } else {
                fprintf(stderr, "Failed to parse chunk\n");
                json_object_put(partial_data_obj);
                return NULL;
            }
        }
        attempts++;
    }
    json_object_put(partial_data_obj);
    return NULL;
}
int main() {
    int port = 8080; // Set your desired port number
    start_server(port);

    if (handshake()) {
        printf("Handshake successful\n");
    } else {
        printf("Handshake failed\n");
    }

    stop_server();
    return 0;
}