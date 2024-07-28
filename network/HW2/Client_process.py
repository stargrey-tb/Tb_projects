
import json
import socket
import time



HOST = '127.0.0.1'
SERVER_PORT = 6001
PROXY_PORT = 2845

if __name__ == "__main__":
    select = input("Choose proxy(p) or server(s) (e for exit) )):")         # which server will be choosen    

    if select=="p":
        client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client_socket.connect((HOST,PROXY_PORT))
        while 1:
            packet = input("Enter the data to be sent to proxy \n")         # data will be sent to proxy
            client_socket.sendall(bytes(packet,'utf-8'))                 # send  
            time.sleep(0.5)
            response_data=client_socket.recv(1024)
            response_data = response_data.decode('utf-8')               # response data
            print("Response data is:")
            print(response_data)                                     # print response data
            if select == 'e':
                break

    elif select=="s":
        client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client_socket.connect((HOST,SERVER_PORT))
        while 1:
            packet = input("Enter the data to be sent to server \n")        # data will be sent to server
            client_socket.sendall(bytes(packet,'utf-8'))                # send 
            time.sleep(0.4)
            response_data=client_socket.recv(1024)
            response_data = response_data.decode('utf-8')        # response data
            print("Response data is:")
            print(response_data)                             # print response data
            if select == 'e':
                break

    
    else:
        print("Wrong letter entered")











